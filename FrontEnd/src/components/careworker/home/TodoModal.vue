<script setup>
import { ref, defineProps, defineEmits, onMounted, onUnmounted, watch, computed } from "vue";
import { getMyBeneficiaries } from "@/api/careworker";

const props = defineProps({
  isOpen: Boolean,
  initialTodo: {
    type: Object,
    default: null,
  },
});

const emit = defineEmits(["close", "add", "update"]);

const content = ref("");
const type = ref("");
const todoDate = ref(new Date().toISOString().split("T")[0]);
const beneficiaryId = ref("");
const beneficiaries = ref([]);
const loadingBeneficiaries = ref(false);
const isEditMode = computed(() => !!props.initialTodo?.id);

// 유형 옵션 목록
const typeOptions = [
  { value: '방문예정', label: '방문예정' },
  { value: '요양일지', label: '요양일지' },
  { value: '기초평가', label: '기초평가' },
  { value: '방문상담', label: '방문상담' },
  { value: '장비회수', label: '장비회수' },
  { value: '기타', label: '기타' }
];

const resetForm = () => {
  content.value = "";
  type.value = "";
  todoDate.value = new Date().toISOString().split("T")[0];
  beneficiaryId.value = "";
};

const prefillForm = () => {
  if (!props.initialTodo) {
    resetForm();
    return;
  }

  content.value = props.initialTodo.text ?? props.initialTodo.content ?? "";
  type.value = props.initialTodo.type ?? "";
  todoDate.value =
    props.initialTodo.todoDate ??
    props.initialTodo.dueDate ??
    new Date().toISOString().split("T")[0];
  beneficiaryId.value = props.initialTodo.beneficiaryId ?? "";
};

const fetchBeneficiaries = async () => {
  loadingBeneficiaries.value = true;
  try {
    const response = await getMyBeneficiaries();
    const list = Array.isArray(response?.data)
      ? response.data
      : Array.isArray(response)
        ? response
        : [];

    beneficiaries.value = list.map((b) => ({
      id: b.beneficiaryId ?? b.id,
      name: b.name ?? b.beneficiaryName ?? "수급자",
    }));
  } catch (error) {
    console.error("수급자 목록 불러오기 실패:", error);
    beneficiaries.value = [];
  } finally {
    loadingBeneficiaries.value = false;
  }
};

const onClose = () => {
  emit("close");
};

const onConfirm = () => {
  if (!content.value.trim()) {
    alert("할 일 내용을 입력해주세요.");
    return;
  }
  const targetBeneficiaryId = beneficiaryId.value;
  if (!targetBeneficiaryId) {
    alert("수급자를 선택해주세요.");
    return;
  }

  const payload = {
    content: content.value,
    type: type.value,
    todoDate: todoDate.value,
    beneficiaryId: targetBeneficiaryId,
  };

  if (isEditMode.value) {
    emit("update", { id: props.initialTodo.id, ...payload });
  } else {
    emit("add", payload);
  }
};

watch(
  () => props.isOpen,
  (open) => {
    if (open) {
      prefillForm();
      fetchBeneficiaries();
    }
  }
);

watch(
  () => props.initialTodo,
  () => {
    if (props.isOpen) {
      prefillForm();
    }
  }
);

// ESC 키로 모달 닫기
const handleKeydown = (event) => {
  if (event.key === 'Escape' && props.isOpen) {
    onClose();
  }
};

onMounted(() => {
  fetchBeneficiaries();
  window.addEventListener('keydown', handleKeydown);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown);
});

defineExpose({ resetForm });
</script>

