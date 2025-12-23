<template>
  <div class="matching-page">
    <div class="top-area">
      <!-- 왼쪽 : 수급자 / 요양보호사 리스트 -->
      <div class="left-column">
        <div class="list-panel">
          <!-- 수급자 선택 -->
          <RecipientMatchingList
            @select-recipient="onSelectRecipient"
          />
        </div>

        <div class="list-panel">
          <!-- 요양보호사 선택 -->
          <CaregiverMatchingList
            @select-caregiver="onSelectCaregiver"
          />
        </div>
      </div>

      <!-- 오른쪽 : 상세 + 주간 일정 -->
      <div class="right-column">
        <!-- 상단 상세 2개 -->
        <div class="detail-row">
          <div class="detail-panel">
            <RecipientDetailPanel
              :recipient="selectedRecipient"
              @remove-caregiver="onRemoveCaregiver"
            />
          </div>

          <div class="detail-panel">
            <CaregiverDetailPanel
              :caregiver="selectedCaregiver"
              @remove-recipient="onRemoveRecipient"
            />
          </div>
        </div>

        <!-- 하단 주간 일정 -->
        <div class="weekly-panel">
          <!-- 🔥 선택된 수급자/요양보호사를 내려준다 -->
          <ScheduleWeeklyPanel
            :recipient="selectedRecipient"
            :caregiver="selectedCaregiver"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

import RecipientMatchingList from '@/components/schedule/matching/RecipientMatchingList.vue'
import CaregiverMatchingList from '@/components/schedule/matching/CaregiverMatchingList.vue'

import RecipientDetailPanel from '@/components/schedule/matching/recipientDetail/RecipientDetailPanel.vue'
import CaregiverDetailPanel from '@/components/schedule/matching/caregiverDetail/CaregiverDetailPanel.vue'

import ScheduleWeeklyPanel from '@/components/schedule/matching/scheduleWeekly/ScheduleWeeklyPanel.vue'

const selectedRecipient = ref(null)
const selectedCaregiver = ref(null)

// 수급자 선택 시
const onSelectRecipient = (recipient) => {
  selectedRecipient.value = recipient
  // 필요하면 요양보호사 선택 해제
  // selectedCaregiver.value = null
}

// 요양보호사 선택 시
const onSelectCaregiver = (caregiver) => {
  selectedCaregiver.value = caregiver
  // 필요하면 수급자 선택 해제
  // selectedRecipient.value = null
}

// 나중에 매칭 해제 기능 붙일 때 사용할 핸들러
const onRemoveCaregiver = (cg) => {
  console.log('수급자에서 요양보호사 매칭 해제', cg)
}

const onRemoveRecipient = (rcp) => {
  console.log('요양보호사에서 수급자 매칭 해제', rcp)
}
</script>

<style scoped>
.matching-page {
  padding: 24px 32px 32px;
  box-sizing: border-box;
}

/* 상단 전체 2열 레이아웃 */
.top-area {
  display: flex;
  gap: 24px;
  align-items: flex-start;
}

/* 왼쪽: 리스트 두 개 (위/아래 50%씩) */
.left-column {
  flex: 0 0 36%;
  display: flex;
  flex-direction: column;
  gap: 20px;
  min-height: 0;
}

.list-panel {
  flex: 1;
  overflow: hidden;
}

/* 오른쪽: 상세 + 주간 일정 */
.right-column {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* 상세 두 개 나란히 */
.detail-row {
  display: flex;
  gap: 20px;
}

.detail-panel {
  flex: 1;
}

/* 주간 일정 영역 */
.weekly-panel {
  flex: 1;
  min-height: 260px;
}
</style>