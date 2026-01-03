<template>
  <section class="weekly-schedule">
    <header class="header">
      <h2>주간 일정</h2>
    </header>

    <ScheduleWeeklyPlaceholder v-if="!hasTarget" />

    <ScheduleWeeklySelected
      v-else
      :key="weeklyKey"
      :recipient="recipient"
      :caregiver="caregiver"
      :refresh-key="refreshKey"
    />
  </section>
</template>

<script setup>
import { computed } from 'vue'
import ScheduleWeeklyPlaceholder from './ScheduleWeeklyPlaceholder.vue'
import ScheduleWeeklySelected from './ScheduleWeeklySelected.vue'

const props = defineProps({
  recipient: { type: Object, default: null },
  caregiver: { type: Object, default: null },
  refreshKey: { type: Number, default: 0 },
})

const hasTarget = computed(() => !!(props.recipient || props.caregiver))

const getRecipientId = (r) => r?.beneficiaryId ?? r?.id ?? 'none'
const getCaregiverId = (c) => c?.careWorkerId ?? c?.id ?? 'none'

const weeklyKey = computed(() => {
  return `weekly-${getRecipientId(props.recipient)}-${getCaregiverId(props.caregiver)}-${props.refreshKey}`
})
</script>


<style scoped>
.weekly-schedule {
  background: #ffffff;
  border-radius: 16px;
  border: 1px solid #e5e7eb;
  padding: 24px 32px;
  min-height: 340px;

  display: flex;
  flex-direction: column;
  gap: 20px;
}

.header h2 {
  margin: 0;
  font-size: 20px;
  font-weight: 700;
  color: #166534;
}
</style>