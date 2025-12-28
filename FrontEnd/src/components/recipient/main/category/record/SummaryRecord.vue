<!-- src/components/recipient/category/record/SummaryRecord.vue -->
<template>
  <div class="record-summary">
    <!-- 월별 보기 -->
    <div v-if="recordViewMode === 'monthly'" class="record-monthly">
      <!-- ✅ 월 카드가 0개면 안내 -->
      <div v-if="monthlySummariesView.length === 0" class="empty-month-card">
        요양일지가 등록되면 월별 카드가 생성됩니다.
      </div>

      <!-- ✅ 월 카드 목록 -->
      <div
        v-else
        v-for="item in monthlySummariesView"
        :key="item.month"
        class="summary-card"
        @click="openDailyList(item.month)"
      >
        <div class="summary-icon">📅</div>

        <div class="summary-main">
          <div class="summary-header">
            <span class="summary-month">{{ item.month }}</span>

            <!-- ✅ AI 요약 버튼 -->
            <button
              type="button"
              class="ai-btn"
              :disabled="!!aiLoadingByMonth[item.month]"
              @click.stop="runAiSummary(item.month)"
            >
              {{ aiLoadingByMonth[item.month] ? '요약 중…' : 'AI 요약' }}
            </button>
          </div>

          <p class="summary-text">
            <!-- ✅ AI 요약 결과가 있으면 보여주고, 없으면 기본 문구 -->
            {{ item.text || '해당 월의 경향을 한눈에 보려면 AI요약 버튼을 클릭하세요!' }}
          </p>

          <!-- ✅ 월 카드별 에러 메시지 -->
          <p v-if="aiErrorByMonth[item.month]" class="ai-error">
            {{ aiErrorByMonth[item.month] }}
          </p>
        </div>
      </div>
    </div>

    <!-- 일지 리스트 보기 -->
    <div v-else-if="recordViewMode === 'dailyList'">
      <button
        type="button"
        class="link-btn mb-8"
        @click="recordViewMode = 'monthly'"
      >
        ← 월별 보기로 돌아가기
      </button>

      <h4 class="section-title">{{ selectedMonth }} 일지</h4>

      <div v-if="listLoading" class="hint">불러오는 중...</div>
      <div v-else-if="listError" class="hint error">{{ listError }}</div>

      <ul v-else class="daily-list">
        <li
          v-for="log in dailyLogList"
          :key="log.logId"
          class="daily-row"
          @click="openDetail(log.logId)"
        >
          <div class="daily-left">
            <span class="daily-icon">📄</span>
            <span class="daily-date">{{ log.serviceDate }}</span>
            <span class="daily-worker">{{ log.careWorkerName }}</span>
          </div>

          <span class="daily-time-pill">
            {{ log.serviceType || '-' }}
          </span>
        </li>

        <li v-if="dailyLogList.length === 0" class="empty-row">
          해당 월의 요양일지가 없습니다.
        </li>
      </ul>
    </div>

    <!-- 상세 기록지 -->
    <div v-else-if="recordViewMode === 'detail'" class="record-detail">
      <button
        type="button"
        class="link-btn mb-8"
        @click="recordViewMode = 'dailyList'"
      >
        ← 일지 리스트로 돌아가기
      </button>

      <div v-if="detailLoading" class="hint">불러오는 중...</div>
      <div v-else-if="detailError" class="hint error">{{ detailError }}</div>

      <template v-else>
        <!-- ✅ 헤더 정보 -->
        <div class="detail-header-row">
          <div class="detail-col">
            <div class="detail-line">
              <span class="detail-label">서비스 일시</span>
              <span class="detail-value">
                {{ detail?.serviceDate || '-' }}
                {{ detail?.startTime || '' }}~{{ detail?.endTime || '' }}
              </span>
            </div>
            <div class="detail-line">
              <span class="detail-label">서비스 구분</span>
              <span class="detail-value">{{ detail?.serviceType || '-' }}</span>
            </div>
          </div>

          <div class="detail-col">
            <div class="detail-line">
              <span class="detail-label">기록 일시</span>
              <span class="detail-value">{{ detail?.recordedAt || '-' }}</span>
            </div>
            <div class="detail-line">
              <span class="detail-label">방문 요양보호사</span>
              <span class="detail-value">{{ detail?.careWorkerName || '-' }}</span>
            </div>
          </div>
        </div>

        <!-- 1) 신체활동 지원 -->
        <div class="detail-section blue">
          <h5>1. 신체활동 지원</h5>

          <div class="subgrid">
            <div class="subgroup-card" v-if="hasAny(detail?.physical?.meal)">
              <div class="sub-title">식사 / 영양</div>
              <div class="chip-row">
                <span v-for="(t, idx) in detail.physical.meal" :key="'meal' + idx" class="chip">
                  {{ t }}
                </span>
              </div>
            </div>

            <div class="subgroup-card" v-if="hasAny(detail?.physical?.excretion)">
              <div class="sub-title">배설 관리</div>
              <div class="chip-row">
                <span v-for="(t, idx) in detail.physical.excretion" :key="'exc' + idx" class="chip">
                  {{ t }}
                </span>
              </div>
            </div>

            <div class="subgroup-card" v-if="hasAny(detail?.physical?.hygiene)">
              <div class="sub-title">위생 / 청결</div>
              <div class="chip-row">
                <span v-for="(t, idx) in detail.physical.hygiene" :key="'hyg' + idx" class="chip">
                  {{ t }}
                </span>
              </div>
            </div>

            <div class="subgroup-card" v-if="hasAny(detail?.physical?.mobility)">
              <div class="sub-title">이동 / 체위</div>
              <div class="chip-row">
                <span v-for="(t, idx) in detail.physical.mobility" :key="'mob' + idx" class="chip">
                  {{ t }}
                </span>
              </div>
            </div>
          </div>

          <div v-if="!hasAnyAllPhysical(detail)" class="empty-sub">
            표시할 신체활동 항목이 없습니다.
          </div>
        </div>

        <!-- 2) 인지 및 정서 지원 -->
        <div class="detail-section purple">
          <h5>2. 인지 및 정서 지원</h5>

          <div class="chip-row" v-if="hasAny(detail?.cognitive)">
            <span v-for="(t, idx) in detail.cognitive" :key="'cog' + idx" class="chip">
              {{ t }}
            </span>
          </div>

          <div v-else class="empty-sub">
            표시할 인지/정서 항목이 없습니다.
          </div>
        </div>

        <!-- 3) 상태 관찰 및 특이사항 -->
        <div class="detail-section green">
          <h5>3. 상태 관찰 및 특이사항</h5>

          <div class="subgrid">
            <div class="subgroup-card" v-if="hasAny(detail?.status?.health)">
              <div class="sub-title">신체 상태</div>
              <div class="chip-row">
                <span v-for="(t, idx) in detail.status.health" :key="'st_h' + idx" class="chip">
                  {{ t }}
                </span>
              </div>
            </div>

            <div class="subgroup-card" v-if="hasAny(detail?.status?.mood)">
              <div class="sub-title">기분 상태</div>
              <div class="chip-row">
                <span v-for="(t, idx) in detail.status.mood" :key="'st_m' + idx" class="chip">
                  {{ t }}
                </span>
              </div>
            </div>

            <div class="subgroup-card" v-if="hasAny(detail?.status?.sleep)">
              <div class="sub-title">수면</div>
              <div class="chip-row">
                <span v-for="(t, idx) in detail.status.sleep" :key="'st_s' + idx" class="chip">
                  {{ t }}
                </span>
              </div>
            </div>

            <div class="subgroup-card note-wide">
              <div class="sub-title">특이사항</div>
              <div class="note-box" :class="{ empty: !detail?.specialNote }">
                {{ detail?.specialNote || '없음' }}
              </div>
            </div>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import api from '@/lib/api'

