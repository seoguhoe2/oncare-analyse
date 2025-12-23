<script setup>
import { ref, computed } from 'vue';
import { careLogFormData, fallRiskAssessment } from '@/mock/careworker/careLogData';

// Form data
const formData = ref({
  recipientName: '',
  careWorkerName: '',
  careDate: new Date().toISOString().split('T')[0],
  startTime: '',
  endTime: '',
  serviceType: 'visit',
  physicalSupport: {},
  cognitiveSupport: {},
  physicalObservation: {},
  specialNotes: '',
  fallRisk: {}
});

// 낙상위험도 점수 계산
const totalFallRiskScore = computed(() => {
  let total = 0;
  Object.values(formData.value.fallRisk).forEach(score => {
    if (typeof score === 'number') total += score;
  });
  return total;
});

// 낙상위험도 등급
const fallRiskGrade = computed(() => {
  const score = totalFallRiskScore.value;
  const grade = fallRiskAssessment.grading.ranges.find(
    r => score >= r.min && score <= r.max
  );
  return grade || fallRiskAssessment.grading.ranges[0];
});

// 낙상위험도 항목 선택
const selectFallRisk = (itemCode, choice) => {
  formData.value.fallRisk[itemCode] = choice.score;
};

// 선택된 항목인지 확인
const isSelected = (itemCode, score) => {
  return formData.value.fallRisk[itemCode] === score;
};

// 폼 제출
const handleSubmit = () => {
  console.log('요양일지 제출:', formData.value);
  alert('요양일지가 저장되었습니다.');
};
</script>

