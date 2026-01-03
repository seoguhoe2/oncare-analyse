<script setup>
import { ref, computed, watch, defineProps, defineEmits, onMounted } from 'vue';
import { bedsoreAssessment } from '@/mock/careworker/bedsoreData';
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

// 담당 수급자 목록 상태
const beneficiaries = ref([]);
const loadingBeneficiaries = ref(false);

// 담당 수급자 목록 불러오기
const loadBeneficiaries = async () => {
  try {
    loadingBeneficiaries.value = true;
    const response = await getMyBeneficiaries();
    const data = response?.data ?? response;
    beneficiaries.value = Array.isArray(data) ? data : [];
  } catch (error) {
    beneficiaries.value = [];
  } finally {
    loadingBeneficiaries.value = false;
  }
};

// Form data 초기화
const formData = ref({
  beneficiaryId: props.initialData?.beneficiaryId ?? 0,
  recipientName: props.initialData?.recipientName || '',
  careWorkerName: props.initialData?.careWorkerName || userStore.name || '',
  assessmentDate: props.initialData?.assessmentDate || new Date().toISOString().split('T')[0],
  bedsoreRisk: props.initialData?.bedsoreRisk || {},
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
      bedsoreRisk: newData.bedsoreRisk || formData.value.bedsoreRisk || {},
      comment: newData.comment || formData.value.comment || ''
    };
  }
}, { deep: true, immediate: true });

// 욕창위험도 점수 계산
const totalBedsoreScore = computed(() => {
  let total = 0;
  if (formData.value.bedsoreRisk) {
    Object.values(formData.value.bedsoreRisk).forEach(score => {
      const num = Number(score);
      if (!isNaN(num)) total += num;
    });
  }
  return total;
});

// 욕창위험도 등급 판정
const bedsoreGrade = computed(() => {
  const score = totalBedsoreScore.value;
  const ranges = bedsoreAssessment.grading.ranges;
  const grade = ranges.find(r => score >= r.min && score <= r.max);
  return grade || ranges[ranges.length - 1]; // 기본값 처리
});

// 점수 범위 텍스트 포맷팅
const formatRange = (min, max) => {
  if (min === 0) return `${max}점 이하`;
  if (max >= 99) return `${min}점 이상`;
  return `${min}점 ~ ${max}점`;
};

// 항목 선택 함수
const selectBedsoreRisk = (itemCode, choice) => {
  if (!choice) return;
  formData.value.bedsoreRisk[itemCode] = choice.score;
};

// 선택된 항목인지 확인
const isSelected = (itemCode, score) => {
  return formData.value.bedsoreRisk?.[itemCode] === score;
};

// 폼 제출
const handleSubmit = () => {
  if (!formData.value.beneficiaryId) {
    alert('수급자를 선택해주세요.');
    return;
  }
  if (!formData.value.careWorkerName) {
    alert('작성자명을 입력해주세요.');
    return;
  }
  
  const requiredCount = bedsoreAssessment.items.length;
  const selectedCount = Object.keys(formData.value.bedsoreRisk).length;

  if (selectedCount < requiredCount) {
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

onMounted(() => {
  loadBeneficiaries();
});
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

    <section class="form-section bedsore-section">
      <h3 class="section-title">욕창위험도 평가 척도 (Braden Scale)</h3>
      
      <div class="bedsore-table">
        <div class="table-header">
          <div class="header-label">구분</div>
          <div class="header-scores">
            <div v-for="col in bedsoreAssessment.columns" :key="col.score" class="score-col">
              {{ col.label }}
            </div>
            <div class="score-col total-col-header">점수</div>
          </div>
        </div>

        <div v-for="item in bedsoreAssessment.items" :key="item.code" class="table-row">
          <div class="row-label">{{ item.label }}</div>
          <div class="row-choices">
            <div
              v-for="(choice, index) in item.choices"
              :key="index"
              class="choice-cell"
              :class="{ 
                'empty-cell': !choice, 
                active: choice && isSelected(item.code, choice.score),
                'read-only': readOnly 
              }"
              @click="!readOnly && selectBedsoreRisk(item.code, choice)"
            >
              <template v-if="choice">
                <div class="radio-circle" :class="{ checked: isSelected(item.code, choice.score) }"></div>
                <span class="choice-text">{{ choice.label }}</span>
              </template>
            </div>
            <div class="score-display-cell">
              {{ formData.bedsoreRisk[item.code] !== undefined ? formData.bedsoreRisk[item.code] + '점' : '-' }}
            </div>
          </div>
        </div>

        <div class="table-footer">
          <div class="footer-label">합계 점수</div>
          <div class="footer-score">{{ totalBedsoreScore }}점</div>
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
            <div v-for="(range, idx) in bedsoreAssessment.grading.ranges" :key="idx" class="c-row">
              <div class="c-col">{{ formatRange(range.min, range.max) }}</div>
              <div class="c-col">{{ range.label }}</div>
            </div>
          </div>
        </div>

        <div class="result-banner">
          <span class="banner-title">현재 평가:</span>
          <span 
            class="banner-result-badge" 
            :style="{
              backgroundColor: bedsoreGrade.color === 'red' ? '#FED7D7' : (bedsoreGrade.color === 'yellow' ? '#FEFCBF' : '#dcfce7'),
              color: bedsoreGrade.color === 'red' ? '#822727' : (bedsoreGrade.color === 'yellow' ? '#744210' : '#16a34a')
            }"
          >
            {{ totalBedsoreScore }}점 - {{ bedsoreGrade.label }}
          </span>
        </div>
      </div>

      <div v-if="bedsoreAssessment.grading.comment_field" class="comment-section">
        <label>특이사항 및 예방 관리 계획</label>
        <textarea 
          v-model="formData.comment" 
          placeholder="욕창 위험 요인, 예방 조치 사항, 관리 계획 등을 기록해주세요."
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
.bedsore-assessment-form {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
  font-family: 'Noto Sans KR', sans-serif;
}

