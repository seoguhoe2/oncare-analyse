<template>
  <section class="schedule-panel">
    <div class="schedule-header">
      <div class="schedule-title-row">
        <h3 class="schedule-title">{{ headerTitle }}</h3>

        <div class="tag-row" v-if="dailySchedules.length">
          <span v-if="summary.care" class="service-tag type-care">요양 {{ summary.care }}</span>
          <span v-if="summary.bath" class="service-tag type-bath">목욕 {{ summary.bath }}</span>
          <span v-if="summary.nurse" class="service-tag type-nurse">간호 {{ summary.nurse }}</span>
        </div>
      </div>
    </div>

    <div class="schedule-table-wrapper">
      <table v-if="dailySchedules.length" class="schedule-table">
        <thead>
          <tr>
            <th>시간</th>
            <th>요양보호사</th>
            <th>수급자</th>
            <th>서비스</th>
            <th>소요시간</th>
          </tr>
        </thead>

        <tbody>
          <tr
            v-for="(item, idx) in dailySchedules"
            :key="item.matchingId ?? item.vsId ?? idx"
            class="table-row"
            :class="{ selected: (item.matchingId ?? item.vsId) === selectedMatchingId }"
            @click="onRowClick(item)"
          >
            <td class="col-time">
              {{ formatTimeHM(item.startTime) }} - {{ formatTimeHM(item.endTime) }}
            </td>
            <td>{{ item.careWorkerName }}</td>
            <td>{{ item.beneficiaryName }}</td>
            <td>
              <span
                class="service-badge"
                :class="{
                  'badge-care': item.serviceTypeId === 1,
                  'badge-bath': item.serviceTypeId === 2,
                  'badge-nurse': item.serviceTypeId === 3,
                }"
              >
                {{ item.serviceTypeName }}
              </span>
            </td>
            <td class="col-duration">{{ formatDuration(item.durationMinutes) }}</td>
          </tr>
        </tbody>
      </table>

      <div v-else class="empty-row">선택한 날짜에 일정이 없습니다.</div>
    </div>
  </section>
</template>

