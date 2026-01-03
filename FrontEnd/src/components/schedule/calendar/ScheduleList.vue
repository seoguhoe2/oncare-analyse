<template>
  <section class="schedule-panel">
    <div class="schedule-header">
      <div class="schedule-title-row">
        <h3 class="schedule-title">{{ headerTitle }}</h3>

        <div class="tag-row" v-if="summary.care || summary.bath || summary.nurse">
          <span v-if="summary.care" class="service-tag type-care">요양 {{ summary.care }}</span>
          <span v-if="summary.bath" class="service-tag type-bath">목욕 {{ summary.bath }}</span>
          <span v-if="summary.nurse" class="service-tag type-nurse">간호 {{ summary.nurse }}</span>
        </div>
      </div>
    </div>

    <div class="schedule-table-wrapper">
      <table v-if="dailySchedules.length" class="schedule-table">
        <thead>
          <tr>
            <th>시간</th>
            <th>요양보호사</th>
            <th>수급자</th>
            <th>서비스</th>
            <th>소요시간</th>
          </tr>
        </thead>

        <tbody>
          <tr
            v-for="(item, idx) in dailySchedules"
            :key="item.matchingId ?? item.vsId ?? idx"
            class="table-row"
            :class="{ selected: (item.matchingId ?? item.vsId) === selectedKey }"
            @click="onRowClick(item)"
          >
            <td class="col-time">
              {{ formatTimeHM(item.startTime) }} - {{ formatTimeHM(item.endTime) }}
            </td>
            <td>{{ item.careWorkerName }}</td>
            <td>{{ item.beneficiaryName }}</td>
            <td>
              <span
                class="service-badge"
                :class="{
                  'badge-care': item.serviceTypeId === 1,
                  'badge-bath': item.serviceTypeId === 2,
                  'badge-nurse': item.serviceTypeId === 3,
                }"
              >
                {{ item.serviceTypeName }}
              </span>
            </td>
            <td class="col-duration">{{ formatDuration(item.durationMinutes) }}</td>
          </tr>
        </tbody>
      </table>

      <div v-else class="empty-row">
        <template v-if="loading">불러오는 중...</template>
        <template v-else-if="error">{{ error }}</template>
        <template v-else>선택한 날짜에 일정이 없습니다.</template>
      </div>
    </div>

    <div v-if="totalPages > 1" class="pagination">
      <button @click="prevPage" :disabled="page === 1">〈</button>
      <span>{{ page }} / {{ totalPages }}</span>
      <button @click="nextPage" :disabled="page === totalPages">〉</button>
    </div>
  </section>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { getScheduleDayList } from '@/api/schedule/scheduleApi'
import { getConfirmedScheduleDayList } from '@/api/schedule/confirmedScheduleApi'

const props = defineProps({
  selectedDate: { type: String, default: '' },
  keyword: { type: String, default: '' },
  searchScope: { type: String, default: 'ALL' },
  serviceTypeId: { type: Number, default: null }, // 추가: null | 1 | 2 | 3
  refreshKey: { type: Number, default: 0 },
})

const emit = defineEmits(['select-schedule'])

const weekdays = ['일', '월', '화', '수', '목', '금', '토']
const selectedKey = ref(null)

const loading = ref(false)
const error = ref('')

const dailySchedules = ref([])
const total = ref(0)

const page = ref(1)
const pageSize = 5

const headerTitle = computed(() => {
  if (!props.selectedDate) return '일정을 선택해주세요'
  const d = new Date(props.selectedDate)
  if (Number.isNaN(d.getTime())) return '일정을 선택해주세요'
  const month = d.getMonth() + 1
  const date = d.getDate()
  const weekday = weekdays[d.getDay()]
  return `${month}월 ${date}일 (${weekday}) 일정`
})

const totalPages = computed(() => {
  const t = Number(total.value)
  if (!Number.isFinite(t) || t <= 0) return 1
  return Math.max(1, Math.ceil(t / pageSize))
})

const summary = computed(() => {
  const result = { care: 0, bath: 0, nurse: 0 }
  dailySchedules.value.forEach((item) => {
    if (item.serviceTypeId === 1) result.care += 1
    if (item.serviceTypeId === 2) result.bath += 1
    if (item.serviceTypeId === 3) result.nurse += 1
  })
  return result
})

const formatTimeHM = (t) => {
  const s = String(t ?? '')
  if (!s) return ''
  if (s.includes('T')) {
    const timePart = s.split('T')[1] || ''
    return timePart.slice(0, 5)
  }
  return s.slice(0, 5)
}

const formatDuration = (minutes) => {
  const m = Number(minutes)
  if (!Number.isFinite(m) || m <= 0) return '0분'
  const h = Math.floor(m / 60)
  const r = m % 60
  if (h <= 0) return `${r}분`
  if (r === 0) return `${h}시간`
  return `${h}시간 ${r}분`
}

const today = new Date()
const monthIndex = (y, m) => y * 12 + m

const getDayListFetcherBySelectedDate = (selectedDateStr) => {
  if (!selectedDateStr) return getScheduleDayList

  const d = new Date(selectedDateStr)
  if (Number.isNaN(d.getTime())) return getScheduleDayList

  const base = monthIndex(today.getFullYear(), today.getMonth())
  const view = monthIndex(d.getFullYear(), d.getMonth())

  if (view <= base - 1) return getConfirmedScheduleDayList

  const isBefore25 = today.getDate() < 25

  if (isBefore25) {
    if (view === base) return getConfirmedScheduleDayList
    if (view === base + 1) return getScheduleDayList
  } else {
    if (view === base || view === base + 1) return getConfirmedScheduleDayList
    if (view === base + 2) return getScheduleDayList
  }

  return getScheduleDayList
}