/* 섹션 박스 */
.form-section {
  background: white;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  border: 1px solid #e2e8f0;
}

/* 헤더 - 보라색 계열로 변경 */
.section-header h2 {
  color: #6b21a8; /* Purple 800 */
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 5px;
}

.section-desc { color: #718096; font-size: 0.9rem; margin-bottom: 20px; }

/* 섹션 소제목 - 보라색 테마 */
.section-title { 
  font-size: 1.1rem; 
  font-weight: 700; 
  color: #4a5568; 
  margin-bottom: 15px; 
  background: #faf5ff; /* Purple 50 */
  padding: 10px; 
  border-left: 4px solid #8b5cf6; /* Violet 500 */
}

.required { color: #e53e3e; margin-left: 2px; }

/* 정보 입력 그리드 */
.info-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; }
.info-row { display: flex; flex-direction: column; gap: 5px; }
.info-row label { font-size: 0.85rem; font-weight: 600; color: #4a5568; }
.info-row input, .info-row select { padding: 8px; border: 1px solid #cbd5e0; border-radius: 4px; font-size: 0.9rem; }

/* 테이블 스타일 */
.bedsore-table { border: 1px solid #e2e8f0; border-radius: 6px; overflow: hidden; margin-bottom: 30px; }
.table-header { display: grid; grid-template-columns: 150px 1fr; background: #edf2f7; border-bottom: 1px solid #e2e8f0; }
.header-label { padding: 12px; font-weight: 700; display: flex; align-items: center; justify-content: center; border-right: 1px solid #e2e8f0; }

/* 4점 척도 + 합계칸 */
.header-scores { display: grid; grid-template-columns: repeat(4, 1fr) 80px; } 
.score-col { padding: 10px; text-align: center; font-weight: 600; font-size: 0.9rem; border-right: 1px solid #e2e8f0; }
.score-col:last-child { border-right: none; }
.total-col-header { background: #fffaf0; color: #d69e2e; }

.table-row { display: grid; grid-template-columns: 150px 1fr; border-bottom: 1px solid #e2e8f0; background: white; }
.row-label { padding: 12px; font-weight: 600; display: flex; align-items: center; background: #f9fafb; border-right: 1px solid #e2e8f0; font-size: 0.9rem; }
.row-choices { display: grid; grid-template-columns: repeat(4, 1fr) 80px; }

/* 선택 셀 스타일 - 보라색 테마 적용 */
.choice-cell { padding: 10px; border-right: 1px solid #e2e8f0; display: flex; align-items: center; cursor: pointer; transition: background 0.2s; font-size: 0.85rem; }
.choice-cell:hover:not(.empty-cell) { background: #faf5ff; /* Purple 50 */ }
.choice-cell.active { background: #f3e8ff; color: #581c87; font-weight: bold; /* Purple 100 & 900 */ }
.choice-cell.empty-cell { background: #fafafa; cursor: default; }

/* 라디오 버튼 커스텀 - 보라색 */
.radio-circle { width: 14px; height: 14px; border: 2px solid #cbd5e0; border-radius: 50%; margin-right: 6px; flex-shrink: 0; }
.radio-circle.checked { 
  border-color: #8b5cf6; /* Violet 500 */
  background: #8b5cf6; 
  box-shadow: inset 0 0 0 2px white; 
}

/* 점수 표시 셀 */
.score-display-cell { display: flex; align-items: center; justify-content: center; font-weight: bold; color: #7c3aed; background: #faf5ff; border-left: 1px solid #e2e8f0; }

.table-footer { display: flex; justify-content: flex-end; align-items: center; padding: 15px; background: #faf5ff; border-top: 2px solid #cbd5e0; gap: 15px; }
.footer-label { font-weight: 700; font-size: 1.1rem; }
.footer-score { font-weight: 800; font-size: 1.3rem; color: #6b21a8; }

/* 판정 기준 박스 - 보라색 테마 */
.grading-criteria-container {
  border: 1px solid #c4b5fd; /* Violet 300 */
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

/* 결과 배너 - 보라색 배경 */
.result-banner {
  background: #f5f3ff; /* Purple 50 */
  border: 1px solid #ddd6fe; /* Violet 200 */
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

/* 코멘트 섹션 */
.comment-section { margin-top: 20px; }
.comment-section textarea { width: 100%; height: 100px; padding: 10px; border: 1px solid #cbd5e0; border-radius: 4px; resize: none; margin-top: 5px; }
.comment-section textarea:focus { outline: none; border-color: #8b5cf6; }

/* 버튼 - 보라색 테마 */
.form-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; }
.btn-primary { 
  background: #8b5cf6; /* Violet 500 */
  color: white; 
  padding: 10px 25px; 
  border-radius: 4px; 
  border: none; 
  font-weight: 700; 
  cursor: pointer; 
}
.btn-primary:hover { background: #7c3aed; /* Violet 600 */ }

.btn-secondary { background: white; color: #4a5568; padding: 10px 25px; border-radius: 4px; border: 1px solid #cbd5e0; font-weight: 600; cursor: pointer; }
.btn-secondary:hover { background: #f9fafb; }

/* 읽기 전용 모드 */
.choice-cell.read-only { cursor: default; opacity: 0.9; }
.choice-cell.read-only:hover { transform: none; }
input:disabled, select:disabled, textarea:disabled { background: #f7fafc; cursor: not-allowed; }
</style>