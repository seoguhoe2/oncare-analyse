<!-- src/components/recipient/longcare/LongCare.vue -->
<template>
  <div class="card longcare-wrap">
    <header class="longcare-header">
      <h3>⚠ 장기요양등급 만료 예정</h3>

      <div class="filters">
        <button
          v-for="btn in rangeButtons"
          :key="btn.key"
          type="button"
          class="range-btn"
          :class="{ active: activeRange === btn.key }"
          :disabled="isNotExtendedMode && btn.key !== 'notExtended'"
          @click="onClickRange(btn.key)"
        >
          {{ btn.label }}
        </button>
      </div>
    </header>

    <div v-if="loading" class="state">불러오는 중...</div>
    <div v-else-if="errorMsg" class="state error">{{ errorMsg }}</div>

    <!-- 스크롤은 테이블 영역만 -->
    <div v-else class="table-wrap scroll-wrapper">
      <table>
        <thead>
          <tr>
            <th>수급자명</th>
            <th>만료일</th>
            <th>담당요양사</th>
            <th>D-Day</th>
            <th>안내여부</th>
          </tr>
        </thead>

        <tbody>
          <!-- 현재 페이지 데이터만 렌더링 -->
          <tr
            v-for="row in pagedItems"
            :key="row.expirationId"
            :class="[
              'clickable-row',
              ddayClass(row.ddayNum),
              row.expirationId === selectedId ? 'is-active' : ''
            ]"
            @click="selectRow(row)"
          >
            <td>{{ row.beneficiaryName }}</td>
            <td>{{ row.endDate }}</td>
            <td>{{ row.careWorkerName || '-' }}</td>
            <td><span class="dday-pill">{{ row.ddayLabel || '-' }}</span></td>
            <td>
              <span
                v-if="String(row.noticeLabel || '').startsWith('완료')"
                class="status-pill complete"
              >
                {{ row.noticeLabel }}
              </span>
              <span v-else class="status-pill pending">
                {{ row.noticeLabel || '미완료' }}
              </span>
            </td>
          </tr>

          <tr v-if="filteredItems.length === 0">
            <td colspan="5" class="empty-row">표시할 항목이 없습니다.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- 하단 중앙 페이징 (페이지가 2 이상일 때만 표시) -->
    <div v-if="!loading && !errorMsg && totalPages > 1" class="bottom-pager">
      <button
        type="button"
        class="page-btn"
        :disabled="page <= 0"
        @click="page--"
      >
        이전
      </button>

      <span class="page-info">
        {{ page + 1 }} / {{ totalPages }}
      </span>

      <button
        type="button"
        class="page-btn"
        :disabled="page >= totalPages - 1"
        @click="page++"
      >
        다음
      </button>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch, onMounted } from 'vue'
import api from '@/lib/api'

const props = defineProps({
  selectedId: { type: [Number, String, null], default: null },
  refreshKey: { type: Number, default: 0 },

  /**
   * 상세에서 올라온 변경 이벤트
   * 예) { type:'extendsStatus', expirationId: 3, extendsStatus:'N' }
   */
  lastChange: { type: Object, default: null }
})
const emit = defineEmits(['update:selectedId'])

const rangeButtons = [
  { key: 'all', label: '전체' },
  { key: '45', label: '45일 이내' },
  { key: '60', label: '60일 이내' },
  { key: '90', label: '90일 이내' },
  { key: 'notExtended', label: '등급 미연장 리스트' }
]

const activeRange = ref('all')
const isNotExtendedMode = computed(() => activeRange.value === 'notExtended')

const loading = ref(false)
const errorMsg = ref('')

/**  실제 렌더링 목록 */
const displayItems = ref([])

/**  페이징 상태 */
const page = ref(0)
const pageSize = ref(10)

/** D-day 파싱 */
const parseDday = (ddayLabel) => {
  const s = String(ddayLabel || '').trim()
  const m = s.match(/D-\s*(\d+)/i)
  return m ? Number(m[1]) : 999999
}

const normalized = computed(() => {
  return (displayItems.value || []).map((it) => ({
    expirationId: it.expirationId,
    beneficiaryName: it.beneficiaryName,
    endDate: it.endDate,
    careWorkerName: it.careWorkerName,
    ddayLabel: it.ddayLabel,
    ddayNum: parseDday(it.ddayLabel),
    noticeLabel: it.noticeLabel,
    extendsStatus: it.extendsStatus
  }))
})

/** 필터 적용 결과 */
const filteredItems = computed(() => {
  let list = normalized.value

  if (isNotExtendedMode.value) {
    return list.filter((i) => i.extendsStatus === 'N')
  }

  list = list.filter((i) => i.extendsStatus !== 'N')

  if (activeRange.value === 'all') return list
  const limit = Number(activeRange.value)
  return list.filter((i) => i.ddayNum <= limit)
})

/**  총 페이지 */
const totalPages = computed(() => {
  const cnt = filteredItems.value.length
  return cnt === 0 ? 0 : Math.ceil(cnt / pageSize.value)
})

/** 현재 페이지에 보여줄 항목 */
const pagedItems = computed(() => {
  const start = page.value * pageSize.value
  return filteredItems.value.slice(start, start + pageSize.value)
})

/** page 범위 보정(필터/데이터 변경으로 페이지가 튀는 것 방지) */
watch(
  () => [filteredItems.value.length, totalPages.value],
  () => {
    if (page.value > 0 && page.value >= totalPages.value) {
      page.value = Math.max(totalPages.value - 1, 0)
    }
  }
)

