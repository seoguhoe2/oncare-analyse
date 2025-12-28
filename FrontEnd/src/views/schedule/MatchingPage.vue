<template>
  <div class="matching-page">
    <div class="top-area">
      <!-- 왼쪽 : 수급자 / 요양보호사 리스트 -->
      <div class="left-column">
        <div class="list-panel">
          <RecipientMatchingList @select-recipient="onSelectRecipient" />
        </div>

        <div class="list-panel">
          <CaregiverMatchingList
            :recipient="selectedRecipient"
            @select-caregiver="onSelectCaregiver"
          />
        </div>
      </div>

      <!-- 오른쪽 : 상세 + 주간 일정 -->
      <div class="right-column">
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

        <div class="weekly-panel">
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

  import { useMatchingSelectionStore } from '@/stores/matchingSelection.js'
  
  const store = useMatchingSelectionStore()
  
  const selectedRecipient = ref(null)
  const selectedCaregiver = ref(null)
  
  const onSelectRecipient = (recipient) => {
    selectedRecipient.value = recipient
    selectedCaregiver.value = null
    store.setRecipient(recipient)
  }
  
  const onSelectCaregiver = (caregiver) => {
    selectedCaregiver.value = caregiver
    store.setCaregiver(caregiver)
  }
  
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
  position: relative;
}

.top-area {
  display: flex;
  gap: 24px;
  align-items: flex-start;

  position: relative;
  z-index: 0;
  min-height: 0;
}

.left-column {
  flex: 0 0 36%;
  display: flex;
  flex-direction: column;
  gap: 20px;
  min-height: 0;

  position: relative;
  z-index: 10;
  pointer-events: auto;
}

.list-panel {
  flex: 1;
  overflow: hidden;

  position: relative;
  z-index: 11;
  pointer-events: auto;
}

.right-column {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 20px;

  position: relative;
  z-index: 1;
  min-height: 0;
}

.detail-row {
  display: flex;
  gap: 20px;

  position: relative;
  z-index: 1;
}

.detail-panel {
  flex: 1;
  position: relative;
  z-index: 1;
}

.weekly-panel {
  flex: 1;
  min-height: 260px;

  position: relative;
  z-index: 1;
  pointer-events: auto;
}
</style>