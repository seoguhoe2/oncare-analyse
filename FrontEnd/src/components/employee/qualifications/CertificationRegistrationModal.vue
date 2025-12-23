<script setup>
import { ref, watch } from 'vue';

const props = defineProps({
  isOpen: Boolean
});

const emit = defineEmits(['close', 'submit']);

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

// 모달이 열릴 때 폼 초기화
watch(() => props.isOpen, (newVal) => {
  if (newVal) {
    form.value = { ...initialForm };
  }
});

const handleSubmit = () => {
  // 유효성 검사
  if (!form.value.certificateId || !form.value.licenseNo || !form.value.issueDate) {
    alert('필수 정보를 모두 입력해주세요.');
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
              <input v-model="form.issueDate" type="date" class="input" />
            </div>
            <div>
              <label class="block-label">만료일</label>
              <input v-model="form.expireDate" type="date" class="input" />
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
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 50; }
.modal-box { background: white; width: 450px; border-radius: 12px; overflow: hidden; box-shadow: 0 10px 25px rgba(0,0,0,0.1); display: flex; flex-direction: column; max-height: 90vh; }
.modal-header { padding: 16px 20px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; }
.modal-header h3 { font-size: 18px; font-weight: 700; color: #111; margin: 0; }
.close-btn { background: none; border: none; cursor: pointer; color: #9ca3af; }
.modal-body { padding: 20px; overflow-y: auto; flex: 1; }
.modal-footer { padding: 16px 20px; border-top: 1px solid #f0f0f0; display: flex; justify-content: flex-end; gap: 8px; background: #fff; }
.space-y-4 > * + * { margin-top: 16px; }
.block-label { display: block; font-size: 14px; color: #374151; margin-bottom: 4px; font-weight: 500; }
.text-red { color: #ef4444; }
.input { width: 100%; padding: 8px 12px; border: 1px solid #e5e7eb; border-radius: 8px; font-size: 14px; outline: none; transition: all 0.2s; box-sizing: border-box; background-color: white; }
.input:focus { border-color: #22c55e; box-shadow: 0 0 0 3px rgba(220, 252, 231, 0.5); }
.grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.btn-cancel { padding: 8px 16px; background-color: #f3f4f6; color: #374151; border-radius: 8px; border: none; cursor: pointer; }
.btn-submit { padding: 8px 16px; background: linear-gradient(to right, #22c55e, #10b981); color: white; border-radius: 8px; border: none; cursor: pointer; font-weight: 600; }
</style>