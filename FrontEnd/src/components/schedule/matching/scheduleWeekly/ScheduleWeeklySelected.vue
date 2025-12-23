<template>
    <div class="weekly-selected">
      <!-- 안쪽 상단 헤더 (주간 일정 + 주간 범위 네비게이션) -->
      <div class="inner-header">
        <h3 class="inner-title">주간 일정</h3>
        <div class="week-nav">
          <button type="button" class="nav-btn">〈</button>
          <span class="week-range">12/1 - 12/7</span>
          <button type="button" class="nav-btn">〉</button>
        </div>
      </div>
  
      <!-- 상단 요일 라벨 -->
      <div class="grid-header">
        <div class="cell time-header">시간</div>
        <div
          v-for="day in days"
          :key="day"
          class="cell day-header"
        >
          {{ day }}
        </div>
      </div>
  
      <!-- 시간 / 요일 그리드 + 일정 블록 -->
      <div class="grid-body">
        <!-- 시간 축 -->
        <div class="time-column">
          <div
            v-for="time in timeSlots"
            :key="time"
            class="time-cell"
          >
            {{ time }}
          </div>
        </div>
  
        <!-- 요일별 컬럼 -->
        <div class="day-columns">
          <div
            v-for="day in days"
            :key="day"
            class="day-column"
          >
            <!-- 회색 줄만 있는 배경용 셀 -->
            <div
              v-for="time in timeSlots"
              :key="time"
              class="day-cell"
            ></div>
  
            <!-- 해당 요일의 일정 블록들 -->
            <div
              v-for="event in eventsByDay[day]"
              :key="event.id"
              class="event-block"
              :class="event.type"
              :style="eventStyle(event)"
            >
              <div class="event-time">
                <!-- 수급자/요양보호사 구분 텍스트 -->
                <span v-if="event.owner === 'recipient'">희망 시간</span>
                <span v-else-if="event.owner === 'caregiver'">{{ event.timeText }}</span>
                <span v-else>{{ event.timeText }}</span>
              </div>
              <div v-if="event.name" class="event-name">{{ event.name }}</div>
              <div v-if="event.service" class="event-service">{{ event.service }}</div>
            </div>
          </div>
        </div>
      </div>
  
      <!-- 하단 범례 -->
      <footer class="legend">
        <div class="legend-item">
          <span class="legend-color wish"></span>
          <span>수급자가 원하는 시간대</span>
        </div>
        <div class="legend-item">
          <span class="legend-color visit"></span>
          <span>요양보호사 가능 시간</span>
        </div>
      </footer>
    </div>
  </template>
  
  <script setup>
  import { computed } from 'vue'
  
  const props = defineProps({
    // 선택된 수급자(없으면 null)
    recipient: {
      type: Object,
      default: null,
    },
    // 선택된 요양보호사(없으면 null)
    caregiver: {
      type: Object,
      default: null,
    },
  })
  
  const days = ['월', '화', '수', '목', '금', '토', '일']
  const timeSlots = [
    '06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
    '12:00', '13:00', '14:00', '15:00', '16:00', '17:00',
    '18:00', '19:00', '20:00', '21:00', '22:00',
  ]
  
  // "화요일 14:00-16:00" -> { day: '화', start: '14:00', end: '16:00' }
  const parseKoreanTimeLabel = (label) => {
    if (!label) return null
    const regex = /([월화수목금토일])요일\s+(\d{1,2}:\d{2})-(\d{1,2}:\d{2})/
    const m = label.match(regex)
    if (!m) return null
  
    const [, day, rawStart, rawEnd] = m
  
    const normalize = (t) => {
      const [h, m] = t.split(':')
      return `${h.padStart(2, '0')}:${m.padStart(2, '0')}`
    }
  
    return {
      day,
      start: normalize(rawStart),
      end: normalize(rawEnd),
    }
  }
  
  // 수급자의 preferredTimes -> 이벤트
  const recipientEvents = computed(() => {
    if (!props.recipient?.preferredTimes?.length) return []
  
    return props.recipient.preferredTimes
      .map((text, idx) => {
        const slot = parseKoreanTimeLabel(text)
        if (!slot) return null
  
        return {
          id: `rec-${props.recipient.id}-${idx}`,
          owner: 'recipient',
          day: slot.day,
          start: slot.start,
          end: slot.end,
          type: 'wish', // 노란색
          timeText: `${slot.start}-${slot.end}`,
          name: null,
          service: null,
        }
      })
      .filter(Boolean)
  })
  
  // 요양보호사의 availableTimes -> 이벤트
  const caregiverEvents = computed(() => {
    if (!props.caregiver?.availableTimes?.length) return []
  
    return props.caregiver.availableTimes
      .map((text, idx) => {
        const slot = parseKoreanTimeLabel(text)
        if (!slot) return null
  
        return {
          id: `cg-${props.caregiver.id}-${idx}`,
          owner: 'caregiver',
          day: slot.day,
          start: slot.start,
          end: slot.end,
          type: 'visit-bath', // 초록 계열(css 재활용)
          timeText: `${slot.start}-${slot.end}`,
          name: props.caregiver.name,
          service: props.caregiver.services?.join(', ') || '',
        }
      })
      .filter(Boolean)
  })
  
  // 둘 다 합친 이벤트
  const allEvents = computed(() => [
    ...recipientEvents.value,
    ...caregiverEvents.value,
  ])
  
  // 요일별로 묶기
  const eventsByDay = computed(() => {
    const map = {}
    days.forEach(d => (map[d] = []))
    allEvents.value.forEach(ev => {
      if (map[ev.day]) map[ev.day].push(ev)
    })
    return map
  })
  
  // 이벤트 블록 위치 계산
  const eventStyle = (event) => {
    const [startH, startM] = event.start.split(':').map(Number)
    const [endH, endM] = event.end.split(':').map(Number)
  
    const slotHeight = 48 // 한 시간 행 높이
    const startIndex = startH - 6 + startM / 60
    const endIndex = endH - 6 + endM / 60
    const top = startIndex * slotHeight
    const height = (endIndex - startIndex) * slotHeight
  
    return {
      top: `${top}px`,
      height: `${height}px`,
    }
  }
  </script>
  
  <style scoped>
  .weekly-selected {
    background: #ffffff;
    border-radius: 16px;
    border: 1px solid #e5e7eb;
    padding: 16px 20px 12px;
    display: flex;
    flex-direction: column;
    gap: 10px;
  }
  
  /* 안쪽 상단 헤더 */
  .inner-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  
  .inner-title {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    color: #166534;
  }
  
  .week-nav {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    font-size: 13px;
    color: #4b5563;
  }
  
  .nav-btn {
    border: none;
    background: transparent;
    cursor: pointer;
    font-size: 16px;
    line-height: 1;
    padding: 2px 4px;
  }
  
  .week-range {
    font-weight: 500;
  }
  
  /* 헤더 row (시간 + 요일) */
  .grid-header {
    display: grid;
    grid-template-columns: 70px repeat(7, 1fr);
    font-size: 13px;
    color: #4b5563;
    margin-top: 4px;
    padding-top: 6px;
    border-top: 1px solid #f3f4f6;
  }
  
  .cell {
    padding: 2px 0 4px;
  }
  .time-header {
    text-align: center;
  }
  .day-header {
    text-align: center;
  }
  
  /* 몸통 그리드 */
  .grid-body {
    display: flex;
  }
  
  /* 왼쪽 시간축 */
  .time-column {
    width: 70px;
    display: flex;
    flex-direction: column;
    background: #f9fafb;
    border-right: 1px solid #e5e7eb;
  }
  .time-cell {
    height: 48px;
    font-size: 11px;
    color: #9ca3af;
    text-align: center;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  /* 오른쪽 요일 컬럼들 */
  .day-columns {
    flex: 1;
    display: grid;
    grid-template-columns: repeat(7, 1fr);
  }
  
  .day-column {
    position: relative;
    border-left: 1px solid #e5e7eb;
  }
  .day-column:last-child {
    border-right: 1px solid #e5e7eb;
  }
  .day-cell {
    height: 48px;
    border-bottom: 1px solid #f3f4f6;
  }
  
  /* 일정 블록 공통 */
  .event-block {
    position: absolute;
    left: 6px;
    right: 6px;
    border-radius: 8px;
    padding: 4px 6px;
    font-size: 11px;
    display: flex;
    flex-direction: column;
    gap: 2px;
    box-sizing: border-box;
  }
  
  /* 수급자 희망 시간 (노랑 – 가운데 정렬) */
  .event-block.wish {
    background: #fef9c3;
    border: 1px solid #facc15;
    color: #92400e;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-size: 13px;
    font-weight: 600;
  }
  
  /* 요양보호사 가능 시간(초록 – 사진 스타일) */
  .event-block.visit-bath {
    background: #dcfce7;
    border: 1px solid #86efac;
    color: #166534;
  }
  
  .event-time {
    font-weight: 600;
  }
  .event-name,
  .event-service {
    font-size: 11px;
  }
  
  /* 하단 범례 – 전체 폭 띠 */
  .legend {
    margin-top: 10px;
    padding: 8px 12px;
    background: #fffbeb;
    border-radius: 10px;
    display: flex;
    gap: 20px;
    font-size: 12px;
    color: #6b7280;
  }
  .legend-item {
    display: inline-flex;
    align-items: center;
    gap: 6px;
  }
  .legend-color {
    width: 14px;
    height: 14px;
    border-radius: 4px;
  }
  .legend-color.wish {
    background: #fef9c3;
    border: 1px solid #facc15;
  }
  .legend-color.visit {
    background: #dcfce7;
    border: 1px solid #86efac;
  }
  </style>