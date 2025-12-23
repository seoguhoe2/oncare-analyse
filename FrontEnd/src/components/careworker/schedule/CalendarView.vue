<!-- components/schedule/CalendarView.vue -->

<script setup>
import { ref, defineEmits } from 'vue';
import { scheduleList } from '@/mock/careworker/scheduleData';

// 부모에게 보낼 이벤트 정의 (일정 선택, 뷰 모드 변경)
const emit = defineEmits(['select-schedule', 'view-change']);

const currentView = ref('day'); // 현재 뷰 상태 (사실상 'day'로 고정됨, 버튼 클릭 시 부모가 뷰를 교체)
const currentDate = ref('2025년 12월 11일 목');
const timeSlots = Array.from({ length: 12 }, (_, i) => i + 7); // 7시 ~ 18시

// 일정 클릭 시 상세 정보창 열기
const handleSelect = (schedule) => {
  emit('select-schedule', schedule);
};

// 뷰 변경 버튼 클릭 시 부모에게 알림 (week, month 등으로 변경 요청)
const changeView = (viewType) => {
  emit('view-change', viewType);
};

// 시간 문자열(10:00)을 그리드 위치(top, height)로 변환하는 함수
const getPositionStyle = (start, end) => {
  const startHour = parseInt(start.split(':')[0]);
  const startMin = parseInt(start.split(':')[1]);
  const endHour = parseInt(end.split(':')[0]);
  const endMin = parseInt(end.split(':')[1]);

  // 7시가 시작점(0), 1시간당 60px 높이
  const top = ((startHour - 7) * 60) + startMin;
  const height = ((endHour - startHour) * 60) + (endMin - startMin);
  
  return {
    top: `${top}px`,
    height: `${height}px`
  };
};
</script>

<template>
  <div class="calendar-container">
    <div class="calendar-controls">
      <div class="view-toggles">
        <button class="active">일간</button>
        <button @click="changeView('week')">주간</button>
        <button @click="changeView('month')">월간</button>
      </div>
      
      <div class="date-navigator">
        <button class="nav-btn">&lt;</button>
        <span class="current-date">{{ currentDate }}</span>
        <button class="nav-btn">&gt;</button>
      </div>

      <div class="right-actions">
        <button class="today-btn">오늘</button>
        <button class="add-btn">+ 일정등록</button>
      </div>
    </div>

    <div class="day-view-body">
      <div class="time-axis">
        <div v-for="hour in timeSlots" :key="hour" class="time-slot">
          {{ hour }}:00
        </div>
      </div>

      <div class="schedule-grid">
        <div class="grid-lines">
          <div v-for="hour in timeSlots" :key="hour" class="grid-line"></div>
        </div>

        <div v-for="item in scheduleList" :key="item.id" 
             class="schedule-block"
             :style="getPositionStyle(item.startTime, item.endTime)"
             @click="handleSelect(item)">
          <div class="block-content">
            <div class="block-time">🕒 {{ item.startTime }} - {{ item.endTime }}</div>
            <div class="block-title">{{ item.recipient }}</div>
            <div class="block-sub">{{ item.serviceType }}</div>
            <div class="block-loc">📍 {{ item.address.split(' ')[1] }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.calendar-container {
  background: white;
  border-radius: 0.75rem;
  padding: 1.5rem;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  height: 100%;
  display: flex;
  flex-direction: column;
}

/* 컨트롤 바 */
.calendar-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.view-toggles button {
  padding: 0.5rem 1rem;
  border: 1px solid #e5e7eb;
  background: white;
  color: #6b7280;
  cursor: pointer;
  font-weight: 600;
}
.view-toggles button:first-child { border-top-left-radius: 0.5rem; border-bottom-left-radius: 0.5rem; }
.view-toggles button:last-child { border-top-right-radius: 0.5rem; border-bottom-right-radius: 0.5rem; }
.view-toggles button.active { background-color: #4ade80; color: white; border-color: #4ade80; }

.date-navigator { display: flex; align-items: center; gap: 1rem; font-weight: 700; color: #374151; font-size: 1.1rem; }
.nav-btn { background: none; border: none; cursor: pointer; font-size: 1.2rem; color: #6b7280; }

.right-actions { display: flex; gap: 0.5rem; }
.today-btn { padding: 0.5rem 1rem; border: 1px solid #e5e7eb; border-radius: 0.5rem; background: #f9fafb; cursor: pointer; font-weight: 600; color: #4b5563; }
.add-btn { padding: 0.5rem 1rem; background-color: #4ade80; color: white; border: none; border-radius: 0.5rem; font-weight: 700; cursor: pointer; }

/* 캘린더 바디 (스크롤 가능 영역) */
.day-view-body { display: flex; flex: 1; overflow-y: auto; min-height: 600px; border-top: 1px solid #f3f4f6; }
.time-axis { width: 60px; border-right: 1px solid #f3f4f6; background-color: #fff; }
.time-slot { height: 60px; font-size: 0.75rem; color: #9ca3af; text-align: right; padding-right: 10px; transform: translateY(-8px); }

.schedule-grid { flex: 1; position: relative; margin-left: 10px; }
.grid-lines { position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; }
.grid-line { height: 60px; border-top: 1px solid #f3f4f6; box-sizing: border-box; }

.schedule-block {
  position: absolute;
  left: 0;
  width: 95%;
  background-color: #fef9c3; /* 연한 노랑 */
  border-left: 4px solid #eab308; /* 진한 노랑 */
  border-radius: 4px;
  padding: 0.5rem;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  overflow: hidden;
  z-index: 10;
}
.schedule-block:hover { transform: scale(1.01); box-shadow: 0 4px 6px rgba(0,0,0,0.1); z-index: 20; }

.block-time { font-size: 0.75rem; color: #854d0e; margin-bottom: 2px; }
.block-title { font-weight: 700; color: #713f12; margin-bottom: 2px; }
.block-sub { font-size: 0.8rem; color: #854d0e; margin-bottom: 4px; }
.block-loc { font-size: 0.75rem; color: #a16207; }
</style>