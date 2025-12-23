<script setup>
import { ref, computed, defineProps, defineEmits } from 'vue';
import { needsAssessment } from '@/mock/careworker/needsData';

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
  recipientName: props.initialData.recipientName || '',
  careWorkerName: props.initialData.careWorkerName || '',
  assessmentDate: props.initialData.assessmentDate || new Date().toISOString().split('T')[0],
  responses: props.initialData.responses || {},
  textInputs: props.initialData.textInputs || {}
});

// 현재 페이지 (섹션 단위로 표시)
const currentPage = ref(1);
const sectionsPerPage = 3;

// 페이지별 섹션 계산
const totalPages = computed(() => {
  return Math.ceil(needsAssessment.sections.length / sectionsPerPage);
});

const currentSections = computed(() => {
  const start = (currentPage.value - 1) * sectionsPerPage;
  const end = start + sectionsPerPage;
  return needsAssessment.sections.slice(start, end);
});

// 페이지 이동
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
};

const nextPage = () => goToPage(currentPage.value + 1);
const prevPage = () => goToPage(currentPage.value - 1);

// 응답 선택/토글
const toggleCheckbox = (itemCode, choice) => {
  if (!formData.value.responses[itemCode]) {
    formData.value.responses[itemCode] = [];
  }
  const index = formData.value.responses[itemCode].indexOf(choice);
  if (index > -1) {
    formData.value.responses[itemCode].splice(index, 1);
  } else {
    formData.value.responses[itemCode].push(choice);
  }
};

const selectRadio = (itemCode, choice) => {
  formData.value.responses[itemCode] = choice;
};

const selectTableRadio = (itemCode, row, column) => {
  if (!formData.value.responses[itemCode]) {
    formData.value.responses[itemCode] = {};
  }
  formData.value.responses[itemCode][row] = column;
};

// 체크박스 선택 여부 확인
const isCheckboxChecked = (itemCode, choice) => {
  return formData.value.responses[itemCode]?.includes(choice) || false;
};

// 라디오 선택 여부 확인
const isRadioSelected = (itemCode, choice) => {
  return formData.value.responses[itemCode] === choice;
};

// 테이블 라디오 선택 여부 확인
const isTableRadioSelected = (itemCode, row, column) => {
  return formData.value.responses[itemCode]?.[row] === column;
};

// 텍스트 입력 필요 여부 확인
const needsTextInput = (item, choice) => {
  if (!item.hasTextWhen) return false;
  if (item.type === 'radio') {
    return item.hasTextWhen.includes(choice) && isRadioSelected(item.code, choice);
  } else if (item.type === 'checkbox') {
    return item.hasTextWhen.includes(choice) && isCheckboxChecked(item.code, choice);
  }
  return false;
};

// 폼 제출
const handleSubmit = () => {
  if (!formData.value.recipientName) {
    alert('수급자명을 입력해주세요.');
    return;
  }
  if (!formData.value.careWorkerName) {
    alert('작성자명을 입력해주세요.');
    return;
  }

  emit('submit', {
    ...formData.value
  });
};

// 임시저장
const handleSaveDraft = () => {
  emit('save-draft', {
    ...formData.value
  });
};
</script>

