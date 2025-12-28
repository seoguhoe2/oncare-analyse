<!-- components/schedule/CalendarView.vue -->

<script setup>
import { ref, defineEmits, defineProps, computed } from 'vue';

// 부모에 전달할 이벤트 (일정 선택, 모드 변경, 일정 등록, 날짜 변경)
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

const currentView = ref('day'); // 현재 뷰 타입 (일간)
const timeSlots = Array.from({ length: 12 }, (_, i) => i + 7); // 7시~18시

const scheduleData = computed(() => props.schedules || []);

// 날짜 포맷 (YYYY-MM-DD)
const formatDateKey = (date) => {
  if (typeof date === 'string') return date;
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

// 화면 표시용 날짜 (부모로부터 받은 currentDate 사용)
const displayDate = computed(() => {
  return formatDateKey(props.currentDate);
});

// 일정 클릭 시 부모로 전달
const handleSelect = (schedule) => {
  emit('select-schedule', schedule);
};

// 뷰 전환
const changeView = (viewType) => {
  emit('view-change', viewType);
};

// 일정 등록 버튼
const openAdd = () => {
  emit('add-schedule', { date: formatDateKey(props.currentDate) });
};

// 이전 날로 이동
const goPrevDay = () => {
  const newDate = new Date(props.currentDate);
  newDate.setDate(newDate.getDate() - 1);
  emit('date-change', newDate);
};

// 다음 날로 이동
const goNextDay = () => {
  const newDate = new Date(props.currentDate);
  newDate.setDate(newDate.getDate() + 1);
  emit('date-change', newDate);
};

// 오늘로 이동
const goToday = () => {
  const newDate = new Date();
  emit('date-change', newDate);
};

// 겹치는 일정 감지 및 배치 계산
const getOverlappingSchedules = () => {
  const overlaps = {};

  scheduleData.value.forEach((schedule, index) => {
    const key = `${schedule.startTime}-${schedule.endTime}`;
    if (!overlaps[key]) {
      overlaps[key] = [];
    }
    overlaps[key].push({ schedule, index });
  });

  return overlaps;
};

// 위치 계산 (start~end) + 겹치는 일정 처리
const getPositionStyle = (start, end, scheduleId) => {
  const startHour = parseInt(start.split(':')[0]);
  const startMin = parseInt(start.split(':')[1]);
  const endHour = parseInt(end.split(':')[0]);
  const endMin = parseInt(end.split(':')[1]);

  const top = ((startHour - 7) * 60) + startMin;
  const heightRaw = ((endHour - startHour) * 60) + (endMin - startMin);
  // 연속된 일정이 겹치지 않도록 하단에 8px 여백 추가
  const height = heightRaw - 8;

  // 같은 시간대의 일정들 찾기
  const key = `${start}-${end}`;
  const overlaps = getOverlappingSchedules();
  const sameTimeSchedules = overlaps[key] || [];

  // 현재 일정이 몇 번째인지 찾기
  const currentIndex = sameTimeSchedules.findIndex(item => item.schedule.id === scheduleId);
  const totalCount = sameTimeSchedules.length;

  // 겹치는 일정이 있으면 너비를 나누고 위치 조정
  if (totalCount > 1) {
    const widthPercent = 95 / totalCount; // 전체 너비를 개수만큼 나눔
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
        <button class="nav-btn" @click="goPrevDay">&lt;</button>
        <span class="current-date">{{ displayDate }}</span>
        <button class="nav-btn" @click="goNextDay">&gt;</button>
      </div>

      <div class="right-actions">
        <button class="today-btn" @click="goToday">오늘</button>
        <button class="add-btn" @click="openAdd">+ 일정등록</button>
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

        <div v-for="item in scheduleData" :key="item.id"
             class="schedule-block"
             :style="getPositionStyle(item.startTime, item.endTime, item.id)"
             @click="handleSelect(item)">
          <div class="block-content">
            <div class="block-time">시간 {{ item.startTime }} - {{ item.endTime }}</div>
            <div class="block-title">{{ item.recipient }}</div>
            <div class="block-sub">{{ item.serviceType || item.serviceLabel }}</div>
            <div class="block-loc">📍 {{ item.address?.split(' ')[1] || '' }}</div>
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

/* 컨트롤바 */
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

/* 타임라인 바디 */
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
  background-color: #fef9c3; /* 밝은 노랑 */
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
