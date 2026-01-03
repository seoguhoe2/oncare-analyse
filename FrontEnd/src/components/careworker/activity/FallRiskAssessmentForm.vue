<script setup>
import { ref, computed, watch, defineProps, defineEmits, onMounted } from 'vue';
import { fallRiskAssessment } from '@/mock/careworker/fallRiskData';
import { getMyBeneficiaries } from '@/api/careworker';
import { useUserStore } from '@/stores/user';

// Props
const props = defineProps({
  initialData: {
    type: Object,
    default: null
  },
  readOnly: {
    type: Boolean,
    default: false
  }
});

// Emits
const emit = defineEmits(['submit', 'save-draft']);

// User store
const userStore = useUserStore();

// 담당 수급자 목록
const beneficiaries = ref([]);
const loadingBeneficiaries = ref(false);

// 담당 수급자 목록 불러오기
const loadBeneficiaries = async () => {
  try {
    loadingBeneficiaries.value = true;
    const response = await getMyBeneficiaries();
    const data = response?.data ?? response;
    beneficiaries.value = data || [];
  } catch (error) {
    console.error('❌ 담당 수급자 목록 불러오기 실패:', error);
    beneficiaries.value = [];
  } finally {
    loadingBeneficiaries.value = false;
  }
};

// Form data
const formData = ref({
  beneficiaryId: props.initialData?.beneficiaryId ?? 0,
  recipientName: props.initialData?.recipientName || '',
  careWorkerName: props.initialData?.careWorkerName || userStore.name || '',
  assessmentDate: props.initialData?.assessmentDate || new Date().toISOString().split('T')[0],
  fallRisk: props.initialData?.fallRisk || {},
  comment: props.initialData?.comment || ''
});

// Watch for initialData changes (for edit mode)
watch(() => props.initialData, (newData) => {
  // initialData에 실제 데이터가 있을 때만 업데이트 (beneficiaryId가 있는 경우만)
  if (newData && Object.keys(newData).length > 0 && newData.beneficiaryId) {
    formData.value = {
      beneficiaryId: newData.beneficiaryId,
      recipientName: newData.recipientName || formData.value.recipientName,
      careWorkerName: newData.careWorkerName || userStore.name || '',
      assessmentDate: newData.assessmentDate || formData.value.assessmentDate,
      fallRisk: newData.fallRisk || formData.value.fallRisk || {},
      comment: newData.comment || formData.value.comment || ''
    };
  }
}, { deep: true, immediate: true });

// 낙상위험도 점수 계산
const totalFallRiskScore = computed(() => {
  let total = 0;
  if (formData.value.fallRisk) {
    Object.values(formData.value.fallRisk).forEach(score => {
      const num = Number(score);
      if (!isNaN(num)) total += num;
    });
  }
  return total;
});

// 낙상위험도 등급 계산
const fallRiskGrade = computed(() => {
  const score = totalFallRiskScore.value;
  const grade = fallRiskAssessment.grading.ranges.find(
    r => score >= r.min && score <= r.max
  );
  return grade || fallRiskAssessment.grading.ranges[0];
});

// 점수 범위 텍스트 포맷팅 (예: 4점 이하, 11점 이상)
const formatRange = (min, max) => {
  if (min === 0) return `${max}점 이하`;
  if (max >= 999) return `${min}점 이상`;
  return `${min}점 ~ ${max}점`;
};

// 항목 선택
const selectFallRisk = (itemCode, choice) => {
  if (!choice) return;
  formData.value.fallRisk[itemCode] = choice.score;
};

// 선택 여부 확인
const isSelected = (itemCode, score) => {
  return formData.value.fallRisk?.[itemCode] === score;
};

// 제출
const handleSubmit = () => {
  if (!formData.value.beneficiaryId) {
    alert('수급자를 선택해주세요.');
    return;
  }
  if (!formData.value.careWorkerName) {
    alert('작성자명을 입력해주세요.');
    return;
  }
  if (Object.keys(formData.value.fallRisk).length < fallRiskAssessment.items.length) {
    alert('모든 평가 항목을 선택해주세요.');
    return;
  }

  emit('submit', {
    ...formData.value,
    totalScore: totalFallRiskScore.value,
    grade: fallRiskGrade.value.label
  });
};

// 임시저장
const handleSaveDraft = () => {
  emit('save-draft', {
    ...formData.value,
    totalScore: totalFallRiskScore.value,
    grade: fallRiskGrade.value.label
  });
};

onMounted(() => {
  loadBeneficiaries();
});
</script>

