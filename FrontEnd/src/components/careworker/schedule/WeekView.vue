<!-- components/schedule/WeekView.vue -->

<script setup>
import { computed, defineEmits, defineProps } from 'vue';

const emit = defineEmits(['select-schedule', 'view-change', 'add-schedule', 'date-change']);

const props = defineProps({
  schedules: {
    type: Array,
    default: () => [],
  },
  currentDate: {
    type: Date,
    default: () => new Date(),
  },
});

const timeSlots = Array.from({ length: 12 }, (_, i) => i + 7); // 07:00 ~ 18:00

const scheduleData = computed(() => props.schedules || []);

// 이번 주 날짜 7개 구하기 (월요일부터 일요일까지)
const weekDates = computed(() => {
  const dates = [];
  const curr = new Date(props.currentDate);
  const day = curr.getDay(); // 0(일) ~ 6(토)

  // 이번 주 월요일 구하기
  // 일요일(0)이면 -6일, 그 외에는 -(day-1)일
  const diff = day === 0 ? -6 : 1 - day;
  const monday = new Date(curr);
  monday.setDate(curr.getDate() + diff);

  for (let i = 0; i < 7; i++) {
    const next = new Date(monday);
    next.setDate(monday.getDate() + i);
    dates.push(next);
  }
  return dates;
});

// 날짜 포맷 (YYYY-MM-DD, 로컬 기준)
const formatDateKey = (date) => {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
};

// 화면 표시용 (예: 2025년 12월 2주차)
const displayWeek = computed(() => {
  const dates = weekDates.value;
  if (dates.length === 0) return '';

  const firstDay = dates[0];
  const lastDay = dates[6];

  // 같은 달이면 "2025년 12월"
  if (firstDay.getMonth() === lastDay.getMonth()) {
    return `${firstDay.getFullYear()}년 ${firstDay.getMonth() + 1}월`;
  }
  // 다른 달이면 "2025년 12월 ~ 2026년 1월"
  return `${firstDay.getFullYear()}년 ${firstDay.getMonth() + 1}월 ~ ${lastDay.getFullYear()}년 ${lastDay.getMonth() + 1}월`;
});

// 해당 날짜의 일정 필터
const getSchedulesForDate = (date) => {
  const dateKey = formatDateKey(date);
  return scheduleData.value.filter(item => item.date === dateKey);
};

// 특정 날짜의 겹치는 일정 감지
const getOverlappingSchedulesForDate = (date) => {
  const dateSchedules = getSchedulesForDate(date);
  const overlaps = {};

  dateSchedules.forEach((schedule, index) => {
    const key = `${schedule.startTime}-${schedule.endTime}`;
    if (!overlaps[key]) {
      overlaps[key] = [];
    }
    overlaps[key].push({ schedule, index });
  });

  return overlaps;
};

// 위치 계산 (시작/끝) + 겹치는 일정 처리
const getPositionStyle = (date, start, end, scheduleId) => {
  const startHour = parseInt(start.split(':')[0]);
  const startMin = parseInt(start.split(':')[1]);
  const endHour = parseInt(end.split(':')[0]);
  const endMin = parseInt(end.split(':')[1]);

  const top = ((startHour - 7) * 60) + startMin;
  const heightRaw = ((endHour - startHour) * 60) + (endMin - startMin);
  // 연속된 일정이 겹치지 않도록 하단에 4px 여백 추가
  const height = heightRaw - 4;

  // 같은 시간대의 일정들 찾기
  const key = `${start}-${end}`;
  const overlaps = getOverlappingSchedulesForDate(date);
  const sameTimeSchedules = overlaps[key] || [];

  // 현재 일정이 몇 번째인지 찾기
  const currentIndex = sameTimeSchedules.findIndex(item => item.schedule.id === scheduleId);
  const totalCount = sameTimeSchedules.length;

  // 겹치는 일정이 있으면 너비를 나누고 위치 조정
  if (totalCount > 1) {
    const widthPercent = 95 / totalCount;
    const leftPercent = (widthPercent * currentIndex);

    return {
      top: `${top}px`,
      height: `${height}px`,
      width: `${widthPercent}%`,
      left: `${leftPercent}%`,
    };
  }

  return {
    top: `${top}px`,
    height: `${height}px`,
    width: '95%',
    left: '0',
  };
};

