<script setup>
import { ref, computed, watch, defineProps, defineEmits, onMounted } from 'vue';
import { cognitiveAssessment } from '@/mock/careworker/cognitiveData';
import { getMyBeneficiaries } from '@/api/careworker';
import { useUserStore } from '@/stores/user';

const props = defineProps({
  initialData: { type: Object, default: null },
  readOnly: { type: Boolean, default: false }
});

const emit = defineEmits(['submit', 'save-draft']);
const userStore = useUserStore();

const beneficiaries = ref([]);
const loadingBeneficiaries = ref(false);

const loadBeneficiaries = async () => {
  try {
    loadingBeneficiaries.value = true;
    const response = await getMyBeneficiaries();
    const data = response?.data ?? response;
    beneficiaries.value = Array.isArray(data) ? data : [];
  } catch (error) {
    console.error('API Error:', error);
    beneficiaries.value = [];
  } finally {
    loadingBeneficiaries.value = false;
  }
};

const formData = ref({
  beneficiaryId: props.initialData?.beneficiaryId ?? 0,
  recipientName: props.initialData?.recipientName || '',
  careWorkerName: props.initialData?.careWorkerName || userStore.name || '',
  assessmentDate: props.initialData?.assessmentDate || new Date().toISOString().split('T')[0],
  educationLevel: props.initialData?.educationLevel || 'MIDDLE_HIGH',
  responses: props.initialData?.responses || props.initialData?.cognitiveItems || {},
  comment: props.initialData?.comment || ''
});

// Watch for initialData changes
watch(() => props.initialData, (newData) => {
  if (newData && Object.keys(newData).length > 0 && newData.beneficiaryId) {
    formData.value = {
      beneficiaryId: newData.beneficiaryId,
      recipientName: newData.recipientName || formData.value.recipientName,
      careWorkerName: newData.careWorkerName || userStore.name || '',
      assessmentDate: newData.assessmentDate || formData.value.assessmentDate,
      educationLevel: newData.educationLevel || formData.value.educationLevel,
      responses: newData.responses || newData.cognitiveItems || formData.value.responses || {},
      comment: newData.comment || formData.value.comment || ''
    };
  }
}, { deep: true, immediate: true });

// 섹션별 점수 계산
const getSectionScore = (section) => {
  let score = 0;
  section.items.forEach(item => {
    const val = formData.value.responses[item.code];

    if (item.type === 'NUMBER_INPUT') {
      const count = parseInt(val) || 0;
      const rule = item.auto_score_rule?.find(r => count >= r.min && count <= r.max);
      if (rule) score += rule.score;
    } else if (section.type === 'OX') {
      if (val === true) score += 1;
    } else if (item.choices && typeof val === 'number') {
      score += val;
    }
  });

  if (section.type === 'CONVERT_SCORE' && section.convert_rule) {
    const { base_total, converted_total } = section.convert_rule;
    score = Math.round((score / base_total) * converted_total);
  }

  return Math.min(score, section.max_score);
};

// 총점
const totalScore = computed(() => {
  let total = 0;
  cognitiveAssessment.sections.forEach(sec => {
    if (sec.max_score > 0) total += getSectionScore(sec);
  });
  return total;
});

// 개별 문항 점수 계산
const getAnimalScore = (item) => {
  const count = parseInt(formData.value.responses[item.code]) || 0;
  const rule = item.auto_score_rule?.find(r => count >= r.min && count <= r.max);
  return rule ? rule.score : 0;
};

// 선택된 학력 정보
const selectedEduInfo = computed(() => {
  return cognitiveAssessment.education_levels.find(e => e.code === formData.value.educationLevel);
});

// 판정 결과
const cognitiveGrade = computed(() => {
  const cutoff = selectedEduInfo.value?.cutoff || 0;
  if (totalScore.value >= cutoff) {
    return { label: '인지기능 정상', color: 'green', class: 'normal' };
  } else {
    return { label: '인지저하 의심', color: 'red', class: 'warning' };
  }
});

// 토글 (O/X)
const toggleOX = (code) => {
  if (props.readOnly) return;
  const current = formData.value.responses[code];
  formData.value.responses[code] = !current;
};

// 선택형 라디오 버튼
const setResponse = (code, value) => {
  if (props.readOnly) return;
  formData.value.responses[code] = value;
};