<template>
  <div class="fall-risk-assessment-form">
    <section class="form-section basic-info">
      <div class="section-header">
        <h2>{{ fallRiskAssessment.title }}</h2>
        <p class="section-desc">연 1회 평가가 필요합니다. 평가 결과를 기록하세요.</p>
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
      </div>
    </section>

    <section class="form-section fall-risk-section">
      <h3 class="section-title">낙상위험도 평가 척도</h3>
      <div class="fall-risk-table">
        <div class="table-header">
          <div class="header-label">구분</div>
          <div class="header-scores">
            <div v-for="col in fallRiskAssessment.columns" :key="col.score" class="score-col">
              {{ col.label }}
            </div>
            <div class="score-col total-col-header">점수</div>
          </div>
        </div>

        <div v-for="item in fallRiskAssessment.items" :key="item.code" class="table-row">
          <div class="row-label">{{ item.label }}</div>
          <div class="row-choices">
            <div
              v-for="(choice, index) in item.choices"
              :key="index"
              class="choice-cell"
              :class="{ 'empty-cell': !choice, active: choice && isSelected(item.code, choice.score), 'read-only': readOnly }"
              @click="!readOnly && selectFallRisk(item.code, choice)"
            >
              <template v-if="choice">
                <div class="radio-circle" :class="{ checked: isSelected(item.code, choice.score) }"></div>
                <span class="choice-text">{{ choice.label }}</span>
              </template>
            </div>
            <div class="score-display-cell">
              {{ formData.fallRisk[item.code] !== undefined ? formData.fallRisk[item.code] + '점' : '-' }}
            </div>
          </div>
        </div>

        <div class="table-footer">
          <div class="footer-label">합계 점수</div>
          <div class="footer-score">{{ totalFallRiskScore }}점</div>
        </div>
      </div>

      <div class="grading-criteria-container">
        <h4 class="criteria-title">점수 판정 기준</h4>
        
        <div class="criteria-table">
          <div class="c-header">
            <div class="c-col">점수</div>
            <div class="c-col">평가</div>
          </div>
          <div class="c-body">
            <div v-for="(range, idx) in fallRiskAssessment.grading.ranges" :key="idx" class="c-row">
              <div class="c-col">{{ formatRange(range.min, range.max) }}</div>
              <div class="c-col">{{ range.label }}</div>
            </div>
          </div>
        </div>

        <div class="result-banner">
          <span class="banner-title">현재 평가:</span>
          <span class="banner-result-badge" :class="fallRiskGrade.colorClass">
            {{ totalFallRiskScore }}점 - {{ fallRiskGrade.label }}
          </span>
        </div>
      </div>

      <div v-if="fallRiskAssessment.grading.comment_field" class="comment-section">
        <label>특이사항 및 제안</label>
        <textarea v-model="formData.comment" placeholder="특이사항, 개선방안 등을 입력하세요" :disabled="readOnly"></textarea>
      </div>
    </section>

    <div v-if="!readOnly" class="form-actions">
      <button class="btn-secondary" @click="handleSaveDraft">임시저장</button>
      <button class="btn-primary" @click="handleSubmit">저장</button>
    </div>
  </div>
</template>

<style scoped>
.fall-risk-assessment-form {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
  font-family: 'Noto Sans KR', sans-serif;
}

.form-section {
  background: white;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  border: 1px solid #e2e8f0;
}

.section-header h2 {
  color: #2f855a; /* 녹색 계열 타이틀 */
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 5px;
}

