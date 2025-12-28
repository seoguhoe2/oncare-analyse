<template>
  <section class="matching-panel">
    <header class="panel-header">
      <h2 class="panel-title">요양보호사</h2>
      <span class="count-badge">{{ caregivers.length }}명</span>
    </header>

    <div class="search-bar">
      <img :src="searchIcon" class="search-icon" />
      <input v-model="search" type="text" placeholder="요양보호사 검색..." />
    </div>

    <div v-if="loading" class="loading">불러오는 중...</div>
    <div v-else-if="error" class="error">{{ error }}</div>

    <div v-else class="table-scroll">
      <table class="list-table">
        <tbody>
          <tr
            v-for="item in pagedList"
            :key="item.careWorkerId ?? item.id"
            class="list-row"
            :class="{ selected: selectedCareWorkerId === (item.careWorkerId ?? item.id) }"
            @click="handleSelect(item)"
          >
            <td class="name">{{ item.name }}</td>
            <td>
              <span :class="badgeClass(item.gender)">
                {{ item.gender }}
              </span>
            </td>
            <td>
              <div class="tags">
                <span v-for="tag in item.tags" :key="tag" class="tag">
                  {{ tag }}
                </span>
              </div>
            </td>
          </tr>

          <tr v-if="!pagedList.length">
            <td colspan="3" class="dash">표시할 요양보호사가 없습니다.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="pagination">
      <button @click="prevPage" :disabled="page === 1">〈</button>
      <span>{{ page }} / {{ totalPages }}</span>
      <button @click="nextPage" :disabled="page === totalPages">〉</button>
    </div>
  </section>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import searchIcon from '@/assets/img/common/search.png'
import {
  getCandidateCareWorkerCards,
  getCreateVisitAvailableCareWorkerCards,
} from '@/api/schedule/matching.js'

const props = defineProps({
  recipient: { type: Object, default: null },
  startDt: { type: String, default: '' },
  endDt: { type: String, default: '' },
  // ✅ 추가: 드롭다운에서 선택한 서비스 타입
  serviceTypeId: { type: Number, default: null },
})

const emit = defineEmits(['select-caregiver'])

const search = ref('')
const page = ref(1)
const pageSize = 10

const loading = ref(false)
const error = ref('')
const caregiversRaw = ref([])

const selectedCareWorkerId = ref(null)

const getBeneficiaryId = (obj) => obj?.beneficiaryId ?? obj?.id ?? null
const beneficiaryId = computed(() => getBeneficiaryId(props.recipient))

// ✅ 생성모드: start/end가 있으면 생성 흐름
const isCreateVisitMode = computed(() => Boolean(props.startDt && props.endDt))

const loadCareWorkers = async () => {
  if (!beneficiaryId.value) {
    caregiversRaw.value = []
    error.value = ''
    return
  }

  // ✅ 생성모드에서는 서비스타입도 필수(드롭다운 선택 전엔 빈 목록)
  if (isCreateVisitMode.value && (!props.startDt || !props.endDt || !props.serviceTypeId)) {
    caregiversRaw.value = []
    error.value = ''
    return
  }

  try {
    loading.value = true
    error.value = ''

    const res = isCreateVisitMode.value
      ? await getCreateVisitAvailableCareWorkerCards({
          beneficiaryId: beneficiaryId.value,
          startDt: props.startDt,
          endDt: props.endDt,
          // ✅ 추가: 백엔드에서 이 값으로 서비스 타입 필터
          serviceTypeId: props.serviceTypeId,
        })
      : await getCandidateCareWorkerCards(beneficiaryId.value)

    const list = Array.isArray(res?.data) ? res.data : []

    caregiversRaw.value = list.map((c) => ({
      careWorkerId: c?.careWorkerId ?? c?.id ?? null,
      name: c?.name ?? '-',
      gender: c?.gender ?? '-',
      tags: Array.isArray(c?.tags) ? c.tags : [],
    }))
  } catch (e) {
    caregiversRaw.value = []
    error.value =
      e?.response?.data?.message || '요양보호사 목록을 불러오지 못했습니다.'
  } finally {
    loading.value = false
  }
}