// 요일 이름 (월요일부터 시작)
const weekNames = ['월', '화', '수', '목', '금', '토', '일'];

// 이전 주로 이동
const goPrevWeek = () => {
  const newDate = new Date(props.currentDate);
  newDate.setDate(newDate.getDate() - 7);
  emit('date-change', newDate);
};

// 다음 주로 이동
const goNextWeek = () => {
  const newDate = new Date(props.currentDate);
  newDate.setDate(newDate.getDate() + 7);
  emit('date-change', newDate);
};

// 오늘로 이동
const goToday = () => {
  const newDate = new Date();
  emit('date-change', newDate);
};

const openAdd = () => {
  emit('add-schedule', { date: formatDateKey(props.currentDate) });
};
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
        <button class="nav-btn" @click="goPrevWeek">&lt;</button>
        <span class="current-date">{{ displayWeek }}</span>
        <button class="nav-btn" @click="goNextWeek">&gt;</button>
      </div>

      <div class="right-actions">
        <button class="today-btn" @click="goToday">오늘</button>
        <button class="add-btn" @click="openAdd">+ 일정등록</button>
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
            <span class="day-num" :class="{ 'today': formatDateKey(date) === formatDateKey(new Date()) }">{{ date.getDate() }}</span>
          </div>

          <div class="column-content">
            <div class="grid-lines">
              <div v-for="hour in timeSlots" :key="hour" class="grid-line"></div>
            </div>

            <div v-for="item in getSchedulesForDate(date)" :key="item.id"
                 class="schedule-block"
                 :class="item.colorClass"
                 :style="getPositionStyle(date, item.startTime, item.endTime, item.id)"
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

/* 컨트롤바(공통) */
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

/* 주간 바디 */
.week-view-body { display: flex; flex: 1; overflow-y: auto; border-top: 1px solid #f3f4f6; }
.time-axis { width: 50px; flex-shrink: 0; background: white; margin-top: 40px; } /* 헤더 높이만큼 마진 */
.time-slot { height: 60px; font-size: 0.75rem; color: #9ca3af; text-align: right; padding-right: 8px; transform: translateY(-8px); }

.week-columns { display: flex; flex: 1; min-width: 600px; } /* 가로 스크롤 여유 */
.day-column { flex: 1; border-left: 1px solid #f3f4f6; display: flex; flex-direction: column; }
.day-column:last-child { border-right: 1px solid #f3f4f6; }

.column-header { 
  height: 40px; display: flex; flex-direction: column; align-items: center; justify-content: center; 
  border-bottom: 1px solid #f3f4f6; background: #f9fafb; padding: 0.5rem 0;
}
.day-name { font-size: 0.75rem; color: #6b7280; }
.day-num { font-weight: 700; font-size: 1rem; }
.day-num.today { color: #16a34a; }

.column-content { position: relative; flex: 1; }
.grid-line { height: 60px; border-bottom: 1px solid #f3f4f6; box-sizing: border-box; }

.schedule-block {
  position: absolute; left: 2px; right: 2px; padding: 4px; border-radius: 4px; cursor: pointer; font-size: 0.75rem; overflow: hidden;
}
.bg-yellow { background: #fefce8; border-left: 3px solid #eab308; color: #854d0e; }
.bg-green { background: #dcfce7; border-left: 3px solid #22c55e; color: #166534; }
.bg-blue { background: #dbeafe; border-left: 3px solid #3b82f6; color: #1e3a8a; }
.bg-purple { background: #f3e8ff; border-left: 3px solid #9333ea; color: #6b21a8; }

.block-title { font-weight: 700; }
.block-time { font-size: 0.75rem; }
</style>
