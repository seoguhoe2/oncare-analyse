<script setup>
import { ref, defineProps, defineEmits } from 'vue';

const props = defineProps({
  isOpen: Boolean
});

const emit = defineEmits(['close', 'add']);

const content = ref('');
const type = ref('');

const onClose = () => {
  emit('close');
};

const onConfirm = () => {
  if (!content.value.trim()) {
    alert('할 일 내용을 입력해주세요.');
    return;
  }
  emit('add', { 
    content: content.value, 
    type: type.value 
  });
  content.value = '';
  type.value = '';
};
</script>

<template>
  <div v-if="isOpen" class="modal-overlay" @click.self="onClose">
    <div class="modal-container">
      <div class="modal-header">
        <h3 class="modal-title">할 일 추가</h3>
        <button class="close-icon-btn" @click="onClose">&times;</button>
      </div>

      <div class="modal-body">
        <div class="form-group">
          <label class="form-label">할 일 내용 <span class="required">*</span></label>
          <input 
            v-model="content" 
            type="text" 
            class="form-input" 
            placeholder="할 일을 입력하세요"
          />
        </div>
        <div class="form-group">
          <label class="form-label">유형</label>
          <input 
            v-model="type" 
            type="text" 
            class="form-input" 
            placeholder="예: 업무일지, 장비회수"
          />
        </div>
      </div>

      <div class="modal-footer">
        <button class="btn-cancel" @click="onClose">취소</button>
        <button class="btn-confirm" @click="onConfirm">추가</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}

.modal-container {
  background-color: white;
  width: 90%;
  max-width: 400px;
  border-radius: 0.75rem;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  overflow: hidden;
  animation: modal-pop 0.2s ease-out;
}

@keyframes modal-pop {
  from { opacity: 0; transform: scale(0.95); }
  to { opacity: 1; transform: scale(1); }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem 1.5rem;
  border-bottom: 1px solid #f3f4f6;
}

.modal-title { font-size: 1.125rem; font-weight: 700; color: #1f2937; margin: 0; }
.close-icon-btn { background: none; border: none; font-size: 1.5rem; color: #9ca3af; cursor: pointer; }

.modal-body { padding: 1.5rem; display: flex; flex-direction: column; gap: 1.25rem; }
.form-group { display: flex; flex-direction: column; gap: 0.5rem; }
.form-label { font-size: 0.875rem; font-weight: 600; color: #374151; }
.required { color: #ef4444; }

.form-input {
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.9rem;
  outline: none;
  transition: border-color 0.2s;
}
.form-input:focus { border-color: #22c55e; ring: 2px solid #bbf7d0; }

.modal-footer { 
  padding: 1rem 1.5rem; 
  background-color: #f9fafb; 
  display: flex; 
  justify-content: flex-end; 
  gap: 0.75rem; 
  border-top: 1px solid #f3f4f6; 
}

.btn-cancel { padding: 0.5rem 1rem; background-color: white; border: 1px solid #d1d5db; color: #374151; border-radius: 0.375rem; font-weight: 600; cursor: pointer; }
.btn-confirm { padding: 0.5rem 1rem; background-color: #22c55e; color: white; border: none; border-radius: 0.375rem; font-weight: 600; cursor: pointer; }
.btn-confirm:hover { background-color: #16a34a; }
</style>