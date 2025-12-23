<!-- views/careworker/workschedule/WorkschedulePage.vue -->

<script setup>
import { ref } from 'vue';
import SimpleHeader from '@/components/common/SimpleHeader.vue';
import ScheduleHeader from '@/components/careworker/schedule/ScheduleHeader.vue';
import CalendarView from '@/components/careworker/schedule/CalendarView.vue'; // 일간
import WeekView from '@/components/careworker/schedule/WeekView.vue';         // 주간
import MonthView from '@/components/careworker/schedule/MonthView.vue';       // 월간
import ScheduleDetail from '@/components/careworker/schedule/ScheduleDetail2.vue';

// 선택된 일정 객체 (null이면 placeholder 표시)
const selectedSchedule = ref(null);

// 현재 뷰 상태 ('day', 'week', 'month')
const currentView = ref('day');

// 일정 클릭 시 실행되는 함수 (상세 정보 표시)
const onSelectSchedule = (schedule) => {
  selectedSchedule.value = schedule;
};

// 상세 패널 닫기 버튼 클릭 시
const onCloseDetail = () => {
  selectedSchedule.value = null;
};

// 캘린더 뷰 변경 핸들러 (자식 컴포넌트에서 emit 받음)
const onViewChange = (viewType) => {
  currentView.value = viewType;
};
</script>

<template>
  <div class="workschedule">
    <SimpleHeader
      title="근무 일정"
      subtitle="나의 근무 일정을 확인합니다"
    />

    <div class="main-content">
      <ScheduleHeader />

      <div class="content-container">
        <div class="calendar-area" :class="{ 'has-detail': selectedSchedule }">
          <MonthView
            v-if="currentView === 'month'"
            @select-schedule="onSelectSchedule"
            @view-change="onViewChange"
          />

          <WeekView
            v-else-if="currentView === 'week'"
            @select-schedule="onSelectSchedule"
            @view-change="onViewChange"
          />

          <CalendarView
            v-else
            @select-schedule="onSelectSchedule"
            @view-change="onViewChange"
          />
        </div>

        <!-- 슬라이드 패널 -->
        <Transition name="slide">
          <div v-if="selectedSchedule" class="detail-panel">
            <ScheduleDetail
              :schedule="selectedSchedule"
              @close="onCloseDetail"
            />
          </div>
        </Transition>
      </div>
    </div>
  </div>
</template>

<style scoped>
.workschedule {
  background-color: #f8fafc;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.main-content {
  flex: 1;
  max-width: 1200px; /* 홈과 동일한 너비 */
  margin: 0 auto;
  width: 100%;
  padding: 1.5rem;
  overflow: hidden; /* 슬라이드 패널이 넘치지 않도록 */
}

.content-container {
  position: relative;
  height: 800px;
  margin-top: 1rem;
  display: flex;
  gap: 0;
}

.calendar-area {
  width: 100%; /* 기본적으로 전체 너비 */
  height: 100%;
  transition: width 0.3s ease-in-out;
}

/* 상세 패널이 열렸을 때 달력 영역 축소 */
.calendar-area.has-detail {
  width: calc(100% - 500px); /* 패널 너비만큼 축소 */
}

.detail-panel {
  position: absolute;
  right: 0;
  top: 0;
  width: 480px; /* 상세 패널 너비 증가 */
  height: 100%;
  background-color: white;
  box-shadow: -4px 0 12px rgba(0, 0, 0, 0.1);
  z-index: 10;
  overflow-y: auto;
}

/* 슬라이드 애니메이션 */
.slide-enter-active,
.slide-leave-active {
  transition: transform 0.3s ease-in-out;
}

.slide-enter-from {
  transform: translateX(100%);
}

.slide-leave-to {
  transform: translateX(100%);
}

.slide-enter-to,
.slide-leave-from {
  transform: translateX(0);
}

/* 반응형 처리: 태블릿 이하에서는 전체 화면 오버레이 */
@media (max-width: 1024px) {
  .content-container {
    height: auto;
    min-height: 600px;
  }

  .calendar-area {
    width: 100% !important; /* 모바일에서는 항상 전체 너비 */
  }

  .detail-panel {
    position: fixed;
    left: 0;
    right: 0;
    top: 0;
    bottom: 0;
    width: 100%;
    height: 100vh;
    z-index: 1000;
  }

  /* 모바일 슬라이드 애니메이션 - 아래에서 위로 */
  .slide-enter-from {
    transform: translateY(100%);
  }

  .slide-leave-to {
    transform: translateY(100%);
  }
}
</style>