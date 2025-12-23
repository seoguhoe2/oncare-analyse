<script setup>
import { ref, computed, defineProps, defineEmits } from 'vue';
import { bedsoreAssessment } from '@/mock/careworker/bedsoreData';

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
  bedsoreRisk: props.initialData.bedsoreRisk || {},
  comment: props.initialData.comment || ''
});

// 욕창위험도 점수 계산
const totalBedsoreScore = computed(() => {
  let total = 0;
  Object.values(formData.value.bedsoreRisk).forEach(score => {
    if (typeof score === 'number') total += score;
  });
  return total;
});

// 욕창위험도 등급
const bedsoreGrade = computed(() => {
  const score = totalBedsoreScore.value;
  const grade = bedsoreAssessment.grading.ranges.find(
    r => score >= r.min && score <= r.max
  );
  return grade || bedsoreAssessment.grading.ranges[bedsoreAssessment.grading.ranges.length - 1];
});

// 욕창위험도 항목 선택
const selectBedsoreRisk = (itemCode, choice) => {
  formData.value.bedsoreRisk[itemCode] = choice.score;
};

// 선택된 항목인지 확인
const isSelected = (itemCode, score) => {
  return formData.value.bedsoreRisk[itemCode] === score;
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
  if (Object.keys(formData.value.bedsoreRisk).length < bedsoreAssessment.items.length) {
    alert('모든 평가 항목을 선택해주세요.');
    return;
  }

  emit('submit', {
    ...formData.value,
    totalScore: totalBedsoreScore.value,
    grade: bedsoreGrade.value.label
  });
};

// 임시저장
const handleSaveDraft = () => {
  emit('save-draft', {
    ...formData.value,
    totalScore: totalBedsoreScore.value,
    grade: bedsoreGrade.value.label
  });
};
</script>