const props = defineProps({
  beneficiaryId: { type: [Number, String], required: true },
  monthlySummaryList: { type: Array, default: () => [] } // ✅ 지금은 안 쓰더라도 props 유지
})

/**
 * ✅ 기존: props(monthlySummaryList) 기반이었는데
 * ✅ 변경: "요양일지 리스트"에서 월을 뽑아 월카드를 생성 + GET으로 DB 요약 채우기
 *
 * - monthlySummaryList는 mock 제거하면서 빈 배열이 될 수 있어도,
 *   이제 월카드는 care-logs 기준으로 생성되므로 문제 없음.
 */
const localMonthlySummaries = ref([])

/** ✅ 템플릿에서 사용하는 월 카드 리스트 */
const monthlySummariesView = computed(() => localMonthlySummaries.value)

const recordViewMode = ref('monthly')
const selectedMonth = ref('') // 초기값은 빈값(클릭한 월로 세팅)

const dailyLogList = ref([])
const selectedLogId = ref(null)
const detail = ref(null)

const listLoading = ref(false)
const listError = ref('')
const detailLoading = ref(false)
const detailError = ref('')

/** ✅ AI 버튼 로딩/에러: 월별로 따로 관리 */
const aiLoadingByMonth = ref({})
const aiErrorByMonth = ref({})

