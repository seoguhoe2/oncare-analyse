<!-- src/components/recipient/RecipientList.vue -->
<template>
  <div class="filter-card">
    <!-- 검색 -->
    <div class="search-box">
      <input v-model="searchText" type="text" placeholder="이름 검색..." />
    </div>

    <!-- 1차 필터 (서비스 상태) -->
    <div class="filter-group">
      <button class="filter-header" type="button" @click="toggle('first')">
        <span>1차 필터</span>
        <span class="arrow" :class="{ open: open.first }">⌃</span>
      </button>
      <div v-if="open.first" class="filter-body">
        <select v-model="statusFilter">
          <option value="">제한 없음</option>
          <option value="서비스 중">서비스 중</option>
          <option value="서비스 해지">서비스 해지</option>
        </select>
      </div>
    </div>

    <!-- 2차 필터 (위험/등급) -->
    <div class="filter-group">
      <button class="filter-header" type="button" @click="toggle('second')">
        <span>2차 필터</span>
        <span class="arrow" :class="{ open: open.second }">⌃</span>
      </button>
      <div v-if="open.second" class="filter-body">
        <select v-model="riskFilterLabel">
          <option value="">위험등급 - 전체</option>
          <option value="고위험">고위험</option>
          <option value="중위험">중위험</option>
          <option value="저위험">저위험</option>
        </select>

        <select v-model="careLevelFilter">
          <option value="">장기요양등급 - 전체</option>
          <option v-for="n in 5" :key="n" :value="String(n)">{{ n }}등급</option>
          <option value="인지지원등급">인지지원등급</option>
        </select>
      </div>
    </div>

    <!-- 정렬 기준 -->
    <div class="filter-group">
      <div class="filter-header no-btn">
        <span>정렬 기준</span>
      </div>
      <div class="filter-body sort-row">
        <select v-model="sortKey">
          <option value="name">이름순</option>
          <option value="risk">위험도순</option>
          <option value="careLevel">장기요양등급순</option>
        </select>

        <button type="button" class="dir-btn" @click="toggleDirection">
          {{ direction === 'ASC' ? '오름차순' : '내림차순' }}
        </button>
      </div>
    </div>

    <div class="list-count">총 {{ totalElements }}명</div>

    <!-- 목록 -->
    <div class="list-card">
      <div class="list-scroll">
        <div v-if="loading" class="loading">불러오는 중...</div>
        <div v-else-if="errorMsg" class="error">{{ errorMsg }}</div>

        <template v-else>
          <button
            v-for="r in list"
            :key="r.beneficiaryId"
            type="button"
            class="recipient-item"
            :class="{ active: r.beneficiaryId === selectedId }"
            @click="$emit('update:selectedId', r.beneficiaryId)"
          >
            <div class="row-top">
              <span class="name">{{ r.name }}</span>

              <div class="badge-row">
                <!--  서비스 상태 뱃지(목록에서 바로 표시) -->
                <span class="badge state" :class="stateClass(r.status)">
                  {{ r.status || '-' }}
                </span>

                <!-- 위험도 뱃지 -->
                <span class="badge status" :class="riskClass(r.riskLevel)">
                  {{ r.riskLevel }}
                </span>
              </div>
            </div>

            <div class="row-middle">
              <span class="meta">
                {{ formatCareLevel(r.careLevel) }}
                · 담당: {{ managerLabel(r.managerName) }}
              </span>
            </div>

            <div class="row-bottom">
              <span class="tag tag-level">
                장기요양 {{ formatCareLevel(r.careLevel) }}
              </span>

              <!--  서비스타입 null 처리 -->
              <span class="tag tag-service">
                {{ serviceTypeLabel(r.serviceType) }}
              </span>
            </div>
          </button>

          <div v-if="!list.length" class="empty">
            조건에 맞는 수급자가 없습니다.
          </div>
        </template>
      </div>

      <!-- 페이지네이션 -->
      <div class="pagination">
        <div class="page-info">
          {{ page + 1 }} / {{ Math.max(totalPages, 1) }}
        </div>

        <div class="pager">
          <button
            type="button"
            class="page-btn"
            :disabled="page <= 0 || loading"
            @click="page--"
          >
            이전
          </button>
          <button
            type="button"
            class="page-btn"
            :disabled="page >= totalPages - 1 || loading || totalPages === 0"
            @click="page++"
          >
            다음
          </button>
        </div>

        <div class="page-size">
          <button
            v-for="size in [10, 15, 20, 30]"
            :key="size"
            type="button"
            class="page-size-btn"
            :class="{ active: pageSize === size }"
            @click="pageSize = size"
          >
            {{ size }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch, defineExpose  } from 'vue'
