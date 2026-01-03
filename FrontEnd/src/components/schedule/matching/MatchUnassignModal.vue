<template>
  <teleport to="body">
    <div v-if="modelValue" class="backdrop" @click.self="onCancel">
      <div class="modal">
        <h3 class="title">배정 취소</h3>
        <p class="desc">정말 배정을 삭제할까요?</p>

        <div class="date-row">
          <div class="date-label">기준일</div>
          <input
            type="date"
            class="date-input"
            v-model="effectiveDate"
            :min="minDate"
          />
        </div>

        <div class="actions">
          <button type="button" class="btn cancel" @click="onCancel">취소</button>
          <button
            type="button"
            class="btn danger"
            :disabled="!effectiveDate"
            @click="onConfirm"
          >
            삭제
          </button>
        </div>
      </div>
    </div>
  </teleport>
</template>

<script setup>
import { computed, ref, watch } from 'vue'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
})

const emit = defineEmits(['update:modelValue', 'confirm'])

const pad2 = (n) => String(n).padStart(2, '0')
const toYmd = (d) => `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`

const minDate = computed(() => toYmd(new Date()))
const effectiveDate = ref('')

watch(
  () => props.modelValue,
  (open) => {
    if (open) effectiveDate.value = minDate.value
  }
)

const onCancel = () => emit('update:modelValue', false)

const onConfirm = () => {
  if (!effectiveDate.value) return
  emit('confirm', effectiveDate.value)
}
</script>

<style scoped>
  .backdrop {
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

.title {
  margin: 0 0 6px;
  font-size: 16px;
  font-weight: 700;
  color: #111827;
}

.desc {
  margin: 0 0 14px;
  font-size: 14px;
  color: #4b5563;
}

.date-row {
  margin: 10px 0 14px;
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 0;
}

.date-label {
  flex: 0 0 auto;
  font-size: 13px;
  color: #6b7280;
  white-space: nowrap;
}

.date-input {
  flex: 1 1 auto;
  min-width: 0;
  width: 100%;
  height: 36px;
  padding: 0 10px;
  border-radius: 10px;
  border: 1px solid #e5e7eb;
  background: #fff;
  font-size: 13px;
  color: #111827;
  box-sizing: border-box;
}

.actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.btn {
  height: 36px;
  padding: 0 12px;
  border-radius: 10px;
  font-size: 14px;
  border: 1px solid transparent;
  cursor: pointer;
}

.cancel {
  background: #f3f4f6;
  color: #111827;
  border-color: #e5e7eb;
}

.danger {
  background: #ef4444;
  color: #fff;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
</style>