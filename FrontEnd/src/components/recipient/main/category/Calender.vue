<!-- src/components/recipient/category/Calender.vue -->
<template>
  <div>
    <div class="schedule-header">
      <button type="button" class="link-btn" @click="prevMonth">
        ← 이전달
      </button>
      <div class="schedule-title">
        {{ currentYear }}년 {{ currentMonth + 1 }}월
      </div>
      <button type="button" class="link-btn" @click="nextMonth">
        다음달 →
      </button>
    </div>

    <div class="schedule-legend">
      <span class="legend">
        <span class="dot dot-care"></span> 요양일정
      </span>
      <span class="legend">
        <span class="dot dot-fixed"></span> 고정일정
      </span>
    </div>

    <div class="calendar">
      <div class="calendar-header-cell" v-for="d in weekDays" :key="d">
        {{ d }}
      </div>
      <div
        v-for="(cell, index) in calendarCells"
        :key="index"
        class="calendar-cell"
        :class="{ 'is-today': cell.isToday }"
      >
        <div class="cell-date" :class="{ muted: !cell.isCurrentMonth }">
          {{ cell.date.getDate() }}
        </div>
        <div class="cell-events">
          <div
            v-for="ev in cell.events"
            :key="ev.id"
            class="event-pill"
            :class="{
              'event-care': ev.type === 'care',
              'event-fixed': ev.type === 'fixed'
            }"
          >
            {{ ev.time }} {{ ev.title }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'

const today = new Date()
const viewDate = ref(new Date(today.getFullYear(), today.getMonth(), 1))

const weekDays = ['일', '월', '화', '수', '목', '금', '토']

const currentYear = computed(() => viewDate.value.getFullYear())
const currentMonth = computed(() => viewDate.value.getMonth())

const scheduleEvents = ref([
  {
    id: 1,
    date: '2025-12-01',
    type: 'fixed',
    time: '09:00',
    title: '박민수'
  },
  {
    id: 2,
    date: '2025-12-05',
    type: 'care',
    time: '14:00',
    title: '박민수'
  },
  {
    id: 3,
    date: '2025-12-10',
    type: 'fixed',
    time: '09:00',
    title: '박민수'
  }
])

const calendarCells = computed(() => {
  const year = currentYear.value
  const month = currentMonth.value
  const firstDay = new Date(year, month, 1)
  const firstWeekDay = firstDay.getDay()
  const daysInMonth = new Date(year, month + 1, 0).getDate()
  const prevMonthDays = new Date(year, month, 0).getDate()

  const cells = []

  // 이전 달
  for (let i = firstWeekDay - 1; i >= 0; i--) {
    const date = new Date(year, month - 1, prevMonthDays - i)
    cells.push(makeCell(date, false))
  }

  // 현재 달
  for (let d = 1; d <= daysInMonth; d++) {
    const date = new Date(year, month, d)
    cells.push(makeCell(date, true))
  }

  // 다음 달 (총 6주 채우기)
  while (cells.length < 42) {
    const last = cells[cells.length - 1].date
    const next = new Date(last)
    next.setDate(last.getDate() + 1)
    cells.push(makeCell(next, false))
  }

  return cells
})

function makeCell(date, isCurrentMonth) {
  const yyyy = date.getFullYear()
  const mm = String(date.getMonth() + 1).padStart(2, '0')
  const dd = String(date.getDate()).padStart(2, '0')
  const key = `${yyyy}-${mm}-${dd}`

  const events = scheduleEvents.value.filter((ev) => ev.date === key)
  const isToday = date.toDateString() === new Date().toDateString()

  return { date, isCurrentMonth, events, isToday }
}

const prevMonth = () => {
  const d = new Date(viewDate.value)
  d.setMonth(d.getMonth() - 1)
  viewDate.value = d
}
const nextMonth = () => {
  const d = new Date(viewDate.value)
  d.setMonth(d.getMonth() + 1)
  viewDate.value = d
}
</script>

<style scoped>
.link-btn {
  border: none;
  background: transparent;
  font-size: 12px;
  color: #4b5563;
  cursor: pointer;
}

/* 헤더 */
.schedule-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}
.schedule-title {
  font-weight: 600;
}
.schedule-legend {
  display: flex;
  gap: 12px;
  font-size: 11px;
  color: #6b7280;
  margin-bottom: 6px;
}
.legend {
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

/* 점 */
.dot {
  width: 8px;
  height: 8px;
  border-radius: 999px;
}
.dot-care {
  background-color: #60a5fa;
}
.dot-fixed {
  background-color: #c4b5fd;
}

/* 캘린더 */
.calendar {
  display: grid;
  grid-template-columns: repeat(7, minmax(0, 1fr));
  border-radius: 10px;
  border: 1px solid #e5e7eb;
  overflow: hidden;
}
.calendar-header-cell {
  padding: 6px;
  text-align: center;
  font-size: 11px;
  background-color: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
}
.calendar-cell {
  min-height: 70px;
  border-bottom: 1px solid #f3f4f6;
  border-right: 1px solid #f3f4f6;
  padding: 4px;
  font-size: 11px;
  position: relative;
}
.calendar-cell:nth-child(7n) {
  border-right: none;
}
.cell-date {
  font-weight: 500;
  margin-bottom: 2px;
}
.cell-date.muted {
  color: #d1d5db;
}
.cell-events {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.event-pill {
  border-radius: 6px;
  padding: 2px 4px;
  font-size: 10px;
}
.event-care {
  background-color: #dbeafe;
  color: #1d4ed8;
}
.event-fixed {
  background-color: #ede9fe;
  color: #6d28d9;
}
.is-today {
  background-color: #f0fdf4;
}

@media (max-width: 1200px) {
  .calendar-cell {
    min-height: 60px;
  }
}
</style>