import api from '@/lib/api'

const props = defineProps({
  selectedId: { type: Number, default: null }
})
defineEmits(['update:selectedId'])

const searchText = ref('')
const statusFilter = ref('')
const riskFilterLabel = ref('')
const careLevelFilter = ref('')
const sortKey = ref('name')
const direction = ref('ASC')

const page = ref(0)
const pageSize = ref(10)

const open = ref({ first: true, second: true })
const toggle = (key) => (open.value[key] = !open.value[key])
const toggleDirection = () => {
  direction.value = direction.value === 'ASC' ? 'DESC' : 'ASC'
}

/** 서버 상태 */
const list = ref([])
const totalElements = ref(0)
const totalPages = ref(0)
const loading = ref(false)
const errorMsg = ref('')

/** 백엔드 파라미터 매핑 */
const riskLevelId = computed(() => {
  if (riskFilterLabel.value === '저위험') return 1
  if (riskFilterLabel.value === '중위험') return 2
  if (riskFilterLabel.value === '고위험') return 3
  return undefined
})

const careLevelId = computed(() => {
  if (!careLevelFilter.value) return undefined
  if (careLevelFilter.value === '인지지원등급') return 6 
  const n = Number(careLevelFilter.value)
  return Number.isFinite(n) ? n : undefined
})

const sortParam = computed(() => {
  if (sortKey.value === 'name') return 'NAME'
  if (sortKey.value === 'risk') return 'RISK'
  if (sortKey.value === 'careLevel') return 'CARE_LEVEL'
  return 'NAME'
})

/* 목록 호출 */
const fetchBeneficiaries = async () => {
  loading.value = true
  errorMsg.value = ''

  try {
    const { data } = await api.get('/api/beneficiaries', {
      params: {
        page: page.value,
        size: pageSize.value,
        status: statusFilter.value || undefined,
        riskLevelId: riskLevelId.value,
        careLevelId: careLevelId.value,
        keyword: searchText.value.trim() || undefined,
        sort: sortParam.value,
        direction: direction.value
      }
    })

    list.value = data?.content ?? []
    totalElements.value = data?.totalElements ?? 0
    totalPages.value = data?.totalPages ?? 0
  } catch (e) {
    console.error(e)
    errorMsg.value = '수급자 목록을 불러오지 못했습니다.'
  } finally {
    loading.value = false
  }
}

/*  외부에서 호출 가능하게 노출 */
defineExpose({
  refresh: fetchBeneficiaries
})

/** 검색 디바운스 */
let searchTimer = null
watch(searchText, () => {
  clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    page.value = 0
    fetchBeneficiaries()
  }, 250)
})

/** 필터/정렬/사이즈 변경 시 재조회 */
watch([statusFilter, riskFilterLabel, careLevelFilter, sortKey, direction, pageSize], () => {
  page.value = 0
  fetchBeneficiaries()
})

/** 페이지 변경 시 재조회 */
watch(page, fetchBeneficiaries)

onMounted(fetchBeneficiaries)

/** UI helpers */
const riskClass = (risk) => ({
  'risk-high': risk === '고위험',
  'risk-mid': risk === '중위험',
  'risk-low': risk === '저위험'
})

const stateClass = (status) => ({
  'state-on': status === '서비스 중',
  'state-off': status === '서비스 해지'
})

const formatCareLevel = (v) => {
  if (!v) return '-'
  const s = String(v)
  return s.includes('등급') ? s : `${s}등급`
}

//  요청사항 1: null 문구 처리
const managerLabel = (name) => (name && String(name).trim() ? name : '담당보호사 없음')
const serviceTypeLabel = (v) => (v && String(v).trim() ? v : '제공받는 서비스 없음')
</script>

