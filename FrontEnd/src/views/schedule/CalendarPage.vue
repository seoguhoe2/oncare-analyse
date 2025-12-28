<template>
  <div class="calendar-layout">
    <div class="search-row">
      <SearchBar
        v-model:keyword="keyword"
        v-model:searchScope="searchScope"
      />
    </div>

    <div class="main-row">
      <div class="left-col">
        <Calendar
          :keyword="keyword"
          :search-scope="searchScope"
          :refresh-key="refreshKey"
          @select-date="onSelectDate"
        />

        <ScheduleList
          :selected-date="selectedDate"
          :keyword="keyword"
          :search-scope="searchScope"
          :refresh-key="refreshKey"
          @select-schedule="onSelectSchedule"
        />
      </div>

      <div class="right-col">
        <ScheduleDetail
          :schedule="selectedSchedule"
          @close="onCloseDetail"
          @refresh="refreshAll"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import SearchBar from '@/components/schedule/calendar/SearchBar.vue';
import Calendar from '@/components/schedule/calendar/Calendar.vue';
import ScheduleList from '@/components/schedule/calendar/ScheduleList.vue';
import ScheduleDetail from '@/components/schedule/calendar/ScheduleDetail.vue';

const formatDateKey = (date) => {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
};

const keyword = ref('');
const searchScope = ref('ALL');

const selectedDate = ref(formatDateKey(new Date()));
const selectedSchedule = ref(null);

const refreshKey = ref(0);

const refreshAll = () => {
  refreshKey.value += 1;
};

const onSelectDate = (dateKey) => {
  selectedDate.value = dateKey;
  selectedSchedule.value = null;
};

const onSelectSchedule = (item) => {
  selectedSchedule.value = item || null;
};

const onCloseDetail = () => {
  selectedSchedule.value = null;
};
</script>

<style scoped>
.calendar-layout {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.search-row {
  width: 49.3%;
}

.main-row {
  display: flex;
  gap: 20px;
  align-items: flex-start;
}

.left-col {
  flex: 1;
  max-width: 50%;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.right-col {
  flex: 1;
  max-width: 50%;
}
</style>