<script setup>
import { ref, onMounted } from 'vue';
import { getDashboardSummary } from '@/api/careworker';

// 초기 표시 값
const summaryStats = ref([
  { label: '오늘 일정', value: '0건', colorClass: 'green-border' },
  { label: '담당 수급자', value: '0명', colorClass: 'blue-border' },
  { label: '월간 근무시간', value: '0h', colorClass: 'purple-border' },
]);

onMounted(async () => {
  try {
    const response = await getDashboardSummary();
    // 백엔드 ApiResponse<{data}> 형태와 순수 데이터 반환을 모두 대응
    const data = response?.data?.data ?? response?.data ?? response;

    console.log('📊 일정관리 통계 - 백엔드 응답:', response);
    console.log('📊 일정관리 통계 - 파싱된 data:', data);

    summaryStats.value = [
      {
        label: '오늘 일정',
        value: `${data?.todayScheduleCount ?? 0}건`,
        colorClass: 'green-border',
      },
      {
        label: '담당 수급자',
        value: `${data?.beneficiaryCount ?? 0}명`,
        colorClass: 'blue-border',
      },
      {
        label: '월간 근무시간',
        value: `${data?.weeklyWorkHours ?? data?.monthlyWorkHours ?? data?.workHours ?? 0}h`,
        colorClass: 'purple-border',
      },
    ];
  } catch (error) {
    console.error('❌ 대시보드 요약 정보 불러오기 실패:', error);
  }
});
</script>

<template>
  <section class="schedule-header">
    <div
      v-for="(stat, index) in summaryStats"
      :key="index"
      :class="['stat-card', stat.colorClass]"
    >
      <div class="stat-info">
        <p class="label">{{ stat.label }}</p>
        <p class="value">{{ stat.value }}</p>
      </div>
    </div>
  </section>
</template>

<style scoped>
.schedule-header {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.stat-card {
  background-color: #f9fafb;
  padding: 1.25rem;
  border-radius: 0.5rem;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  position: relative;
  overflow: hidden;
}

.green-border { border-top: 4px solid #4ade80; background-color: #f0fdf4; }
.blue-border { border-top: 4px solid #3b82f6; background-color: #eff6ff; }
.purple-border { border-top: 4px solid #a855f7; background-color: #faf5ff; }

.stat-info { display: flex; flex-direction: column; z-index: 1; }
.label { font-size: 0.875rem; font-weight: 600; color: #4b5563; margin-bottom: 0.5rem; }
.value { font-size: 1.5rem; font-weight: 800; color: #111827; display: flex; align-items: center; gap: 0.35rem; }

@media (max-width: 640px) {
  .schedule-header { grid-template-columns: 1fr; }
}
</style>