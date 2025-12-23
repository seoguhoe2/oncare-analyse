<script setup>
import DashboardHeader from '@/components/careworker/home/DashboardHeader.vue';
import SummaryStats from '@/components/careworker/home/SummaryStats.vue';
import AlertBox from '@/components/careworker/home/AlertBox.vue';
import TodoList from '@/components/careworker/home/TodoList.vue';
import ScheduleList from '@/components/careworker/home/ScheduleList.vue';
import QuickMenu from '@/components/careworker/home/QuickMenu.vue';
</script>

<template>
  <div class="home-container">
    <DashboardHeader />

    <main class="main-content">
      <SummaryStats />

      <AlertBox />

      <TodoList />

      <ScheduleList />
    </main>
    
    </div>
</template>

<style scoped>
.home-container {
  background-color: #f8fafc; /* 전체 배경색 (아주 연한 회색) */
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.main-content {
  flex: 1;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
  padding: 1.5rem;
  padding-bottom: 5rem; /* 하단 퀵메뉴 공간 확보 (사용 시) */
}

@media (max-width: 768px) {
  .main-content {
    padding: 1rem;
  }
}
</style>