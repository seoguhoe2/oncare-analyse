<script setup>
import { ref, computed } from 'vue';

const props = defineProps({
  schedules: { type: Array, default: () => [] }
});

// --- 날짜 상태 ---
const currentDate = ref(new Date());

// --- 날짜 계산 헬퍼 함수 ---
const getDateString = (date) => {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
};

// 현재 월의 정보 계산
const currentYear = computed(() => currentDate.value.getFullYear());
const currentMonth = computed(() => currentDate.value.getMonth());
const monthNames = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"];

// --- 핵심 로직: 월별 주(Week) 데이터 생성 ---
const calendarWeeks = computed(() => {
  const weeks = [];
  const firstDayOfMonth = new Date(currentYear.value, currentMonth.value, 1);
  const startDayOfWeek = firstDayOfMonth.getDay();
  const startDate = new Date(firstDayOfMonth);
  startDate.setDate(startDate.getDate() - startDayOfWeek);

  let currentIterDate = new Date(startDate);
  
  for (let w = 0; w < 6; w++) {
    const week = { id: w, days: [], segments: [] };
    const weekStart = new Date(currentIterDate);
    for (let d = 0; d < 7; d++) {
      week.days.push({
        date: currentIterDate.getDate(),
        fullDate: getDateString(currentIterDate),
        isCurrentMonth: currentIterDate.getMonth() === currentMonth.value,
        isToday: getDateString(currentIterDate) === getDateString(new Date()),
        dayIndex: d
      });
      currentIterDate.setDate(currentIterDate.getDate() + 1);
    }
    const weekEnd = new Date(currentIterDate);
    weekEnd.setDate(weekEnd.getDate() - 1);
    week.segments = processEventsForWeek(weekStart, weekEnd);
    weeks.push(week);
  }
  return weeks;
});

// --- 일정 처리 로직 (주 단위로 자르기) ---
const processEventsForWeek = (weekStart, weekEnd) => {
  const segments = [];
  const weekStartStr = getDateString(weekStart);
  const weekEndStr = getDateString(weekEnd);

  props.schedules.forEach((event, index) => {
    // 1. FullCalendar 포맷(start, end) 대응 및 시간 제거 (YYYY-MM-DD)
    const rawStart = event.start || event.startDate || event.date;
    const rawEnd = event.end || event.endDate || event.date;
    
    if (!rawStart || !rawEnd) return;

    const eventStart = rawStart.substring(0, 10);
    const eventEnd = rawEnd.substring(0, 10);

    // 2. 주(Week) 범위 밖이면 패스
    if (eventEnd < weekStartStr || eventStart > weekEndStr) return;

    // 3. 타입 추론 (extendedProps.serviceType 등 활용)
    //    API에는 serviceType이 한글로 들어옴 ("방문요양", "복지용구" 등)
    const serviceType = event.extendedProps?.serviceType || '';
    let type = 'care';
    if (serviceType.includes('렌탈') || serviceType.includes('용구')) {
      type = 'rental';
    } else if (event.type) {
      type = event.type;
    }

    const effectiveStart = eventStart < weekStartStr ? weekStartStr : eventStart;
    const effectiveEnd = eventEnd > weekEndStr ? weekEndStr : eventEnd;

    const startDateObj = new Date(effectiveStart);
    const endDateObj = new Date(effectiveEnd);
    
    const startCol = startDateObj.getDay() + 1;
    const endCol = endDateObj.getDay() + 1;
    const span = endCol - startCol + 1;

    const isContinuesLeft = eventStart < weekStartStr;
    const isContinuesRight = eventEnd > weekEndStr;

    // 시간 포맷팅
    let formattedTime = '';
    if (rawStart && rawStart.length >= 16) {
      formattedTime = rawStart.substring(11, 16);
      if (rawEnd && rawEnd.length >= 16) {
        formattedTime += `~${rawEnd.substring(11, 16)}`;
      }
    }

    segments.push({
      ...event,
      title: event.title || serviceType || event.recipient, // 제목 없을 경우 처리
      time: formattedTime, // [신규] 시간 표시용
      type, // 결정된 타입 (care/rental)
      _uiKey: `evt-${index}-${startCol}`,
      gridColumnStart: startCol,
      gridColumnSpan: span,
      isContinuesLeft,
      isContinuesRight
    });
  });

  return segments.sort((a, b) => {
    if (a.gridColumnSpan !== b.gridColumnSpan) return b.gridColumnSpan - a.gridColumnSpan;
    const dateA = a.start || a.startDate || '';
    const dateB = b.start || b.startDate || '';
    return dateA.localeCompare(dateB);
  });
};

const prevMonth = () => currentDate.value = new Date(currentYear.value, currentMonth.value - 1, 1);
const nextMonth = () => currentDate.value = new Date(currentYear.value, currentMonth.value + 1, 1);
</script>

