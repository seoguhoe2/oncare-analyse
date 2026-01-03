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
const SLOT_HEIGHT = 80; // 각 시간 칸의 높이 (px)

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

// 시간을 분 단위로 변환
const timeToMinutes = (time) => {
  const [hour, min] = time.split(':').map(Number);
  return hour * 60 + min;
};

// 두 일정이 시간적으로 겹치는지 확인
const isOverlapping = (start1, end1, start2, end2) => {
  const s1 = timeToMinutes(start1);
  const e1 = timeToMinutes(end1);
  const s2 = timeToMinutes(start2);
  const e2 = timeToMinutes(end2);

  // 겹침 조건: 한 일정의 시작이 다른 일정의 종료 전이고, 종료가 다른 일정의 시작 후인 경우
  return s1 < e2 && e1 > s2;
};

// 겹치는 일정 그룹 찾기 (서로 연결된 모든 일정)
const getOverlappingGroup = (currentSchedule) => {
  const group = new Set();
  const toCheck = [currentSchedule];

  while (toCheck.length > 0) {
    const checking = toCheck.pop();
    if (group.has(checking.id)) continue;

    group.add(checking.id);

    // 현재 일정과 겹치는 모든 일정 찾기
    scheduleData.value.forEach(schedule => {
      if (!group.has(schedule.id) && isOverlapping(
        checking.startTime,
        checking.endTime,
        schedule.startTime,
        schedule.endTime
      )) {
        toCheck.push(schedule);
      }
    });
  }

  // 그룹에 속한 일정들을 시작 시간 순으로 정렬
  const groupSchedules = scheduleData.value.filter(s => group.has(s.id));

  return groupSchedules.sort((a, b) => {
    const startA = timeToMinutes(a.startTime);
    const startB = timeToMinutes(b.startTime);

    if (startA !== startB) {
      return startA - startB; // 시작 시간이 이른 것부터
    }

    const endA = timeToMinutes(a.endTime);
    const endB = timeToMinutes(b.endTime);

    if (endA !== endB) {
      return endA - endB; // 종료 시간이 이른 것부터
    }

    // 시작/종료 시간이 같으면 ID로 정렬
    const idA = typeof a.id === 'string' ? a.id : String(a.id);
    const idB = typeof b.id === 'string' ? b.id : String(b.id);
    return idA.localeCompare(idB);
  });
};

// 위치 계산 (start~end) + 겹치는 일정 처리
const getPositionStyle = (start, end, scheduleId) => {
  const startHour = parseInt(start.split(':')[0]);
  const startMin = parseInt(start.split(':')[1]);
  const endHour = parseInt(end.split(':')[0]);
  const endMin = parseInt(end.split(':')[1]);

  // 시간당 픽셀 비율 계산 (SLOT_HEIGHT / 60분)
  const pixelPerMin = SLOT_HEIGHT / 60;
  const top = ((startHour - 7) * SLOT_HEIGHT) + (startMin * pixelPerMin);
  const heightRaw = ((endHour - startHour) * SLOT_HEIGHT) + ((endMin - startMin) * pixelPerMin);
  // 연속된 일정이 겹치지 않도록 하단에 12px 여백 추가
  const height = heightRaw - 12;

  // 현재 일정 찾기
  const currentSchedule = scheduleData.value.find(s => s.id === scheduleId);
  if (!currentSchedule) {
    return {
      top: `${top}px`,
      height: `${height}px`,
      width: '95%',
      left: '0',
    };
  }

  // 겹치는 일정들 찾기 (그래프 탐색으로 연결된 모든 일정 포함)
  const overlappingSchedules = getOverlappingGroup(currentSchedule);
  const totalCount = overlappingSchedules.length;

  // 현재 일정의 인덱스 찾기
  const currentIndex = overlappingSchedules.findIndex(s => s.id === scheduleId);

  // 겹치는 일정이 있으면 너비를 나누고 위치 조정
  if (totalCount > 1) {
    const widthPercent = 100 / totalCount; // 전체를 균등 분할 (예: 4개면 25%씩)
    const leftPercent = widthPercent * currentIndex; // 왼쪽 위치 (겹치지 않게)

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
    width: '100%',
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
             :class="item.colorClass"
             :style="getPositionStyle(item.startTime, item.endTime, item.id)"
             @click="handleSelect(item)">
          <div class="block-content">
            <div class="block-time">시간 {{ item.startTime }} - {{ item.endTime }}</div>
            <div class="block-title">{{ item.recipient }}</div>
            <div class="block-sub">{{ item.serviceType || item.serviceLabel }}</div>
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
.time-slot { height: 80px; font-size: 0.75rem; color: #9ca3af; text-align: right; padding-right: 10px; transform: translateY(-8px); }

.schedule-grid { flex: 1; position: relative; margin-left: 10px; }
.grid-lines { position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; }
.grid-line { height: 80px; border-top: 1px solid #f3f4f6; box-sizing: border-box; }

.schedule-block {
  position: absolute;
  left: 0;
  width: 95%;
  border-radius: 4px;
  padding: 0.5rem;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  overflow: hidden;
  z-index: 10;
}
.schedule-block:hover { transform: scale(1.01); box-shadow: 0 4px 6px rgba(0,0,0,0.1); z-index: 20; }

/* 일정 색상 클래스 (상태별) */
.bg-blue { background-color: #dbeafe; border-left: 4px solid #3b82f6; }      /* 예정 */
.bg-blue .block-time,
.bg-blue .block-title,
.bg-blue .block-sub,
.bg-blue .block-loc { color: #1e40af; }

.bg-green { background-color: #dcfce7; border-left: 4px solid #22c55e; }     /* 진행중 */
.bg-green .block-time,
.bg-green .block-title,
.bg-green .block-sub,
.bg-green .block-loc { color: #166534; }

.bg-red { background-color: #fee2e2; border-left: 4px solid #ef4444; }       /* 완료 */
.bg-red .block-time,
.bg-red .block-title,
.bg-red .block-sub,
.bg-red .block-loc { color: #991b1b; }

.bg-purple { background-color: #f3e8ff; border-left: 4px solid #9333ea; }    /* 개인일정 */
.bg-purple .block-time,
.bg-purple .block-title,
.bg-purple .block-sub,
.bg-purple .block-loc { color: #6b21a8; }

.bg-gray { background-color: #f3f4f6; border-left: 4px solid #9ca3af; }      /* 취소 */
.bg-gray .block-time,
.bg-gray .block-title,
.bg-gray .block-sub,
.bg-gray .block-loc { color: #6b7280; }

.bg-yellow { background-color: #fef9c3; border-left: 4px solid #eab308; }
.bg-yellow .block-time,
.bg-yellow .block-title,
.bg-yellow .block-sub,
.bg-yellow .block-loc { color: #854d0e; }

.block-time { font-size: 0.75rem; margin-bottom: 2px; }
.block-title { font-weight: 700; margin-bottom: 2px; }
.block-sub { font-size: 0.8rem; margin-bottom: 4px; }
.block-loc { font-size: 0.75rem; }
</style>