// ✅ serviceTypeId 변경에도 다시 로드
watch(
  () => [beneficiaryId.value, props.startDt, props.endDt, props.serviceTypeId, isCreateVisitMode.value],
  () => {
    page.value = 1
    search.value = ''
    selectedCareWorkerId.value = null
    loadCareWorkers()
  },
  { immediate: true }
)

watch(search, () => {
  page.value = 1
})

const caregivers = computed(() => {
  const q = search.value.toLowerCase().trim()
  if (!q) return caregiversRaw.value

  return caregiversRaw.value.filter((c) =>
    [c.name, c.gender, ...(c.tags || [])].some((f) =>
      String(f ?? '').toLowerCase().includes(q)
    )
  )
})

const totalPages = computed(() =>
  Math.max(1, Math.ceil(caregivers.value.length / pageSize))
)

const pagedList = computed(() =>
  caregivers.value.slice((page.value - 1) * pageSize, page.value * pageSize)
)

const prevPage = () => {
  if (page.value > 1) page.value--
}
const nextPage = () => {
  if (page.value < totalPages.value) page.value++
}

const handleSelect = (item) => {
  const careWorkerId = item?.careWorkerId ?? item?.id ?? null
  selectedCareWorkerId.value = careWorkerId
  emit('select-caregiver', { ...item, careWorkerId })
}

const badgeClass = (gender) => ({
  badge: true,
  male: gender === '남자',
  female: gender === '여자',
})
</script>

<style scoped>
/* ✅ 스타일은 그대로 사용하셔도 됩니다 */
.matching-panel {
  background: #ffffff;
  border-radius: 16px;
  padding: 16px 20px;
  border: 1px solid #e5e7eb;
  box-shadow: 0 4px 12px rgba(15, 23, 42, 0.04);
  display: flex;
  flex-direction: column;
  height: 480px;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.panel-title {
  font-size: 20px;
  font-weight: 600;
  color: #1a5928;
}

.count-badge {
  padding: 4px 10px;
  background: #f3e8ff;
  border-radius: 999px;
  font-size: 13px;
  color: #9333ea;
}

.search-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
  background: #f9fafb;
  margin-bottom: 10px;
}

.search-icon {
  width: 16px;
  height: 16px;
  opacity: 0.6;
}

.search-bar input {
  flex: 1;
  border: none;
  background: transparent;
  font-size: 14px;
  outline: none;
}

.table-scroll {
  flex: 1;
  overflow-y: auto;
  padding-right: 4px;
  max-height: 320px;
}

.table-scroll::-webkit-scrollbar {
  width: 6px;
}
.table-scroll::-webkit-scrollbar-thumb {
  background: #d1d5db;
  border-radius: 8px;
}

.list-table {
  width: 100%;
  border-collapse: collapse;
}

.list-row {
  cursor: pointer;
  transition: background-color 0.15s ease;
}
.list-row:hover {
  background: #f9fafb;
}

.list-row.selected {
  background: #ecfdf5;
}
.list-row.selected:hover {
  background: #d1fae5;
}
.list-row.selected td {
  font-weight: 600;
  color: #065f46;
}

.list-table td {
  padding: 10px 6px;
  border-bottom: 1px solid #f3f4f6;
  font-size: 15px;
}

.name {
  font-weight: 500;
}

.dash {
  color: #9ca3af;
}

.badge {
  padding: 3px 8px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 500;
}

.male {
  background: #e0f2fe;
  color: #0284c7;
}

.female {
  background: #fde2e8;
  color: #ec4899;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.tag {
  background: #dcfce7;
  color: #15803d;
  padding: 3px 8px;
  border-radius: 999px;
  font-size: 12px;
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 14px;
  padding-top: 8px;
}

.pagination button {
  border: none;
  background: transparent;
  font-size: 18px;
  cursor: pointer;
}
.pagination button:disabled {
  opacity: 0.3;
  cursor: not-allowed;
}

.pagination span {
  font-size: 14px;
}
</style>