/**
 * ✅ (선택) "요양일지 없어..." 같은 메시지를 카드에 덮어쓰지 않을지 여부
 * - true: 덮어쓰기 방지(추천)
 * - false: 그대로 덮어씀
 */
const BLOCK_EMPTY_SUMMARY_OVERWRITE = true

/**
 * ✅ 월 카드 생성용: 요양일지 전체 조회 후 "월"만 추출
 * - 백엔드: GET /api/beneficiaries/{id}/care-logs (month 없이 호출)
 * - 응답의 serviceDate(YYYY-MM-DD)에서 YYYY-MM만 뽑아 월 목록 만들기
 */
const fetchMonthlyCardsFromLogs = async () => {
  if (!props.beneficiaryId) return

  try {
    // ✅ month 없이 호출: 전체(또는 백엔드가 기본 기간을 줄 수도 있음)
    const { data } = await api.get(`/api/beneficiaries/${props.beneficiaryId}/care-logs`)
    const logs = Array.isArray(data) ? data : []

    // serviceDate에서 YYYY-MM 추출
    const monthSet = new Set()
    for (const log of logs) {
      const sd = String(log?.serviceDate || '')
      if (sd.length >= 7) monthSet.add(sd.slice(0, 7))
    }

    // 최신 월이 위로 오게 정렬(내림차순)
    const months = Array.from(monthSet).sort((a, b) => (a < b ? 1 : a > b ? -1 : 0))

    // 월 카드 기본 형태 생성(요약 text는 일단 비워둠)
    localMonthlySummaries.value = months.map((m) => ({
      month: m,
      text: '' // ✅ GET으로 채울 예정
    }))

    // ✅ 월 카드 생성 후, DB에 저장된 요약이 있으면 GET으로 채우기
    await fetchSavedSummariesForMonths(months)
  } catch (e) {
    // 월 카드 생성 자체가 실패한 케이스
    localMonthlySummaries.value = []
  }
}

/**
 * ✅ (핵심) GET: DB에 저장된 "최신 월별 요약" 불러와서 카드에 채우기
 * - GET /api/beneficiaries/{id}/care-logs/monthly-summary?month=YYYY-MM
 * - 없으면(404 또는 null) 그냥 비워둠 → 기본 안내 문구가 보임
 */
const fetchSavedSummariesForMonths = async (months) => {
  if (!Array.isArray(months) || months.length === 0) return

  // 병렬로 때려도 되고, 너무 많으면 순차도 OK
  const tasks = months.map(async (m) => {
    try {
      const { data } = await api.get(
        `/api/beneficiaries/${props.beneficiaryId}/care-logs/monthly-summary`,
        { params: { month: m } }
      )

      const summaryText = (data?.summaryText || '').trim()
      if (!summaryText) return { month: m, text: '' }
      return { month: m, text: summaryText }
    } catch (e) {
      // ✅ 요약이 없는 경우(보통 404) → 빈값 유지
      return { month: m, text: '' }
    }
  })

  const results = await Promise.all(tasks)

  // 결과를 월 카드에 반영
  const map = new Map(results.map((r) => [String(r.month), r.text]))
  localMonthlySummaries.value = localMonthlySummaries.value.map((it) => {
    const t = map.get(String(it.month)) ?? it.text
    return { ...it, text: t }
  })
}

