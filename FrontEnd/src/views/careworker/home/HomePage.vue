<script setup>
import DashboardHeader from '@/components/careworker/home/DashboardHeader.vue';
import SummaryStats from '@/components/careworker/home/SummaryStats.vue';
import TodoList from '@/components/careworker/home/TodoList.vue';
import ScheduleList from '@/components/careworker/home/ScheduleList.vue';
</script>

<template>
  <div class="home-page">
    <DashboardHeader />

    <div class="dashboard-box">
      <section class="section-row">
        <SummaryStats />
      </section>

      <section class="section-row">
        <TodoList />
      </section>

      <section class="section-row">
        <ScheduleList />
      </section>
    </div>
  </div>
</template>

<style scoped>
/* 페이지 전체 레이아웃 */
.home-page {
  padding: 0 24px 24px;
  background-color: transparent;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* 메인 컨텐츠 박스 */
.dashboard-box {
  background: #ffffff;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 4px 12px rgba(15, 23, 42, 0.05);
  padding: 24px;
  margin-top: 16px;
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 24px; /* 각 섹션 사이의 간격 (통계, 할일, 일정 사이) */
}

/* 내부 섹션 스타일 */
.section-row {
  width: 100%;
}

/* 반응형 처리 */
@media (max-width: 768px) {
  .home-page {
    padding: 16px;
  }

  .dashboard-box {
    padding: 16px;
  }
}
</style>