<template>
  <section class="calendar-panel">
    <div class="calendar-header">
      <div class="calendar-title-group">
        <h2 class="month-title">{{ monthTitle }}</h2>
        <h4 class="calendar-mode-text">{{ calendarModeText }}</h4>
      </div>

      <div class="month-controls">
        <button class="arrow-btn" type="button" @click="goPrevMonth">‹</button>
        <button class="arrow-btn" type="button" @click="goNextMonth">›</button>
      </div>
    </div>

    <div class="legend-row">
      <span class="legend-item"><span class="legend-dot type-visit"></span> 방문 요양</span>
      <span class="legend-item"><span class="legend-dot type-bath"></span> 방문 목욕</span>
      <span class="legend-item"><span class="legend-dot type-nurse"></span> 방문 간호</span>
    </div>

    <div class="calendar-grid">
      <div
        v-for="(label, idx) in weekdayLabels"
        :key="label"
        class="weekday-cell"
        :class="{ 'weekday-sun': idx === 0, 'weekday-sat': idx === 6 }"
      >
        {{ label }}
      </div>

      <div
        v-for="day in calendarDays"
        :key="day.key"
        class="day-cell"
        :class="{
          'other-month': !day.inCurrentMonth,
          'sunday-cell': day.isSunday,
          'saturday-cell': day.isSaturday,
          'selected-cell': isSelected(day),
        }"
        @click="onDayClick(day)"
      >
        <div class="day-header">
          <span class="day-number" :class="{ 'today-number': day.isToday }">
            {{ day.date.getDate() }}
          </span>
          <span v-if="day.isToday" class="today-label">오늘</span>
        </div>

        <div v-if="day.summary" class="badge-row">
          <span v-if="day.summary.care" class="badge badge-care">
            요양 {{ day.summary.care }}
          </span>
          <span v-if="day.summary.bath" class="badge badge-bath">
            목욕 {{ day.summary.bath }}
          </span>
          <span v-if="day.summary.nurse" class="badge badge-nurse">
            간호 {{ day.summary.nurse }}
          </span>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
  import { ref, computed, watch } from 'vue';
  import { getScheduleRangeCounts } from '@/api/schedule/scheduleApi';
  import { getConfirmedScheduleRangeCounts } from '@/api/schedule/confirmedScheduleApi';
  
  const props = defineProps({
    keyword: { type: String, default: '' },
    searchScope: { type: String, default: 'ALL' }, // BENEFICIARY | CAREWORKER | SERVICE | ALL
    refreshKey: { type: Number, default: 0 }, 
  });
  
  const emit = defineEmits(['select-date']);
  
  const weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];
  
  const today = new Date();
  const year = ref(today.getFullYear());
  const month = ref(today.getMonth());
  
  /* -------------------- util -------------------- */
  const formatDateKey = (date) => {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  };
  
  const parseDateKey = (key) => {
    // key: YYYY-MM-DD
    const [y, m, d] = key.split('-').map((v) => Number(v));
    return new Date(y, m - 1, d);
  };
  
  const monthIndex = (y, m) => y * 12 + m;
  
  /* -------------------- state -------------------- */
  const summaryByDate = ref(new Map());
  const selectedDateKey = ref(formatDateKey(today));
  
  const monthTitle = computed(() => `${year.value}년 ${month.value + 1}월`);

  const isViewMonthConfirmed = computed(() => {
    const base = monthIndex(today.getFullYear(), today.getMonth()); // N월(오늘 월)
    const view = monthIndex(year.value, month.value);               // 현재 달력에서 보고 있는 월

    if (view <= base - 1) return true;

    const isBefore25 = today.getDate() < 25;

    if (isBefore25) {
      return view === base; // N월만 confirmed
    }

    return view === base || view === base + 1; // 25일 이후: N월, N+1월 confirmed
  });