<template>
  <div class="care-log-form">
    <section class="form-section basic-info">
      <div class="section-header">
        <h2>장기요양보호 제공기록지</h2>
      </div>

      <div class="info-grid">
        <div class="info-row">
          <label>성명</label>
          <input v-model="formData.recipientName" type="text" placeholder="수급자명" />
        </div>
        <div class="info-row">
          <label>작성자 성명</label>
          <input v-model="formData.careWorkerName" type="text" placeholder="요양보호사" />
        </div>
      </div>

      <div class="info-grid">
        <div class="info-row">
          <label>제공일</label>
          <input v-model="formData.careDate" type="date" />
        </div>
        <div class="info-row time-row">
          <label>서비스 시간</label>
          <div class="time-inputs">
            <input v-model="formData.startTime" type="time" />
            <span>-</span>
            <input v-model="formData.endTime" type="time" />
          </div>
        </div>
      </div>

      <div class="info-grid">
        <div class="info-row full-width">
          <label>서비스 유형</label>
          <div class="radio-group">
            <label v-for="type in careLogFormData.serviceTypes" :key="type.value" class="radio-label">
              <input v-model="formData.serviceType" type="radio" :value="type.value" />
              <span>{{ type.label }}</span>
            </label>
          </div>
        </div>
      </div>
    </section>

    <section class="form-section">
      <h3 class="section-title">{{ careLogFormData.physicalSupport.title }}</h3>

      <div class="checklist">
        <div v-for="item in careLogFormData.physicalSupport.items" :key="item.code" class="checklist-item">
          <div class="item-label">{{ item.label }}</div>
          <div class="item-options">
            <label v-for="option in item.options" :key="option.value" class="checkbox-label">
              <input
                v-model="formData.physicalSupport[item.code]"
                type="checkbox"
                :value="option.value"
              />
              <span>{{ option.label }}</span>
            </label>
          </div>
        </div>
      </div>
    </section>

    <section class="form-section">
      <h3 class="section-title">{{ careLogFormData.cognitiveSupport.title }}</h3>

      <div class="checklist">
        <div v-for="item in careLogFormData.cognitiveSupport.items" :key="item.code" class="checklist-item">
          <div class="item-label">{{ item.label }}</div>
          <div class="item-options">
            <label v-for="option in item.options" :key="option.value" class="radio-label">
              <input
                v-model="formData.cognitiveSupport[item.code]"
                type="radio"
                :value="option.value"
              />
              <span>{{ option.label }}</span>
            </label>
          </div>
        </div>
      </div>
    </section>

    <section class="form-section">
      <h3 class="section-title">{{ careLogFormData.physicalObservation.title }}</h3>

      <div class="observation-grid">
        <div v-for="item in careLogFormData.physicalObservation.items" :key="item.code" class="observation-item">
          <div class="obs-label">{{ item.label }}</div>
          <div class="obs-fields">
            <div v-for="field in item.fields" :key="field.code" class="field-group">
              <label>{{ field.label }}</label>
              <select v-if="field.type === 'select'" v-model="formData.physicalObservation[field.code]">
                <option value="">선택</option>
                <option v-for="opt in field.options" :key="opt.value" :value="opt.value">
                  {{ opt.label }}
                </option>
              </select>
              <div v-else-if="field.type === 'text'" class="text-with-unit">
                <input
                  v-model="formData.physicalObservation[field.code]"
                  type="text"
                  :placeholder="field.label"
                />
                <span class="unit">{{ field.unit }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="form-section fall-risk-section">
      <h3 class="section-title">{{ fallRiskAssessment.title }}</h3>

      <div class="fall-risk-table">
        <div class="risk-table-header">
          <div class="header-label">평가항목</div>
          <div class="header-scores">
            <div v-for="col in fallRiskAssessment.columns" :key="col.score" class="score-col">
              {{ col.label }}
            </div>
          </div>
        </div>

        <div v-for="item in fallRiskAssessment.items" :key="item.code" class="risk-row">
          <div class="row-label">{{ item.label }}</div>
          <div class="row-choices">
            <div
              v-for="choice in item.choices"
              :key="choice.score"
              class="choice-cell"
              :class="{ active: isSelected(item.code, choice.score) }"
              @click="selectFallRisk(item.code, choice)"
            >
              <input
                type="radio"
                :name="`risk-${item.code}`"
                :value="choice.score"
                :checked="isSelected(item.code, choice.score)"
              />
              <span class="choice-text">{{ choice.label }}</span>
            </div>
          </div>
        </div>

        <div class="risk-result">
          <div class="result-score">
            <strong>총점:</strong> {{ totalFallRiskScore }}점
          </div>
          <div class="result-grade" :class="`grade-${fallRiskGrade.color}`">
            {{ fallRiskGrade.label }}
          </div>
        </div>
      </div>

      <div class="fall-risk-comment">
        <label>특이사항 및 건강상태 메모</label>
        <textarea
          v-model="formData.specialNotes"
          :placeholder="careLogFormData.specialNotes.placeholder"
          rows="4"
        ></textarea>
      </div>
    </section>

    <div class="form-actions">
      <button type="button" class="btn-secondary">임시저장</button>
      <button type="button" class="btn-primary" @click="handleSubmit">제출하기</button>
    </div>
  </div>
</template>

<style scoped>
.care-log-form {
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
  font-size: 1.25rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 1rem 0;
  text-align: center;
}

.section-title {
  font-size: 1.125rem;
  font-weight: 700;
  color: #16a34a;
  margin: 0 0 1rem 0;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #dcfce7;
}

/* 기본 정보 */
.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
  margin-bottom: 1rem;
}

.info-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.info-row.full-width {
  grid-column: 1 / -1;
}

.info-row label {
  min-width: 100px;
  font-weight: 600;
  color: #4b5563;
  font-size: 0.875rem;
}

.info-row input[type="text"],
.info-row input[type="date"],
.info-row input[type="time"] {
  flex: 1;
  padding: 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
}

.time-inputs {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex: 1;
}

.time-inputs input {
  flex: 1;
}

.radio-group {
  display: flex;
  gap: 1rem;
  flex: 1;
}

.radio-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  font-size: 0.875rem;
  color: #4b5563;
}

