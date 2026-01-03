<template>
    <section class="panel">
      <header class="panel-header">
        <div class="panel-title">배정된 요양보호사 근무 시간</div>
        <div class="panel-sub">
          {{ careWorker?.name || '-' }}
          <span v-if="genderText" class="gender-pill">{{ genderText }}</span>
        </div>
      </header>
  
      <div class="block">
        <div class="block-title">근무 시간</div>
  
        <div v-if="workingTimes?.length" class="time-list">
          <div v-for="(w, idx) in workingTimes" :key="idx" class="time-row">
            <span class="dot"></span>
            <span class="time-text">
              {{ formatWorking(w) }}
              <span v-if="w.serviceTypeName"> · {{ w.serviceTypeName }}</span>
            </span>
          </div>
        </div>
  
        <div v-else class="empty">근무시간 정보가 없습니다.</div>
      </div>
    </section>
  </template>
  
  <script setup>
  import { computed } from 'vue'
  
  const props = defineProps({
    careWorker: { type: Object, default: null },
    workingTimes: { type: Array, default: () => [] },
  })
  
  const genderText = computed(() => {
    const g = props.careWorker?.gender
    if (!g) return ''
    if (g === 'M') return '남자'
    if (g === 'F') return '여자'
    return String(g)
  })
  
  const normalizeTime = (t) => {
    if (!t) return ''
    const s = String(t)
    return s.length >= 5 ? s.slice(0, 5) : s
  }
  
  const formatWorking = (w) => {
    if (!w) return '-'
  
    const dayRaw = w.dayName || w.day || ''
    const st = normalizeTime(w.startTime)
    const et = normalizeTime(w.endTime)
  
    const dayMap = { 1: '월', 2: '화', 3: '수', 4: '목', 5: '금', 6: '토', 7: '일' }
  
    const day = typeof dayRaw === 'number' ? (dayMap[dayRaw] || '') : String(dayRaw)
  
    if (!day || !st || !et) return '-'
    return `${day} ${st}-${et}`
  }
  </script>
  
  <style scoped>
  .panel {
    border: 1px solid #e5e7eb;
    border-radius: 16px;
    background: #ffffff;
    padding: 14px;
  }
  
  .panel-header {
    display: flex;
    flex-direction: column;
    gap: 2px;
    margin-bottom: 10px;
    padding-bottom: 10px;
    border-bottom: 1px solid #f3f4f6;
  }
  
  .panel-title {
    font-size: 13px;
    font-weight: 800;
    color: #111827;
  }
  
  .panel-sub {
    font-size: 12px;
    color: #6b7280;
    display: inline-flex;
    align-items: center;
    gap: 6px;
  }
  
  .gender-pill {
    font-size: 11px;
    padding: 2px 8px;
    border-radius: 999px;
    background: #dbeafe;
    color: #1d4ed8;
    border: 1px solid #bfdbfe;
  }
  
  .block {
    margin-top: 10px;
  }
  
  .block-title {
    font-size: 12px;
    font-weight: 700;
    color: #374151;
    margin-bottom: 6px;
  }
  
  .time-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  
  .time-row {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 13px;
    color: #111827;
  }
  
  .dot {
    width: 16px;
    height: 16px;
    border-radius: 999px;
    border: 3px solid #22c55e;
    background: #fff;
    box-sizing: border-box;
    flex: 0 0 16px;
  }
  
  .time-text {
    line-height: 1.45;
  }
  
  .empty {
    font-size: 13px;
    color: #9ca3af;
  }
  </style>