const calendarModeText = computed(() => (isViewMonthConfirmed.value ? '' : '예정 스케줄'));

  const displayRange = computed(() => {
    const first = new Date(year.value, month.value, 1);
    const startPad = first.getDay(); // 0~6
    const start = new Date(year.value, month.value, 1 - startPad);
  
    const last = new Date(year.value, month.value + 1, 0); // 말일
    const endPad = 6 - last.getDay(); // 토요일까지 채우기
    const end = new Date(year.value, month.value + 1, 0 + endPad);
  
    return { start, end };
  });
  
  const calendarDays = computed(() => {
    const { start, end } = displayRange.value;
  
    const days = [];
    const cur = new Date(start);
  
    while (cur <= end) {
      const date = new Date(cur);
      const key = formatDateKey(date);
      const summary = summaryByDate.value.get(key) || null;
  
      days.push({
        key,
        date,
        inCurrentMonth:
          date.getFullYear() === year.value && date.getMonth() === month.value,
        isToday: date.toDateString() === today.toDateString(),
        isSunday: date.getDay() === 0,
        isSaturday: date.getDay() === 6,
        summary,
      });
  
      cur.setDate(cur.getDate() + 1);
    }
  
    return days;
  });
  
  const isSelected = (day) => formatDateKey(day.date) === selectedDateKey.value;
  
  /* -------------------- month navigation -------------------- */
  const goPrevMonth = () => {
    if (month.value === 0) {
      month.value = 11;
      year.value -= 1;
    } else {
      month.value -= 1;
    }
  };
  
  const goNextMonth = () => {
    if (month.value === 11) {
      month.value = 0;
      year.value += 1;
    } else {
      month.value += 1;
    }
  };
  
  const onDayClick = (day) => {
    const key = formatDateKey(day.date);
    selectedDateKey.value = key;
    emit('select-date', key);
  };
  
  const shouldUseConfirmedByDate = (dateObj) => {
    const base = monthIndex(today.getFullYear(), today.getMonth()); // N월
    const view = monthIndex(dateObj.getFullYear(), dateObj.getMonth());
  
    // N 전달 이전은 무조건 confirmed
    if (view <= base - 1) return true;
  
    const isBefore25 = today.getDate() < 25;
  
    if (isBefore25) {
      if (view === base) return true;       // N월 confirmed
      if (view === base + 1) return false;  // N+1월 normal
    } else {
      if (view === base || view === base + 1) return true; // N월, N+1월 confirmed
      if (view === base + 2) return false;                 // N+2월 normal
    }
  
    return false; // 그 외는 normal
  };
  
  /**
   * ✅ displayRange를 "confirmed 구간" / "normal 구간"으로 나누기
   * - 날짜가 섞여 있어도 구간별로 API를 다르게 호출 가능
   */
  const buildSegments = (startDate, endDate, predicate) => {
    const segments = [];
    const cur = new Date(startDate);
  
    let segStart = null;
    let segFlag = null;
  
    while (cur <= endDate) {
      const d = new Date(cur);
      const flag = Boolean(predicate(d));
  
      if (segStart == null) {
        segStart = new Date(d);
        segFlag = flag;
      } else if (flag !== segFlag) {
        const prev = new Date(d);
        prev.setDate(prev.getDate() - 1);
        segments.push({
          flag: segFlag, // true=confirmed, false=normal
          start: new Date(segStart),
          end: new Date(prev),
        });
        segStart = new Date(d);
        segFlag = flag;
      }
  
      cur.setDate(cur.getDate() + 1);
    }
  
    if (segStart != null) {
      segments.push({
        flag: segFlag,
        start: new Date(segStart),
        end: new Date(endDate),
      });
    }
  
    return segments;
  };
  
  /* -------------------- load -------------------- */
  const loadRangeCounts = async () => {
    const { start, end } = displayRange.value;
  
    const searchField =
      props.searchScope && props.searchScope !== 'ALL'
        ? props.searchScope
        : null;
  
    const baseParams = {
      keyword: props.keyword,
      searchField,
    };

    const isInVisibleMonthForBadges = (dateKey) => {
      // dateKey: 'YYYY-MM-DD'
      const [y, m, d] = dateKey.split('-').map(Number);
      const dt = new Date(y, m - 1, d);
      return dt.getFullYear() === year.value && dt.getMonth() === month.value;
    };

    // ✅ displayRange 내부 날짜를 기준으로 confirmed/normal 구간 분리
    const segments = buildSegments(start, end, shouldUseConfirmedByDate);
  
    const map = new Map();
  
    for (const seg of segments) {
      const params = {
        ...baseParams,
        start: formatDateKey(seg.start),
        end: formatDateKey(seg.end),
      };
  
      // seg.flag === true -> confirmed, false -> normal
      const preferredFetcher = seg.flag
        ? getConfirmedScheduleRangeCounts
        : getScheduleRangeCounts;
  
      let data = [];
      try {
        data = await preferredFetcher(params);
      } catch (e) {
        // ✅ confirmed가 500이면 해당 구간만 normal로 폴백
        if (seg.flag) {
          console.warn('[calendar] confirmed segment failed → fallback normal', params, e);
          data = await getScheduleRangeCounts(params);
        } else {
          throw e;
        }
      }
  
      (Array.isArray(data) ? data : []).forEach((row) => {
        if (!isInVisibleMonthForBadges(row.date)) return;

        map.set(row.date, {
          care: row.careCount || 0,
          bath: row.bathCount || 0,
          nurse: row.nurseCount || 0,
        });
      });
    }
  
    summaryByDate.value = map;
  };

  let timer = null;
  watch(
    () => [year.value, month.value, props.keyword, props.searchScope, props.refreshKey],
    () => {
      clearTimeout(timer);
      timer = setTimeout(loadRangeCounts, 250);
    },
    { immediate: true }
  );
  </script>

