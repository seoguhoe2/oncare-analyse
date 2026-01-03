<template>
  <div class="alternate-box">
    <div class="alternate-header">
      <span class="title">{{ headerTitle }}</span>
      <span class="count">{{ totalCount }}명 가능</span>
    </div>

    <div class="alternate-body">
      <div v-if="loading" class="loading">불러오는 중...</div>
      <div v-else-if="error" class="error">{{ error }}</div>

      <template v-else>
        <button
          v-for="alt in pagedAlternatives"
          :key="alt.careWorkerId ?? alt.id"
          type="button"
          class="alternate-item"
          @click="openDetail(alt)"
        >
          <div class="item-left">
            <span class="name">{{ alt.name || '-' }}</span>

            <span class="gender" :class="badgeClass(alt.gender)">
              {{ displayGender(alt.gender) }}
            </span>

            <div class="tags">
              <span v-for="tag in alt.tags || []" :key="tag" class="tag">
                {{ tag }}
              </span>
              <span v-if="!alt.tags?.length" class="tag-empty">태그 없음</span>
            </div>
          </div>

          <span class="assign-chip">배정가능</span>
        </button>

        <div v-if="!pagedAlternatives.length" class="empty">
          대체 가능한 요양보호사가 없습니다.
        </div>

        <div v-if="totalCount > 0" class="pagination">
          <button @click="prevPage" :disabled="uiPage === 1">〈</button>
          <span>{{ uiPage }} / {{ totalPages }}</span>
          <button @click="nextPage" :disabled="uiPage === totalPages">〉</button>
        </div>
      </template>
    </div>

    <!-- 1) 상세 모달 -->
    <CareWorkerDetailModal
      :open="detailOpen"
      :loading="detailLoading"
      :error="detailError"
      :detail="detail"
      :confirm-loading="changeLoading"
      :mode="changeMode"
      @close="detailOpen = false"
      @confirm-change="onConfirmChange"
    />

    <!-- 2) 변경 확인 모달 -->
    <CareWorkerChangeConfirmModal
      :open="confirmOpen"
      :loading="changeLoading"
      :mode="changeMode"
      :date-text="props.scheduleDate"
      :beneficiary-name="props.beneficiaryName"
      :from-care-worker-name="props.currentCareWorkerName"
      :to-care-worker-name="pendingCareWorkerName"
      @close="confirmOpen = false"
      @confirm="onFinalConfirm"
    />
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import CareWorkerDetailModal from '@/components/schedule/calendar/detail/CareWorkerDetailModal.vue'
import CareWorkerChangeConfirmModal from '@/components/schedule/calendar/detail/CareWorkerChangeConfirmModal.vue'

import {
  getCandidateCareWorkerCards,
  getVisitAvailableCareWorkerCards,
  getCareWorkerDetail,
  changeMatchingCareWorker,
  changeVisitScheduleCareWorker,
} from '@/api/schedule/matching.js'

const props = defineProps({
  beneficiaryId: { type: [Number, String], default: null },
  source: { type: String, default: 'NORMAL' }, // 'CONFIRMED' | 'NORMAL'

  matchingId: { type: [Number, String], default: null }, // NORMAL 변경 시 필요
  vsId: { type: [Number, String], default: null },       // CONFIRMED 변경 시 필요

  beneficiaryName: { type: String, default: '' },
  currentCareWorkerName: { type: String, default: '' },
  scheduleDate: { type: String, default: '' }, // 'YYYY-MM-DD'

  startDt: { type: String, default: '' }, // 'YYYY-MM-DD HH:mm:ss' or 'YYYY-MM-DDTHH:mm:ss'
  endDt: { type: String, default: '' },
  startTime: { type: String, default: '' }, // 'HH:mm'
  endTime: { type: String, default: '' },   // 'HH:mm'
})

const emit = defineEmits(['changed'])

/** =========================
 * paging rules
 * =========================
 * CONFIRMED: server size=3 fixed
 * NORMAL: server size=8 fixed(기존 화면 유지) + 이 화면에서만 UI size=3
 */
const UI_PAGE_SIZE = 3
const NORMAL_SERVER_SIZE = 8

const uiPage = ref(1) // 1-based
const loading = ref(false)
const error = ref('')

// 실제 렌더링할 3개
const pagedAlternatives = ref([])

// 헤더/페이지 계산용 total
const totalCount = ref(0)

const totalPages = computed(() => Math.max(1, Math.ceil((totalCount.value || 0) / UI_PAGE_SIZE)))

const prevPage = () => {
  if (uiPage.value > 1) uiPage.value--
}
const nextPage = () => {
  if (uiPage.value < totalPages.value) uiPage.value++
}

const isValid = (v) => v !== null && v !== undefined && String(v).trim() !== ''

const normalizeDate = (v) => {
  const s = String(v ?? '').trim()
  if (!s) return ''
  return s.includes('T') ? s.split('T')[0] : s.slice(0, 10)
}
const normalizeDt = (s) => {
  const v = String(s ?? '').trim()
  if (!v) return ''
  return v.includes('T') ? v.replace('T', ' ') : v
}
const buildDtFromDateAndTime = (date, hm) => {
  const d = normalizeDate(date)
  const t = String(hm ?? '').trim()
  if (!d || !t) return ''
  return `${d} ${t.slice(0, 5)}:00`
}

