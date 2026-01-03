<script setup>
import { ref, watch, onMounted, onUnmounted } from 'vue';

const props = defineProps({
  isOpen: Boolean
});

const emit = defineEmits(['close', 'submit']);

// 키보드 이벤트 핸들러
const handleKeydown = (e) => {
  if (!props.isOpen) return;

  if (e.key === 'Escape') {
    emit('close');
  } else if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
    // Ctrl+Enter 또는 Cmd+Enter로 제출
    handleSubmit();
  }
};

onMounted(() => {
  window.addEventListener('keydown', handleKeydown);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown);
});

// 자격증 종류 마스터 데이터 (실제 프로젝트에서는 API로 받아오거나 상수로 관리)
const certificateOptions = [
  { id: 1, name: '요양보호사 1급' },
  { id: 2, name: '요양보호사 2급' },
  { id: 3, name: '사회복지사 1급' },
  { id: 4, name: '사회복지사 2급' },
  { id: 5, name: '간호조무사' },
  { id: 6, name: '물리치료사' }
];

// API 스펙에 맞춘 초기 데이터 정의
const initialForm = { 
  certificateId: '', // 자격증 ID (필수)
  licenseNo: '',     // 자격증 번호 (필수)
  issueDate: '',     // 발급일 (필수)
  expireDate: ''     // 만료일 (선택)
};

const form = ref({ ...initialForm });
const dateError = ref(''); // 에러 메시지 저장용

// 모달이 열릴 때 폼 초기화
watch(() => props.isOpen, (newVal) => {
  if (newVal) {
    form.value = { ...initialForm };
    dateError.value = '';
  }
});

// 날짜 유효성 검사 함수
const validateDates = () => {
  const today = new Date();
  today.setHours(0, 0, 0, 0); // 시간 정보 제거 (날짜만 비교)

  // 1. 발급일이 미래인지 체크
  if (form.value.issueDate) {
    const issue = new Date(form.value.issueDate);
    if (issue > today) {
      dateError.value = "발급일은 미래일 수 없습니다.";
      return false;
    }
  }

  // 2. 만료일이 발급일보다 이전인지 체크
  if (form.value.issueDate && form.value.expireDate) {
    const issue = new Date(form.value.issueDate);
    const expire = new Date(form.value.expireDate);
    if (issue > expire) {
      dateError.value = "만료일은 발급일보다 이후여야 합니다.";
      return false;
    }
  }

  dateError.value = ''; // 에러 없음
  return true;
};

// 값이 변할 때마다 감시
watch(() => [form.value.issueDate, form.value.expireDate], validateDates, { deep: true });

const handleSubmit = () => {
  // 유효성 검사
  if (!form.value.certificateId || !form.value.licenseNo || !form.value.issueDate) {
    alert('필수 정보를 모두 입력해주세요.');
    return;
  }

  // 날짜 유효성 검사
  if (!validateDates()) {
    alert('날짜를 확인해주세요!');
    return;
  }

  // [수정] API 포맷에 맞춰 데이터 전송
  const payload = {
    certificateId: form.value.certificateId,
    licenseNo: form.value.licenseNo,
    issueDate: form.value.issueDate,
    expireDate: form.value.expireDate || null // 만료일 없으면 null 처리
  };

  emit('submit', payload);
};
</script>

