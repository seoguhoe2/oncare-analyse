<!-- src/components/recipient/main/category/servicerental/Service.vue -->
<template>
  <section>
    <!-- ✅ 1번 화면 -->
    <div v-if="view === 'one'">
      <div class="page-head">
        <h3 class="title">서비스 내역</h3>
      </div>

      <!-- ✅ 문의이력처럼: 목록만 스크롤 -->
      <div class="scroll-wrapper">
        <ul class="svc-card-list">
          <li v-if="!beneficiaryId" class="empty">수급자를 선택해주세요.</li>
          <li v-else-if="loading" class="empty">불러오는 중...</li>
          <li v-else-if="months.length === 0" class="empty">데이터가 없습니다.</li>

          <!-- ✅ 현재 페이지 데이터만 표시 -->
          <li
            v-else
            v-for="m in pagedMonths"
            :key="m.month"
            class="svc-card clickable"
            @click="openTwo(m.month)"
          >
            <div class="svc-left">
              <span class="pill month-pill">{{ m.month }}</span>
              <span class="svc-name">월 누계</span>
            </div>
            <div class="svc-right">
              <span class="svc-amount">{{ formatCurrency(m.totalAmount) }}</span>
              <span class="svc-status">자세히</span>
            </div>
          </li>
        </ul>
      </div>

      <!-- ✅ 하단 중앙 페이징 -->
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
    </div>

    <!-- ✅ 2번 화면 -->
    <Service_two
      v-else-if="view === 'two'"
      :beneficiary-id="beneficiaryId"
      :month="selectedMonth"
      @back="goOne"
      @select-type="openThree"
    />

    <!-- ✅ 3번 화면 -->
    <Service_three
      v-else
      :beneficiary-id="beneficiaryId"
      :month="selectedMonth"
      :service-type-id="selectedServiceTypeId"
      @back="goTwo"
    />
  </section>
</template>

<script setup>
import { onMounted, ref, watch, computed } from 'vue'
import api from '@/lib/api'

import Service_two from './Service_two.vue'
import Service_three from './Service_three.vue'

const props = defineProps({
  beneficiaryId: { type: Number, default: null },
})

const beneficiaryId = computed(() => props.beneficiaryId)

const view = ref('one')
const loading = ref(false)

const months = ref([])

const selectedMonth = ref('')
const selectedServiceTypeId = ref(null)

/** ✅ 프론트 페이징 상태 */
const page = ref(0)
const pageSize = ref(10)

/** 포맷터 */
const formatCurrency = (n) => `${(n ?? 0).toLocaleString('ko-KR')}원`

/** ✅ 총 페이지 */
const totalPages = computed(() =>
  months.value.length === 0
    ? 0
    : Math.ceil(months.value.length / pageSize.value)
)

/** ✅ 현재 페이지 데이터 */
const pagedMonths = computed(() => {
  const start = page.value * pageSize.value
  return months.value.slice(start, start + pageSize.value)
})

const fetchMonths = async () => {
  if (!beneficiaryId.value) {
    months.value = []
    page.value = 0
    return
  }

  loading.value = true
  try {
    const { data } = await api.get(
      `/api/beneficiaries/${beneficiaryId.value}/services`
    )

    months.value = data?.histories ?? []

    // ✅ 페이지 범위 보정
    if (page.value > 0 && page.value >= totalPages.value) {
      page.value = Math.max(totalPages.value - 1, 0)
    }
  } catch (e) {
    console.error(e)
    months.value = []
    page.value = 0
  } finally {
    loading.value = false
  }
}

const openTwo = (month) => {
  selectedMonth.value = month
  view.value = 'two'
}

const openThree = (serviceTypeId) => {
  selectedServiceTypeId.value = serviceTypeId
  view.value = 'three'
}

const goOne = () => {
  view.value = 'one'
  selectedMonth.value = ''
  selectedServiceTypeId.value = null
}

const goTwo = () => {
  view.value = 'two'
  selectedServiceTypeId.value = null
}

onMounted(fetchMonths)

// ✅ 수급자 변경 시: 초기화 + 페이지 리셋
watch(
  () => beneficiaryId.value,
  async () => {
    view.value = 'one'
    months.value = []
    selectedMonth.value = ''
    selectedServiceTypeId.value = null
    page.value = 0
    await fetchMonths()
  }
)
</script>

<style scoped>
.page-head {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}
.title {
  margin: 0;
  font-size: 14px;
  font-weight: 800;
}

.svc-card-list {
  list-style: none;
  margin: 0;
  padding: 0;
}

/* ✅ 문의이력처럼: 목록만 스크롤 */
.scroll-wrapper {
  max-height: 360px;
  overflow-y: auto;
  padding-right: 4px;
}

.svc-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  border-radius: 10px;
  background-color: #f9fafb;
  font-size: 12px;
  margin-bottom: 6px;
}

.clickable {
  cursor: pointer;
}
.clickable:hover {
  filter: brightness(0.98);
}

.svc-left {
  display: flex;
  align-items: center;
  gap: 8px;
}
.svc-right {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 11px;
}

.svc-name {
  font-weight: 600;
}
.svc-amount {
  font-weight: 800;
}
.svc-status {
  color: #6b7280;
}

.pill {
  border-radius: 999px;
  padding: 2px 8px;
  font-size: 11px;
}
.month-pill {
  background-color: #eef2ff;
  color: #4f46e5;
}

.empty {
  padding: 14px 10px;
  color: #6b7280;
  font-size: 12px;
}

/* ✅ 하단 중앙 페이징 */
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
}
.page-btn:hover {
  background: #e5e7eb;
}
.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
