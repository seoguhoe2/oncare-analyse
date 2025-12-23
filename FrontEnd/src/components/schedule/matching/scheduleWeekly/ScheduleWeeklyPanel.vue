<!-- src/components/schedule/matching/scheduleWeekly/ScheduleWeeklyPanel.vue -->
<template>
    <section class="weekly-schedule">
      <header class="header">
        <h2>주간 일정</h2>
      </header>
  
      <!-- 아무도 선택 안 됐을 때 -->
      <ScheduleWeeklyPlaceholder v-if="!hasTarget" />
  
      <!-- 수급자 또는 요양보호사 중 하나라도 선택됐을 때 -->
      <ScheduleWeeklySelected
        v-else
        :recipient="recipient"
        :caregiver="caregiver"
      />
    </section>
  </template>
  
  <script setup>
  import { computed } from 'vue'
  import ScheduleWeeklyPlaceholder from './ScheduleWeeklyPlaceholder.vue'
  import ScheduleWeeklySelected from './ScheduleWeeklySelected.vue'
  
  const props = defineProps({
    // 선택된 수급자
    recipient: {
      type: Object,
      default: null,
    },
    // 선택된 요양보호사
    caregiver: {
      type: Object,
      default: null,
    },
  })
  
  // 둘 중 하나라도 있으면 true
  const hasTarget = computed(() => !!(props.recipient || props.caregiver))
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