.section-desc { color: #718096; font-size: 0.9rem; margin-bottom: 20px; }
.section-title { font-size: 1.1rem; font-weight: 700; color: #4a5568; margin-bottom: 15px; background: #f7fafc; padding: 10px; border-left: 4px solid #4299e1; }
.required { color: #e53e3e; margin-left: 2px; }

/* 정보 입력 그리드 */
.info-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; }
.info-row { display: flex; flex-direction: column; gap: 5px; }
.info-row label { font-size: 0.85rem; font-weight: 600; color: #4a5568; }
.info-row input, .info-row select { padding: 8px; border: 1px solid #cbd5e0; border-radius: 4px; font-size: 0.9rem; }

/* 평가 테이블 스타일 */
.fall-risk-table { border: 1px solid #e2e8f0; border-radius: 6px; overflow: hidden; margin-bottom: 30px; }
.table-header { display: grid; grid-template-columns: 150px 1fr; background: #edf2f7; border-bottom: 1px solid #e2e8f0; }
.header-label { padding: 12px; font-weight: 700; display: flex; align-items: center; justify-content: center; border-right: 1px solid #e2e8f0; }
.header-scores { display: grid; grid-template-columns: repeat(5, 1fr) 80px; } /* 점수칸 + 합계칸 */
.score-col { padding: 10px; text-align: center; font-weight: 600; font-size: 0.9rem; border-right: 1px solid #e2e8f0; }
.score-col:last-child { border-right: none; }
.total-col-header { background: #fffaf0; color: #d69e2e; }

.table-row { display: grid; grid-template-columns: 150px 1fr; border-bottom: 1px solid #e2e8f0; background: white; }
.row-label { padding: 12px; font-weight: 600; display: flex; align-items: center; background: #f9fafb; border-right: 1px solid #e2e8f0; font-size: 0.9rem; }
.row-choices { display: grid; grid-template-columns: repeat(5, 1fr) 80px; }

.choice-cell { padding: 10px; border-right: 1px solid #e2e8f0; display: flex; align-items: center; cursor: pointer; transition: background 0.2s; font-size: 0.85rem; }
.choice-cell:hover:not(.empty-cell) { background: #f0fff4; }
.choice-cell.active { background: #e6fffa; color: #276749; font-weight: bold; }
.choice-cell.empty-cell { background: #fafafa; cursor: default; }

.radio-circle { width: 14px; height: 14px; border: 2px solid #cbd5e0; border-radius: 50%; margin-right: 6px; flex-shrink: 0; }
.radio-circle.checked { border-color: #38a169; background: #38a169; box-shadow: inset 0 0 0 2px white; }

.score-display-cell { display: flex; align-items: center; justify-content: center; font-weight: bold; color: #38a169; background: #f0fff4; border-left: 1px solid #e2e8f0; }

.table-footer { display: flex; justify-content: flex-end; align-items: center; padding: 15px; background: #f0fff4; border-top: 2px solid #cbd5e0; gap: 15px; }
.footer-label { font-weight: 700; font-size: 1.1rem; }
.footer-score { font-weight: 800; font-size: 1.3rem; color: #276749; }

/* [NEW] 점수 판정 기준 박스 (이미지 구현) */
.grading-criteria-container {
  border: 1px solid #9AE6B4; /* 연한 녹색 테두리 */
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 25px;
  background: white;
}
.criteria-title { font-size: 1rem; font-weight: 700; margin-bottom: 15px; color: #2d3748; }

.criteria-table { width: 100%; border: 1px solid #e2e8f0; margin-bottom: 15px; }
.c-header { display: flex; background: #f7fafc; border-bottom: 1px solid #e2e8f0; font-weight: 600; text-align: center; }
.c-body { display: flex; flex-direction: column; }
.c-row { display: flex; border-bottom: 1px solid #e2e8f0; text-align: center; }
.c-row:last-child { border-bottom: none; }
.c-col { flex: 1; padding: 12px; border-right: 1px solid #e2e8f0; font-size: 0.9rem; color: #4a5568; }
.c-col:last-child { border-right: none; }

/* 결과 배너 */
.result-banner {
  background: #F0FFF4; /* 아주 연한 녹색 배경 */
  border: 1px solid #C6F6D5;
  border-radius: 6px;
  padding: 15px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.banner-title { font-weight: 600; color: #2D3748; }
.banner-result-badge {
  padding: 6px 16px;
  border-radius: 20px;
  font-weight: 700;
  font-size: 0.95rem;
}
/* 상태별 배지 색상 */
.banner-result-badge.low { background: #C6F6D5; color: #22543D; } /* 녹색 */
.banner-result-badge.high { background: #FEFCBF; color: #744210; } /* 노란색 */
.banner-result-badge.very-high { background: #FED7D7; color: #822727; } /* 빨간색 */

/* 특이사항 */
.comment-section { margin-top: 20px; }
.comment-section textarea { width: 100%; height: 100px; padding: 10px; border: 1px solid #cbd5e0; border-radius: 4px; resize: none; margin-top: 5px; }

/* 버튼 */
.form-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; }
.btn-primary { background: #38a169; color: white; padding: 10px 25px; border-radius: 4px; border: none; font-weight: 700; cursor: pointer; }
.btn-secondary { background: white; color: #4a5568; padding: 10px 25px; border-radius: 4px; border: 1px solid #cbd5e0; font-weight: 600; cursor: pointer; }

/* 읽기 전용 모드 */
.choice-cell.read-only { cursor: default; opacity: 0.9; }
.choice-cell.read-only:hover { transform: none; }
input:disabled, select:disabled, textarea:disabled { background: #f7fafc; cursor: not-allowed; }
</style>