/* 체크리스트 */
.checklist {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.checklist-item {
  display: grid;
  grid-template-columns: 150px 1fr;
  gap: 1rem;
  align-items: start;
  padding: 0.75rem;
  border: 1px solid #e5e7eb;
  border-radius: 0.375rem;
}

.item-label {
  font-weight: 600;
  color: #374151;
  font-size: 0.875rem;
}

.item-options {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  font-size: 0.875rem;
  color: #4b5563;
}

/* 관찰 그리드 */
.observation-grid {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.observation-item {
  border: 1px solid #e5e7eb;
  border-radius: 0.375rem;
  padding: 1rem;
}

.obs-label {
  font-weight: 600;
  color: #374151;
  margin-bottom: 0.75rem;
  font-size: 0.875rem;
}

.obs-fields {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.field-group label {
  font-size: 0.75rem;
  color: #6b7280;
  font-weight: 600;
}

.field-group select,
.field-group input {
  padding: 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
}

.text-with-unit {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.text-with-unit input {
  flex: 1;
}

.unit {
  font-size: 0.75rem;
  color: #6b7280;
  white-space: nowrap;
}

/* 낙상위험도 평가 */
.fall-risk-section {
  background: #fffbeb;
}

.fall-risk-table {
  border: 1px solid #d1d5db;
  border-radius: 0.5rem;
  overflow: hidden;
  margin-bottom: 1rem;
}

.risk-table-header {
  display: grid;
  grid-template-columns: 200px 1fr;
  background: #f3f4f6;
  border-bottom: 2px solid #d1d5db;
}

.header-label {
  padding: 0.75rem;
  font-weight: 700;
  color: #1f2937;
  border-right: 1px solid #d1d5db;
}

.header-scores {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
}

.score-col {
  padding: 0.75rem;
  text-align: center;
  font-weight: 600;
  color: #4b5563;
  border-right: 1px solid #e5e7eb;
}

.score-col:last-child {
  border-right: none;
}

.risk-row {
  display: grid;
  grid-template-columns: 200px 1fr;
  border-bottom: 1px solid #e5e7eb;
}

.risk-row:last-child {
  border-bottom: none;
}

.row-label {
  padding: 1rem 0.75rem;
  font-weight: 600;
  color: #374151;
  border-right: 1px solid #d1d5db;
  font-size: 0.875rem;
  display: flex;
  align-items: center;
}

.row-choices {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 0.5rem;
  padding: 0.75rem;
}

.choice-cell {
  padding: 0.75rem;
  border: 2px solid #e5e7eb;
  border-radius: 0.375rem;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: start;
  gap: 0.5rem;
}

.choice-cell:hover {
  border-color: #16a34a;
  background: #f0fdf4;
}

.choice-cell.active {
  border-color: #16a34a;
  background: #dcfce7;
}

.choice-cell input[type="radio"] {
  margin-top: 0.25rem;
  cursor: pointer;
}

.choice-text {
  font-size: 0.75rem;
  color: #374151;
  line-height: 1.4;
  flex: 1;
}

.risk-result {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background: #f9fafb;
  border-top: 2px solid #d1d5db;
}

.result-score {
  font-size: 1.125rem;
  font-weight: 700;
  color: #1f2937;
}

.result-grade {
  padding: 0.5rem 1rem;
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

.fall-risk-comment {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.fall-risk-comment label {
  font-weight: 600;
  color: #374151;
  font-size: 0.875rem;
}

.fall-risk-comment textarea {
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  resize: vertical;
  font-family: inherit;
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
  padding: 0.75rem 2rem;
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
}

.btn-secondary {
  background: white;
  color: #4b5563;
  border: 1px solid #d1d5db;
}

.btn-secondary:hover {
  background: #f9fafb;
}

/* 반응형 */
@media (max-width: 768px) {
  .info-grid {
    grid-template-columns: 1fr;
  }

  .checklist-item {
    grid-template-columns: 1fr;
  }

  .obs-fields {
    grid-template-columns: 1fr;
  }

  .risk-table-header,
  .risk-row {
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
}
</style>