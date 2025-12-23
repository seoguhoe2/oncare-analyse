<!-- components/schedule/MonthView.vue -->

<script setup>
import { ref, computed, defineEmits } from 'vue';
import { scheduleList } from '@/mock/careworker/scheduleData';

const emit = defineEmits(['select-schedule', 'view-change']);

// 현재 기준 날짜 (초기값: 2025년 12월)
const currentDate = ref(new Date('2025-12-01'));

// 달력 데이터 계산을 위한 computed 속성들
const currentYear = computed(() => currentDate.value.getFullYear());
const currentMonth = computed(() => currentDate.value.getMonth());

// 해당 월의 일정을 날짜별로 그룹화
const schedulesByDate = computed(() => {
  const grouped = {};
  scheduleList.forEach(schedule => {
    if (!grouped[schedule.date]) {
      grouped[schedule.date] = [];
    }
    grouped[schedule.date].push(schedule);
  });
  return grouped;
});

// 달력 그리드에 표시할 날짜 배열 생성 (이전달 말일 + 이번달 + 다음달 초)
const calendarDays = computed(() => {
  const days = [];
  const firstDayOfMonth = new Date(currentYear.value, currentMonth.value, 1);
  const lastDayOfMonth = new Date(currentYear.value, currentMonth.value + 1, 0);
  
  // 시작일: 이번달 1일이 속한 주의 일요일
  const startDate = new Date(firstDayOfMonth);
  startDate.setDate(startDate.getDate() - startDate.getDay());

  // 종료일: 이번달 말일이 속한 주의 토요일 (6주 분량 확보를 위해 여유있게 설정)
  const endDate = new Date(startDate);
  endDate.setDate(endDate.getDate() + 41); // 6주 * 7일 = 42일

  let dateIter = new Date(startDate);
  while (dateIter <= endDate) {
    days.push(new Date(dateIter));
    dateIter.setDate(dateIter.getDate() + 1);
  }
  return days;
});

// 날짜 포맷팅 (YYYY-MM-DD)
const formatDate = (date) => {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
};

// 화면 표시용 날짜 포맷 (2025년 12월)
const displayMonth = computed(() => {
  return `${currentYear.value}년 ${currentMonth.value + 1}월`;
});

// 이전/다음 달 이동
const prevMonth = () => {
  currentDate.value = new Date(currentYear.value, currentMonth.value - 1, 1);
};
const nextMonth = () => {
  currentDate.value = new Date(currentYear.value, currentMonth.value + 1, 1);
};

// 오늘로 이동
const goToday = () => {
  currentDate.value = new Date();
};

// 이번 달 날짜인지 확인
const isCurrentMonth = (date) => {
  return date.getMonth() === currentMonth.value;
};

// 오늘 날짜인지 확인
const isToday = (date) => {
  const today = new Date();
  return formatDate(date) === formatDate(today);
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
        <button class="add-btn">+ 일정등록</button>
      </div>
    </div>

    <div class="month-view-body">
      <div class="weekday-header">
        <div class="weekday">일</div>
        <div class="weekday">월</div>
        <div class="weekday">화</div>
        <div class="weekday">수</div>
        <div class="weekday">목</div>
        <div class="weekday">금</div>
        <div class="weekday">토</div>
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
/* 컨트롤 바 스타일 (기존 CalendarView와 동일하게 유지) */
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

/* 월간 뷰 스타일 */
.month-view-body { flex: 1; display: flex; flex-direction: column; border: 1px solid #f3f4f6; border-radius: 0.5rem; overflow: hidden; }

/* 요일 헤더 */
.weekday-header { display: grid; grid-template-columns: repeat(7, 1fr); background: #f9fafb; border-bottom: 1px solid #f3f4f6; }
.weekday { padding: 0.75rem; text-align: center; font-weight: 600; color: #6b7280; font-size: 0.9rem; }
.weekday:first-child { color: #ef4444; /* 일요일 빨간색 */ }

/* 날짜 그리드 */
.date-grid { display: grid; grid-template-columns: repeat(7, 1fr); flex: 1; }
.date-cell {
  border-right: 1px solid #f3f4f6; border-bottom: 1px solid #f3f4f6;
  min-height: 100px; /* 셀 최소 높이 */
  padding: 0.5rem;
  display: flex; flex-direction: column; gap: 0.25rem;
}
.date-cell:nth-child(7n) { border-right: none; } /* 오른쪽 끝 테두리 제거 */

/* 날짜 숫자 스타일 */
.date-number { text-align: left; font-weight: 600; color: #374151; margin-bottom: 0.25rem; }
.not-current-month .date-number { color: #d1d5db; /* 이전/다음달 날짜 흐리게 */ }
.today-circle {
  display: inline-block; width: 1.5rem; height: 1.5rem;
  background-color: #4ade80; color: white; border-radius: 50%;
  text-align: center; line-height: 1.5rem;
}

/* 셀 내부 일정 아이템 스타일 */
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

/* 일정 색상 클래스 (mock 데이터의 colorClass와 매칭) */
.bg-yellow { background-color: #fef9c3; color: #854d0e; border-left: 3px solid #eab308; }
.bg-blue { background-color: #dbeafe; color: #1e40af; border-left: 3px solid #3b82f6; }
.bg-green { background-color: #dcfce7; color: #166534; border-left: 3px solid #22c55e; }
.bg-purple { background-color: #f3e8ff; color: #6b21a8; border-left: 3px solid #9333ea; }

/* 반응형: 모바일에서는 셀 높이 줄이고 글자 작게 */
@media (max-width: 768px) {
  .date-cell { min-height: 80px; padding: 0.25rem; }
  .schedule-item { font-size: 0.7rem; padding: 0.1rem 0.25rem; }
  .time { display: none; /* 공간 부족 시 시간 숨김 */ }
}
</style>