const openDailyList = async (month) => {
  selectedMonth.value = String(month || '')
  recordViewMode.value = 'dailyList'
  await fetchDailyList()
}

const fetchDailyList = async () => {
  if (!selectedMonth.value) return

  listLoading.value = true
  listError.value = ''
  try {
    const { data } = await api.get(`/api/beneficiaries/${props.beneficiaryId}/care-logs`, {
      params: { month: selectedMonth.value }
    })
    dailyLogList.value = Array.isArray(data) ? data : []
  } catch (e) {
    listError.value = e?.response?.data?.message || e?.message || '일지 리스트 조회 실패'
    dailyLogList.value = []
  } finally {
    listLoading.value = false
  }
}

const openDetail = async (logId) => {
  selectedLogId.value = logId
  recordViewMode.value = 'detail'
  await fetchDetail()
}

const fetchDetail = async () => {
  detailLoading.value = true
  detailError.value = ''
  detail.value = null

  try {
    const { data } = await api.get(
      `/api/beneficiaries/${props.beneficiaryId}/care-logs/${selectedLogId.value}`
    )
    detail.value = data
  } catch (e) {
    if (e?.response?.status === 404) {
      detailError.value = '해당 요양일지를 찾을 수 없습니다.'
    } else {
      detailError.value = e?.response?.data?.message || e?.message || '일지 상세 조회 실패'
    }
  } finally {
    detailLoading.value = false
  }
}

/** ✅ 월별 AI 요약 실행(백엔드 POST 실행) */
const runAiSummary = async (month) => {
  if (!month) return
  const key = String(month)

  // 중복 클릭 방지
  if (aiLoadingByMonth.value[key]) return

  aiLoadingByMonth.value = { ...aiLoadingByMonth.value, [key]: true }
  aiErrorByMonth.value = { ...aiErrorByMonth.value, [key]: '' }

  try {
    const { data } = await api.post(
      `/api/beneficiaries/${props.beneficiaryId}/care-logs/monthly-summary`,
      null,
      { params: { month: key } }
    )

    const summaryText = (data?.summaryText || '').trim()

    // (선택) "요양일지 없어..." 메시지는 카드에 덮어쓰기 방지
    if (BLOCK_EMPTY_SUMMARY_OVERWRITE && summaryText.includes('요양일지가 없어')) {
      aiErrorByMonth.value = { ...aiErrorByMonth.value, [key]: summaryText }
      return
    }

    // ✅ 카드 내용 업데이트 (해당 month만)
    localMonthlySummaries.value = localMonthlySummaries.value.map((it) => {
      if (String(it.month) !== key) return it
      return { ...it, text: summaryText }
    })

    /**
     * ✅ (선택) POST 후에도 "DB에 저장된 최신"이 맞는지 확실히 하고 싶으면
     * 바로 GET 한 번 더 때려서 동기화해도 됨.
     * 지금은 POST 응답을 믿고 즉시 반영만 해도 충분.
     */
    // await fetchSavedSummariesForMonths([key])
  } catch (e) {
    aiErrorByMonth.value = {
      ...aiErrorByMonth.value,
      [key]: e?.response?.data?.message || e?.response?.data?.detail || e?.message || 'AI 요약 실패'
    }
  } finally {
    aiLoadingByMonth.value = { ...aiLoadingByMonth.value, [key]: false }
  }
}

/**
 * ✅ beneficiaryId 바뀌면
 * - 월카드 다시 만들고(GET care-logs)
 * - 월별 저장된 요약 다시 불러오기(GET monthly-summary)
 */
watch(
  () => props.beneficiaryId,
  async () => {
    recordViewMode.value = 'monthly'
    selectedMonth.value = ''
    dailyLogList.value = []
    detail.value = null
    selectedLogId.value = null
    aiLoadingByMonth.value = {}
    aiErrorByMonth.value = {}

    // ✅ 월카드 재생성 + 저장된 요약 GET 반영
    await fetchMonthlyCardsFromLogs()
  },
  { immediate: true }
)

const hasAny = (arr) => Array.isArray(arr) && arr.length > 0
const hasAnyAllPhysical = (d) => {
  const p = d?.physical
  return hasAny(p?.meal) || hasAny(p?.excretion) || hasAny(p?.hygiene) || hasAny(p?.mobility)
}
</script>