<template>
  <div v-if="isOpen" class="modal-overlay">
    <div class="modal-box">
      <div class="modal-header">
        <h3>자격증 등록</h3>
        <button @click="$emit('close')" class="close-btn">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
      </div>

      <div class="modal-body">
        <form @submit.prevent="handleSubmit" class="space-y-4">
          
          <div>
            <label class="block-label">자격증 종류 <span class="text-red">*</span></label>
            <select v-model="form.certificateId" class="input">
              <option value="" disabled>자격증을 선택하세요</option>
              <option v-for="opt in certificateOptions" :key="opt.id" :value="opt.id">
                {{ opt.name }}
              </option>
            </select>
          </div>

          <div>
            <label class="block-label">자격증 번호 <span class="text-red">*</span></label>
            <input v-model="form.licenseNo" type="text" class="input" placeholder="예: SOC-2025-99" />
          </div>

          <div class="grid-2">
            <div>
              <label class="block-label">발급일 <span class="text-red">*</span></label>
              <input
                v-model="form.issueDate"
                type="date"
                class="input"
                :class="{ 'input-error': dateError }"
                :max="new Date().toISOString().split('T')[0]"
              />
            </div>
            <div>
              <label class="block-label">만료일</label>
              <input
                v-model="form.expireDate"
                type="date"
                class="input"
                :class="{ 'input-error': dateError }"
                :min="form.issueDate"
              />
            </div>
          </div>

          <p v-if="dateError" class="error-msg">{{ dateError }}</p>

          </form>
      </div>

      <div class="modal-footer">
        <button type="button" @click="$emit('close')" class="btn-cancel">취소</button>
        <button type="button" @click="handleSubmit" class="btn-submit">등록</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4); /* Slightly lighter overlay */
  backdrop-filter: blur(4px); /* Adds a modern blur effect */
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 50;
  transition: opacity 0.3s ease;
}
.modal-box {
  background: white;
  width: 550px; /* Increased size */
  border-radius: 24px; /* Softer corners */
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); /* Richer shadow */
  display: flex;
  flex-direction: column;
  max-height: 90vh;
  animation: modal-pop 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}
@keyframes modal-pop {
  from { transform: scale(0.95); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}
.modal-header {
  padding: 24px 32px;
  border-bottom: 1px solid #f3f4f6;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.modal-header h3 {
  font-size: 20px; /* Larger title */
  font-weight: 700;
  color: #111827;
  letter-spacing: -0.02em;
  margin: 0;
}
.close-btn {
  background: none;
  border: none;
  cursor: pointer;
  color: #9ca3af;
  border-radius: 50%;
  padding: 8px;
  transition: background 0.2s, color 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}
.close-btn:hover {
  background: #f3f4f6;
  color: #4b5563;
}
.modal-body {
  padding: 32px;
  overflow-y: auto;
  flex: 1;
}
.modal-footer {
  padding: 24px 32px;
  border-top: 1px solid #f3f4f6;
  display: flex;
  justify-content: flex-end;
  gap: 12px; /* Increased gap */
  background: #f9fafb; /* Slight background distinction */
}
.space-y-4 > * + * {
  margin-top: 24px; /* Increased vertical spacing */
}
.block-label {
  display: block;
  font-size: 15px; /* Larger label */
  color: #374151;
  margin-bottom: 8px;
  font-weight: 600;
}
.text-red {
  color: #ef4444;
  margin-left: 2px;
}
.input {
  width: 100%;
  padding: 12px 16px; /* Larger touch area */
  border: 1px solid #e5e7eb;
  border-radius: 12px; /* Softer input corners */
  font-size: 15px;
  outline: none;
  transition: all 0.2s;
  box-sizing: border-box;
  background-color: #f9fafb; /* Light background for inputs mostly seen in modern forms */
}
.input:focus {
  background-color: white;
  border-color: #22c55e;
  box-shadow: 0 0 0 4px rgba(34, 197, 94, 0.1); /* Softer focus ring */
}
.input::placeholder {
  color: #9ca3af;
}
.input-error {
  border-color: #ef4444;
  background-color: #fef2f2;
}
.input-error:focus {
  border-color: #ef4444;
  box-shadow: 0 0 0 4px rgba(239, 68, 68, 0.1);
}
.error-msg {
  color: #ef4444;
  font-size: 13px;
  margin-top: 8px;
  font-weight: 500;
}
.grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px; /* Increased gap */
}
.btn-cancel {
  padding: 12px 24px;
  background-color: white;
  color: #4b5563;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}
.btn-cancel:hover {
  background-color: #f9fafb;
  border-color: #d1d5db;
}
.btn-submit {
  padding: 12px 24px;
  background: #22c55e; /* Solid green usually looks cleaner than gradient in modern flat design, but keeping gradient if requested, user said "soft". Gradient can be soft. Let's stick to user provided image. The image has a green gradient button. */
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  color: white;
  border-radius: 12px;
  border: none;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  box-shadow: 0 4px 6px -1px rgba(34, 197, 94, 0.2);
  transition: all 0.2s;
}
.btn-submit:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 8px -1px rgba(34, 197, 94, 0.3);
}
.btn-submit:active {
  transform: translateY(0);
}
</style>