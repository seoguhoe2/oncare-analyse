<template>
    <teleport to="body">
      <div v-if="show" class="modal-backdrop" @click.self="onClose">
        <div class="modal">
          <h3 class="modal-title">매칭하기</h3>
          <p class="modal-desc">기준일을 선택한 뒤 매칭을 진행해 주세요.</p>
  
          <div class="field">
            <div class="label">기준일</div>
            <input type="date" v-model="effectiveDate" :min="minDate" class="date-input" />
          </div>
  
          <div class="modal-actions">
            <button type="button" class="modal-btn cancel" @click="onClose">취소</button>
            <button
              type="button"
              class="modal-btn primary"
              :disabled="!effectiveDate || saving"
              @click="onConfirm"
            >
              {{ saving ? '처리 중...' : '확인' }}
            </button>
          </div>
        </div>
      </div>
    </teleport>
  </template>
  
  <script setup>
  import { computed, ref, watch } from 'vue'
  
  const props = defineProps({
    show: { type: Boolean, default: false },
    min: { type: String, default: '' }, // optional: 'YYYY-MM-DD'
    defaultDate: { type: String, default: '' }, // optional
    saving: { type: Boolean, default: false },
  })
  
  const emit = defineEmits(['close', 'confirm'])
  
  const pad2 = (n) => String(n).padStart(2, '0')
  const toYmd = (d) => `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`
  
  const todayYmd = toYmd(new Date())
  const minDate = computed(() => props.min || todayYmd)
  
  const effectiveDate = ref('')
  
  watch(
    () => props.show,
    (open) => {
      if (!open) return
      effectiveDate.value = props.defaultDate || minDate.value
    },
    { immediate: true }
  )
  
  const onClose = () => emit('close')
  
  const onConfirm = () => {
    if (!effectiveDate.value) return
    emit('confirm', effectiveDate.value)
  }
  </script>
  
  <style scoped>
  .modal-backdrop {
    position: fixed;
    inset: 0;
    background: rgba(17, 24, 39, 0.45);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
  }
  
  .modal {
    width: 360px;
    max-width: calc(100vw - 32px);
    background: #fff;
    border-radius: 16px;
    padding: 18px 18px 14px;
    border: 1px solid #e5e7eb;
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
    box-sizing: border-box;
  }
  
  .modal-title {
    margin: 0 0 6px;
    font-size: 16px;
    font-weight: 700;
    color: #111827;
  }
  
  .modal-desc {
    margin: 0 0 14px;
    font-size: 14px;
    color: #4b5563;
  }
  
  .field {
    margin: 10px 0 14px;
  }
  
  .label {
    font-size: 13px;
    color: #6b7280;
    margin-bottom: 6px;
  }
  
  .date-input {
    display: block;
    width: 100%;
    height: 38px;
    padding: 0 12px;
    border-radius: 12px;
    border: 1px solid #e5e7eb;
    background: #fff;
    font-size: 14px;
    color: #111827;
    box-sizing: border-box;
  }
  
  .modal-actions {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
  }
  
  .modal-btn {
    height: 38px;
    padding: 0 14px;
    border-radius: 12px;
    font-size: 14px;
    border: 1px solid transparent;
    cursor: pointer;
  }
  
  .modal-btn.cancel {
    background: #f3f4f6;
    color: #111827;
    border-color: #e5e7eb;
  }
  
  .modal-btn.primary {
    background: #4f46e5;
    color: #fff;
    border-color: #4f46e5;
  }
  
  .modal-btn:disabled {
    opacity: 0.55;
    cursor: not-allowed;
  }
  </style>