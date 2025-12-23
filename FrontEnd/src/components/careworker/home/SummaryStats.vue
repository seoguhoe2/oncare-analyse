<script setup>
import { summaryStats } from '@/mock/careworker/homeData';
</script>

<template>
  <section class="stats-container">
    <div v-for="(stat, index) in summaryStats" :key="index" :class="['stat-card', stat.colorClass]">
      <div class="stat-info">
        <p class="label">{{ stat.label }}</p>
        <p class="value">
          {{ stat.value }}
          <span v-if="stat.icon" class="stat-icon">👤</span> </p>
      </div>
      <div v-if="index === 0" class="card-icon">📅</div> <div v-if="index === 1" class="card-icon">👤</div>
      <div v-if="index === 2" class="card-icon">🕒</div>
    </div>
  </section>
</template>

<style scoped>
.stats-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); /* 반응형 그리드 */
  gap: 1rem;
  margin-top: 1rem;
}

.stat-card {
  background-color: #f9fafb; /* 연한 회색 배경 */
  padding: 1.25rem;
  border-radius: 0.5rem;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  position: relative;
  overflow: hidden;
}

/* 상단 테두리 색상 */
.green-border { border-top: 4px solid #4ade80; background-color: #f0fdf4; }
.blue-border { border-top: 4px solid #3b82f6; background-color: #eff6ff; }
.purple-border { border-top: 4px solid #a855f7; background-color: #faf5ff; }

.stat-info {
  display: flex;
  flex-direction: column;
  z-index: 1;
}

.label {
  font-size: 0.875rem;
  font-weight: 600;
  color: #4b5563; /* 조금 진한 회색 */
  margin-bottom: 0.5rem;
}

.value {
  font-size: 1.5rem;
  font-weight: 800;
  color: #111827; /* 검정색에 가까운 */
}

.card-icon {
  font-size: 1.5rem;
  opacity: 0.5;
}
</style>