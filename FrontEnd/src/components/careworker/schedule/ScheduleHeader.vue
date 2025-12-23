<script setup>
import { scheduleStats } from '@/mock/careworker/scheduleData';
</script>

<template>
  <div class="schedule-header">
    <div class="stat-item">
      <div class="stat-label">
        <span>오늘 일정</span>
        <span class="icon calendar">📅</span>
      </div>
      <div class="stat-value">{{ scheduleStats.todayCount }}건</div>
    </div>
    <div class="stat-item">
      <div class="stat-label">
        <span>이번주 근무일</span>
        <span class="icon user">👤</span>
      </div>
      <div class="stat-value">{{ scheduleStats.weeklyDays }}일</div>
    </div>
    <div class="stat-item">
      <div class="stat-label">
        <span>이번주 근무시간</span>
        <span class="icon clock">🕒</span>
      </div>
      <div class="stat-value">{{ scheduleStats.weeklyHours }}h</div>
    </div>
  </div>
</template>

<style scoped>
.schedule-header {
  display: flex;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.stat-item {
  flex: 1;
  background: white;
  padding: 1.25rem;
  border-radius: 0.75rem;
  border: 1px solid #f3f4f6;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
}

.stat-label {
  display: flex;
  justify-content: space-between;
  font-size: 0.875rem;
  color: #6b7280;
  margin-bottom: 0.5rem;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1f2937;
}

.icon { opacity: 0.6; }

@media (max-width: 640px) {
  .schedule-header { flex-direction: column; gap: 0.5rem; }
}
</style>