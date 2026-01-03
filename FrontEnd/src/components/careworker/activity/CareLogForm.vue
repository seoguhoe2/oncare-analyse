<script setup>
import { ref, onMounted } from 'vue';
import { careLogFormData } from '@/mock/careworker/careLogData';
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
  },
  hideActions: {
    type: Boolean,
    default: false
  },
  hideDraftButton: {
    type: Boolean,
    default: false
  }
});

// Emits
const emit = defineEmits(['submit', 'draft']);

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

    if (Array.isArray(data)) {
      beneficiaries.value = data;
    } else if (data && typeof data === 'object') {
      beneficiaries.value = data.data || [];
    } else {
      beneficiaries.value = [];
    }
  } catch (error) {
    beneficiaries.value = [];
  } finally {
    loadingBeneficiaries.value = false;
  }
};

// Form data initialization
const initializeFormData = () => {
  const baseData = {
    beneficiaryId: '',
    recipientName: '',
    careWorkerName: userStore.name || '',
    careDate: new Date().toISOString().split('T')[0],
    startTime: '',
    endTime: '',
    serviceType: '방문요양',
    
    // 신체활동 지원
    isBreakfast: false, isLunch: false, isDinner: false, isSnack: false,
    diaperCount: 0, toiletCount: 0, isPortableToilet: false, isUrine: false, isStool: false,
    stoolNormal: false, stoolDiarrhea: false, stoolConstipation: false,
    isFaceWash: false, isOralCare: false, isHairWash: false, isBodyWash: false, isChangeClothes: false,
    isMealPrep: false, isBedCare: false, isPositionChange: false, isGetUpHelp: false, isIndoorMove: false, isWalkHelp: false,
    
    // 인지/정서
    isEmotionalTalk: false, isCommunication: false, isCounseling: false, isCognitiveCare: false, isBehaviorCare: false,
    
    // 상태 관찰
    isHealthGood: false, isPain: false, isEdema: false, isSkinIssue: false, isBodyEtc: false,
    isMoodCalm: false, isMoodAnxious: false, isMoodDepressed: false, isMoodAngry: false, isMoodEtc: false,
    isExcretionMistake: false, isSleepLack: false, isNapExcess: false,
    
    // 특이사항
    specialNotes: ''
  };

  if (props.initialData) {
    const merged = { ...baseData, ...props.initialData };
    if (!merged.careWorkerName) merged.careWorkerName = userStore.name || '';
    return merged;
  }
  return baseData;
};

const formData = ref(initializeFormData());

// 유효성 검증 함수
const validateForm = (isDraft = false) => {
  // 임시저장은 검증 없이 허용
  if (isDraft) return true;

  // 제출할 때는 각 섹션마다 최소 1개씩 선택 필수

  // 기본 정보 검증
  if (!formData.value.beneficiaryId) {
    alert('모든 항목을 선택해주세요.');
    return false;
  }
  if (!formData.value.careDate) {
    alert('모든 항목을 선택해주세요.');
    return false;
  }
  if (!formData.value.startTime) {
    alert('모든 항목을 선택해주세요.');
    return false;
  }
  if (!formData.value.endTime) {
    alert('모든 항목을 선택해주세요.');
    return false;
  }

  // 시간 유효성 검증
  if (formData.value.startTime >= formData.value.endTime) {
    alert('종료 시간은 시작 시간보다 늦어야 합니다.');
    return false;
  }

  // 각 섹션별 검증 (각 섹션마다 최소 1개 선택)

  // 1. 식사 (최소 1개)
  const mealSelected = formData.value.isBreakfast || formData.value.isLunch ||
                       formData.value.isDinner || formData.value.isSnack;
  if (!mealSelected) {
    alert('모든 항목을 선택해주세요.');
    return false;
  }

  // 2. 배설 도움 - 선택 안 해도 됨 (스킵)

  // 3. 위생 (최소 1개)
  const hygieneSelected = formData.value.isFaceWash || formData.value.isOralCare ||
                          formData.value.isHairWash || formData.value.isBodyWash ||
                          formData.value.isChangeClothes;
  if (!hygieneSelected) {
    alert('모든 항목을 선택해주세요.');
    return false;
  }

  // 4. 활동 지원 (최소 1개)
  const activitySelected = formData.value.isMealPrep || formData.value.isBedCare ||
                           formData.value.isPositionChange || formData.value.isGetUpHelp ||
                           formData.value.isIndoorMove || formData.value.isWalkHelp;
  if (!activitySelected) {
    alert('모든 항목을 선택해주세요.');
    return false;
  }

  // 5. 인지/정서 지원 (최소 1개)
  const cognitiveSelected = formData.value.isEmotionalTalk || formData.value.isCommunication ||
                            formData.value.isCounseling || formData.value.isCognitiveCare ||
                            formData.value.isBehaviorCare;
  if (!cognitiveSelected) {
    alert('모든 항목을 선택해주세요.');
    return false;
  }

  // 6. 신체 상태 (최소 1개)
  const bodyStateSelected = formData.value.isHealthGood || formData.value.isPain ||
                            formData.value.isEdema || formData.value.isSkinIssue ||
                            formData.value.isBodyEtc;
  if (!bodyStateSelected) {
    alert('모든 항목을 선택해주세요.');
    return false;
  }

  // 7. 기분/행동 상태 (최소 1개)
  const moodSelected = formData.value.isMoodCalm || formData.value.isMoodAnxious ||
                       formData.value.isMoodDepressed || formData.value.isMoodAngry ||
                       formData.value.isMoodEtc;
  if (!moodSelected) {
    alert('모든 항목을 선택해주세요.');
    return false;
  }

  // 8. 기타 관찰 (최소 1개)
  const observationSelected = formData.value.isExcretionMistake || formData.value.isSleepLack ||
                              formData.value.isNapExcess;
  if (!observationSelected) {
    alert('모든 항목을 선택해주세요.');
    return false;
  }

  return true;
};

