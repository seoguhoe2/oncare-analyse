<script setup>
import { ref, computed, defineProps, defineEmits } from 'vue';
import { cognitiveAssessment } from '@/mock/careworker/cognitiveData';

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
  educationLevel: props.initialData.educationLevel || '',
  responses: props.initialData.responses || {},
  animalCount: props.initialData.animalCount || '',
  comment: props.initialData.comment || ''
});

// 섹션별 점수 계산
const getSectionScore = (section) => {
  let total = 0;

  section.items.forEach(item => {
    const response = formData.value.responses[item.code];

    if (item.score !== undefined) {
      // 단순 O/X 문제 (지남력, 주의력)
      if (response === true) total += item.score;
    } else if (item.choices) {
      // 선택지가 있는 문제
      if (response !== undefined && response !== null) {
        total += response;
      }
    } else if (item.auto_score_rule) {
      // 동물 이름 말하기 (자동 점수 계산)
      const count = parseInt(formData.value.animalCount) || 0;
      const rule = item.auto_score_rule.find(r => count >= r.min && count <= r.max);
      if (rule) total += rule.score;
    }
  });

  // 기억력-회상은 변환 필요
  if (section.code === 'F' && section.converted_total) {
    const baseScore = total;
    total = Math.round((baseScore / section.base_total) * section.converted_total);
  }

  return total;
};

// 총점 계산
const totalScore = computed(() => {
  let total = 0;
  cognitiveAssessment.sections.forEach(section => {
    if (section.max_score > 0) {
      total += getSectionScore(section);
    }
  });
  return total;
});

// 학력별 컷오프 기준
const selectedEducation = computed(() => {
  return cognitiveAssessment.education_levels.find(
    edu => edu.code === formData.value.educationLevel
  );
});

// 인지저하 판정
const cognitiveStatus = computed(() => {
  if (!selectedEducation.value) {
    return { label: '학력 선택 필요', color: 'gray' };
  }

  const cutoff = selectedEducation.value.cutoff;
  const score = totalScore.value;

  if (score >= cutoff) {
    return { label: '정상', color: 'green' };
  } else {
    return { label: '인지저하 의심', color: 'red' };
  }
});

// 응답 선택
const selectResponse = (itemCode, value) => {
  formData.value.responses[itemCode] = value;
};

// 토글 (O/X)
const toggleResponse = (itemCode) => {
  formData.value.responses[itemCode] = !formData.value.responses[itemCode];
};

// 선택 여부 확인
const isSelected = (itemCode, score) => {
  return formData.value.responses[itemCode] === score;
};

// 폼 제출
const handleSubmit = () => {
  // 필수 항목 검증
  if (!formData.value.recipientName) {
    alert('수급자명을 입력해주세요.');
    return;
  }
  if (!formData.value.careWorkerName) {
    alert('작성자명을 입력해주세요.');
    return;
  }
  if (!formData.value.educationLevel) {
    alert('학력을 선택해주세요.');
    return;
  }

  emit('submit', {
    ...formData.value,
    totalScore: totalScore.value,
    status: cognitiveStatus.value.label,
    cutoff: selectedEducation.value?.cutoff
  });
};

// 임시저장
const handleSaveDraft = () => {
  emit('save-draft', {
    ...formData.value,
    totalScore: totalScore.value,
    status: cognitiveStatus.value.label,
    cutoff: selectedEducation.value?.cutoff
  });
};
</script>