<template>
  <div v-if="isOpen" class="modal-overlay" @click.self="onClose">
    <div class="modal-container">
      <div class="modal-header">
        <h3 class="modal-title">{{ isEditMode ? "할 일 수정" : "할 일 추가" }}</h3>
        <button class="close-icon-btn" @click="onClose">
          <span class="close-icon">&times;</span>
        </button>
      </div>

      <div class="modal-body">
        <div class="form-group">
          <label class="form-label">
            <span class="label-icon">📝</span>
            할 일 내용
            <span class="required">*</span>
          </label>
          <input
            v-model="content"
            type="text"
            class="form-input"
            placeholder="할 일을 입력하세요"
          />
        </div>

        <div class="form-group">
          <label class="form-label">
            <span class="label-icon">🏷️</span>
            유형
          </label>
          <select
            v-model="type"
            class="form-input form-select"
          >
            <option value="" disabled>유형을 선택하세요</option>
            <option
              v-for="option in typeOptions"
              :key="option.value"
              :value="option.value"
            >
              {{ option.label }}
            </option>
          </select>
        </div>

        <div class="form-group">
          <label class="form-label">
            <span class="label-icon">👤</span>
            수급자
            <span class="required">*</span>
          </label>
          <select
            v-model="beneficiaryId"
            class="form-input form-select"
          >
            <option value="" disabled>담당 수급자를 선택하세요</option>
            <option
              v-for="person in beneficiaries"
              :key="person.id"
              :value="person.id"
            >
              {{ person.name }}
            </option>
          </select>
          <p v-if="loadingBeneficiaries" class="help-text">
            <span class="loading-spinner">⏳</span> 수급자를 불러오는 중...
          </p>
          <p v-else-if="!beneficiaries.length" class="help-text warning">
            ⚠️ 담당 수급자가 없습니다.
          </p>
        </div>
      </div>

      <div class="modal-footer">
        <button class="btn-cancel" @click="onClose">취소</button>
        <button class="btn-confirm" @click="onConfirm">
          {{ isEditMode ? "✓ 수정" : "✓ 추가" }}
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(34, 197, 94, 0.1) 0%, rgba(0, 0, 0, 0.6) 100%);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
  animation: overlay-fade 0.3s ease-out;
}

@keyframes overlay-fade {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal-container {
  background-color: white;
  width: 90%;
  max-width: 480px;
  border-radius: 20px;
  box-shadow:
    0 20px 25px -5px rgba(34, 197, 94, 0.15),
    0 10px 10px -5px rgba(0, 0, 0, 0.08),
    0 0 0 1px rgba(34, 197, 94, 0.1);
  overflow: hidden;
  animation: modal-pop 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes modal-pop {
  from {
    opacity: 0;
    transform: scale(0.9) translateY(20px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 1.75rem;
  background: linear-gradient(135deg, #ecfdf1 0%, #d1fae5 100%);
  border-bottom: 2px solid #a7f3d0;
}

.modal-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: #166534;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.close-icon-btn {
  background: white;
  border: 2px solid #d1fae5;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
}

.close-icon-btn:hover {
  background: #fee2e2;
  border-color: #fecaca;
  transform: rotate(90deg);
}

.close-icon {
  font-size: 1.5rem;
  color: #6b7280;
  line-height: 1;
}

.close-icon-btn:hover .close-icon {
  color: #ef4444;
}

.modal-body {
  padding: 1.75rem;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.625rem;
}

.form-label {
  font-size: 0.9375rem;
  font-weight: 600;
  color: #1f2937;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.label-icon {
  font-size: 1.125rem;
}

.required {
  color: #ef4444;
  font-weight: 700;
  margin-left: 0.125rem;
}

.help-text {
  margin: 0.375rem 0 0;
  font-size: 0.8125rem;
  color: #6b7280;
  display: flex;
  align-items: center;
  gap: 0.375rem;
}

.help-text.warning {
  color: #d97706;
}

.loading-spinner {
  animation: spin 1s linear infinite;
  display: inline-block;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.form-input {
  padding: 0.875rem 1rem;
  border: 2px solid #e5e7eb;
  border-radius: 12px;
  font-size: 0.9375rem;
  outline: none;
  transition: all 0.2s ease;
  background: white;
}

.form-input:hover {
  border-color: #d1d5db;
}

.form-input:focus {
  border-color: #22c55e;
  box-shadow: 0 0 0 4px rgba(34, 197, 94, 0.1);
  background: #f9fafb;
}

.form-input::placeholder {
  color: #9ca3af;
}

.form-select {
  cursor: pointer;
  appearance: none;
  -webkit-appearance: none;
  -moz-appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2322c55e'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 0.75rem center;
  background-size: 1.25rem;
  padding-right: 2.5rem;
}

.modal-footer {
  padding: 1.25rem 1.75rem;
  background: #f9fafb;
  display: flex;
  justify-content: flex-end;
  gap: 0.875rem;
  border-top: 2px solid #f3f4f6;
}

.btn-cancel {
  padding: 0.75rem 1.5rem;
  background: white;
  border: 2px solid #d1d5db;
  color: #374151;
  border-radius: 12px;
  font-size: 0.9375rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-cancel:hover {
  background: #f3f4f6;
  border-color: #9ca3af;
  transform: translateY(-1px);
}

.btn-confirm {
  padding: 0.75rem 1.5rem;
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 0.9375rem;
  font-weight: 600;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(34, 197, 94, 0.3);
  transition: all 0.2s ease;
}

.btn-confirm:hover {
  background: linear-gradient(135deg, #16a34a 0%, #15803d 100%);
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.4);
  transform: translateY(-2px);
}

.btn-confirm:active {
  transform: translateY(0);
}
</style>
