<template>
  <section class="detail-panel">
    <!-- placeholder -->
    <div v-if="!viewModel" class="placeholder">
      <div class="placeholder-icon">
        <img
          :src="scheduleManagementIcon"
          alt="일정 선택"
          class="calendar-icon-img"
        />
      </div>
      <p class="placeholder-main">일정을 선택하면</p>
      <p class="placeholder-sub">상세 정보가 표시됩니다</p>
    </div>

    <!-- content -->
    <div v-else class="detail-content">
      <div class="detail-header">
        <div class="header-top">
          <h3 class="detail-title">일정 상세</h3>
          <button class="close-btn" type="button" @click="onClose">
            <img :src="closeIcon" alt="close" />
          </button>
        </div>

        <div class="header-bottom">
          <span
            class="type-pill"
            :class="typePillClass(viewModel.serviceTypeId)"
          >
            {{ viewModel.serviceTypeName }}
          </span>
        </div>
      </div>

      <div class="detail-body">
        <div class="top-grid">
          <!-- schedule box -->
          <div class="schedule-box">
            <div class="schedule-box-title">
              <img :src="detailClockIcon" alt="clock" class="schedule-icon" />
              <span class="schedule-title">일정</span>
            </div>

            <div class="info-row">
              <span class="label">날짜:</span>
              <span class="value">{{ formatDate(viewModel.date) }}</span>
            </div>
            <div class="info-row">
              <span class="label">시작:</span>
              <span class="value">{{ formatTimeHM(viewModel.startTime) }}</span>
            </div>
            <div class="info-row">
              <span class="label">종료:</span>
              <span class="value">{{ formatTimeHM(viewModel.endTime) }}</span>
            </div>
            <div class="info-row">
              <span class="label">소요시간:</span>
              <span class="value strong">{{ formatDuration(viewModel.durationMinutes) }}</span>
            </div>
          </div>

          <!-- people -->
          <div class="person-col">
            <div class="person-card">
              <img :src="memberIcon" alt="member" class="member-icon" />
              <div class="person-text">
                수급자&nbsp;&nbsp;{{ viewModel.beneficiaryName }}
              </div>
            </div>

            <div class="person-card">
              <img :src="memberIcon" alt="member" class="member-icon" />
              <div class="person-text-wrap">
                <div class="person-text">
                  요양보호사&nbsp;&nbsp;{{ viewModel.careWorkerName }}
                </div>
              </div>
            </div>

            <!-- status -->
            <div class="person-card status-card">
              <div
                v-if="viewModel.status"
                class="status-text"
                :class="statusClass(viewModel.status)"
              >
                {{ statusLabel(viewModel.status) }}
              </div>
              <div v-else class="status-text status-empty">-</div>
            </div>
          </div>
        </div>

        <AlternateCareWorkers />

        <ScheduleMemo
          :source="schedule?.source || 'NORMAL'"
          :matching-id="viewModel?.matchingId ?? null"
          :vs-id="viewModel?.vsId ?? schedule?.vsId ?? null"
          :memo-date="formatDate(viewModel?.date)"
        />
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed, ref, watch } from 'vue';

import AlternateCareWorkers from '@/components/schedule/calendar/detail/AlternateCareWorkers.vue';
import ScheduleMemo from '@/components/schedule/calendar/detail/ScheduleMemo.vue';

import { getScheduleDetail } from '@/api/schedule/scheduleApi';
import { getConfirmedScheduleDetail } from '@/api/schedule/confirmedScheduleApi';

import detailClockIcon from '@/assets/img/schedule/detailClock.png';
import memberIcon from '@/assets/img/schedule/member.png';
import closeIcon from '@/assets/img/common/closeButton.png';
import scheduleManagementIcon from '@/assets/img/common/scheduleManagement.png';

const props = defineProps({
  schedule: { type: Object, default: null },
});

const emit = defineEmits(['close']);

const loading = ref(false);
const detail = ref(null);

const schedule = computed(() => props.schedule || null);
const viewModel = computed(() => detail.value || schedule.value || null);

const formatDate = (v) => {
  const s = String(v ?? '');
  if (!s) return '';
  return s.includes('T') ? s.split('T')[0] : s.slice(0, 10);
};

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

const typePillClass = (serviceTypeId) => {
  const n = Number(serviceTypeId);
  if (n === 1) return 'pill-care';
  if (n === 2) return 'pill-bath';
  if (n === 3) return 'pill-nurse';
  return '';
};

const statusLabel = (status) => {
  const s = String(status ?? '').toUpperCase();
  if (s === 'SCHEDULED' || s === 'PLANNED') return '방문 예정';
  if (s === 'IN_PROGRESS') return '방문 진행중';
  if (s === 'DONE') return '방문 완료';
  return '';
};