<style scoped>
/* 기존 스타일 유지 + badge-row/state 뱃지만 추가 */
.filter-card { background-color: #fff; border-radius: 12px; padding: 14px; box-shadow: 0 0 0 1px rgba(15, 23, 42, 0.04); }
.search-box { margin-bottom: 6px; }
.search-box input { width: 100%; padding: 4px 8px; border-radius: 8px; border: 1px solid #e5e7eb; font-size: 12px; box-sizing: border-box; }
.filter-group { margin-top: 8px; }
.filter-header { width: 100%; border: none; background: transparent; padding: 4px 2px; font-size: 12px; display: flex; justify-content: space-between; align-items: center; cursor: pointer; color: #6b7280; }
.filter-header.no-btn { cursor: default; }
.filter-body { margin-top: 4px; display: flex; flex-direction: column; gap: 4px; }
.filter-body select { width: 100%; padding: 4px 8px; border-radius: 8px; border: 1px solid #e5e7eb; font-size: 12px; }
.sort-row { flex-direction: row; align-items: center; }
.dir-btn { border: none; background: #f3f4f6; padding: 6px 10px; border-radius: 8px; font-size: 12px; cursor: pointer; white-space: nowrap; }
.dir-btn:hover { background: #e5e7eb; }
.arrow { font-size: 10px; transition: transform 0.15s; }
.arrow.open { transform: rotate(180deg); }
.list-count { margin-top: 10px; font-size: 11px; color: #9ca3af; }

.list-card { margin-top: 8px; background-color: #fff; border-radius: 12px; padding: 10px 10px 8px; box-shadow: 0 0 0 1px rgba(15, 23, 42, 0.04); }
.list-scroll { max-height: 360px; overflow-y: auto; padding-right: 4px; }
.loading, .error, .empty { padding: 10px; font-size: 12px; color: #6b7280; }
.error { color: #b91c1c; }

.recipient-item { width: 100%; border: none; background: #fff; border-radius: 10px; padding: 8px 10px; margin-bottom: 6px; text-align: left; cursor: pointer; transition: background-color 0.15s, box-shadow 0.15s; }
.recipient-item:hover { background-color: #f3f4f6; }
.recipient-item.active { background-color: #e9f8f0; box-shadow: 0 0 0 1px #22c55e33; }

.row-top { display: flex; justify-content: space-between; align-items: center; gap: 8px; }
.badge-row { display: flex; gap: 6px; align-items: center; }
.name { font-size: 14px; font-weight: 600; }
.row-middle { margin-top: 2px; }
.meta { font-size: 11px; color: #9ca3af; }
.row-bottom { margin-top: 4px; display: flex; gap: 4px; flex-wrap: wrap; }

.tag { padding: 2px 8px; border-radius: 999px; font-size: 10px; }
.tag-level { background-color: #ecfdf3; color: #15803d; }
.tag-service { background-color: #e0f2fe; color: #1d4ed8; }

.badge { padding: 2px 8px; border-radius: 999px; font-size: 10px; }
.status.risk-high { background-color: #fee2e2; color: #b91c1c; }
.status.risk-mid  { background-color: #fef3c7; color: #92400e; }
.status.risk-low  { background-color: #e0f2fe; color: #1d4ed8; }

/*  서비스 상태 뱃지 */
.state { background-color: #f3f4f6; color: #374151; }
.state-on { background-color: #dcfce7; color: #15803d; }
.state-off { background-color: #e5e7eb; color: #374151; }

.pagination { display: flex; justify-content: space-between; align-items: center; margin-top: 6px; font-size: 11px; gap: 8px; }
.pager { display: flex; gap: 6px; }
.page-btn { border: none; background: #f3f4f6; padding: 4px 10px; border-radius: 8px; font-size: 11px; cursor: pointer; }
.page-btn:disabled { opacity: 0.5; cursor: not-allowed; }
.page-size { display: flex; gap: 4px; }
.page-size-btn { border: none; background: #f3f4f6; padding: 2px 6px; border-radius: 6px; font-size: 11px; cursor: pointer; }
.page-size-btn.active { background-color: #22c55e; color: #fff; }
</style>
