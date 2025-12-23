<template>
  <div class="page-body">
    <!-- 왼쪽: 수급자 목록 -->
    <section class="left-panel">
      <RecipientList
        :recipients="recipients"
        v-model:selected-id="selectedId"
      />
    </section>

    <!-- 오른쪽: 안내 또는 상세 정보 -->
    <section class="right-panel">
      <!-- ❌ 아직 선택 안 됐을 때: 안내 카드 -->
      <div v-if="!selectedRecipient" class="placeholder-card">
        <div class="placeholder-icon">👤</div>
        <p class="placeholder-text">좌측 목록에서 수급자를 선택해주세요</p>
      </div>

      <!-- ✅ 선택된 수급자가 있을 때: 정보 + 탭 -->
      <template v-else>
        <RecipientInformation :recipient="selectedRecipient" />

        <RecipientCategory
          :recipient="selectedRecipient"
          :service-history="filteredServiceHistory"
          :rental-items="filteredRentalItems"
        />
      </template>
    </section>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

import RecipientList from '@/components/recipient/main/RecipientList.vue'
import RecipientInformation from '@/components/recipient/main/RecipientInformation.vue'
import RecipientCategory from '@/components/recipient/main/RecipientCategory.vue'

import { recipientsMock } from '@/mock/recipient/recipientMock'
import { serviceHistoryMock } from '@/mock/recipient/serviceHistoryMock'
import { rentalItemsMock } from '@/mock/recipient/rentalItemsMock'

const recipients = ref(recipientsMock)
const serviceHistory = ref(serviceHistoryMock)
const rentalItems = ref(rentalItemsMock)

// ✅ 처음에는 아무도 선택 안 함
const selectedId = ref(null)

const selectedRecipient = computed(
  () => recipients.value.find((r) => r.id === selectedId.value) || null
)

/**
 * 🔥 선택한 수급자 기준으로 서비스 이력 필터링
 *  - serviceHistoryMock 안에 들어있는 "수급자 식별자" 필드명에 맞춰서
 *    recipientId 부분만 바꿔주면 됨.
 */
const filteredServiceHistory = computed(() => {
  if (!selectedId.value) return []
  return serviceHistory.value.filter(
    (h) => h.recipientId === selectedId.value // 👈 필드명 맞게 변경
  )
})

/**
 * 🔥 선택한 수급자 기준으로 렌탈 이력 필터링
 *  - 마찬가지로 rentalItemsMock 에 있는 수급자 FK 필드명으로 수정
 */
const filteredRentalItems = computed(() => {
  if (!selectedId.value) return []
  return rentalItems.value.filter(
    (r) => r.recipientId === selectedId.value // 👈 필드명 맞게 변경
  )
})
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

/* 오른쪽 안내 카드 */
.placeholder-card {
  width: 100%;
  height: 100%;
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