const statusClass = (status) => {
  const s = String(status ?? '').toUpperCase();
  if (s === 'SCHEDULED' || s === 'PLANNED') return 'status-planned';
  if (s === 'IN_PROGRESS') return 'status-progress';
  if (s === 'DONE') return 'status-done';
  return '';
};

const loadDetail = async () => {
  detail.value = null;
  if (!schedule.value) return;

  loading.value = true;
  try {
    const src = schedule.value.source;

    if (src === 'CONFIRMED') {
      const vsId = schedule.value.vsId ?? schedule.value.matchingId;
      if (!vsId) {
        detail.value = schedule.value;
        return;
      }
      detail.value = await getConfirmedScheduleDetail({ vsId });
      return;
    }

    detail.value = await getScheduleDetail({
      matchingId: schedule.value.matchingId,
      date: formatDate(schedule.value.date),
      serviceTypeId: schedule.value.serviceTypeId,
      startTime: schedule.value.startTime,
    });
  } catch (e) {
    detail.value = schedule.value;
    console.error('[ScheduleDetail] loadDetail failed:', e);
  } finally {
    loading.value = false;
  }
};

watch(
  () => schedule.value,
  () => loadDetail(),
  { immediate: true }
);

const memoMatchingId = computed(() => {
  const vm = viewModel.value;
  if (!vm) return null;
  return vm.matchingId ?? vm.vsId ?? null;
});

const onClose = () => emit('close');
</script>

<style scoped>
.detail-panel {
  box-sizing: border-box;
  width: 100%;
  height: 100%;
  background: #ffffff;
  border-radius: 24px;
  border: 1px solid #d7f3dd;
  box-shadow: 0 4px 16px rgba(15, 23, 42, 0.05);
  overflow: hidden;
}

.placeholder {
  height: 100%;
  min-height: 360px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #9ca3af;
  padding: 24px;
}

.placeholder-icon {
  margin-bottom: 16px;
}

.calendar-icon-img {
  width: 33px;
  height: 33px;
}

.placeholder-main {
  font-size: 16px;
  margin: 0;
}

.placeholder-sub {
  font-size: 14px;
  margin: 4px 0 0;
}

.detail-content {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.detail-header {
  background: #ecfdf1;
  padding: 18px 20px 14px;
  border-bottom: 1px solid #e5e7eb;
}

.header-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.detail-title {
  font-size: 20px;
  font-weight: 600;
  color: #388e3c;
  margin: 0;
}

.close-btn {
  border: none;
  background: transparent;
  padding: 0;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.close-btn img {
  width: 22px;
  height: 40px;
}

.header-bottom {
  margin-top: 10px;
}

.type-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
  border: 1px solid rgba(34, 197, 94, 0.35);
  background: #dfffe9;
  color: #166534;
}

.pill-care {
  background: #dbeafe;
  color: #1d4ed8;
  border-color: rgba(29, 78, 216, 0.25);
}

.pill-bath {
  background: #ffe4ef;
  color: #be185d;
  border-color: rgba(190, 24, 93, 0.25);
}

.pill-nurse {
  background: #dcfce7;
  color: #15803d;
  border-color: rgba(21, 128, 61, 0.25);
}

.detail-body {
  padding: 14px 18px 18px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.top-grid {
  display: grid;
  grid-template-columns: 1.4fr 1fr;
  gap: 16px;
  align-items: start;
}

/* left */
.schedule-box {
  background: #f9fafb;
  border-radius: 14px;
  border: 2px solid #e5e7eb;
  padding: 14px 16px;
}

.schedule-box-title {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.schedule-icon {
  width: 18px;
  height: 18px;
}

.schedule-title {
  font-size: 14px;
  font-weight: 600;
  color: #4a5565;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
  padding: 8px 0;
}

.label {
  color: #4a5565;
  font-weight: 600;
}

.value {
  color: #4a5565;
  font-weight: 600;
}

.value.strong {
  font-weight: 900;
}

/* right */
.person-col {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.person-card {
  background: #f9fafb;
  border-radius: 14px;
  border: 2px solid #e5e7eb;
  padding: 18px 16px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.member-icon {
  width: 18px;
  height: 18px;
}

.person-text {
  font-size: 14px;
  font-weight: 500;
  color: #101828;
}

.person-text-wrap {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.status-card {
  justify-content: center;
  align-items: center;
}

.status-text {
  text-align: center;
  font-size: 16px;
  font-weight: 500;
  line-height: 1;
}

.status-empty {
  color: #9ca3af;
  font-weight: 500;
}

.status-planned {
  color: #2563eb;
}

.status-progress {
  color: #d97706;
}

.status-done {
  color: #16a34a;
}
</style>