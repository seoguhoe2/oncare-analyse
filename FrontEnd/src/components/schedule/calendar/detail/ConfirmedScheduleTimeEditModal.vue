<template>
  <div v-if="open" class="modal-backdrop" @click.self="onCancel">
    <div class="modal-card" role="dialog" aria-modal="true">
      <div class="modal-head">
        <h3 class="modal-title">일정 수정</h3>
      </div>

      <!-- ✅ 모달 내부 토스트 (겹침 에러만) -->
      <StatusToast
        v-model:show="showToast"
        :message="toastMessage"
        type="warning"
        :duration="2600"
      />

      <div class="modal-body">
        <div class="form-grid">
          <div class="form-row">
            <label class="form-label">날짜</label>
            <input class="form-input" type="date" v-model="editDate" />
          </div>

          <div class="form-row">
            <label class="form-label">시작</label>
            <input class="form-input" type="time" v-model="startTime" step="60" />
          </div>

          <div class="form-row">
            <label class="form-label">종료</label>
            <input class="form-input" type="time" v-model="endTime" step="60" />
          </div>
        </div>
      </div>

      <div class="modal-foot">
        <button class="btn ghost" type="button" @click="onCancel" :disabled="loading">
          취소
        </button>
        <button class="btn solid" type="button" @click="onSubmit" :disabled="loading">
          {{ loading ? '저장 중...' : '저장' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue';
import StatusToast from '@/components/schedule/calendar/detail/ScheduleToastMessage.vue';

const props = defineProps({
  open: { type: Boolean, default: false },
  loading: { type: Boolean, default: false }, // ✅ 부모 로딩 사용
  serverError: { type: String, default: '' }, // ✅ 부모가 내려주는 에러(겹침만)

  vsId: { type: [Number, String], default: null },

  date: { type: [String, Date], default: '' },
  startTime: { type: String, default: '' },
  endTime: { type: String, default: '' },
});

const emit = defineEmits(['close', 'submit', 'updated']);

// ✅ 토스트 상태
const showToast = ref(false);
const toastMessage = ref('');
let toastRaf = 0;

const openModalToast = (msg) => {
  const m = String(msg ?? '').trim();
  if (!m) return;

  toastMessage.value = m;

  // 연속 호출 시에도 애니메이션/표시 보장
  showToast.value = false;
  cancelAnimationFrame(toastRaf);
  toastRaf = requestAnimationFrame(() => {
    showToast.value = true;
  });
};

// 내부 편집 상태
const editDate = ref('');
const startTime = ref('');
const endTime = ref('');

// ---- helpers ----
const toDateOnly = (v) => {
  const s = String(v ?? '');
  if (!s) return '';
  return s.includes('T') ? s.split('T')[0] : s.slice(0, 10);
};

const toHM = (v) => {
  const s = String(v ?? '');
  if (!s) return '';
  if (s.includes('T')) return (s.split('T')[1] || '').slice(0, 5);
  return s.slice(0, 5);
};

const toLocalDateTime = (dateStr, timeStr) => {
  const d = String(dateStr ?? '').slice(0, 10);
  const t = String(timeStr ?? '').slice(0, 5);
  if (!d || !t) return '';
  return `${d}T${t}:00`;
};

const isValid = computed(() => {
  if (!props.vsId) return false;
  if (!editDate.value || !startTime.value || !endTime.value) return false;

  const s = toLocalDateTime(editDate.value, startTime.value);
  const e = toLocalDateTime(editDate.value, endTime.value);
  if (!s || !e) return false;

  return e > s;
});

// ✅ 모달 열릴 때 초기값 세팅 + (겹침 에러 있으면) 토스트로 띄움
watch(
  () => props.open,
  (v) => {
    if (!v) return;

    editDate.value = toDateOnly(props.date);
    startTime.value = toHM(props.startTime);
    endTime.value = toHM(props.endTime);

    if (!editDate.value && String(props.startTime || '').includes('T')) {
      editDate.value = toDateOnly(props.startTime);
    }

    const se = String(props.serverError ?? '').trim();
    if (se) openModalToast(se);
  },
  { immediate: true }
);

// ✅ serverError가 새로 내려오면 모달 토스트로 즉시 반영
watch(
  () => props.serverError,
  (v) => {
    const msg = String(v ?? '').trim();
    if (msg) openModalToast(msg);
  }
);

const onCancel = () => {
  if (props.loading) return;
  emit('close');
};

const onSubmit = () => {
  if (!props.vsId) {
    openModalToast('vsId가 없습니다. (viewModel.vsId 확인)');
    return;
  }
  if (!editDate.value || !startTime.value || !endTime.value) {
    openModalToast('날짜/시간을 모두 입력해 주세요.');
    return;
  }

  const startDt = toLocalDateTime(editDate.value, startTime.value);
  const endDt = toLocalDateTime(editDate.value, endTime.value);

  if (!startDt || !endDt) {
    openModalToast('날짜/시간 형식이 올바르지 않습니다.');
    return;
  }
  if (endDt <= startDt) {
    openModalToast('종료 시간이 시작 시간보다 늦어야 합니다.');
    return;
  }
  const now = new Date();
  const startDateObj = new Date(startDt);

  // 파싱 실패 방어
  if (Number.isNaN(startDateObj.getTime())) {
    openModalToast('날짜/시간 형식이 올바르지 않습니다.');
    return;
  }

  if (startDateObj <= now) {
    openModalToast('일정 수정은 현재시각 이후로 가능합니다.');
    return;
  }

  if (!isValid.value) {
    openModalToast('입력값을 확인해 주세요.');
    return;
  }
  emit('submit', { vsId: Number(props.vsId), startDt, endDt });
};
</script>

<style scoped>
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  z-index: 9999;
}

.modal-card {
  width: 520px;
  background: #fff;
  border-radius: 18px;
  border: 1px solid #e5e7eb;
  box-shadow: 0 12px 40px rgba(15, 23, 42, 0.18);
  overflow: hidden;
  position: relative;
}

.modal-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 18px;
  border-bottom: 1px solid #e5e7eb;
}

.modal-title {
  margin: 0;
  font-size: 16px;
  font-weight: 700;
  color: #111827;
}

.modal-body {
  padding: 16px 18px;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 12px;
}

.form-row {
  display: grid;
  grid-template-columns: 90px 1fr;
  gap: 10px;
  align-items: center;
}

.form-label {
  font-size: 14px;
  font-weight: 700;
  color: #374151;
}

.form-input {
  height: 40px;
  border-radius: 10px;
  border: 1px solid #e5e7eb;
  padding: 0 12px;
  font-size: 14px;
  outline: none;
}

.form-input:focus {
  border-color: #cbd5e1;
}

.modal-foot {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  padding: 14px 18px 16px;
  border-top: 1px solid #e5e7eb;
}

.btn {
  height: 40px;
  padding: 0 14px;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  border: 1px solid transparent;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn.ghost {
  background: #fff;
  border-color: #e5e7eb;
  color: #111827;
}

.btn.solid {
  background: #111827;
  color: #fff;
}
</style>