const ddayClass = (ddayNum) => {
  if (ddayNum <= 45) return 'row-red'
  if (ddayNum <= 60) return 'row-yellow'
  if (ddayNum <= 90) return 'row-normal'
  return ''
}

const selectRow = (row) => {
  emit('update:selectedId', row.expirationId)
}

/** notExtended 토글 */
const onClickRange = (key) => {
  if (key === 'notExtended') {
    activeRange.value = activeRange.value === 'notExtended' ? 'all' : 'notExtended'
  } else {
    activeRange.value = key
  }
}

/** 서버 조회 */
const fetchList = async () => {
  loading.value = true
  errorMsg.value = ''
  try {
    const params = {}
    if (isNotExtendedMode.value) params.extendsStatus = 'N'

    const { data } = await api.get('/api/care-level/expirations', { params })
    displayItems.value = data?.items ?? []
  } catch (e) {
    console.error(e)
    errorMsg.value = '목록을 불러오지 못했습니다.'
    displayItems.value = []
  } finally {
    loading.value = false
  }
}

onMounted(fetchList)

/** 필터 전환 시 서버 재조회 + 선택 해제 + 페이지 초기화 */
watch(
  () => activeRange.value,
  async () => {
    emit('update:selectedId', null)
    page.value = 0
    await fetchList()
  }
)

/** refreshKey 올라오면(완료/삭제 등) 서버 재조회 + page 보정 */
watch(
  () => props.refreshKey,
  async () => {
    await fetchList()
  }
)

/**
 * 핵심: extendsStatus 변경 즉시 반영
 * - 연장예정 목록에서 N 되면 즉시 제거
 * - 미연장 목록에서 Y 되면 즉시 제거
 */
watch(
  () => props.lastChange,
  (chg) => {
    if (!chg || chg.type !== 'extendsStatus') return

    const id = Number(chg.expirationId)
    const next = String(chg.extendsStatus || '').toUpperCase() // 'N' or 'Y'

    // 1) 로컬 항목 갱신
    displayItems.value = (displayItems.value || []).map((it) => {
      if (Number(it.expirationId) !== id) return it
      return { ...it, extendsStatus: next }
    })

    // 2) 현재 모드에 따라 즉시 제거
    if (isNotExtendedMode.value) {
      if (next !== 'N') {
        displayItems.value = displayItems.value.filter((it) => Number(it.expirationId) !== id)
        if (Number(props.selectedId) === id) emit('update:selectedId', null)
      }
    } else {
      if (next === 'N') {
        displayItems.value = displayItems.value.filter((it) => Number(it.expirationId) !== id)
        if (Number(props.selectedId) === id) emit('update:selectedId', null)
      }
    }

    // 변경 후 페이지 보정
    if (page.value > 0 && page.value >= totalPages.value) {
      page.value = Math.max(totalPages.value - 1, 0)
    }
  },
  { deep: true }
)
</script>

<style scoped>
/* (네 스타일 그대로) */
.longcare-wrap {
  box-sizing: border-box;
  min-width: 0;
  background-color: #fff;
  border-radius: 12px;
  padding: 14px 16px;
  box-shadow: 0 0 0 1px rgba(15, 23, 42, 0.04);
}
.longcare-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}
.longcare-header h3 {
  margin: 0;
  font-size: 15px;
}

.filters {
  display: flex;
  gap: 4px;
}
.range-btn {
  border: 1px solid #e5e7eb;
  background: #f9fafb;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 11px;
  cursor: pointer;
}
.range-btn.active {
  background-color: #111827;
  color: #fff;
}
.range-btn:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

.state {
  padding: 10px 0;
  font-size: 12px;
  color: #6b7280;
}
.state.error {
  color: #b91c1c;
}

/* 스크롤바 */
.scroll-wrapper {
  max-height: 360px;
  overflow-y: auto;
  overflow-x: auto;
  padding-right: 4px;
}
.scroll-wrapper::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}
.scroll-wrapper::-webkit-scrollbar-thumb {
  background-color: #d1d5db;
  border-radius: 4px;
}
.scroll-wrapper::-webkit-scrollbar-track {
  background-color: transparent;
}

table {
  width: 100%;
  border-collapse: collapse;
  font-size: 12px;
}
thead th {
  text-align: left;
  padding: 8px 10px;
  background-color: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
}
tbody td {
  padding: 8px 10px;
  border-bottom: 1px solid #f3f4f6;
}
.empty-row {
  text-align: center;
  color: #9ca3af;
  padding: 16px 10px;
}

.row-red {
  background-color: #fef2f2;
}
.row-yellow {
  background-color: #fff7ed;
}
.row-normal {
  background-color: #fefce8;
}

.clickable-row {
  cursor: pointer;
}
.clickable-row.is-active {
  outline: 2px solid rgba(34, 197, 94, 0.6);
  outline-offset: -2px;
}

.dday-pill {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 999px;
  background-color: #fee2e2;
  color: #b91c1c;
  font-size: 10px;
}
.status-pill {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 999px;
  font-size: 10px;
}
.status-pill.complete {
  background-color: #dcfce7;
  color: #15803d;
}
.status-pill.pending {
  background-color: #f3f4f6;
  color: #6b7280;
}

/* 하단 중앙 페이징 */
.bottom-pager {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 10px;
  margin-top: 8px;
  padding: 6px 0;
}

.page-info {
  font-size: 12px;
  color: #6b7280;
}

.page-btn {
  border: none;
  background: #f3f4f6;
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 12px;
  cursor: pointer;
  white-space: nowrap;
}
.page-btn:hover {
  background: #e5e7eb;
}
.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