<template>
  <div class="calendar-wrapper">
    <div class="header">
      <button @click="prevMonth" class="nav-btn">
        <svg class="icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        이전달
      </button>
      <h2 class="title">{{ currentYear }}년 {{ monthNames[currentMonth] }}</h2>
      <button @click="nextMonth" class="nav-btn">
        다음달 
        <svg class="icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>
      </button>
    </div>

    <div class="legend">
      <div class="item"><span class="dot care"></span> 요양일정</div>
      <div class="item"><span class="dot rental"></span> 렌탈</div>
    </div>

    <div class="weekdays">
      <div class="weekday sun">일</div>
      <div class="weekday">월</div>
      <div class="weekday">화</div>
      <div class="weekday">수</div>
      <div class="weekday">목</div>
      <div class="weekday">금</div>
      <div class="weekday sat">토</div>
    </div>

    <div class="calendar-body">
      <div v-for="week in calendarWeeks" :key="week.id" class="week-row">
        
        <div class="bg-layer">
          <div 
            v-for="day in week.days" 
            :key="day.fullDate" 
            class="day-cell"
            :class="{ 'not-current-month': !day.isCurrentMonth }"
          >
            <span 
              class="day-number"
              :class="{ 
                'sun': day.dayIndex === 0, 
                'sat': day.dayIndex === 6,
                'today': day.isToday
              }"
            >
              {{ day.date }}
            </span>
          </div>
        </div>

        <div class="events-layer">
          <div 
            v-for="event in week.segments" 
            :key="event._uiKey" 
            class="event-bar"
            :class="[
              event.type,
              { 'rounded-l-md': !event.isContinuesLeft, 'rounded-r-md': !event.isContinuesRight }
            ]"
            :style="{
              gridColumnStart: event.gridColumnStart,
              gridColumnEnd: `span ${event.gridColumnSpan}`
            }"
          >
            <span class="event-content">
              <span v-if="event.type === 'rental' && !event.isContinuesLeft" class="icon-box">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/><path d="m3.3 7 8.7 5 8.7-5"/><path d="M12 22V12"/></svg>
              </span>
              
              <span v-if="event.type === 'care'" class="icon-box">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><path d="m22 4-12 12-4-4"/></svg>
              </span>

              <span class="event-title truncate">
                {{ event.title || event.recipient }}
                <span class="time-text">{{ event.time }}</span>
              </span>
            </span>
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

<style scoped>
.calendar-wrapper {
  background: white;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
  height: 100%;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
}

/* 헤더 */
.header { display: flex; justify-content: space-between; align-items: center; padding: 16px 20px; border-bottom: 1px solid #f0f0f0; }
.title { font-size: 20px; font-weight: 700; color: #166534; margin: 0; }
.nav-btn { display: flex; align-items: center; gap: 4px; padding: 6px 12px; border: 1px solid #ddd; border-radius: 6px; background: white; color: #555; font-size: 13px; cursor: pointer; transition: all 0.2s; }
.nav-btn:hover { background: #f9fafb; border-color: #ccc; color: #333; }

/* 범례 */
.legend { display: flex; gap: 16px; padding: 12px 20px; font-size: 13px; color: #555; background: #fff; border-bottom: 1px solid #f0f0f0; }
.legend .item { display: flex; align-items: center; gap: 6px; }
.dot { width: 8px; height: 8px; border-radius: 50%; }
.dot.care { background: #22c55e; }
.dot.rental { background: #f97316; }

/* 요일 헤더 */
.weekdays { display: grid; grid-template-columns: repeat(7, 1fr); border-bottom: 1px solid #e5e7eb; text-align: center; background: #fbfbfc; }
.weekday { padding: 10px 0; font-size: 13px; color: #666; font-weight: 600; }
.weekday.sun { color: #ef4444; }
.weekday.sat { color: #3b82f6; }

/* 달력 본문 */
.calendar-body { display: flex; flex-direction: column; flex: 1; }
.week-row { position: relative; min-height: 100px; border-bottom: 1px solid #e5e7eb; flex: 1; }
.week-row:last-child { border-bottom: none; }

/* 배경 레이어 (날짜) */
.bg-layer { position: absolute; inset: 0; display: grid; grid-template-columns: repeat(7, 1fr); pointer-events: none; }
.day-cell { border-right: 1px solid #f3f4f6; padding: 8px; }
.day-cell:last-child { border-right: none; }
.day-cell.not-current-month .day-number { opacity: 0.3; }
.day-number { font-size: 13px; font-weight: 500; color: #333; }
.day-number.sun { color: #ef4444; }
.day-number.sat { color: #3b82f6; }
.day-number.today { display: inline-block; width: 24px; height: 24px; line-height: 24px; text-align: center; background: #ef4444; color: white; border-radius: 50%; }

/* 일정 레이어 */
.events-layer { position: relative; z-index: 10; display: grid; grid-template-columns: repeat(7, 1fr); grid-auto-flow: row; gap: 3px 0; padding-top: 32px; padding-bottom: 8px; }

/* 일정 바 스타일 */
.event-bar {
  height: 22px;
  margin: 0 1px; /* 좌우 간격 최소화 */
  font-size: 12px;
  display: flex; align-items: center;
  overflow: hidden;
  cursor: pointer;
  transition: opacity 0.2s;
  border-radius: 0; 
}
.event-bar:hover { opacity: 0.9; }

/* 렌탈 스타일 */
.event-bar.rental {
  background-color: #fff7ed;
  color: #c2410c;
  border: 1px solid #fed7aa;
  border-left-width: 4px;
  border-left-color: #f97316;
}

/* 요양 스타일 */
.event-bar.care {
  background-color: #dcfce7;
  color: #166534;
  border: 1px solid #bbf7d0;
  border-left-width: 4px;
  border-left-color: #22c55e;
}

.event-content { padding: 0 6px; display: flex; align-items: center; width: 100%; }
.icon-box { margin-right: 6px; opacity: 0.8; display: flex; align-items: center; }
.event-title { font-weight: 600; }
.time-text { font-weight: normal; font-size: 11px; margin-left: 4px; opacity: 0.9; }
.truncate { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

/* 둥근 모서리 (연결 효과) */
.rounded-l-md { border-top-left-radius: 4px; border-bottom-left-radius: 4px; }
.rounded-r-md { border-top-right-radius: 4px; border-bottom-right-radius: 4px; }
</style>