<script setup>
import { ref, watch, computed, onMounted, onUnmounted } from 'vue';

const props = defineProps({
  isOpen: Boolean,
  certificates: { type: Array, default: () => [] }
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

const initialForm = {
  targetCertIndex: null,
  eduName: '',
  institution: '',
  eduDate: '',
  nextEduDate: '',
  isOverdue: false
};

const form = ref({ ...initialForm });

// 오늘 날짜를 'YYYY-MM-DD' 형식으로 구하기
const today = computed(() => {
  return new Date().toISOString().split('T')[0];
});

// 모달이 열릴 때 초기화
watch(() => props.isOpen, (newVal) => {
  if (newVal) {
    form.value = { ...initialForm };

    // 자격증이 하나뿐이고, 그 자격증에 ID가 있다면 자동 선택
    if (props.certificates.length === 1) {
      const cert = props.certificates[0];
      // ID가 확실히 있는 경우에만 자동 선택
      if (cert.certificateId || cert.id) {
        form.value.targetCertIndex = 0;
      }
    }
  }
});

// 이수일 변경 시 다음 교육 예정일(2년 뒤) 자동 계산
watch(() => form.value.eduDate, (newDate) => {
  if (newDate) {
    const date = new Date(newDate);
    if (!isNaN(date.getTime())) {
      date.setFullYear(date.getFullYear() + 2);
      // YYYY-MM-DD 포맷 변환
      const yyyy = date.getFullYear();
      const mm = String(date.getMonth() + 1).padStart(2, '0');
      const dd = String(date.getDate()).padStart(2, '0');
      form.value.nextEduDate = `${yyyy}-${mm}-${dd}`;
    }
  }
});

const handleSubmit = () => {
  // 자격증 선택 여부 확인
  if (form.value.targetCertIndex === null) {
    alert('교육을 등록할 자격증을 선택해주세요.');
    return;
  }

  // 필수 정보 확인
  if (!form.value.eduName || !form.value.institution || !form.value.eduDate) {
    alert('필수 정보를 입력해주세요.');
    return;
  }

  // 날짜 검증 - 이수일이 미래인지 체크
  if (form.value.eduDate > today.value) {
    alert('보수교육 이수일은 미래일 수 없습니다.');
    return;
  }

  // 선택된 자격증에서 진짜 ID 추출
  const selectedCert = props.certificates[form.value.targetCertIndex];

  const realId = selectedCert.certificateId || selectedCert.id;

  // ID가 없으면 중단 (DB 저장 불가)
  if (!realId) {
    console.error("선택된 자격증 데이터:", selectedCert);
    alert('오류: 선택한 자격증의 고유 ID(PK)를 찾을 수 없습니다.\n새로고침 후 다시 시도하거나 관리자에게 문의하세요.');
    return;
  }

  // 전송 (ID와 폼 데이터)
  const { targetCertIndex, ...payload } = form.value;

  emit('submit', {
    targetCertId: realId,
    ...payload
  });
};
</script>

<template>
  <div v-if="isOpen" class="modal-overlay">
    <div class="modal-box">
      <div class="modal-header">
        <h3>보수교육 등록</h3>
        <button @click="$emit('close')" class="close-btn">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
      </div>

      <div class="modal-body">
        <form @submit.prevent="handleSubmit" class="space-y-4">
          
          <div>
            <label class="block-label">대상 자격증 <span class="text-red">*</span></label>
            <select v-model.number="form.targetCertIndex" class="input">
              <option :value="null" disabled>자격증을 선택하세요</option>

              <option
                v-for="(cert, index) in certificates"
                :key="index"
                :value="index"
                :disabled="!cert.certificateId && !cert.id" 
              >
                {{ cert.certificateName || cert.name }} 
                ({{ cert.licenseNo }}) 
                {{ (!cert.certificateId && !cert.id) ? '[ID 없음 - 선택불가]' : '' }}
              </option>
            </select>
          </div>

          <div>
            <label class="block-label">교육명 <span class="text-red">*</span></label>
            <input v-model="form.eduName" type="text" class="input" placeholder="예: 2025년 직무교육" />
          </div>
          <div>
            <label class="block-label">교육기관 <span class="text-red">*</span></label>
            <input v-model="form.institution" type="text" class="input" />
          </div>
          <div class="grid-2">
            <div>
              <label class="block-label">이수일 <span class="text-red">*</span></label>
              <input
                v-model="form.eduDate"
                type="date"
                class="input"
                :max="today"
              />
            </div>
            <div>
              <label class="block-label">다음 교육 예정일</label>
              <input v-model="form.nextEduDate" type="date" class="input" />
            </div>
          </div>
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
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 50;
  transition: opacity 0.3s ease;
}
.modal-box {
  background: white;
  width: 550px;
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
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
  font-size: 20px;
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
  gap: 12px;
  background: #f9fafb;
}
.space-y-4 > * + * {
  margin-top: 24px;
}
.block-label {
  display: block;
  font-size: 15px;
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
  padding: 12px 16px;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  font-size: 15px;
  outline: none;
  transition: all 0.2s;
  box-sizing: border-box;
  background-color: #f9fafb;
}
.input:focus {
  background-color: white;
  border-color: #22c55e;
  box-shadow: 0 0 0 4px rgba(34, 197, 94, 0.1);
}
.input::placeholder {
  color: #9ca3af;
}
.grid-2 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
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