<template>
  <div class="needs-assessment-form">
    <!-- 기본 정보 -->
    <section class="form-section basic-info">
      <div class="section-header">
        <h2>{{ needsAssessment.title }}</h2>
        <p class="section-desc">수급자의 전반적인 욕구를 파악하고 맞춤형 서비스를 계획합니다</p>
      </div>

      <div class="info-grid">
        <div class="info-row">
          <label>수급자명 <span class="required">*</span></label>
          <input
            v-model="formData.recipientName"
            type="text"
            placeholder="수급자명을 입력하세요"
          />
        </div>
        <div class="info-row">
          <label>작성자명 <span class="required">*</span></label>
          <input
            v-model="formData.careWorkerName"
            type="text"
            placeholder="요양보호사명을 입력하세요"
          />
        </div>
        <div class="info-row">
          <label>평가일</label>
          <input
            v-model="formData.assessmentDate"
            type="date"
          />
        </div>
      </div>
    </section>

    <!-- 페이지 인디케이터 -->
    <div class="page-indicator">
      <span class="page-text">{{ currentPage }} / {{ totalPages }} 페이지</span>
    </div>

    <!-- 평가 섹션들 (페이지별) -->
    <section
      v-for="section in currentSections"
      :key="section.code"
      class="form-section needs-section"
    >
      <h3 class="section-title">{{ section.code }}. {{ section.title }}</h3>

      <div class="items-container">
        <div
          v-for="item in section.items"
          :key="item.code"
          class="item-group"
        >
          <label class="item-label">{{ item.label }}</label>

          <!-- 숫자 입력 -->
          <div v-if="item.type === 'number'" class="number-input-group">
            <input
              v-model="formData.responses[item.code]"
              type="number"
              :placeholder="`${item.label} 입력`"
            />
            <span v-if="item.unit" class="unit">{{ item.unit }}</span>
          </div>

          <!-- 텍스트 입력 -->
          <div v-else-if="item.type === 'text'" class="text-input-group">
            <input
              v-model="formData.responses[item.code]"
              type="text"
              :placeholder="`${item.label} 입력`"
            />
          </div>

          <!-- 텍스트영역 -->
          <div v-else-if="item.type === 'textarea'" class="textarea-group">
            <textarea
              v-model="formData.responses[item.code]"
              :placeholder="`${item.label}을(를) 입력하세요`"
              rows="5"
            ></textarea>
          </div>

          <!-- 라디오 -->
          <div v-else-if="item.type === 'radio'" class="radio-group">
            <label
              v-for="choice in item.choices"
              :key="choice"
              class="radio-label"
              :class="{ active: isRadioSelected(item.code, choice) }"
            >
              <input
                type="radio"
                :name="item.code"
                :value="choice"
                :checked="isRadioSelected(item.code, choice)"
                @change="selectRadio(item.code, choice)"
              />
              <span>{{ choice }}</span>
            </label>
            <!-- 추가 텍스트 입력 -->
            <input
              v-for="choice in item.choices"
              v-if="needsTextInput(item, choice)"
              :key="`${item.code}_${choice}_text`"
              v-model="formData.textInputs[`${item.code}_${choice}`]"
              type="text"
              class="additional-text"
              placeholder="상세 입력"
            />
          </div>

          <!-- 체크박스 -->
          <div v-else-if="item.type === 'checkbox'" class="checkbox-group">
            <label
              v-for="choice in item.choices"
              :key="choice"
              class="checkbox-label"
              :class="{ active: isCheckboxChecked(item.code, choice) }"
            >
              <input
                type="checkbox"
                :checked="isCheckboxChecked(item.code, choice)"
                @change="toggleCheckbox(item.code, choice)"
              />
              <span>{{ choice }}</span>
            </label>
            <!-- 추가 텍스트 입력 -->
            <input
              v-for="choice in item.choices"
              v-if="needsTextInput(item, choice)"
              :key="`${item.code}_${choice}_text`"
              v-model="formData.textInputs[`${item.code}_${choice}`]"
              type="text"
              class="additional-text"
              placeholder="상세 입력"
            />
          </div>

          <!-- 테이블 라디오 (ADL) -->
          <div v-else-if="item.type === 'table_radio'" class="table-container">
            <table class="adl-table">
              <thead>
                <tr>
                  <th>항목</th>
                  <th v-for="col in item.columns" :key="col">{{ col }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in item.rows" :key="row">
                  <td class="row-label">{{ row }}</td>
                  <td
                    v-for="col in item.columns"
                    :key="`${row}_${col}`"
                    class="radio-cell"
                  >
                    <input
                      type="radio"
                      :name="`${item.code}_${row}`"
                      :checked="isTableRadioSelected(item.code, row, col)"
                      @change="selectTableRadio(item.code, row, col)"
                    />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </section>

    <!-- 페이지네이션 -->
    <div class="pagination">
      <button
        type="button"
        class="page-btn"
        :disabled="currentPage === 1"
        @click="prevPage"
      >
        ← 이전
      </button>
      <div class="page-numbers">
        <button
          v-for="page in totalPages"
          :key="page"
          type="button"
          class="page-number"
          :class="{ active: page === currentPage }"
          @click="goToPage(page)"
        >
          {{ page }}
        </button>
      </div>
      <button
        type="button"
        class="page-btn"
        :disabled="currentPage === totalPages"
        @click="nextPage"
      >
        다음 →
      </button>
    </div>

    <!-- 제출 버튼 (마지막 페이지에만 표시) -->
    <div v-if="currentPage === totalPages" class="form-actions">
      <button type="button" class="btn-secondary" @click="handleSaveDraft">
        임시저장
      </button>
      <button type="button" class="btn-primary" @click="handleSubmit">
        제출하기
      </button>
    </div>
  </div>
</template>

<style scoped>
.needs-assessment-form {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1.5rem;
}

/* 섹션 공통 */
.form-section {
  background: white;
  border-radius: 0.5rem;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.section-header h2 {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 0.5rem 0;
  text-align: center;
}

.section-desc {
  text-align: center;
  color: #6b7280;
  font-size: 0.875rem;
  margin: 0 0 1.5rem 0;
}

.section-title {
  font-size: 1.125rem;
  font-weight: 700;
  color: #10b981;
  margin: 0 0 1.5rem 0;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #d1fae5;
}

.required {
  color: #ef4444;
  margin-left: 0.25rem;
}

/* 기본 정보 */
.info-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
}

.info-row {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.info-row label {
  font-weight: 600;
  color: #4b5563;
  font-size: 0.875rem;
}

.info-row input {
  padding: 0.625rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
}

.info-row input:focus {
  outline: none;
  border-color: #10b981;
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
}

/* 페이지 인디케이터 */
.page-indicator {
  text-align: center;
  padding: 1rem;
  background: #ecfdf5;
  border-radius: 0.5rem;
  margin-bottom: 1.5rem;
}

.page-text {
  font-size: 0.9375rem;
  font-weight: 600;
  color: #10b981;
}

/* 욕구사정 섹션 */
.needs-section {
  background: #f0fdf4;
}

.items-container {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.item-group {
  background: white;
  padding: 1.25rem;
  border-radius: 0.5rem;
  border: 1px solid #e5e7eb;
}

.item-label {
  display: block;
  font-weight: 600;
  color: #374151;
  font-size: 0.9375rem;
  margin-bottom: 0.75rem;
}

/* 숫자/텍스트 입력 */
.number-input-group,
.text-input-group {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.number-input-group input,
.text-input-group input {
  flex: 1;
  padding: 0.625rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
}

.number-input-group input {
  max-width: 150px;
}

.unit {
  font-size: 0.875rem;
  color: #6b7280;
}

/* 텍스트영역 */
.textarea-group textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  resize: vertical;
  font-family: inherit;
}

.textarea-group textarea:focus {
  outline: none;
  border-color: #10b981;
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
}

/* 라디오/체크박스 */
.radio-group,
.checkbox-group {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.radio-label,
.checkbox-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1rem;
  border: 2px solid #e5e7eb;
  border-radius: 0.375rem;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 0.875rem;
}

.radio-label:hover,
.checkbox-label:hover {
  border-color: #10b981;
  background: #f0fdf4;
}

.radio-label.active,
.checkbox-label.active {
  border-color: #10b981;
  background: #d1fae5;
}

.radio-label input,
.checkbox-label input {
  cursor: pointer;
  accent-color: #10b981;
}

.additional-text {
  width: 100%;
  margin-top: 0.5rem;
  padding: 0.625rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
}

/* 테이블 */
.table-container {
  overflow-x: auto;
}

.adl-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
}

.adl-table th,
.adl-table td {
  padding: 0.875rem;
  border: 1px solid #e5e7eb;
  text-align: center;
  font-size: 0.875rem;
}

.adl-table th {
  background: #f9fafb;
  font-weight: 600;
  color: #374151;
}

.adl-table .row-label {
  text-align: left;
  font-weight: 500;
  color: #4b5563;
}

.adl-table .radio-cell {
  cursor: pointer;
}

.adl-table input[type="radio"] {
  cursor: pointer;
  accent-color: #10b981;
  width: 18px;
  height: 18px;
}

/* 페이지네이션 */
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  margin: 2rem 0;
}

.page-btn {
  padding: 0.75rem 1.5rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  background: white;
  color: #374151;
  font-weight: 600;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s;
}

.page-btn:hover:not(:disabled) {
  border-color: #10b981;
  background: #f0fdf4;
  color: #10b981;
}

.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-numbers {
  display: flex;
  gap: 0.5rem;
}

.page-number {
  width: 40px;
  height: 40px;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  background: white;
  color: #374151;
  font-weight: 600;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s;
}

.page-number:hover {
  border-color: #10b981;
  background: #f0fdf4;
}

.page-number.active {
  border-color: #10b981;
  background: #10b981;
  color: white;
}

/* 버튼 */
.form-actions {
  display: flex;
  justify-content: center;
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
  background: #10b981;
  color: white;
}

.btn-primary:hover {
  background: #059669;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
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
  .info-grid {
    grid-template-columns: 1fr;
  }

  .radio-group,
  .checkbox-group {
    flex-direction: column;
  }

  .radio-label,
  .checkbox-label {
    width: 100%;
  }

  .page-numbers {
    flex-wrap: wrap;
  }

  .table-container {
    font-size: 0.75rem;
  }

  .adl-table th,
  .adl-table td {
    padding: 0.5rem;
  }
}
</style>