<style scoped>
  .calendar-panel {
  box-sizing: border-box;
  width: 100%;
  background: #ffffff;
  border-radius: 22px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 3px 12px rgba(15, 23, 42, 0.04);
  padding: 14px 18px 18px;
}

.calendar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}

.calendar-title-group {
  display: flex;
  align-items: baseline;
  gap: 10px;
  min-width: 0;
}

.month-title {
  font-size: 22px;
  font-weight: 700;
  color: #15803d;
  margin: 0;
}

.calendar-mode-text {
  font-size: 18px;
  font-weight: 600;
  color: #16a34a;
  margin: 0;
  white-space: nowrap;
}

.month-controls {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-shrink: 0;
}

.arrow-btn {
  border: none;
  background: transparent;
  cursor: pointer;
  font-size: 16px;
  padding: 0 3px;
}

.legend-row {
  display: flex;
  gap: 12px;
  font-size: 12px;
  color: #4b5563;
  margin: 8px 0 12px;
}

.legend-item {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.legend-dot {
  width: 11px;
  height: 11px;
  border-radius: 999px;
}

.legend-dot.type-visit { background: #bfdbfe; }
.legend-dot.type-bath { background: #ffe4ef; }
.legend-dot.type-nurse { background: #dcfce7; }

.calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  row-gap: 6px;
  column-gap: 6px;
}

.weekday-cell {
  text-align: center;
  font-size: 12px;
  font-weight: 500;
  color: #6b7280;
  padding-bottom: 4px;
}

.weekday-sun { color: #ef4444; }
.weekday-sat { color: #3b82f6; }

.day-cell {
  min-height: 70px;
  border-radius: 14px;
  border: 1px solid #e5e7eb;
  background: #ffffff;
  padding: 6px 8px;
  font-size: 13px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  cursor: pointer;
}

.other-month .day-number { color: #cbd5e1; }
.sunday-cell .day-number { color: #ef4444; }
.saturday-cell .day-number { color: #3b82f6; }

.selected-cell {
  border-color: #4ade80;
  box-shadow: 0 0 0 2px rgba(74, 222, 128, 0.3);
}

.day-header {
  display: flex;
  align-items: center;
  gap: 4px;
}

.day-number {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 22px;
  height: 22px;
  border-radius: 999px;
}

.today-number {
  background: #22c55e;
  color: #ffffff;
}

.today-label {
  font-size: 11px;
  color: #16a34a;
}

.badge-row {
  display: flex;
  flex-wrap: wrap;
  gap: 3px;
}

.badge {
  padding: 1px 6px;
  border-radius: 999px;
  font-size: 10px;
}

.badge-care { background: #dbeafe; color: #2563eb; }
.badge-bath { background: #ffe4ef; color: #be185d; }
.badge-nurse { background: #dcfce7; color: #15803d; }
</style>