<template>
  <div class="bedsore-assessment-form">
    <section class="form-section basic-info">
      <div class="section-header">
        <h2>{{ bedsoreAssessment.title }}</h2>
        <p class="section-desc">욕창 발생 위험도를 평가하여 예방 관리 계획을 수립합니다.</p>
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

    <section class="form-section bedsore-section">
      <h3 class="section-title">평가 항목</h3>

      <div class="bedsore-table">
        <div class="table-header">
          <div class="header-label">평가항목</div>
          <div class="header-scores">
            <div
              v-for="col in bedsoreAssessment.columns"
              :key="col.score"
              class="score-col"
            >
              {{ col.label }}
            </div>
          </div>
        </div>

        <div
          v-for="item in bedsoreAssessment.items"
          :key="item.code"
          class="table-row"
        >
          <div class="row-label">
            {{ item.label }}
            <span class="required">*</span>
          </div>
          <div class="row-choices">
            <div
              v-for="choice in item.choices"
              :key="choice.score"
              class="choice-cell"
              :class="{ active: isSelected(item.code, choice.score) }"
              @click="selectBedsoreRisk(item.code, choice)"
            >
              <input
                type="radio"
                :name="`bedsore-${item.code}`"
                :value="choice.score"
                :checked="isSelected(item.code, choice.score)"
              />
              <span class="choice-text">{{ choice.label }}</span>
            </div>
          </div>
        </div>

        <div class="table-result">
          <div class="result-score">
            <strong>총점:</strong> {{ totalBedsoreScore }}점
          </div>
          <div
            class="result-grade"
            :class="`grade-${bedsoreGrade.color}`"
          >
            {{ bedsoreGrade.label }}
          </div>
        </div>
      </div>

      <div v-if="bedsoreAssessment.grading.comment_field" class="comment-section">
        <label>특이사항 및 관리 계획</label>
        <textarea
          v-model="formData.comment"
          placeholder="욕창 발생 위험 요인, 예방 관리 계획 등을 기록해주세요."
          rows="5"
        ></textarea>
      </div>
    </section>

    <div class="form-actions">
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
.bedsore-assessment-form {
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
  color: #7c3aed;
  margin: 0 0 1rem 0;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #ede9fe;
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
  margin-bottom: 0;
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

.info-row input[type="text"],
.info-row input[type="date"] {
  padding: 0.625rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  transition: border-color 0.2s;
}

.info-row input:focus {
  outline: none;
  border-color: #7c3aed;
  box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
}

/* 욕창위험도 평가 섹션 */
.bedsore-section {
  background: #faf5ff;
}

.bedsore-table {
  border: 1px solid #d1d5db;
  border-radius: 0.5rem;
  overflow: hidden;
  margin-bottom: 1.5rem;
}

/* 테이블 헤더 */
.table-header {
  display: grid;
  grid-template-columns: 200px 1fr;
  background: #f3f4f6;
  border-bottom: 2px solid #d1d5db;
}

.header-label {
  padding: 1rem;
  font-weight: 700;
  color: #1f2937;
  border-right: 1px solid #d1d5db;
  display: flex;
  align-items: center;
}

.header-scores {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
}

.score-col {
  padding: 1rem;
  text-align: center;
  font-weight: 600;
  color: #4b5563;
  border-right: 1px solid #e5e7eb;
}

.score-col:last-child {
  border-right: none;
}

/* 테이블 행 */
.table-row {
  display: grid;
  grid-template-columns: 200px 1fr;
  border-bottom: 1px solid #e5e7eb;
  background: white;
}

.table-row:last-child {
  border-bottom: none;
}

.row-label {
  padding: 1rem;
  font-weight: 600;
  color: #374151;
  border-right: 1px solid #d1d5db;
  font-size: 0.875rem;
  display: flex;
  align-items: center;
}

.row-choices {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 0;
}

.choice-cell {
  padding: 1rem;
  border-right: 1px solid #e5e7eb;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.choice-cell:last-child {
  border-right: none;
}

.choice-cell:hover {
  background: #faf5ff;
}

.choice-cell.active {
  background: #ede9fe;
  border-color: #7c3aed;
}

.choice-cell input[type="radio"] {
  cursor: pointer;
  accent-color: #7c3aed;
}

.choice-text {
  font-size: 0.8125rem;
  color: #374151;
  line-height: 1.4;
  flex: 1;
}

/* 총점 및 결과 */
.table-result {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem;
  background: #f9fafb;
  border-top: 2px solid #d1d5db;
}

.result-score {
  font-size: 1.25rem;
  font-weight: 700;
  color: #1f2937;
}

.result-grade {
  padding: 0.625rem 1.25rem;
  border-radius: 9999px;
  font-weight: 700;
  font-size: 0.875rem;
}

.grade-green {
  background: #dcfce7;
  color: #16a34a;
}

.grade-yellow {
  background: #fef3c7;
  color: #d97706;
}

.grade-red {
  background: #fee2e2;
  color: #dc2626;
}

/* 특이사항 메모 */
.comment-section {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.comment-section label {
  font-weight: 600;
  color: #374151;
  font-size: 0.875rem;
}

.comment-section textarea {
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  resize: vertical;
  font-family: inherit;
  transition: border-color 0.2s;
}

.comment-section textarea:focus {
  outline: none;
  border-color: #7c3aed;
  box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
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
  background: #7c3aed;
  color: white;
}

.btn-primary:hover {
  background: #6d28d9;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(124, 58, 237, 0.3);
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
@media (max-width: 1024px) {
  .table-header,
  .table-row {
    grid-template-columns: 150px 1fr;
  }

  .choice-text {
    font-size: 0.75rem;
  }
}

@media (max-width: 768px) {
  .info-grid {
    grid-template-columns: 1fr;
  }

  .table-header,
  .table-row {
    grid-template-columns: 1fr;
  }

  .header-label,
  .row-label {
    border-right: none;
    border-bottom: 1px solid #d1d5db;
  }

  .row-choices {
    grid-template-columns: 1fr;
  }

  .choice-cell {
    border-right: none;
    border-bottom: 1px solid #e5e7eb;
  }

  .choice-cell:last-child {
    border-bottom: none;
  }

  .table-result {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
    text-align: center;
  }
}
</style>