const isConfirmedMonthBySelectedDate = (selectedDateStr) => {
  if (!selectedDateStr) return false

  const d = new Date(selectedDateStr)
  if (Number.isNaN(d.getTime())) return false

  const base = monthIndex(today.getFullYear(), today.getMonth())
  const view = monthIndex(d.getFullYear(), d.getMonth())

  if (view <= base - 1) return true

  const isBefore25 = today.getDate() < 25

  if (isBefore25) {
    if (view === base) return true
    if (view === base + 1) return false
  } else {
    if (view === base || view === base + 1) return true
    if (view === base + 2) return false
  }

  return false
}

const normalizePageResponse = (res) => {
  const items = Array.isArray(res?.items)
    ? res.items
    : Array.isArray(res?.content)
      ? res.content
      : Array.isArray(res)
        ? res
        : []

  const t =
    Number(res?.total) ||
    Number(res?.totalElements) ||
    Number(res?.totalCount) ||
    (Array.isArray(items) ? items.length : 0)

  return { items, total: Number.isFinite(t) ? t : items.length }
}

const loadDay = async () => {
  selectedKey.value = null
  error.value = ''
  loading.value = true

  dailySchedules.value = []
  total.value = 0

  if (!props.selectedDate) {
    loading.value = false
    return
  }

  const searchField =
    props.searchScope && props.searchScope !== 'ALL' ? props.searchScope : null

  const fetcher = getDayListFetcherBySelectedDate(props.selectedDate)

  try {
    const res = await fetcher({
      date: props.selectedDate,
      page: Math.max(0, page.value - 1),
      size: pageSize,
      keyword: props.keyword,
      searchField,
      ...(props.serviceTypeId != null ? { serviceTypeId: props.serviceTypeId } : {}), // ✅ 추가
    })

    const normalized = normalizePageResponse(res)
    dailySchedules.value = normalized.items
    total.value = normalized.total

    if (page.value > totalPages.value) page.value = totalPages.value
  } catch (e) {
    error.value = e?.response?.data?.message || '일정 목록을 불러오지 못했습니다.'
  } finally {
    loading.value = false
  }
}

const prevPage = async () => {
  if (page.value <= 1) return
  page.value -= 1
  await loadDay()
}

const nextPage = async () => {
  if (page.value >= totalPages.value) return
  page.value += 1
  await loadDay()
}

let timer = null
watch(
  () => [props.selectedDate, props.keyword, props.searchScope, props.serviceTypeId, props.refreshKey],
  () => {
    clearTimeout(timer)
    page.value = 1
    timer = setTimeout(loadDay, 250)
  },
  { immediate: true }
)

watch(
  () => page.value,
  () => loadDay()
)

const onRowClick = (item) => {
  selectedKey.value = item.matchingId ?? item.vsId ?? null
  const confirmed = isConfirmedMonthBySelectedDate(props.selectedDate)

  emit('select-schedule', {
    ...item,
    source: confirmed ? 'CONFIRMED' : 'NORMAL',
  })
}
</script>

<style scoped>
.schedule-panel {
  box-sizing: border-box;
  width: 100%;
  background: #ffffff;
  border-radius: 20px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 3px 12px rgba(15, 23, 42, 0.04);
  padding: 14px 18px 18px;
}

.schedule-title-row {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 10px;
}

.schedule-title {
  font-size: 17px;
  font-weight: 700;
  color: #15803d;
  margin: 0;
}

.tag-row {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.service-tag {
  padding: 3px 8px;
  border-radius: 999px;
  font-size: 11px;
}

.type-care {
  background: #dbeafe;
  color: #1d4ed8;
}
.type-bath {
  background: #ffe4ef;
  color: #be185d;
}
.type-nurse {
  background: #dcfce7;
  color: #15803d;
}

.schedule-table-wrapper {
  margin-top: 10px;
  border-radius: 14px;
  overflow: hidden;
  border: 1px solid #e5e7eb;
  background: #ffffff;
}

.schedule-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}

.schedule-table thead {
  background: #f9fafb;
}

.schedule-table th,
.schedule-table td {
  padding: 9px 12px;
  text-align: left;
}

.schedule-table th {
  color: #6b7280;
  font-weight: 500;
  border-bottom: 1px solid #e5e7eb;
}

.schedule-table tbody tr + tr td {
  border-top: 1px solid #f3f4f6;
}

.table-row {
  cursor: pointer;
}
.table-row:hover {
  background: #f9fafb;
}

.col-time,
.col-duration {
  white-space: nowrap;
}

.service-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 3px 8px;
  border-radius: 999px;
  font-size: 11px;
}

.badge-care {
  background: #dbeafe;
  color: #1d4ed8;
}
.badge-bath {
  background: #ffe4ef;
  color: #be185d;
}
.badge-nurse {
  background: #dcfce7;
  color: #15803d;
}

.empty-row {
  padding: 18px 12px;
  text-align: center;
  font-size: 13px;
  color: #9ca3af;
  background: #f9fafb;
}

.table-row.selected {
  background: #d7f3dd;
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 14px;
  padding-top: 10px;
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
  font-size: 13px;
  color: #6b7280;
}
</style>