<!-- components/schedule/WeekView.vue -->

<script setup>
import { ref, computed, defineEmits } from 'vue';
import { scheduleList } from '@/mock/careworker/scheduleData';

const emit = defineEmits(['select-schedule', 'view-change']);

const currentDate = ref(new Date('2025-12-11')); // 기준 날짜
const timeSlots = Array.from({ length: 12 }, (_, i) => i + 7); // 07:00 ~ 18:00

// 이번 주 날짜 7개 구하기 (일~토)
const weekDates = computed(() => {
  const dates = [];
  const curr = new Date(currentDate.value);
  const day = curr.getDay(); // 0(일) ~ 6(토)
  
  // 이번 주 일요일 구하기
  const firstDay = new Date(curr.setDate(curr.getDate() - day));

  for (let i = 0; i < 7; i++) {
    const next = new Date(firstDay);
    next.setDate(firstDay.getDate() + i);
    dates.push(next);
  }
  return dates;
});

// 날짜 포맷 (YYYY-MM-DD) - 비교용
const formatDateKey = (date) => {
  return date.toISOString().split('T')[0];
};

// 화면 표시용 날짜 (12월 2째주)
const displayWeek = computed(() => {
  const d = currentDate.value;
  return `${d.getFullYear()}년 ${d.getMonth() + 1}월`; 
});

// 해당 날짜의 일정 필터링
const getSchedulesForDate = (date) => {
  const dateKey = formatDateKey(date);
  return scheduleList.filter(item => item.date === dateKey);
};

// 위치 계산 (일간 뷰와 동일)
const getPositionStyle = (start, end) => {
  const startHour = parseInt(start.split(':')[0]);
  const startMin = parseInt(start.split(':')[1]);
  const endHour = parseInt(end.split(':')[0]);
  const endMin = parseInt(end.split(':')[1]);

  const top = ((startHour - 7) * 60) + startMin;
  const height = ((endHour - startHour) * 60) + (endMin - startMin);
  
  return { top: `${top}px`, height: `${height}px` };
};

// 요일 이름
const weekNames = ['일', '월', '화', '수', '목', '금', '토'];
</script>

<template>
  <div class="calendar-container">
    <div class="calendar-controls">
      <div class="view-toggles">
        <button @click="emit('view-change', 'day')">일간</button>
        <button class="active">주간</button>
        <button @click="emit('view-change', 'month')">월간</button>
      </div>
      
      <div class="date-navigator">
        <button class="nav-btn">&lt;</button>
        <span class="current-date">{{ displayWeek }}</span>
        <button class="nav-btn">&gt;</button>
      </div>

      <div class="right-actions">
        <button class="today-btn">오늘</button>
        <button class="add-btn">+ 일정등록</button>
      </div>
    </div>

    <div class="week-view-body">
      <div class="time-axis">
        <div v-for="hour in timeSlots" :key="hour" class="time-slot">{{ hour }}:00</div>
      </div>

      <div class="week-columns">
        <div v-for="(date, idx) in weekDates" :key="idx" class="day-column">
          <div class="column-header">
            <span class="day-name">{{ weekNames[idx] }}</span>
            <span class="day-num" :class="{ 'today': false }">{{ date.getDate() }}</span>
          </div>

          <div class="column-content">
            <div class="grid-lines">
              <div v-for="hour in timeSlots" :key="hour" class="grid-line"></div>
            </div>

            <div v-for="item in getSchedulesForDate(date)" :key="item.id"
                 class="schedule-block"
                 :class="item.colorClass"
                 :style="getPositionStyle(item.startTime, item.endTime)"
                 @click="emit('select-schedule', item)">
              <div class="block-title">{{ item.recipient }}</div>
              <div class="block-time">{{ item.startTime }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.calendar-container { background: white; border-radius: 0.75rem; padding: 1.5rem; height: 100%; display: flex; flex-direction: column; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }

/* 컨트롤 바 (공통) */
.calendar-controls { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
.view-toggles button { padding: 0.5rem 1rem; border: 1px solid #e5e7eb; background: white; color: #6b7280; cursor: pointer; }
.view-toggles button:first-child { border-top-left-radius: 0.5rem; border-bottom-left-radius: 0.5rem; }
.view-toggles button:last-child { border-top-right-radius: 0.5rem; border-bottom-right-radius: 0.5rem; }
.view-toggles button.active { background-color: #4ade80; color: white; border-color: #4ade80; font-weight: 700; }
.date-navigator { font-weight: 700; font-size: 1.1rem; display: flex; gap: 1rem; align-items: center; }
.nav-btn { background: none; border: none; font-size: 1.2rem; cursor: pointer; }
.right-actions { display: flex; gap: 0.5rem; }
.today-btn { padding: 0.5rem 1rem; border: 1px solid #e5e7eb; border-radius: 0.5rem; background: #f9fafb; cursor: pointer; }
.add-btn { padding: 0.5rem 1rem; background-color: #4ade80; color: white; border: none; border-radius: 0.5rem; font-weight: 700; cursor: pointer; }

/* 주간 뷰 스타일 */
.week-view-body { display: flex; flex: 1; overflow-y: auto; border-top: 1px solid #f3f4f6; }
.time-axis { width: 50px; flex-shrink: 0; background: white; margin-top: 40px; } /* 헤더 높이만큼 마진 */
.time-slot { height: 60px; font-size: 0.75rem; color: #9ca3af; text-align: right; padding-right: 8px; transform: translateY(-8px); }

.week-columns { display: flex; flex: 1; min-width: 600px; } /* 가로 스크롤 대응 */
.day-column { flex: 1; border-left: 1px solid #f3f4f6; display: flex; flex-direction: column; }
.day-column:last-child { border-right: 1px solid #f3f4f6; }

.column-header { 
  height: 40px; display: flex; flex-direction: column; align-items: center; justify-content: center; 
  border-bottom: 1px solid #f3f4f6; background: #f9fafb; padding: 0.5rem 0;
}
.day-name { font-size: 0.75rem; color: #6b7280; }
.day-num { font-weight: 700; font-size: 1rem; }

.column-content { position: relative; flex: 1; }
.grid-line { height: 60px; border-bottom: 1px solid #f3f4f6; box-sizing: border-box; }

.schedule-block {
  position: absolute; left: 2px; right: 2px; padding: 4px; border-radius: 4px; cursor: pointer; font-size: 0.75rem; overflow: hidden;
}
.bg-yellow { background: #fefce8; border-left: 3px solid #eab308; color: #854d0e; }
.block-title { font-weight: 700; }
</style>