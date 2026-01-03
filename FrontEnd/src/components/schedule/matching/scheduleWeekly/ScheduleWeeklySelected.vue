<template>
  <div class="weekly-selected">
    <div class="grid-header">
      <div class="cell time-header">시간</div>
      <div v-for="day in days" :key="day" class="cell day-header">
        {{ day }}
      </div>
    </div>

    <div class="grid-body">
      <div class="time-column">
        <div v-for="time in timeSlots" :key="time" class="time-cell">
          {{ time }}
        </div>
      </div>

      <div class="day-columns">
        <div v-for="day in days" :key="day" class="day-column">
          <div v-for="time in timeSlots" :key="time" class="day-cell"></div>

          <div
            v-for="event in eventsByDay[day]"
            :key="event.id"
            class="event-block"
            :class="event.type"
            :style="eventStyle(event)"
          >
            <div class="event-time">{{ event.title }}</div>
            <div class="event-name">{{ event.timeText }}</div>
            <div v-if="event.service" class="event-service">{{ event.service }}</div>
          </div>
        </div>
      </div>
    </div>

    <footer class="legend">
      <div class="legend-item">
        <span class="legend-color wish"></span>
        <span>수급자 희망 시간</span>
      </div>
      <div class="legend-item">
        <span class="legend-color work"></span>
        <span>요양보호사 근무 시간</span>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { getBeneficiaryDetail, getCareWorkerDetail } from '@/api/schedule/matching.js'
import { useMatchingSelectionStore } from '@/stores/matchingSelection'

const props = defineProps({
  recipient: { type: Object, default: null },
  caregiver: { type: Object, default: null },
  refreshKey: { type: Number, default: 0 },
})

const store = useMatchingSelectionStore()

const days = ['월', '화', '수', '목', '금', '토', '일']
const timeSlots = [
  '06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
  '12:00', '13:00', '14:00', '15:00', '16:00', '17:00',
  '18:00', '19:00', '20:00', '21:00', '22:00',
]

const getBeneficiaryId = (obj) => obj?.beneficiaryId ?? obj?.id ?? null
const getCareWorkerId = (obj) => obj?.careWorkerId ?? obj?.id ?? null

const loading = ref(false)
const error = ref('')

const recipientDetail = ref(null)
const caregiverDetail = ref(null)

/* ===== API ===== */
async function loadRecipientDetail() {
  const beneficiaryId = getBeneficiaryId(props.recipient)
  if (!beneficiaryId) {
    recipientDetail.value = null
    return
  }

  try {
    loading.value = true
    error.value = ''
    const res = await getBeneficiaryDetail(beneficiaryId)
    recipientDetail.value = res?.data ?? res ?? null
  } catch (e) {
    recipientDetail.value = null
    error.value = e?.response?.data?.message || '주간 일정을 불러오지 못했습니다.'
  } finally {
    loading.value = false
  }
}

async function loadCaregiverDetail() {
  const careWorkerId = getCareWorkerId(props.caregiver)
  if (!careWorkerId) {
    caregiverDetail.value = null
    return
  }

  try {
    const res = await getCareWorkerDetail(careWorkerId)
    caregiverDetail.value = res?.data ?? res ?? null
  } catch (e) {
    caregiverDetail.value = null
  }
}

function reloadBoth() {
  loadRecipientDetail()
  loadCaregiverDetail()
}

/* ===== watch ===== */
watch(
  () => getBeneficiaryId(props.recipient),
  () => loadRecipientDetail(),
  { immediate: true }
)

watch(
  () => getCareWorkerId(props.caregiver),
  () => loadCaregiverDetail(),
  { immediate: true }
)

watch(
  () => props.refreshKey,
  () => reloadBoth()
)

watch(
  () => store.refreshTick,
  () => reloadBoth()
)

/* ===== 데이터 가공 ===== */
const dayToKor = (day) => {
  const map = { 1: '월', 2: '화', 3: '수', 4: '목', 5: '금', 6: '토', 7: '일' }
  return map[day] || ''
}

const normalizeTime = (t) => {
  if (!t) return ''
  const s = String(t)
  return s.length >= 5 ? s.slice(0, 5) : s
}

const recipientEvents = computed(() => {
  const beneficiaryId = getBeneficiaryId(props.recipient)
  const schedules = recipientDetail.value?.schedules || []
  if (!beneficiaryId || !Array.isArray(schedules)) return []

  return schedules
    .map((s, idx) => {
      const day = s.dayName || dayToKor(s.day)
      const start = normalizeTime(s.startTime)
      const end = normalizeTime(s.endTime)
      if (!day || !start || !end) return null

      return {
        id: `rec-${beneficiaryId}-${idx}`,
        day,
        start,
        end,
        type: 'wish',
        title: '희망 시간',
        timeText: `${start}-${end}`,
        service: s.serviceTypeName || '',
      }
    })
    .filter(Boolean)
})

const caregiverEvents = computed(() => {
  const careWorkerId = getCareWorkerId(props.caregiver)
  const times = caregiverDetail.value?.workingTimes || []
  if (!careWorkerId || !Array.isArray(times)) return []

  return times
    .map((w, idx) => {
      const day = w.dayName || dayToKor(w.day)
      const start = normalizeTime(w.startTime)
      const end = normalizeTime(w.endTime)
      if (!day || !start || !end) return null

      return {
        id: `cw-${careWorkerId}-${idx}`,
        day,
        start,
        end,
        type: 'work',
        title: '근무',
        timeText: `${start}-${end}`,
        service: w.serviceTypeName || '',
      }
    })
    .filter(Boolean)
})

const eventsByDay = computed(() => {
  const map = {}
  days.forEach((d) => (map[d] = []))

  ;[...recipientEvents.value].forEach((ev) => {
    if (map[ev.day]) map[ev.day].push(ev)
  })

  Object.keys(map).forEach((k) => {
    map[k].sort((a, b) => (a.type === b.type ? 0 : a.type === 'work' ? -1 : 1))
  })

  return map
})

const eventStyle = (event) => {
  const [sh, sm] = event.start.split(':').map(Number)
  const [eh, em] = event.end.split(':').map(Number)

  const slotHeight = 48
  const startIndex = sh - 6 + sm / 60
  const endIndex = eh - 6 + em / 60

  const top = startIndex * slotHeight
  const height = (endIndex - startIndex) * slotHeight

  return { top: `${top}px`, height: `${height}px` }
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

.grid-body {
  display: flex;
}

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

.event-block {
  position: absolute;
  left: 6px;
  right: 6px;
  border-radius: 8px;
  padding: 6px 8px;
  font-size: 11px;
  display: flex;
  flex-direction: column;
  gap: 2px;
  box-sizing: border-box;
}

/* 수급자 희망 */
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

.event-block.work {
  background: #dcfce7;
  border: 1px solid #86efac;
  color: #166534;
}

.event-time {
  font-weight: 700;
}
.event-name,
.event-service {
  font-size: 11px;
}

.legend {
  margin-top: 10px;
  padding: 8px 12px;
  background: #f9fafb;
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
.legend-color.work {
  background: #dcfce7;
  border: 1px solid #86efac;
}
</style>