<script setup>
  import { computed, ref, watch } from 'vue';
  import { getScheduleDayList } from '@/api/schedule/scheduleApi';
  import { getConfirmedScheduleDayList } from '@/api/schedule/confirmedScheduleApi';
  
  const props = defineProps({
    selectedDate: { type: String, default: '' }, // "YYYY-MM-DD"
    keyword: { type: String, default: '' },
    searchScope: { type: String, default: 'ALL' }, // BENEFICIARY | CAREWORKER | SERVICE | ALL
  });
  
  const emit = defineEmits(['select-schedule']);
  
  const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
  const selectedMatchingId = ref(null);
  
  const headerTitle = computed(() => {
    if (!props.selectedDate) return '일정을 선택해주세요';
    const d = new Date(props.selectedDate);
    if (Number.isNaN(d.getTime())) return '일정을 선택해주세요';
    const month = d.getMonth() + 1;
    const date = d.getDate();
    const weekday = weekdays[d.getDay()];
    return `${month}월 ${date}일 (${weekday}) 일정`;
  });
  
  const dailySchedules = ref([]);
  
  const summary = computed(() => {
    const result = { care: 0, bath: 0, nurse: 0 };
    dailySchedules.value.forEach((item) => {
      if (item.serviceTypeId === 1) result.care += 1;
      if (item.serviceTypeId === 2) result.bath += 1;
      if (item.serviceTypeId === 3) result.nurse += 1;
    });
    return result;
  });
  
  const formatTimeHM = (t) => {
    const s = String(t ?? '');
    if (!s) return '';
    if (s.includes('T')) {
      const timePart = s.split('T')[1] || '';
      return timePart.slice(0, 5);
    }
    return s.slice(0, 5);
  };
  
  const formatDuration = (minutes) => {
    const m = Number(minutes);
    if (!Number.isFinite(m) || m <= 0) return '0분';
    const h = Math.floor(m / 60);
    const r = m % 60;
    if (h <= 0) return `${r}분`;
    if (r === 0) return `${h}시간`;
    return `${h}시간 ${r}분`;
  };
  
  const today = new Date();
  const monthIndex = (y, m) => y * 12 + m;
  
  /**
   * ✅ N월 기준 규칙 적용
   * - N 전달 이전(view <= N-1): 무조건 Confirmed
   * - 25일 기준 분기:
   *    <25:  N월 confirmed, N+1월 normal
   *    >=25: N월, N+1월 confirmed, N+2월 normal
   */
  const getDayListFetcherBySelectedDate = (selectedDateStr) => {
    if (!selectedDateStr) return getScheduleDayList;
  
    const d = new Date(selectedDateStr);
    if (Number.isNaN(d.getTime())) return getScheduleDayList;
  
    const base = monthIndex(today.getFullYear(), today.getMonth()); // N월
    const view = monthIndex(d.getFullYear(), d.getMonth());
  
    if (view <= base - 1) return getConfirmedScheduleDayList;
  
    const isBefore25 = today.getDate() < 25;
  
    if (isBefore25) {
      if (view === base) return getConfirmedScheduleDayList;
      if (view === base + 1) return getScheduleDayList;
    } else {
      if (view === base || view === base + 1) return getConfirmedScheduleDayList;
      if (view === base + 2) return getScheduleDayList;
    }
  
    return getScheduleDayList;
  };
  
  /** ✅ 현재 선택 날짜 기준으로 confirmed 여부 판단 (emit에 같이 전달용) */
  const isConfirmedMonthBySelectedDate = (selectedDateStr) => {
    if (!selectedDateStr) return false;
  
    const d = new Date(selectedDateStr);
    if (Number.isNaN(d.getTime())) return false;
  
    const base = monthIndex(today.getFullYear(), today.getMonth()); // N월
    const view = monthIndex(d.getFullYear(), d.getMonth());
  
    if (view <= base - 1) return true;
  
    const isBefore25 = today.getDate() < 25;
  
    if (isBefore25) {
      if (view === base) return true;
      if (view === base + 1) return false;
    } else {
      if (view === base || view === base + 1) return true;
      if (view === base + 2) return false;
    }
  
    return false;
  };
  
  const loadDay = async () => {
    selectedMatchingId.value = null;
  
    if (!props.selectedDate) {
      dailySchedules.value = [];
      return;
    }
  
    const searchField =
      props.searchScope && props.searchScope !== 'ALL'
        ? props.searchScope
        : null;
  
    const fetcher = getDayListFetcherBySelectedDate(props.selectedDate);
  
    const data = await fetcher({
      date: props.selectedDate,
      keyword: props.keyword,
      searchField,
    });
  
    dailySchedules.value = Array.isArray(data) ? data : [];
  };
  
  let timer = null;
  watch(
    () => [props.selectedDate, props.keyword, props.searchScope],
    () => {
      clearTimeout(timer);
      timer = setTimeout(loadDay, 250);
    },
    { immediate: true }
  );
  
  const onRowClick = (item) => {
    selectedMatchingId.value = item.matchingId ?? item.vsId ?? null;
  
    const confirmed = isConfirmedMonthBySelectedDate(props.selectedDate);
  
    emit('select-schedule', {
      ...item,
      source: confirmed ? 'CONFIRMED' : 'NORMAL',
    });
  };
</script>

<style scoped>
.schedule-panel {
  box-sizing: border-box;
  width: 100%;
  background: #ffffff;
  border-radius: 20px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 3px 12px rgba(15, 23, 42, 0.04);
  padding: 14px 18px 18px;
}

.schedule-title-row {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 10px;
}

.schedule-title {
  font-size: 17px;
  font-weight: 700;
  color: #15803d;
  margin: 0;
}

.tag-row {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.service-tag {
  padding: 3px 8px;
  border-radius: 999px;
  font-size: 11px;
}

.type-care { background: #dbeafe; color: #1d4ed8; }
.type-bath { background: #ffe4ef; color: #be185d; }
.type-nurse { background: #dcfce7; color: #15803d; }

.schedule-table-wrapper {
  margin-top: 10px;
  border-radius: 14px;
  overflow: hidden;
  border: 1px solid #e5e7eb;
  background: #ffffff;
}

.schedule-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}

.schedule-table thead { background: #f9fafb; }

.schedule-table th,
.schedule-table td {
  padding: 9px 12px;
  text-align: left;
}

.schedule-table th {
  color: #6b7280;
  font-weight: 500;
  border-bottom: 1px solid #e5e7eb;
}

.schedule-table tbody tr + tr td {
  border-top: 1px solid #f3f4f6;
}

.table-row { cursor: pointer; }
.table-row:hover { background: #f9fafb; }

.col-time,
.col-duration { white-space: nowrap; }

.service-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 3px 8px;
  border-radius: 999px;
  font-size: 11px;
}

.badge-care { background: #dbeafe; color: #1d4ed8; }
.badge-bath { background: #ffe4ef; color: #be185d; }
.badge-nurse { background: #dcfce7; color: #15803d; }

.empty-row {
  padding: 18px 12px;
  text-align: center;
  font-size: 13px;
  color: #9ca3af;
  background: #f9fafb;
}

.table-row.selected {
  background: #d7f3dd;
}
</style>