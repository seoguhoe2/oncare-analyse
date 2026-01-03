<!-- src/components/recipient/main/category/servicerental/Service_three.vue -->
<template>
  <section class="svc-visit-wrap">
    <!-- 헤더 -->
    <div class="page-head">
      <button class="back-btn" type="button" @click="$emit('back')">←</button>

      <div class="head-text">
        <h3 class="title">방문 기록</h3>

        <!-- ✅ sub 라인: 좌(월/서비스) + 우(총 건수) -->
        <div class="sub-row">
          <span class="sub-text">
            {{ month }} · {{ serviceTypeNameLabel }}
          </span>
          <span class="total">
            총 {{ totalCount }}건
          </span>
        </div>
      </div>
    </div>

    <!-- ✅ 문의이력처럼: 이 영역만 스크롤 -->
    <div class="scroll-wrapper">
      <ul class="svc-card-list">
        <li v-if="!beneficiaryId" class="empty">수급자를 선택해주세요.</li>
        <li v-else-if="loading" class="empty">불러오는 중...</li>
        <li v-else-if="errorMsg" class="empty">{{ errorMsg }}</li>
        <li v-else-if="totalCount === 0" class="empty">방문 기록이 없습니다.</li>

        <!-- ✅ 현재 페이지에 해당하는 것만 보여줌 -->
        <li v-else v-for="r in pagedRecords" :key="r.recordId" class="svc-card">
          <div class="top">
            <div class="svc-left">
              <span class="pill date-pill">{{ r.workDate }}</span>
              <span class="svc-name">{{ r.startTime }} - {{ r.endTime }}</span>
              <span class="pill hour-pill">{{ formatHours(r.hours) }}</span>
            </div>

            <div class="svc-right">
              <span class="pill worker-pill">{{ r.careWorkerName ?? '담당자 없음' }}</span>
              <span class="svc-amount">{{ formatCurrency(r.amount) }}</span>
            </div>
          </div>

          <div v-if="r.note" class="note">{{ r.note }}</div>
        </li>
      </ul>
    </div>

    <!-- ✅ 하단 중앙 페이징 (페이지가 2 이상일 때만 표시) -->
    <div v-if="totalPages > 1" class="bottom-pager">
      <button
        type="button"
        class="page-btn"
        :disabled="loading || page <= 0"
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
        :disabled="loading || page >= totalPages - 1"
        @click="page++"
      >
        다음
      </button>
    </div>
  </section>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import api from '@/lib/api'

const props = defineProps({
  beneficiaryId: { type: Number, default: null },
  month: { type: String, required: true },
  serviceTypeId: { type: Number, required: true },
})
defineEmits(['back'])

const beneficiaryId = computed(() => props.beneficiaryId)

const loading = ref(false)
const errorMsg = ref('')
const records = ref([])
const serviceTypeName = ref('')

/** ✅ 페이징 상태(문의이력처럼 프론트 페이징) */
const page = ref(0)
const pageSize = ref(10)

/** 포맷터 */
const formatCurrency = (n) => `${(n ?? 0).toLocaleString('ko-KR')}원`
const formatHours = (h) => `${Number(h ?? 0).toFixed(1)}시간`

const serviceTypeNameLabel = computed(() =>
  serviceTypeName.value
    ? `${serviceTypeName.value}(#${props.serviceTypeId})`
    : `#${props.serviceTypeId}`
)

/** ✅ 총 건수 */
const totalCount = computed(() => records.value.length)

/** ✅ 총 페이지 */
const totalPages = computed(() =>
  totalCount.value === 0 ? 0 : Math.ceil(totalCount.value / pageSize.value)
)

/** ✅ 현재 페이지에 보여줄 10개 */
const pagedRecords = computed(() => {
  const start = page.value * pageSize.value
  return records.value.slice(start, start + pageSize.value)
})

const fetchRecords = async () => {
  if (!beneficiaryId.value || !props.month || !props.serviceTypeId) {
    records.value = []
    serviceTypeName.value = ''
    page.value = 0
    return
  }

  loading.value = true
  errorMsg.value = ''
  try {
    const { data } = await api.get(
      `/api/beneficiaries/${beneficiaryId.value}/services/${encodeURIComponent(
        props.month
      )}/types/${props.serviceTypeId}/records`
    )

    serviceTypeName.value = data?.serviceTypeName ?? ''
    records.value = data?.records ?? []

    // ✅ 목록 로드 후 현재 page가 범위를 벗어나면 보정
    if (page.value > 0 && page.value >= totalPages.value) {
      page.value = Math.max(totalPages.value - 1, 0)
    }
  } catch (e) {
    console.error(e)
    records.value = []
    serviceTypeName.value = ''
    page.value = 0
    errorMsg.value = '방문 기록을 불러오지 못했습니다.'
  } finally {
    loading.value = false
  }
}

onMounted(fetchRecords)

// ✅ beneficiaryId/month/serviceTypeId 바뀌면 재조회 + 페이지 초기화
watch(
  () => [beneficiaryId.value, props.month, props.serviceTypeId],
  () => {
    page.value = 0
    fetchRecords()
  }
)
</script>

<style scoped>
/* 래퍼 */
.svc-visit-wrap {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

/* 헤더 */
.page-head {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 6px;
}

.back-btn {
  border: none;
  background: transparent;
  cursor: pointer;
  font-size: 14px;
}

.head-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
  width: 100%;
}

.title {
  margin: 0;
  font-size: 14px;
  font-weight: 800;
}

/* ✅ sub 라인 */
.sub-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
}

.sub-text {
  font-size: 11px;
  color: #6b7280;
}

/* 총 건수 */
.total {
  font-size: 11px;
  color: #6b7280;
  white-space: nowrap;
  margin-right: 10px; /* 살짝 왼쪽으로 이동 */
}

/* ✅ 문의이력처럼: 목록 영역만 스크롤 */
.scroll-wrapper {
  max-height: 360px;
  overflow-y: auto;
  padding-right: 4px;
}

/* 리스트 */
.svc-card-list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.svc-card {
  padding: 10px;
  border-radius: 10px;
  background-color: #f9fafb;
  font-size: 12px;
  margin-bottom: 6px;
}

.top {
  display: flex;
  justify-content: space-between;
  gap: 10px;
  flex-wrap: wrap;
}

.svc-left,
.svc-right {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.svc-name {
  font-weight: 700;
}

.svc-amount {
  font-weight: 800;
}

.note {
  margin-top: 8px;
  padding: 8px 10px;
  border-radius: 10px;
  background: #fff;
  color: #374151;
  font-size: 11px;
  line-height: 1.4;
}

/* pill */
.pill {
  border-radius: 999px;
  padding: 2px 8px;
  font-size: 11px;
}
.date-pill {
  background: #eef2ff;
  color: #4f46e5;
}
.hour-pill {
  background: #ecfeff;
  color: #0891b2;
}
.worker-pill {
  background: #f0fdf4;
  color: #16a34a;
}

.empty {
  padding: 14px 10px;
  color: #6b7280;
  font-size: 12px;
}

/* ✅ 하단 중앙 페이징 (문의이력 스타일) */
.bottom-pager {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 10px;
  margin-top: 6px;
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