const resolvedStartDt = computed(() => {
  if (isValid(props.startDt)) return normalizeDt(props.startDt)
  return buildDtFromDateAndTime(props.scheduleDate, props.startTime)
})
const resolvedEndDt = computed(() => {
  if (isValid(props.endDt)) return normalizeDt(props.endDt)
  return buildDtFromDateAndTime(props.scheduleDate, props.endTime)
})

/**
 * ✅ 응답 파싱:
 * - 배열 직접 반환: res.data가 Array
 * - 페이지 객체: res.data.data가 Array + res.data.total 존재
 */
const pickPage = (res) => {
  const d = res?.data
  if (Array.isArray(d)) {
    return { list: d, total: d.length }
  }
  const list =
    Array.isArray(d?.data) ? d.data
    : Array.isArray(d?.list) ? d.list
    : Array.isArray(d?.content) ? d.content
    : []
  const total =
    Number.isFinite(Number(d?.total)) ? Number(d.total)
    : Number.isFinite(Number(d?.totalElements)) ? Number(d.totalElements)
    : list.length
  return { list, total }
}

const changeMode = computed(() => (props.source === 'CONFIRMED' ? 'CONFIRMED' : 'NORMAL'))
const headerTitle = computed(() =>
  changeMode.value === 'CONFIRMED' ? '대체 가능한 요양보호사' : '대체 가능한 담당 요양보호사'
)

/**
 * ✅ 핵심 로드:
 * - CONFIRMED: uiPage(1-based) -> server page(0-based)
 * - NORMAL: uiPage(3개 단위) -> serverPage(8개 단위)로 변환해서 받고,
 *           서버에서 받은 8개 중에서 다시 3개만 잘라서 렌더
 */
const load = async () => {
  error.value = ''
  pagedAlternatives.value = []
  totalCount.value = 0

  if (!isValid(props.beneficiaryId)) return

  const isConfirmed = props.source === 'CONFIRMED'

  if (isConfirmed) {
    if (!isValid(props.vsId)) return
    if (!isValid(resolvedStartDt.value) || !isValid(resolvedEndDt.value)) return
  }

  try {
    loading.value = true

    if (isConfirmed) {
      const res = await getVisitAvailableCareWorkerCards({
        vsId: props.vsId,
        startDt: resolvedStartDt.value,
        endDt: resolvedEndDt.value,
        page: Math.max(uiPage.value - 1, 0), // 서버는 0-based
      })

      const { list, total } = pickPage(res)
      pagedAlternatives.value = list // 서버가 이미 3개로 잘라줌
      totalCount.value = total
      return
    }

    // NORMAL: 서버는 8개 페이징 유지
    const uiIndex0 = (uiPage.value - 1) * UI_PAGE_SIZE            // 0-based item index (3단위)
    const serverPage = Math.floor(uiIndex0 / NORMAL_SERVER_SIZE)  // 8개 단위로 어느 page?
    const serverOffsetInPage = uiIndex0 % NORMAL_SERVER_SIZE      // 그 8개 중 어디서부터?

    const res = await getCandidateCareWorkerCards({
      beneficiaryId: props.beneficiaryId,
      page: serverPage,
      size: NORMAL_SERVER_SIZE,
      keyword: null,
    })

    const { list, total } = pickPage(res)
    totalCount.value = total

    // 서버에서 받은 8개 중에서 UI는 3개만 보여줌
    pagedAlternatives.value = list.slice(serverOffsetInPage, serverOffsetInPage + UI_PAGE_SIZE)
  } catch (e) {
    error.value = '대체 요양보호사를 불러오지 못했습니다.'
  } finally {
    loading.value = false
  }
}

// ✅ uiPage 바뀌면 다음 3개 로드
watch(() => uiPage.value, load)

// ✅ 입력값 바뀌면 1페이지로 리셋 후 로드
watch(
  () => [
    props.beneficiaryId,
    props.source,
    props.vsId,
    props.scheduleDate,
    props.startDt,
    props.endDt,
    props.startTime,
    props.endTime,
  ],
  () => {
    uiPage.value = 1
    load()
  },
  { immediate: true }
)

/* =========================
 * UI helpers
 * ========================= */
const badgeClass = (g) => ({
  male: g === '남자' || g === 'M',
  female: g === '여자' || g === 'F',
})
const displayGender = (g) => (g === 'M' ? '남자' : g === 'F' ? '여자' : g || '-')

/* =========================
 * Detail Modal
 * ========================= */
const detailOpen = ref(false)
const detailLoading = ref(false)
const detailError = ref('')
const detail = ref(null)

const changeLoading = ref(false)

