<template>
  <div class="matching-page">
    <div class="top-area">
      <div class="left-column">
        <div class="list-panel">
          <RecipientMatchingList
            :refresh-key="store.refreshTick"
            @select-recipient="onSelectRecipient"
          />
        </div>

        <div class="list-panel">
          <CaregiverMatchingList
            :recipient="store.recipient"
            :refresh-key="store.refreshTick"
            @select-caregiver="onSelectCaregiver"
          />
        </div>
      </div>

      <div class="right-column">
        <div class="detail-row">
          <div class="detail-panel">
            <RecipientDetailPanel
              :recipient="store.recipient"
              :refresh-key="store.refreshTick"
              @unassigned="onUnassigned"
              @assigned-careworker="onAssignedCareworker"
            />
          </div>

          <div class="detail-panel">
            <CaregiverDetailPanel
              :caregiver="store.caregiver"
              :refresh-key="store.refreshTick"
              @remove-recipient="onRemoveRecipient"
            />
          </div>
        </div>

        <div class="weekly-panel">
          <ScheduleWeeklyPanel
            :recipient="store.recipient"
            :caregiver="store.caregiver"
            :refresh-key="store.refreshTick"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import RecipientMatchingList from '@/components/schedule/matching/RecipientMatchingList.vue'
import CaregiverMatchingList from '@/components/schedule/matching/CaregiverMatchingList.vue'

import RecipientDetailPanel from '@/components/schedule/matching/recipientDetail/RecipientDetailPanel.vue'
import CaregiverDetailPanel from '@/components/schedule/matching/caregiverDetail/CaregiverDetailPanel.vue'

import ScheduleWeeklyPanel from '@/components/schedule/matching/scheduleWeekly/ScheduleWeeklyPanel.vue'

import { useMatchingSelectionStore } from '@/stores/matchingSelection.js'

const store = useMatchingSelectionStore()

const getRecipientId = (r) => r?.beneficiaryId ?? r?.id ?? null
const getCaregiverId = (c) => c?.careWorkerId ?? c?.id ?? null

const onSelectRecipient = (recipient) => {
  const nextId = getRecipientId(recipient)
  if (!nextId) return
  if (nextId === store.recipientId) {
    store.syncRecipient(recipient)
    return
  }
  store.setRecipient(recipient)
}

const onSelectCaregiver = (caregiver) => {
  const nextId = getCaregiverId(caregiver)
  if (!nextId) return
  if (nextId === store.caregiverId) {
    store.syncCaregiver(caregiver)
    return
  }
  store.setCaregiver(caregiver)
}

const onRemoveRecipient = (rcp) => {
  console.log('요양보호사에서 수급자 매칭 해제', rcp)
}

const onAssignedCareworker = (cw) => {
  if (!cw) return
  store.setCaregiver(cw)
}

const onUnassigned = () => {
  store.setCaregiver(null)
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