<style scoped>
.link-btn {
  border: none;
  background: transparent;
  font-size: 12px;
  color: #4b5563;
  cursor: pointer;
}
.mb-8 { margin-bottom: 8px; }

/* 월별 카드 */
.record-monthly { display: flex; flex-direction: column; gap: 8px; }

.empty-month-card{
  padding: 14px 12px;
  border-radius: 10px;
  border: 1px dashed #e5e7eb;
  background: #fafafa;
  color: #6b7280;
  font-size: 12px;
}

.summary-card {
  display: flex;
  gap: 10px;
  padding: 10px 12px;
  border-radius: 10px;
  background-color: #f9fafb;
  cursor: pointer;
}
.summary-icon { font-size: 18px; }
.summary-main { flex: 1; }
.summary-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}
.summary-month { font-weight: 600; font-size: 13px; }
.ai-btn {
  border-radius: 999px;
  border: none;
  padding: 4px 8px;
  font-size: 11px;
  background-color: #eef2ff;
  color: #4f46e5;
  cursor: pointer;
}
.ai-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
.summary-text { margin: 0; font-size: 12px; color: #4b5563; }
.ai-error { margin: 6px 0 0; font-size: 11px; color: #dc2626; }

/* 일지 리스트 */
.section-title { margin: 0 0 6px; font-size: 14px; font-weight: 600; }
.daily-list { list-style: none; margin: 0; padding: 0; }
.daily-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 10px;
  border-radius: 8px;
  background-color: #f9fafb;
  font-size: 12px;
  margin-bottom: 4px;
  cursor: pointer;
}
.daily-left { display: flex; align-items: center; gap: 8px; }
.daily-icon { font-size: 14px; }
.daily-date { font-weight: 500; }
.daily-worker { color: #6b7280; }
.daily-time-pill {
  border-radius: 999px;
  padding: 2px 8px;
  font-size: 11px;
  background-color: #eef2ff;
  color: #4f46e5;
  white-space: nowrap;
}
.empty-row { padding: 10px 8px; color: #6b7280; font-size: 12px; }

/* 상세 기록지 */
.record-detail { font-size: 12px; }
.detail-header-row {
  display: flex;
  justify-content: space-between;
  gap: 20px;
  margin-bottom: 10px;
}
.detail-col { flex: 1; }
.detail-line {
  display: grid;
  grid-template-columns: 110px 1fr;
  column-gap: 14px;
  align-items: center;
  margin-bottom: 4px;
}
.detail-label { color: #6b7280; }
.detail-value { justify-self: start; }

/* 섹션 */
.detail-section {
  border-radius: 10px;
  padding: 10px 12px;
  margin-bottom: 8px;
}
.detail-section.blue { background-color: #eef2ff; }
.detail-section.purple { background-color: #f5f3ff; }
.detail-section.green { background-color: #ecfdf3; }
.detail-section h5 { margin: 0 0 8px; font-size: 12px; }

.subgrid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px 10px;
}
@media (max-width: 520px) {
  .subgrid { grid-template-columns: 1fr; }
}
.subgroup-card {
  border-radius: 10px;
  padding: 8px 10px;
  background: rgba(255, 255, 255, 0.55);
}
.note-wide { grid-column: 1 / -1; }

.sub-title {
  font-size: 11px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 6px;
}
.chip-row { display: flex; flex-wrap: wrap; gap: 4px; }
.chip {
  border-radius: 999px;
  padding: 2px 8px;
  font-size: 11px;
  background-color: #e5e7eb;
  color: #374151;
}

.note-box {
  border-radius: 10px;
  padding: 8px 10px;
  font-size: 12px;
  line-height: 1.4;
  background: rgba(255, 255, 255, 0.7);
  color: #374151;
  white-space: pre-wrap;
}
.note-box.empty { color: #6b7280; }

.hint { font-size: 12px; color: #6b7280; padding: 6px 2px; }
.hint.error { color: #dc2626; }
.empty-sub { margin-top: 6px; font-size: 12px; color: #6b7280; }
</style>
