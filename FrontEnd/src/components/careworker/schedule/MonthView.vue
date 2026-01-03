<!-- components/schedule/MonthView.vue -->

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

const currentYear = computed(() => props.currentDate.getFullYear());
const currentMonth = computed(() => props.currentDate.getMonth());

const scheduleData = computed(() => props.schedules || []);

// 일정 데이터를 날짜별로 그룹화
const schedulesByDate = computed(() => {
  const grouped = {};
  scheduleData.value.forEach(schedule => {
    if (!grouped[schedule.date]) {
      grouped[schedule.date] = [];
    }
    grouped[schedule.date].push(schedule);
  });
  return grouped;
});

// 달력 그리드 (이전/다음달 포함 6주) - 월요일부터 시작
const calendarDays = computed(() => {
  const days = [];
  const firstDayOfMonth = new Date(currentYear.value, currentMonth.value, 1);
  const lastDayOfMonth = new Date(currentYear.value, currentMonth.value + 1, 0);

  // 시작: 이번 달 1일이 속한 주의 월요일
  const startDate = new Date(firstDayOfMonth);
  const day = startDate.getDay(); // 0(일) ~ 6(토)
  const diff = day === 0 ? -6 : 1 - day; // 일요일이면 -6, 그 외에는 1-day
  startDate.setDate(startDate.getDate() + diff);

  // 끝: 6주(42칸) 채우기
  const endDate = new Date(startDate);
  endDate.setDate(endDate.getDate() + 41);

  let dateIter = new Date(startDate);
  while (dateIter <= endDate) {
    days.push(new Date(dateIter));
    dateIter.setDate(dateIter.getDate() + 1);
  }
  return days;
});

// 날짜 포맷 (YYYY-MM-DD)
const formatDate = (date) => {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
};

// 화면 표시용
const displayMonth = computed(() => {
  return `${currentYear.value}년 ${currentMonth.value + 1}월`;
});

// 이전/다음 이동
const prevMonth = () => {
  const newDate = new Date(currentYear.value, currentMonth.value - 1, 1);
  emit('date-change', newDate);
};
const nextMonth = () => {
  const newDate = new Date(currentYear.value, currentMonth.value + 1, 1);
  emit('date-change', newDate);
};

// 오늘로 이동
const goToday = () => {
  const newDate = new Date();
  emit('date-change', newDate);
};

// 현재 달 여부
const isCurrentMonth = (date) => date.getMonth() === currentMonth.value;
const isToday = (date) => formatDate(date) === formatDate(new Date());

const openAdd = () => {
  emit('add-schedule', { date: formatDate(new Date()) });
};
</script>

<template>
  <div class="calendar-container">
    <div class="calendar-controls">
      <div class="view-toggles">
        <button @click="emit('view-change', 'day')">일간</button>
        <button @click="emit('view-change', 'week')">주간</button>
        <button class="active">월간</button>
      </div>
      
      <div class="date-navigator">
        <button class="nav-btn" @click="prevMonth">&lt;</button>
        <span class="current-date">{{ displayMonth }}</span>
        <button class="nav-btn" @click="nextMonth">&gt;</button>
      </div>

      <div class="right-actions">
        <button class="today-btn" @click="goToday">오늘</button>
        <button class="add-btn" @click="openAdd">+ 일정등록</button>
      </div>
    </div>

    <div class="month-view-body">
      <div class="weekday-header">
        <div class="weekday">월</div>
        <div class="weekday">화</div>
        <div class="weekday">수</div>
        <div class="weekday">목</div>
        <div class="weekday">금</div>
        <div class="weekday">토</div>
        <div class="weekday">일</div>
      </div>

      <div class="date-grid">
        <div 
          v-for="day in calendarDays" 
          :key="formatDate(day)"
          class="date-cell"
          :class="{ 'not-current-month': !isCurrentMonth(day), 'today': isToday(day) }"
        >
          <div class="date-number">
            <span :class="{ 'today-circle': isToday(day) }">{{ day.getDate() }}</span>
          </div>
          
          <div class="cell-schedules">
            <div 
              v-for="schedule in schedulesByDate[formatDate(day)] || []"
              :key="schedule.id"
              class="schedule-item"
              :class="schedule.colorClass"
              @click.stop="emit('select-schedule', schedule)"
            >
              <span class="time">{{ schedule.startTime }}</span>
              <span class="recipient">{{ schedule.recipient }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 컨트롤바 */
.calendar-container {
  background: white;
  border-radius: 0.75rem;
  padding: 1.5rem;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  height: 100%;
  display: flex;
  flex-direction: column;
}
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

/* 월간 바디 */
.month-view-body { flex: 1; display: flex; flex-direction: column; border: 1px solid #f3f4f6; border-radius: 0.5rem; overflow: hidden; }

.weekday-header { display: grid; grid-template-columns: repeat(7, 1fr); background: #f9fafb; border-bottom: 1px solid #f3f4f6; }
.weekday { padding: 0.75rem; text-align: center; font-weight: 600; color: #6b7280; font-size: 0.9rem; }
.weekday:first-child { color: #ef4444; /* 일요일 빨간색 */ }

.date-grid { display: grid; grid-template-columns: repeat(7, 1fr); flex: 1; }
.date-cell {
  border-right: 1px solid #f3f4f6; border-bottom: 1px solid #f3f4f6;
  min-height: 100px; /* 셀 최소 높이 */
  padding: 0.5rem;
  display: flex; flex-direction: column; gap: 0.25rem;
}
.date-cell:nth-child(7n) { border-right: none; } /* 맨오른쪽 줄 닫기 */

.date-number { text-align: left; font-weight: 600; color: #374151; margin-bottom: 0.25rem; }
.not-current-month .date-number { color: #d1d5db; /* 이전/다음달 날짜 흐리게*/ }
.today-circle {
  display: inline-block; width: 1.5rem; height: 1.5rem;
  background-color: #4ade80; color: white; border-radius: 50%;
  text-align: center; line-height: 1.5rem;
}

.cell-schedules { display: flex; flex-direction: column; gap: 0.25rem; overflow-y: auto; }
.schedule-item {
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  font-size: 0.75rem;
  cursor: pointer;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
  display: flex; align-items: center; gap: 0.25rem;
}
.schedule-item:hover { opacity: 0.8; }
.time { font-weight: 600; }

/* 일정 색상 클래스 (상태별) */
.bg-blue { background-color: #dbeafe; color: #1e40af; border-left: 3px solid #3b82f6; }      /* 예정 */
.bg-green { background-color: #dcfce7; color: #166534; border-left: 3px solid #22c55e; }     /* 진행중 */
.bg-red { background-color: #fee2e2; color: #991b1b; border-left: 3px solid #ef4444; }       /* 완료 */
.bg-purple { background-color: #f3e8ff; color: #6b21a8; border-left: 3px solid #9333ea; }    /* 개인일정 */
.bg-gray { background-color: #f3f4f6; color: #6b7280; border-left: 3px solid #9ca3af; }      /* 취소 */
.bg-yellow { background-color: #fef9c3; color: #854d0e; border-left: 3px solid #eab308; }

/* 반응형: 모바일에서는 높이/폰트 축소 */
@media (max-width: 768px) {
  .date-cell { min-height: 80px; padding: 0.25rem; }
  .schedule-item { font-size: 0.7rem; padding: 0.1rem 0.25rem; }
  .time { display: none; /* 공간 부족 시 시간 숨김 */ }
}
</style>
