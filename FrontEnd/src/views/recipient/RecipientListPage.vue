<!-- src/views/RecipientListPage.vue -->
<template>
  <div class="page-body">
    <!-- 왼쪽: 수급자 목록 -->
    <section class="left-panel">
      <!-- ref 반드시 필요 -->
      <RecipientList
        ref="listRef"
        v-model:selected-id="selectedId"
      />
    </section>

    <!-- 오른쪽 -->
    <section class="right-panel">
      <div v-if="!selectedId" class="placeholder-card">
        <div class="placeholder-icon">👤</div>
        <p class="placeholder-text">좌측 목록에서 수급자를 선택해주세요</p>
      </div>

      <template v-else>
        <!-- updated(수급자 정보 수정) 이벤트 받기 -->
        <RecipientInformation
          :beneficiary-id="selectedId"
          @updated="handleUpdated"
        />

        <RecipientCategory
          :beneficiary-id="selectedId"
          :refresh-key="refreshKey"
          :monthly-summary-list="monthlySummaryCards"
        />
      </template>
    </section>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import api from '@/lib/api'

import RecipientList from '@/components/recipient/main/RecipientList.vue'
import RecipientInformation from '@/components/recipient/main/RecipientInformation.vue'
import RecipientCategory from '@/components/recipient/main/RecipientCategory.vue'

const selectedId = ref(null)
const listRef = ref(null) // 모든 탭에게 "수급자 변경됨" 신호
const refreshKey = ref(0)  // 모든 탭들이 수급자 정보가 수정되면 새로고침 없이 자동으로 수정

/** ✅ 월 카드(요양일지 있는 월만) */
const monthlySummaryCards = ref([])

/** ✅ 카드 기본 문구(요약 전) */
const DEFAULT_MONTH_TEXT = '해당 월의 경향을 한눈에 보려면 AI요약 버튼을 클릭하세요!'

const handleUpdated = async () => {
  // 좌측 목록(수급자 전체조회) 즉시 갱신
  listRef.value?.refresh()

  // 모든 탭에게 "수급자 변경됨" 신호
  refreshKey.value++

  // (선택) 수급자 정보 수정이 요양일지에는 영향 없을 가능성이 높지만,
  // 혹시 몰라 월카드도 새로 생성
  await fetchMonthlyCards()
}

/**
 * ✅ 수급자 선택되면:
 * 1) 요양일지 전체 조회(월 파라미터 없이)
 * 2) serviceDate로 월(YYYY-MM) 뽑아서 월카드 생성
 */
const fetchMonthlyCards = async () => {
  if (!selectedId.value) {
    monthlySummaryCards.value = []
    return
  }

  try {
    const { data } = await api.get(`/api/beneficiaries/${selectedId.value}/care-logs`)
    const list = Array.isArray(data) ? data : []

    const monthsSet = new Set()
    for (const row of list) {
      const sd = String(row?.serviceDate || '')
      if (sd.length >= 7) monthsSet.add(sd.slice(0, 7)) // 'YYYY-MM'
    }

    // 최신 월이 위로 오도록 내림차순
    const months = Array.from(monthsSet).sort((a, b) => (a < b ? 1 : -1))

    monthlySummaryCards.value = months.map((m) => ({
      month: m,
      text: DEFAULT_MONTH_TEXT
    }))
  } catch (e) {
    console.error('[fetchMonthlyCards] failed:', e)
    monthlySummaryCards.value = []
  }
}

/** ✅ 수급자 바뀔 때마다 월카드 생성 */
watch(
  () => selectedId.value,
  async () => {
    await fetchMonthlyCards()
  }
)
</script>

<style scoped>
.page-body {
  display: grid;
  grid-template-columns: 500px minmax(0, 1fr);
  gap: 16px;
  margin-top: 12px;
}
.left-panel,
.right-panel {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.placeholder-card {
  min-height: 260px;
  border-radius: 16px;
  border: 1px solid #e5e7eb;
  background: #f9fafb;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
.placeholder-icon {
  font-size: 40px;
  margin-bottom: 10px;
  color: #9ca3af;
}
.placeholder-text {
  margin: 0;
  font-size: 14px;
  color: #6b7280;
}
@media (max-width: 960px) {
  .page-body {
    grid-template-columns: 1fr;
  }
}
</style>