const handleSubmit = () => {
  if (!formData.value.beneficiaryId) return alert('수급자를 선택하세요.');
  if (!formData.value.careWorkerName) return alert('작성자명을 입력하세요.');
  
  // 모든 항목 입력 검사
  for (const section of cognitiveAssessment.sections) {
    // OX (정답/오답) 항목은 필수 입력 제외 (체크 안하면 0점 처리됨)
    if (section.type === 'OX') continue;

    for (const item of section.items) {
      // INSTRUCTION_ONLY 섹션의 경우(예: B섹션), 실제 입력 컴포넌트가 items에 없을 수 있음. 
      // 하지만 B1은 choices가 있어서 일반 item으로 처리됨.
      if (section.type === 'INSTRUCTION_ONLY' && !item.choices) continue; 

      const val = formData.value.responses[item.code];
      // undefined, null, 빈 문자열인 경우 미입력으로 간주 (0, false는 유효값)
      if (val === undefined || val === null || val === '') {
        alert(`'${section.title}'의\n[${item.question}] 항목을 입력해주세요.`);
        return;
      }
    }
  }

  emit('submit', {
    ...formData.value,
    totalScore: totalScore.value,
    grade: cognitiveGrade.value.label
  });
};

const handleSaveDraft = () => {
  emit('save-draft', { ...formData.value });
};

onMounted(() => {
  loadBeneficiaries();
});
</script>

<template>
  <div class="cognitive-assessment-form">
    <section class="form-section basic-info">
      <div class="section-header">
        <h2>{{ cognitiveAssessment.title }}</h2>
        <p class="section-desc">CIST(인지선별검사) 기반으로 인지기능을 평가합니다. (연 1회)</p>
      </div>

      <div class="info-grid">
        <div class="info-row">
          <label>수급자명 <span v-if="!readOnly" class="required">*</span></label>
          <input
            v-if="readOnly"
            v-model="formData.recipientName"
            type="text"
            disabled
            class="readonly-field"
          />
          <select v-else v-model.number="formData.beneficiaryId" :disabled="loadingBeneficiaries">
            <option :value="0">{{ loadingBeneficiaries ? '불러오는 중...' : '선택하세요' }}</option>
            <option v-for="b in beneficiaries" :key="b.beneficiaryId" :value="b.beneficiaryId">{{ b.name }}</option>
          </select>
        </div>
        <div class="info-row">
          <label>작성자명 <span v-if="!readOnly" class="required">*</span></label>
          <input v-model="formData.careWorkerName" type="text" placeholder="입력하세요" :disabled="readOnly" />
        </div>
        <div class="info-row">
          <label>평가일</label>
          <input v-model="formData.assessmentDate" type="date" :disabled="readOnly" />
        </div>
        <div class="info-row">
          <label>수급자 학력 (판정 기준)</label>
          <select v-model="formData.educationLevel" :disabled="readOnly">
            <option v-for="edu in cognitiveAssessment.education_levels" :key="edu.code" :value="edu.code">
              {{ edu.label }}
            </option>
          </select>
        </div>
      </div>
    </section>

    <section class="form-section cognitive-section">
      <div class="section-top-bar">
        <h3 class="section-title">평가 문항</h3>
        <div class="current-score-pill">
          현재 총점: <strong>{{ totalScore }}</strong> / {{ cognitiveAssessment.max_score }}점
        </div>
      </div>

      <div 
        v-for="section in cognitiveAssessment.sections" 
        :key="section.code" 
        class="question-group"
      >
        <div class="group-header">
          <h4 class="group-title">
            {{ section.title }} 
            <span class="max-score">({{ section.max_score }}점)</span>
          </h4>
          <span class="group-score">
            획득: {{ getSectionScore(section) }}점
            <span v-if="section.type === 'CONVERT_SCORE'" class="convert-badge">환산</span>
          </span>
        </div>

        <div v-if="section.instruction" class="instruction-box">
          <p class="inst-text">💡 {{ section.instruction }}</p>
          <p v-if="section.sub_instruction" class="sub-inst-text">{{ section.sub_instruction }}</p>
        </div>

        <div class="items-container">
          <div v-for="item in section.items" :key="item.code" class="item-row">
            
            <div class="item-content">
              <p class="item-question">{{ item.question }}</p>
              <p v-if="item.desc" class="item-desc">{{ item.desc }}</p>
            </div>

            <div class="item-action">
              <div v-if="section.type === 'OX'" class="ox-toggle">
                <button 
                  type="button" 
                  class="ox-btn"
                  :class="{ active: formData.responses[item.code] === true, 'read-only': readOnly }"
                  @click="toggleOX(item.code)"
                >
                  <span class="ox-icon">{{ formData.responses[item.code] ? '⭕' : '❌' }}</span>
                  <span class="ox-label">{{ formData.responses[item.code] ? '정답' : '오답' }}</span>
                </button>
              </div>

              <div v-else-if="item.type === 'NUMBER_INPUT'" class="number-input-group">
                <div class="input-wrapper">
                  <input 
                    type="number" 
                    v-model="formData.responses[item.code]" 
                    class="score-input" 
                    min="0" 
                    :disabled="readOnly"
                  />
                  <span class="unit">{{ item.unit }}</span>
                </div>
                <span class="auto-score-display">{{ getAnimalScore(item) }}점 획득</span>
              </div>

              <div v-else-if="item.choices" class="choice-group">
                <div 
                  v-for="choice in item.choices" 
                  :key="choice.label" 
                  class="choice-chip"
                  :class="{ 
                    active: formData.responses[item.code] === (choice.value ?? choice.score),
                    'read-only': readOnly
                  }"
                  @click="setResponse(item.code, (choice.value ?? choice.score))"
                >
                  <div class="radio-circle" :class="{ checked: formData.responses[item.code] === (choice.value ?? choice.score) }"></div>
                  <span>{{ choice.label }}</span>
                </div>
              </div>
            </div>

          </div>
        </div>
      </div>

      <div class="grading-summary-box">
        <h4 class="summary-title">판정 결과</h4>
        
        <div class="criteria-info">
          <div class="criteria-row">
            <span class="c-label">선택된 학력 기준:</span>
            <span class="c-val">{{ selectedEduInfo?.label }} (절단점: {{ selectedEduInfo?.cutoff }}점)</span>
          </div>
          <div class="criteria-desc">
            {{ cognitiveAssessment.grading.description }}
          </div>
        </div>

        <div class="result-banner" :class="cognitiveGrade.class">
          <div class="result-content">
            <span class="result-label">총점 {{ totalScore }}점</span>
            <span class="result-grade">{{ cognitiveGrade.label }}</span>
          </div>
        </div>
      </div>

      <div class="comment-section">
        <label>종합 의견 및 특이사항</label>
        <textarea 
          v-model="formData.comment" 
          placeholder="검사 태도, 수행 특이사항 등을 기록해주세요."
          :disabled="readOnly"
        ></textarea>
      </div>
    </section>

    <div v-if="!readOnly" class="form-actions">
      <button class="btn-secondary" @click="handleSaveDraft">임시저장</button>
      <button class="btn-primary" @click="handleSubmit">저장</button>
    </div>
  </div>
