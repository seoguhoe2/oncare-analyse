<script setup>
import { ref, defineProps, defineEmits } from 'vue';
import { visitCounselData } from '@/mock/careworker/visitCounselData';

// Props
const props = defineProps({
  initialData: {
    type: Object,
    default: () => ({})
  }
});

// Emits
const emit = defineEmits(['submit', 'save-draft']);

// Form data
const formData = ref({
  visit_date: props.initialData.visit_date || '',
  recipient: props.initialData.recipient || '',
  visit_type: props.initialData.visit_type || '',
  reaction: props.initialData.reaction || '',
  visit_detail: props.initialData.visit_detail || '',
  observed_condition: props.initialData.observed_condition || '',
  subjective_needs: props.initialData.subjective_needs || '',
  counselor_notes: props.initialData.counselor_notes || '',
  next_action: props.initialData.next_action || ''
});

// Get options for select fields
const getOptions = (field) => {
  if (field.options === 'counselTypes') {
    return visitCounselData.counselTypes;
  } else if (field.options === 'reactionOptions') {
    return visitCounselData.reactionOptions;
  } else if (Array.isArray(field.options)) {
    return field.options;
  }
  return [];
};

// 폼 제출
const handleSubmit = () => {
  // 필수 항목 검증
  const section = visitCounselData.sections[0];
  const requiredFields = section.fields.filter(f => f.required);

  for (const field of requiredFields) {
    if (!formData.value[field.code] || formData.value[field.code].trim() === '') {
      alert(`${field.label}을(를) 입력해주세요.`);
      return;
    }
  }

  emit('submit', { ...formData.value });
};

// 임시저장
const handleSaveDraft = () => {
  emit('save-draft', { ...formData.value });
};
</script>

<template>
  <div class="visit-counsel-form">
    <section
      v-for="section in visitCounselData.sections"
      :key="section.code"
      class="form-section"
    >
      <div class="section-header">
        <h2>{{ section.title }}</h2>
        <p class="section-desc">{{ section.description }}</p>
      </div>

      <div class="form-grid">
        <div
          v-for="field in section.fields"
          :key="field.code"
          class="form-field"
          :class="`grid-${field.gridColumn || 'full'}`"
        >
          <label :for="field.code">
            {{ field.label }}
            <span v-if="field.required" class="required">*</span>
          </label>

          <!-- Text input -->
          <input
            v-if="field.type === 'text'"
            :id="field.code"
            v-model="formData[field.code]"
            type="text"
            :placeholder="field.placeholder"
          />

          <!-- Datetime-local input -->
          <input
            v-else-if="field.type === 'datetime-local'"
            :id="field.code"
            v-model="formData[field.code]"
            type="datetime-local"
          />

          <!-- Select dropdown -->
          <select
            v-else-if="field.type === 'select'"
            :id="field.code"
            v-model="formData[field.code]"
          >
            <option value="">{{ field.placeholder || '선택하세요' }}</option>
            <option
              v-for="option in getOptions(field)"
              :key="option.code"
              :value="option.code"
            >
              {{ option.label }}
            </option>
          </select>

          <!-- Textarea -->
          <textarea
            v-else-if="field.type === 'textarea'"
            :id="field.code"
            v-model="formData[field.code]"
            :rows="field.rows || 3"
            :placeholder="field.placeholder"
          ></textarea>
        </div>
      </div>
    </section>

    <!-- 제출 버튼 -->
    <div class="form-actions">
      <button type="button" class="btn-secondary" @click="handleSaveDraft">
        임시저장
      </button>
      <button type="button" class="btn-primary" @click="handleSubmit">
        저장
      </button>
    </div>
  </div>
</template>

<style scoped>
.visit-counsel-form {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0;
}

/* 폼 섹션 */
.form-section {
  background: white;
  border-radius: 0.5rem;
  padding: 2rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.section-header h2 {
  font-size: 1.25rem;
  font-weight: 700;
  color: #16a34a;
  margin: 0 0 0.5rem 0;
}

.section-desc {
  color: #6b7280;
  font-size: 0.875rem;
  margin: 0 0 1.5rem 0;
}

.required {
  color: #ef4444;
  margin-left: 0.25rem;
}

/* 폼 그리드 */
.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.25rem;
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-field.grid-full {
  grid-column: span 2;
}

.form-field.grid-half {
  grid-column: span 1;
}

.form-field label {
  font-weight: 600;
  color: #374151;
  font-size: 0.875rem;
}

.form-field input[type="text"],
.form-field input[type="datetime-local"],
.form-field select,
.form-field textarea {
  padding: 0.625rem 0.875rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  font-family: inherit;
  transition: all 0.2s;
}

.form-field input:focus,
.form-field select:focus,
.form-field textarea:focus {
  outline: none;
  border-color: #16a34a;
  box-shadow: 0 0 0 3px rgba(22, 163, 74, 0.1);
}

.form-field textarea {
  resize: vertical;
  min-height: 80px;
}

.form-field select {
  cursor: pointer;
  background-color: white;
}

/* 버튼 */
.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 2rem;
}

.btn-primary,
.btn-secondary {
  padding: 0.875rem 2.5rem;
  border-radius: 0.5rem;
  font-weight: 700;
  font-size: 0.875rem;
  border: none;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-primary {
  background: #16a34a;
  color: white;
}

.btn-primary:hover {
  background: #15803d;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(22, 163, 74, 0.3);
}

.btn-secondary {
  background: white;
  color: #4b5563;
  border: 1px solid #d1d5db;
}

.btn-secondary:hover {
  background: #f9fafb;
  border-color: #9ca3af;
}

/* 반응형 */
@media (max-width: 768px) {
  .visit-counsel-form {
    padding: 0;
  }

  .form-section {
    padding: 1.5rem;
  }

  .form-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .form-field.grid-full,
  .form-field.grid-half {
    grid-column: span 1;
  }

  .form-actions {
    flex-direction: column-reverse;
  }

  .btn-primary,
  .btn-secondary {
    width: 100%;
  }
}
</style>