<template>
  <div class="cognitive-assessment-form">
    <!-- 기본 정보 -->
    <section class="form-section basic-info">
      <div class="section-header">
        <h2>{{ cognitiveAssessment.title }}</h2>
        <p class="section-desc">수급자의 인지 능력을 평가합니다 (총점: {{ cognitiveAssessment.max_score }}점)</p>
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

      <div class="education-select">
        <label>학력 선택 <span class="required">*</span></label>
        <div class="education-options">
          <label
            v-for="edu in cognitiveAssessment.education_levels"
            :key="edu.code"
            class="education-label"
            :class="{ active: formData.educationLevel === edu.code }"
          >
            <input
              v-model="formData.educationLevel"
              type="radio"
              :value="edu.code"
            />
            <span class="edu-text">
              {{ edu.label }}
              <span class="cutoff-text">(기준: {{ edu.cutoff }}점)</span>
            </span>
          </label>
        </div>
      </div>
    </section>

    <!-- 평가 섹션들 -->
    <section
      v-for="section in cognitiveAssessment.sections"
      :key="section.code"
      class="form-section cognitive-section"
    >
      <div class="section-title-row">
        <h3 class="section-title">
          {{ section.title }}
          <span v-if="section.max_score > 0" class="max-score">
            ({{ getSectionScore(section) }} / {{ section.max_score }}점)
          </span>
        </h3>
      </div>

      <!-- 기억력 등록 (점수 없음) -->
      <div v-if="section.code === 'B'" class="instruction-box">
        <p class="instruction-text">{{ section.items[0].instruction }}</p>
        <p class="note-text">※ {{ section.items[0].note }}</p>
      </div>

      <!-- 지남력, 주의력 (O/X) -->
      <div
        v-else-if="section.code === 'A' || section.code === 'C'"
        class="question-list"
      >
        <div
          v-for="item in section.items"
          :key="item.code"
          class="question-item"
        >
          <div class="question-text">{{ item.question }}</div>
          <button
            type="button"
            class="toggle-btn"
            :class="{ active: formData.responses[item.code] }"
            @click="toggleResponse(item.code)"
          >
            {{ formData.responses[item.code] ? '✓ 정답' : '✗ 오답' }}
          </button>
        </div>
      </div>

      <!-- 선택지가 있는 항목들 (시공간, 집행, 기억력-회상, 언어) -->
      <div v-else class="choice-list">
        <!-- 동물 이름 말하기 (숫자 입력) -->
        <div
          v-for="item in section.items"
          :key="item.code"
          class="choice-item"
        >
          <div class="choice-question">
            <span v-if="item.word" class="word-badge">{{ item.word }}</span>
            {{ item.question }}
          </div>

          <!-- 숫자 입력 (동물 이름) -->
          <div v-if="item.input_type === 'number'" class="number-input-box">
            <input
              v-model="formData.animalCount"
              type="number"
              min="0"
              max="99"
              placeholder="개수 입력"
            />
            <span class="unit">개</span>
          </div>

          <!-- 선택지 버튼 -->
          <div v-else-if="item.choices" class="choice-buttons">
            <button
              v-for="choice in item.choices"
              :key="choice.score"
              type="button"
              class="choice-btn"
              :class="{ active: isSelected(item.code, choice.score) }"
              @click="selectResponse(item.code, choice.score)"
            >
              <span class="choice-score">{{ choice.score }}점</span>
              <span class="choice-label">{{ choice.label }}</span>
            </button>
          </div>
        </div>
      </div>
    </section>

    <!-- 총점 및 결과 -->
    <section class="form-section result-section">
      <h3 class="section-title">평가 결과</h3>

      <div class="result-box">
        <div class="result-row">
          <span class="result-label">총점</span>
          <span class="result-value total-score">{{ totalScore }} / {{ cognitiveAssessment.max_score }}점</span>
        </div>
        <div v-if="selectedEducation" class="result-row">
          <span class="result-label">기준 점수</span>
          <span class="result-value">{{ selectedEducation.cutoff }}점 ({{ selectedEducation.label }})</span>
        </div>
        <div class="result-row">
          <span class="result-label">판정</span>
          <span class="result-badge" :class="`status-${cognitiveStatus.color}`">
            {{ cognitiveStatus.label }}
          </span>
        </div>
      </div>

      <!-- 특이사항 메모 -->
      <div class="comment-section">
        <label>특이사항 및 평가 소견</label>
        <textarea
          v-model="formData.comment"
          placeholder="평가 과정에서 관찰된 특이사항, 수급자의 반응, 추가 소견 등을 기록해주세요."
          rows="5"
        ></textarea>
      </div>
    </section>

    <!-- 제출 버튼 -->
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
.cognitive-assessment-form {
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

.section-title-row {
  margin-bottom: 1rem;
}

.section-title {
  font-size: 1.125rem;
  font-weight: 700;
  color: #6366f1;
  margin: 0;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #e0e7ff;
}

.max-score {
  font-size: 0.875rem;
  color: #6b7280;
  margin-left: 0.5rem;
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
  margin-bottom: 1.5rem;
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
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

/* 학력 선택 */
.education-select {
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

.education-select > label {
  display: block;
  font-weight: 600;
  color: #4b5563;
  font-size: 0.875rem;
  margin-bottom: 0.75rem;
}

.education-options {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.education-label {
  flex: 1;
  min-width: 200px;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.875rem;
  border: 2px solid #e5e7eb;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.2s;
}

.education-label:hover {
  border-color: #6366f1;
  background: #f5f3ff;
}

.education-label.active {
  border-color: #6366f1;
  background: #e0e7ff;
}

.education-label input {
  cursor: pointer;
  accent-color: #6366f1;
}

.edu-text {
  flex: 1;
  font-size: 0.875rem;
  color: #374151;
  font-weight: 500;
}

.cutoff-text {
  display: block;
  font-size: 0.75rem;
  color: #6b7280;
  margin-top: 0.25rem;
}

/* 인지 평가 섹션 */
.cognitive-section {
  background: #faf5ff;
}

/* 지시사항 박스 */
.instruction-box {
  background: white;
  padding: 1.25rem;
  border-radius: 0.5rem;
  border-left: 4px solid #6366f1;
}

.instruction-text {
  font-size: 0.9375rem;
  color: #1f2937;
  font-weight: 600;
  margin: 0 0 0.5rem 0;
}

.note-text {
  font-size: 0.8125rem;
  color: #6b7280;
  margin: 0;
}

/* 질문 리스트 (O/X) */
.question-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.question-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background: white;
  border-radius: 0.5rem;
  border: 1px solid #e5e7eb;
}

.question-text {
  font-size: 0.9375rem;
  color: #374151;
  font-weight: 500;
}

.toggle-btn {
  padding: 0.5rem 1.25rem;
  border: 2px solid #e5e7eb;
  border-radius: 0.375rem;
  background: white;
  color: #6b7280;
  font-weight: 600;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s;
  min-width: 100px;
}

.toggle-btn:hover {
  border-color: #6366f1;
  background: #f5f3ff;
}

.toggle-btn.active {
  border-color: #6366f1;
  background: #6366f1;
  color: white;
}

/* 선택지 리스트 */
.choice-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.choice-item {
  background: white;
  padding: 1.25rem;
  border-radius: 0.5rem;
  border: 1px solid #e5e7eb;
}

.choice-question {
  font-size: 0.9375rem;
  color: #374151;
  font-weight: 600;
  margin-bottom: 1rem;
}

.word-badge {
  display: inline-block;
  background: #6366f1;
  color: white;
  padding: 0.25rem 0.75rem;
  border-radius: 0.25rem;
  font-size: 0.8125rem;
  margin-right: 0.5rem;
}

/* 숫자 입력 */
.number-input-box {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.number-input-box input {
  width: 120px;
  padding: 0.625rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
}

.number-input-box input:focus {
  outline: none;
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

.unit {
  font-size: 0.875rem;
  color: #6b7280;
}

/* 선택지 버튼 */
.choice-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.choice-btn {
  flex: 1;
  min-width: 150px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
  padding: 0.875rem;
  border: 2px solid #e5e7eb;
  border-radius: 0.5rem;
  background: white;
  cursor: pointer;
  transition: all 0.2s;
}

.choice-btn:hover {
  border-color: #6366f1;
  background: #f5f3ff;
}

.choice-btn.active {
  border-color: #6366f1;
  background: #e0e7ff;
}

.choice-score {
  font-size: 1rem;
  font-weight: 700;
  color: #6366f1;
}

.choice-label {
  font-size: 0.8125rem;
  color: #374151;
  text-align: center;
}

/* 결과 섹션 */
.result-section {
  background: #f0fdf4;
  border: 2px solid #86efac;
}

.result-box {
  background: white;
  padding: 1.5rem;
  border-radius: 0.5rem;
  margin-bottom: 1.5rem;
}

.result-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.875rem 0;
  border-bottom: 1px solid #e5e7eb;
}

.result-row:last-child {
  border-bottom: none;
}

.result-label {
  font-size: 0.9375rem;
  color: #6b7280;
  font-weight: 600;
}

.result-value {
  font-size: 1rem;
  color: #374151;
  font-weight: 600;
}

.total-score {
  font-size: 1.25rem;
  color: #6366f1;
  font-weight: 700;
}

.result-badge {
  padding: 0.5rem 1rem;
  border-radius: 9999px;
  font-weight: 700;
  font-size: 0.875rem;
}

.status-green {
  background: #dcfce7;
  color: #16a34a;
}

.status-red {
  background: #fee2e2;
  color: #dc2626;
}

.status-gray {
  background: #f3f4f6;
  color: #6b7280;
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
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
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
  background: #6366f1;
  color: white;
}

.btn-primary:hover {
  background: #4f46e5;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
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

  .education-label {
    min-width: 100%;
  }

  .question-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.75rem;
  }

  .toggle-btn {
    width: 100%;
  }

  .choice-buttons {
    flex-direction: column;
  }

  .choice-btn {
    min-width: 100%;
  }
}
</style>