</template>

<style scoped>
.cognitive-assessment-form {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
  font-family: 'Noto Sans KR', sans-serif;
}

/* --- 공통 섹션 스타일 (노란색 테마) --- */
.form-section {
  background: white;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  border: 1px solid #e2e8f0;
}

/* 헤더 왼쪽 정렬로 수정 */
.section-header h2 {
  color: #b45309; /* Amber 700 */
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 5px;
  /* text-align 제거 -> 기본값 Left */
}

.section-desc {
  color: #6b7280;
  font-size: 0.9rem;
  margin-bottom: 20px;
  /* text-align 제거 -> 기본값 Left */
}

.required { color: #ef4444; margin-left: 2px; }

/* 정보 입력 그리드 */
.info-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; }
.info-row { display: flex; flex-direction: column; gap: 5px; }
.info-row label { font-size: 0.85rem; font-weight: 600; color: #4b5563; }
.info-row input, .info-row select { 
  padding: 8px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 0.9rem; 
}
.info-row input:focus, .info-row select:focus {
  outline: none; border-color: #f59e0b; box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.1);
}

/* --- 평가 본문 스타일 --- */
.cognitive-section { background: #fffbeb; /* Amber 50 */ }

.section-top-bar {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 15px; border-bottom: 2px solid #fcd34d; padding-bottom: 10px;
}
.section-title { font-size: 1.1rem; font-weight: 700; color: #92400e; }
.current-score-pill { 
  background: #fcd34d; color: #78350f; padding: 4px 12px; 
  border-radius: 20px; font-size: 0.9rem; font-weight: 600; 
}

/* 질문 그룹 (카드 형태) */
.question-group {
  background: white; border: 1px solid #fde68a; border-radius: 8px;
  margin-bottom: 15px; overflow: hidden;
}

.group-header {
  background: #fff7ed; padding: 10px 15px; border-bottom: 1px solid #fde68a;
  display: flex; justify-content: space-between; align-items: center;
}
.group-title { margin: 0; font-size: 1rem; font-weight: 700; color: #92400e; }
.max-score { font-size: 0.85rem; color: #b45309; font-weight: normal; }
.group-score { font-size: 0.9rem; font-weight: 700; color: #d97706; }
.convert-badge { 
  background: #fcd34d; color: #78350f; font-size: 0.7rem; 
  padding: 2px 6px; border-radius: 4px; margin-left: 5px; 
}

/* 지시문 */
.instruction-box { padding: 10px 15px; background: #fafaf9; border-bottom: 1px solid #f3f4f6; }
.inst-text { margin: 0; font-size: 0.85rem; color: #57534e; line-height: 1.4; }
.sub-inst-text { margin: 4px 0 0 0; font-size: 0.8rem; color: #78716c; }

/* 문항 리스트 */
.items-container { padding: 5px 0; }
.item-row {
  display: flex; justify-content: space-between; align-items: center;
  padding: 12px 15px; border-bottom: 1px dashed #e5e7eb;
}
.item-row:last-child { border-bottom: none; }

.item-content { flex: 1; padding-right: 15px; }
.item-question { margin: 0; font-size: 0.95rem; font-weight: 600; color: #1f2937; }
.item-desc { margin: 4px 0 0 0; font-size: 0.8rem; color: #6b7280; }

.item-action { min-width: 140px; display: flex; justify-content: flex-end; }

/* 액션 컴포넌트들 (노란색 테마 적용) */

/* 1. OX 버튼 */
.ox-toggle { display: flex; }
.ox-btn {
  display: flex; align-items: center; gap: 6px;
  padding: 6px 12px; border: 1px solid #d1d5db; border-radius: 6px;
  background: white; cursor: pointer; transition: all 0.2s;
}
.ox-btn:hover:not(.read-only) { background: #fff7ed; }
.ox-btn.active {
  background: #fef3c7; border-color: #f59e0b; color: #92400e;
}
.ox-icon { font-size: 1rem; }
.ox-label { font-size: 0.9rem; font-weight: 700; }

/* 2. 숫자 입력 */
.number-input-group { display: flex; align-items: center; gap: 10px; }
.input-wrapper { display: flex; align-items: center; gap: 5px; }
.score-input {
  width: 60px; padding: 6px; text-align: center; border: 1px solid #d1d5db; border-radius: 4px;
}
.score-input:focus { outline: none; border-color: #f59e0b; }
.auto-score-display { font-size: 0.85rem; color: #d97706; font-weight: 600; }

/* 3. 라디오 칩 */
.choice-group { display: flex; flex-direction: column; gap: 6px; width: 100%; }
.choice-chip {
  display: flex; align-items: center; gap: 8px; padding: 8px 12px;
  border: 1px solid #e5e7eb; border-radius: 6px; cursor: pointer;
  background: #f9fafb; transition: all 0.2s;
}
.choice-chip:hover:not(.read-only) { background: #fff7ed; }
.choice-chip.active {
  background: #fef3c7; border-color: #fcd34d; color: #92400e; font-weight: 600;
}
.radio-circle {
  width: 14px; height: 14px; border: 2px solid #d1d5db; border-radius: 50%;
}
.choice-chip.active .radio-circle {
  border-color: #f59e0b; background: #f59e0b; box-shadow: inset 0 0 0 2px white;
}

/* 결과 요약 박스 */
.grading-summary-box {
  background: white; border: 1px solid #fcd34d; border-radius: 8px;
  padding: 20px; margin-bottom: 20px;
}
.summary-title { font-size: 1.1rem; font-weight: 700; color: #92400e; margin-bottom: 15px; }

.criteria-info {
  background: #fffbeb; padding: 12px; border-radius: 6px; margin-bottom: 15px;
  font-size: 0.9rem; color: #78350f;
}
.criteria-row { display: flex; justify-content: space-between; font-weight: 600; margin-bottom: 5px; }
.criteria-desc { font-size: 0.85rem; color: #92400e; }

.result-banner {
  display: flex; justify-content: center; align-items: center;
  padding: 15px; border-radius: 8px; font-weight: 700;
}
.result-banner.normal { background: #dcfce7; color: #166534; border: 1px solid #86efac; }
.result-banner.warning { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }

.result-content { display: flex; gap: 15px; font-size: 1.1rem; }

/* 코멘트 */
.comment-section textarea {
  width: 100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 6px;
  resize: vertical; min-height: 80px; margin-top: 5px;
}
.comment-section textarea:focus { outline: none; border-color: #f59e0b; }

/* 버튼 */
.form-actions { display: flex; justify-content: center; gap: 1rem; margin-top: 2rem; }
.btn-primary {
  background: #f59e0b; /* Amber 500 */
  color: white; padding: 0.875rem 2.5rem; border-radius: 0.5rem; font-weight: 700; border: none; cursor: pointer;
}
.btn-primary:hover { background: #d97706; }
.btn-secondary {
  background: white; color: #4b5563; padding: 0.875rem 2.5rem;
  border-radius: 0.5rem; border: 1px solid #d1d5db; font-weight: 700; cursor: pointer;
}
.btn-secondary:hover { background: #f9fafb; }

/* Readonly styles */
.read-only { cursor: default !important; opacity: 0.9; }
input:disabled, select:disabled, textarea:disabled { background: #f3f4f6; cursor: not-allowed; }

@media (max-width: 768px) {
  .info-grid { grid-template-columns: 1fr; }
  .item-row { flex-direction: column; align-items: flex-start; gap: 10px; }
  .item-action { width: 100%; justify-content: flex-start; }
  .choice-group { width: 100%; }
}
</style>