const dayLabel = (v) => {
  const s = String(v ?? '').trim()
  if (!s) return '-'
  if (s.length === 1 && /[월화수목금토일]/.test(s)) return s

  const n = Number(s)
  if (!Number.isFinite(n)) return s

  const map1to7 = ['', '월', '화', '수', '목', '금', '토', '일']
  const map0to6 = ['일', '월', '화', '수', '목', '금', '토']

  if (n >= 1 && n <= 7) return map1to7[n] || s
  if (n >= 0 && n <= 6) return map0to6[n] || s
  return s
}
const timeHM = (t) => {
  const s = String(t ?? '').trim()
  if (!s) return ''
  if (s.includes('T')) return (s.split('T')[1] || '').slice(0, 5)
  return s.slice(0, 5)
}
const normalizeDetailForModal = (raw) => {
  const d = raw && typeof raw === 'object' ? raw : {}
  const wt = Array.isArray(d.workingTimes) ? d.workingTimes : []
  const normalizedWorkingTimes = wt.map((x) => ({
    ...x,
    day: dayLabel(x?.day ?? x?.weekday ?? x?.dayOfWeek),
    start: timeHM(x?.start ?? x?.startTime),
    end: timeHM(x?.end ?? x?.endTime),
    serviceTypeName: x?.serviceTypeName ?? x?.serviceType ?? x?.serviceName,
  }))

  const normalizedServices = (() => {
    if (Array.isArray(d.services)) return d.services
    if (Array.isArray(d.serviceTypes)) return d.serviceTypes
    if (Array.isArray(d.availableServices)) return d.availableServices
    if (Array.isArray(d.serviceTypeNames)) return d.serviceTypeNames
    return []
  })()

  return { ...d, workingTimes: normalizedWorkingTimes, services: normalizedServices }
}

const openDetail = async (alt) => {
  const careWorkerId = alt?.careWorkerId ?? alt?.id ?? null
  if (!careWorkerId) return

  detailOpen.value = true
  detailLoading.value = true
  detailError.value = ''
  detail.value = null

  try {
    const res = await getCareWorkerDetail(careWorkerId)
    detail.value = normalizeDetailForModal(res?.data ?? null)
  } catch (e) {
    detailError.value = '요양보호사 상세 정보를 불러오지 못했습니다.'
  } finally {
    detailLoading.value = false
  }
}

/* =========================
 * Confirm Modal
 * ========================= */
const confirmOpen = ref(false)
const pendingCareWorkerId = ref(null)
const pendingCareWorkerName = ref('')

const onConfirmChange = async (careWorkerId) => {
  if (!careWorkerId) return
  pendingCareWorkerId.value = careWorkerId
  pendingCareWorkerName.value = String(detail.value?.name ?? '').trim() || ''
  confirmOpen.value = true
}

const onFinalConfirm = async () => {
  const careWorkerId = pendingCareWorkerId.value
  if (!careWorkerId) return

  try {
    changeLoading.value = true
    detailError.value = ''

    if (props.source === 'CONFIRMED') {
      if (!isValid(props.vsId)) throw new Error('vsId missing')
      await changeVisitScheduleCareWorker(props.vsId, careWorkerId)
    } else {
      if (!isValid(props.matchingId)) throw new Error('matchingId missing')
      await changeMatchingCareWorker(props.matchingId, careWorkerId)
    }

    confirmOpen.value = false
    detailOpen.value = false
    emit('changed')
  } catch (e) {
    detailError.value = '요양보호사 변경에 실패했습니다.'
    confirmOpen.value = false
  } finally {
    changeLoading.value = false
  }
}
</script>

<style scoped>
.alternate-box {
  background: #f0f9ff;
  border: 1px solid #bfdbfe;
  border-radius: 16px;
  overflow: hidden;
}
.alternate-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
}
.title {
  font-size: 14px;
  font-weight: 700;
  color: #2563eb;
}
.count {
  font-size: 12px;
  color: #2563eb;
  font-weight: 600;
}
.alternate-body {
  padding: 10px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.alternate-item {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #ffffff;
  border: 1px solid #bfdbfe;
  border-radius: 14px;
  padding: 12px 14px;
  gap: 12px;
  cursor: pointer;
  text-align: left;
}
.alternate-item:hover {
  background: #f8fbff;
}
.item-left {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
  flex: 1;
}
.name {
  font-size: 14px;
  font-weight: 700;
  color: #111827;
  white-space: nowrap;
}
.gender {
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
  white-space: nowrap;
}
.gender.male {
  background: #e0f2fe;
  color: #0284c7;
}
.gender.female {
  background: #fde2e8;
  color: #ec4899;
}
.tags {
  display: flex;
  gap: 6px;
  flex-wrap: nowrap;
  overflow: hidden;
}
.tag {
  background: #dcfce7;
  color: #15803d;
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
  white-space: nowrap;
}
.tag-empty {
  font-size: 12px;
  color: #9ca3af;
}
.assign-chip {
  background: #dcfce7;
  color: #15803d;
  font-size: 12px;
  font-weight: 800;
  padding: 8px 14px;
  border-radius: 999px;
  white-space: nowrap;
}
.loading,
.error,
.empty {
  font-size: 13px;
  color: #6b7280;
  padding: 6px 4px;
}
.error {
  color: #b91c1c;
}
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 14px;
  padding-top: 6px;
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