const handleSubmit = () => {
  if (props.readOnly) return;

  // 제출 시 유효성 검증
  if (!validateForm(false)) return;

  emit('submit', formData.value);
};

const handleDraft = () => {
  if (props.readOnly) return;

  // 임시저장 시 유효성 검증 생략
  if (!validateForm(true)) return;

  emit('draft', formData.value);
};

onMounted(async () => {
  if (!props.readOnly) {
    await loadBeneficiaries();
  }
});
</script>

<template>
  <div class="care-log-form">
    
    <section class="form-section basic-info">
      <div class="section-header">
        <h2>장기요양보호 제공기록지</h2>
        <p class="section-desc">서비스 제공 내용을 정확하게 기록해주세요.</p>
      </div>

      <div class="info-grid">
        <div class="info-row">
          <label>수급자명 <span v-if="!readOnly" class="required">*</span></label>
          <input
            v-if="readOnly || (props.initialData && props.initialData.recipientName)"
            :value="formData.recipientName || '정보 없음'"
            type="text"
            disabled
            class="readonly-field"
          />
          <select
            v-else
            v-model="formData.beneficiaryId"
            :disabled="loadingBeneficiaries"
          >
            <option value="">{{ loadingBeneficiaries ? '불러오는 중...' : '선택하세요' }}</option>
            <option v-for="b in beneficiaries" :key="b.beneficiaryId" :value="b.beneficiaryId">{{ b.name }}</option>
          </select>
        </div>
        <div class="info-row">
          <label>작성자</label>
          <input v-model="formData.careWorkerName" type="text" disabled class="readonly-field" />
        </div>
        <div class="info-row">
          <label>제공일</label>
          <input v-model="formData.careDate" type="date" :disabled="readOnly" />
        </div>
        <div class="info-row">
          <label>시간</label>
          <div class="time-inputs">
            <input v-model="formData.startTime" type="time" :disabled="readOnly" />
            <span>~</span>
            <input v-model="formData.endTime" type="time" :disabled="readOnly" />
          </div>
        </div>
      </div>

      <div class="service-type-row">
        <label>서비스 유형</label>
        <div class="radio-group">
          <div 
            v-for="type in careLogFormData.serviceTypes" 
            :key="type.value" 
            class="choice-cell"
            :class="{ active: formData.serviceType === type.value, 'read-only': readOnly }"
            @click="!readOnly && (formData.serviceType = type.value)"
          >
            <div class="radio-circle" :class="{ checked: formData.serviceType === type.value }"></div>
            <span class="choice-text">{{ type.label }}</span>
          </div>
        </div>
      </div>
    </section>

    <section class="form-section">
      <h3 class="section-title">{{ careLogFormData.physicalSupport.title }}</h3>
      
      <div class="physical-support-container">
        <div 
          v-for="section in careLogFormData.physicalSupport.sections" 
          :key="section.code" 
          class="support-category"
        >
          <h4 class="category-label">{{ section.label }}</h4>

          <div class="options-row">
            
            <template v-if="section.type === 'checkbox'">
              <div 
                v-for="option in section.options" 
                :key="option.value" 
                class="option-chip"
                :class="{ active: formData[option.field], 'read-only': readOnly }"
                @click="!readOnly && (formData[option.field] = !formData[option.field])"
              >
                {{ option.label }}
              </div>
            </template>

            <template v-else-if="section.type === 'mixed'">
              <div v-for="option in section.options" :key="option.value" class="mixed-item-wrapper">
                
                <div v-if="option.type === 'number'" class="number-control-box" :class="{'has-value': formData[option.field] > 0}">
                  <span class="control-label">{{ option.label }}</span>
                  <div class="stepper-group" @click.stop>
                    <button 
                      type="button"
                      class="step-btn minus" 
                      :disabled="readOnly || formData[option.field] <= 0"
                      @click="formData[option.field]--"
                    >−</button>
                    
                    <div class="value-display">
                      <input 
                        v-model.number="formData[option.field]" 
                        type="number" 
                        min="0" 
                        readonly 
                        :disabled="readOnly"
                      />
                      <span class="unit-text">{{ option.unit }}</span>
                    </div>

                    <button 
                      type="button"
                      class="step-btn plus" 
                      :disabled="readOnly"
                      @click="formData[option.field]++"
                    >+</button>
                  </div>
                </div>

                <div 
                  v-else 
                  class="option-chip"
                  :class="{ active: formData[option.field], 'read-only': readOnly }"
                  @click="!readOnly && (formData[option.field] = !formData[option.field])"
                >
                  {{ option.label }}
                </div>
              </div>
            </template>

          </div>
        </div>
      </div>
    </section>

    <section class="form-section">
      <h3 class="section-title">{{ careLogFormData.cognitiveSupport.title }}</h3>
      <div class="physical-support-container">
        <div 
          v-for="section in careLogFormData.cognitiveSupport.sections" 
          :key="section.code" 
          class="support-category"
        >
          <h4 class="category-label">{{ section.label }}</h4>
          <div class="options-row">
            <div 
              v-for="option in section.options" 
              :key="option.value" 
              class="option-chip"
              :class="{ active: formData[option.field], 'read-only': readOnly }"
              @click="!readOnly && (formData[option.field] = !formData[option.field])"
            >
              {{ option.label }}
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="form-section">
      <h3 class="section-title">{{ careLogFormData.observationStatus.title }}</h3>
      <div class="physical-support-container">
        <div 
          v-for="section in careLogFormData.observationStatus.sections" 
          :key="section.code" 
          class="support-category"
        >
          <h4 class="category-label">{{ section.label }}</h4>
          <div class="options-row">
            <div 
              v-for="option in section.options" 
              :key="option.value" 
              class="option-chip"
              :class="{ active: formData[option.field], 'read-only': readOnly }"
              @click="!readOnly && (formData[option.field] = !formData[option.field])"
            >
              {{ option.label }}
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="form-section">
      <h3 class="section-title">특이사항 및 제안</h3>
      <div class="comment-section">
        <textarea
          v-model="formData.specialNotes"
          :placeholder="careLogFormData.specialNotes.placeholder"
          rows="4"
          :disabled="readOnly"
        ></textarea>
      </div>
    </section>

    <div v-if="!hideActions" class="form-actions">
      <button v-if="!hideDraftButton" type="button" class="btn-secondary" @click="handleDraft">임시저장</button>
      <button type="button" class="btn-primary" @click="handleSubmit">
        {{ props.initialData && !readOnly ? '수정 저장' : '제출하기' }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.care-log-form {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
  font-family: 'Noto Sans KR', sans-serif;
}

/* --- 공통 섹션 --- */
.form-section {
  background: white;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.section-header h2 {
  color: #166534;
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 5px;
}

.section-desc { color: #718096; font-size: 0.9rem; margin-bottom: 20px; }

.section-title {
  font-size: 1.1rem;
  font-weight: 700;
  color: #4a5568;
  margin-bottom: 15px;
  background: #f0fdf4;
  padding: 10px;
  border-left: 4px solid #16a34a;
}

.required { color: #e53e3e; margin-left: 2px; }

/* --- 기본 정보 --- */
.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 15px;
  margin-bottom: 15px;
}
.info-row { display: flex; flex-direction: column; gap: 5px; }
.info-row label { font-size: 0.85rem; font-weight: 600; color: #4b5563; }
.info-row input, .info-row select {
  padding: 8px; border: 1px solid #cbd5e0; border-radius: 4px; font-size: 0.9rem; background-color: white;
}
.readonly-field { background-color: #f7fafc; color: #4a5568; cursor: default; }
.time-inputs { display: flex; align-items: center; gap: 5px; }
.time-inputs input { flex: 1; text-align: center; }

.service-type-row { display: flex; flex-direction: column; gap: 5px; margin-top: 15px; }
.radio-group { display: flex; gap: 10px; flex-wrap: wrap; }
.choice-cell {
  padding: 10px 15px; border: 1px solid #e2e8f0; border-radius: 6px;
  display: flex; align-items: center; cursor: pointer; transition: all 0.2s; background: white;
}
.choice-cell:hover:not(.read-only) { background: #f0fff4; }
.choice-cell.active { background: #dcfce7; border-color: #16a34a; color: #14532d; font-weight: 600; }
.radio-circle {
  width: 14px; height: 14px; border: 2px solid #cbd5e0; border-radius: 50%; margin-right: 8px; flex-shrink: 0;
}
.radio-circle.checked { border-color: #16a34a; background: #16a34a; box-shadow: inset 0 0 0 2px white; }
.choice-text { font-size: 0.9rem; }

/* --- 신체활동 지원 등 스타일 --- */
.physical-support-container, .support-category {
  display: flex; flex-direction: column; gap: 1.5rem;
}

.support-category {
  gap: 0.8rem; border-bottom: 1px dashed #e5e7eb; padding-bottom: 1rem;
}
.support-category:last-child { border-bottom: none; padding-bottom: 0; }

.category-label {
  font-size: 0.95rem; font-weight: 700; color: #374151; margin: 0;
}

.options-row {
  display: flex; flex-wrap: wrap; gap: 8px; align-items: center;
}

/* 기본 칩 스타일 */
.option-chip {
  padding: 6px 14px; border: 1px solid #d1d5db; border-radius: 20px;
  font-size: 0.85rem; color: #4b5563; background-color: white;
  cursor: pointer; transition: all 0.2s; user-select: none;
}
.option-chip:hover:not(.read-only) { background-color: #f3f4f6; }
.option-chip.active {
  border-color: #16a34a; background-color: #dcfce7; color: #15803d; font-weight: 600;
}

/* [수정됨] 숫자 입력 컨트롤 박스 스타일 */
.number-control-box {
  display: flex; align-items: center; gap: 12px;
  padding: 4px 6px 4px 12px; border: 1px solid #d1d5db; border-radius: 24px;
  background-color: white; transition: all 0.2s;
}
.number-control-box.has-value {
  border-color: #16a34a; background-color: #f0fdf4;
}

.control-label {
  font-size: 0.85rem; font-weight: 600; color: #374151;
}

.stepper-group {
  display: flex; align-items: center; gap: 4px;
}

.step-btn {
  width: 32px; height: 32px; border-radius: 50%;
  border: 1px solid #e5e7eb; background-color: white;
  color: #4b5563; font-size: 1.2rem; font-weight: bold; line-height: 1;
  display: flex; align-items: center; justify-content: center;
  cursor: pointer; transition: all 0.1s;
}
.step-btn:active:not(:disabled) { transform: scale(0.95); background-color: #f3f4f6; }
.step-btn:disabled { opacity: 0.3; cursor: not-allowed; border-color: transparent; }

/* 플러스 버튼 강조 */
.step-btn.plus {
  background-color: #16a34a; color: white; border-color: #16a34a;
}
.step-btn.plus:active:not(:disabled) { background-color: #15803d; }

.value-display {
  display: flex; align-items: center; justify-content: center; min-width: 40px;
}
.value-display input {
  width: 24px; border: none; background: transparent; text-align: right;
  font-size: 1.1rem; font-weight: 700; color: #1f2937; padding: 0; outline: none;
}
.unit-text { font-size: 0.8rem; color: #6b7280; margin-left: 2px; }

/* 특이사항 */
.comment-section textarea {
  width: 100%; height: 100px; padding: 10px; border: 1px solid #cbd5e0;
  border-radius: 4px; resize: vertical; outline: none;
}
.comment-section textarea:focus { border-color: #16a34a; }

/* 버튼 */
.form-actions { display: flex; justify-content: center; gap: 10px; margin-top: 20px; }
.btn-primary { background: #16a34a; color: white; padding: 10px 30px; border-radius: 4px; border: none; font-weight: 700; cursor: pointer; }
.btn-primary:hover { background: #15803d; }
.btn-secondary { background: white; color: #4b5563; padding: 10px 30px; border-radius: 4px; border: 1px solid #cbd5e0; font-weight: 600; cursor: pointer; }
.btn-secondary:hover { background: #f7fafc; }

/* 읽기 전용 및 반응형 */
.read-only { cursor: default; opacity: 0.9; }
input:disabled, select:disabled, textarea:disabled { background: #f7fafc; cursor: not-allowed; }

@media (max-width: 768px) {
  .info-grid { grid-template-columns: 1fr; }
}
</style>