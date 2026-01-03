<script setup>
import { ref, computed, watch, defineProps, defineEmits, onMounted } from 'vue';
import { needsAssessment } from '@/mock/careworker/needsData';
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
    console.error('❌ 담당 수급자 목록 불러오기 실패:', error);
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
  responses: props.initialData?.responses || props.initialData?.needsItems || {},
  textResponses: props.initialData?.textResponses || {},
});

watch(() => props.initialData, (newData) => {
  if (newData && Object.keys(newData).length > 0 && newData.beneficiaryId) {
    formData.value = {
      beneficiaryId: newData.beneficiaryId,
      recipientName: newData.recipientName || formData.value.recipientName,
      careWorkerName: newData.careWorkerName || userStore.name || '',
      assessmentDate: newData.assessmentDate || formData.value.assessmentDate,
      responses: newData.responses || newData.needsItems || formData.value.responses || {},
      textResponses: newData.textResponses || formData.value.textResponses || {}
    };
  }
}, { deep: true, immediate: true });

// --- 페이지네이션 ---
const currentPage = ref(1);
const sectionsPerPage = 2;

const totalPages = computed(() => Math.ceil(needsAssessment.sections.length / sectionsPerPage));

const currentSections = computed(() => {
  const start = (currentPage.value - 1) * sectionsPerPage;
  const end = start + sectionsPerPage;
  return needsAssessment.sections.slice(start, end);
});

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
};

// --- 로직 헬퍼 ---
const toggleCheckbox = (code, value) => {
  if (props.readOnly) return;
  if (!formData.value.responses[code]) formData.value.responses[code] = [];
  
  const index = formData.value.responses[code].indexOf(value);
  if (index === -1) {
    formData.value.responses[code].push(value);
  } else {
    formData.value.responses[code].splice(index, 1);
    if (formData.value.textResponses[`${code}_${value}`]) {
      delete formData.value.textResponses[`${code}_${value}`];
    }
  }
};

const checkShowCondition = (condition) => {
  if (!condition) return true;
  return Object.keys(condition).every(key => formData.value.responses[key] === condition[key]);
};

const shouldShowTextInput = (item, choice) => {
  if (!item.hasTextWhen) return false;
  if (item.type === 'checkbox') {
    return formData.value.responses[item.code]?.includes(choice) && item.hasTextWhen.includes(choice);
  } else if (item.type === 'radio') {
    return formData.value.responses[item.code] === choice && item.hasTextWhen.includes(choice);
  }
  return false;
};

const handleSubmit = () => {
  if (!formData.value.beneficiaryId) return alert('수급자를 선택하세요.');
  if (!formData.value.careWorkerName) return alert('작성자명을 입력하세요.');

  // 필수 항목 검사
  for (const section of needsAssessment.sections) {
    for (const item of section.items) {
      if (item.isOptional) continue; // 선택 항목은 건너뜀

      // 1. 일반 텍스트/라디오/숫자
      if (['text', 'number', 'radio', 'textarea'].includes(item.type)) {
        const val = formData.value.responses[item.code];
        if (val === undefined || val === null || val === '') {
          alert(`'${section.title}'의 [${item.label}] 항목을 입력해 주세요.`);
          return;
        }
      }
      
      // 2. 체크박스 (배열 확인)
      else if (item.type === 'checkbox') {
        const val = formData.value.responses[item.code];
        if (!val || val.length === 0) {
          alert(`'${section.title}'의 [${item.label}] 항목을 선택해 주세요.`);
          return;
        }
      }

      // 3. 테이블 라디오 (ADL 등)
      else if (item.type === 'table_radio') {
        for (const row of item.rows) {
          const key = `${item.code}_${row}`;
          if (!formData.value.responses[key]) {
             alert(`'${section.title}'의 [${row}] 항목을 선택해 주세요.`);
             return;
          }
        }
      }

      // 4. 복합 필드
      else if (item.type === 'compound') {
        for (const field of item.fields) {
          // 조건부 표시 필드인지 확인
          if (field.showWhen && !checkShowCondition(field.showWhen)) continue;
          
          const val = formData.value.responses[field.code];
          if (val === undefined || val === null || val === '') {
            alert(`'${item.label}'의 [${field.label}] 항목을 입력해 주세요.`);
            return;
          }
        }
      }
    }
  }

  emit('submit', { ...formData.value });
};

const handleSaveDraft = () => {
  emit('save-draft', { ...formData.value });
};

onMounted(() => {
  loadBeneficiaries();
});
</script>

<template>
  <div class="needs-assessment-form">
    <section class="form-section basic-info">
      <div class="section-header">
        <h2>{{ needsAssessment.title }}</h2>
        <p class="section-desc">수급자의 전반적인 상태와 욕구를 파악하고 맞춤형 서비스를 계획합니다.</p>
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

    <div class="page-indicator">
      <div class="progress-bar">
        <div 
          class="progress-fill" 
          :style="{ width: `${(currentPage / totalPages) * 100}%` }"
        ></div>
      </div>
      <div class="page-numbers">
        <span class="page-text">Step {{ currentPage }} of {{ totalPages }}</span>
      </div>
    </div>

    <section
      v-for="section in currentSections"
      :key="section.code"
      class="form-section needs-section"
    >
      <div class="sec-header">
        <div class="sec-code-circle">{{ section.code }}</div>
        <h3 class="sec-title">{{ section.title }}</h3>
      </div>

      <div class="items-container">
        <div 
          v-for="item in section.items" 
          :key="item.code" 
          class="item-group"
          v-show="checkShowCondition(item.showWhen)"
        >
          <div class="item-label-row" v-if="item.type !== 'compound' && item.type !== 'table_radio'">
            <label class="item-label">
              {{ item.label }}
              <span v-if="item.isOptional" class="optional-badge">(선택)</span>
            </label>
          </div>

          <div v-if="['text', 'number'].includes(item.type)" class="input-wrapper">
            <input 
              :type="item.type" 
              v-model="formData.responses[item.code]" 
              :placeholder="`${item.label} 입력`"
              class="form-input"
              :disabled="readOnly"
            />
            <span v-if="item.unit" class="unit">{{ item.unit }}</span>
          </div>

          <div v-else-if="item.type === 'textarea'" class="textarea-wrapper">
            <textarea 
              v-model="formData.responses[item.code]" 
              rows="4" 
              placeholder="내용을 입력하세요"
              :disabled="readOnly"
            ></textarea>
          </div>

          <div v-else-if="item.type === 'radio'" class="choice-group">
            <div 
              v-for="choice in item.choices" 
              :key="choice" 
              class="choice-chip radio"
              :class="{ 
                active: formData.responses[item.code] === choice,
                'read-only': readOnly 
              }"
            >
              <label class="choice-label">
                <input 
                  type="radio" 
                  :name="item.code" 
                  :value="choice" 
                  v-model="formData.responses[item.code]"
                  :disabled="readOnly"
                />
                <div class="custom-radio"></div>
                <span class="choice-text">{{ choice }}</span>
              </label>
              
              <input 
                v-if="shouldShowTextInput(item, choice)"
                type="text" 
                v-model="formData.textResponses[`${item.code}_${choice}`]" 
                class="sub-text-input" 
                :placeholder="item.textLabel?.[choice] || '내용 입력'"
                :disabled="readOnly"
              />
            </div>
          </div>

          <div v-else-if="item.type === 'checkbox'" class="choice-group">
            <div 
              v-for="choice in item.choices" 
              :key="choice" 
              class="choice-chip checkbox"
              :class="{ 
                active: formData.responses[item.code]?.includes(choice),
                'read-only': readOnly 
              }"
            >
              <label class="choice-label">
                <input 
                  type="checkbox" 
                  :value="choice" 
                  :checked="formData.responses[item.code]?.includes(choice)"
                  @change="toggleCheckbox(item.code, choice)"
                  :disabled="readOnly"
                />
                <div class="custom-checkbox">
                  <span v-if="formData.responses[item.code]?.includes(choice)">✔</span>
                </div>
                <span class="choice-text">{{ choice }}</span>
              </label>

              <input 
                v-if="shouldShowTextInput(item, choice)"
                type="text" 
                v-model="formData.textResponses[`${item.code}_${choice}`]" 
                class="sub-text-input" 
                :placeholder="item.textLabel?.[choice] || '내용 입력'"
                :disabled="readOnly"
              />
            </div>
          </div>

          <div v-else-if="item.type === 'table_radio'" class="table-wrapper">
            <table class="adl-table">
              <thead>
                <tr>
                  <th>항목</th>
                  <th v-for="col in item.columns" :key="col">{{ col }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in item.rows" :key="row">
                  <td class="row-head">{{ row }}</td>
                  <td v-for="col in item.columns" :key="col" class="center-td">
                    <label class="table-radio-label">
                      <input 
                        type="radio" 
                        :name="`${item.code}_${row}`" 
                        :value="col"
                        v-model="formData.responses[`${item.code}_${row}`]"
                        :disabled="readOnly"
                      />
                      <div class="custom-radio-sm"></div>
                    </label>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-else-if="item.type === 'compound'" class="compound-wrapper">
            <span class="compound-main-label">{{ item.label }}</span>
            <div class="compound-fields">
              <div 
                v-for="field in item.fields" 
                :key="field.code" 
                class="sub-field"
                v-show="checkShowCondition(field.showWhen)"
              >
                <label v-if="field.label" class="sub-label">{{ field.label }}</label>
                
                <input 
                  v-if="field.type === 'text' || field.type === 'number'"
                  :type="field.type" 
                  v-model="formData.responses[field.code]"
                  class="form-input mini"
                  :disabled="readOnly"
                />
                
                <div v-else-if="field.type === 'radio'" class="radio-inline">
                  <label v-for="c in field.choices" :key="c" class="radio-label small">
                    <input type="radio" :name="field.code" :value="c" v-model="formData.responses[field.code]" :disabled="readOnly" />
                    {{ c }}
                  </label>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>

    <div class="nav-buttons">
      <button v-if="currentPage > 1" class="btn-nav prev" @click="goToPage(currentPage - 1)">
        ← 이전 단계
      </button>
      <div class="spacer"></div>
      <button v-if="currentPage < totalPages" class="btn-nav next" @click="goToPage(currentPage + 1)">
        다음 단계 →
      </button>
      
      <div v-if="currentPage === totalPages && !readOnly" class="submit-group">
        <button class="btn-secondary" @click="handleSaveDraft">임시저장</button>
        <button class="btn-primary" @click="handleSubmit">제출하기</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.needs-assessment-form {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
  font-family: 'Noto Sans KR', sans-serif;
}

/* --- 공통 섹션 스타일 (파란색 테마) --- */
.form-section {
  background: white;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  border: 1px solid #e2e8f0;
}

.section-header h2 {
  color: #1d4ed8; /* Blue 700 */
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 5px;
}

.section-desc { color: #6b7280; font-size: 0.9rem; margin-bottom: 20px; }

.required { color: #ef4444; margin-left: 2px; }

/* 정보 입력 그리드 */
.info-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; }
.info-row { display: flex; flex-direction: column; gap: 5px; }
.info-row label { font-size: 0.85rem; font-weight: 600; color: #4b5563; }
.info-row input, .info-row select { 
  padding: 8px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 0.9rem; 
}
.info-row input:focus, .info-row select:focus {
  outline: none; border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

/* --- 페이지 인디케이터 --- */
.page-indicator { margin-bottom: 25px; padding: 0 10px; }
.progress-bar {
  height: 6px; background: #e5e7eb; border-radius: 3px; overflow: hidden; margin-bottom: 8px;
}
.progress-fill {
  height: 100%; background: #3b82f6; /* Blue 500 */
  transition: width 0.3s ease;
}
.page-numbers { text-align: right; }
.page-text { font-size: 0.85rem; color: #2563eb; font-weight: 600; }

/* --- 평가 섹션 스타일 --- */
.needs-section { 
  border-top: 4px solid #3b82f6; /* Blue 500 */
}

.sec-header {
  display: flex; align-items: center; gap: 10px; 
  margin-bottom: 20px; border-bottom: 1px solid #eff6ff; padding-bottom: 10px;
}
.sec-code-circle {
  width: 28px; height: 28px; background: #3b82f6; color: white;
  border-radius: 50%; display: flex; align-items: center; justify-content: center;
  font-weight: 700; font-size: 0.9rem;
}
.sec-title { font-size: 1.1rem; color: #1e3a8a; /* Blue 900 */ margin: 0; }

/* 아이템 그룹 */
.item-group { margin-bottom: 25px; padding-bottom: 15px; border-bottom: 1px dashed #e5e7eb; }
.item-group:last-child { border-bottom: none; }

.item-label { display: block; font-weight: 600; font-size: 0.95rem; margin-bottom: 10px; color: #1f2937; }

/* 입력 필드 공통 */
.input-wrapper { display: flex; align-items: center; gap: 8px; }
.form-input { 
  padding: 10px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 0.9rem; flex: 1; max-width: 300px; 
}
.form-input:focus { outline: none; border-color: #3b82f6; }
.unit { color: #6b7280; font-size: 0.9rem; }

.textarea-wrapper textarea {
  width: 100%; padding: 12px; border: 1px solid #d1d5db; border-radius: 6px; 
  resize: vertical; min-height: 100px;
}
.textarea-wrapper textarea:focus { outline: none; border-color: #3b82f6; }

/* 선택형 (칩 스타일) - 파란색 테마 */
.optional-badge { font-size: 0.8rem; color: #9ca3af; font-weight: normal; margin-left: 5px; }

.choice-group { display: flex; flex-wrap: wrap; gap: 10px; }
.choice-chip {
  display: flex; align-items: center; gap: 8px; padding: 8px 14px;
  border: 1px solid #e5e7eb; border-radius: 20px; background: #fff;
  transition: all 0.2s; cursor: pointer;
}
.choice-chip:hover:not(.read-only) { background: #eff6ff; border-color: #3b82f6; }
.choice-chip.active {
  background: #dbeafe; border-color: #3b82f6; color: #1e40af; font-weight: 600;
}

.choice-label { display: flex; align-items: center; gap: 8px; cursor: pointer; }
.choice-label input { display: none; } 

/* 커스텀 라디오/체크박스 아이콘 */
.custom-radio, .custom-checkbox {
  width: 16px; height: 16px; border: 2px solid #d1d5db; border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
}
.choice-chip.checkbox .custom-checkbox { border-radius: 4px; }
.choice-chip.active .custom-radio, .choice-chip.active .custom-checkbox {
  border-color: #3b82f6; background: #3b82f6;
}
.choice-chip.active .custom-radio::after {
  content: ''; width: 6px; height: 6px; background: white; border-radius: 50%;
}
.custom-checkbox span { color: white; font-size: 10px; line-height: 1; }

/* 추가 텍스트 입력 */
.sub-text-input {
  border: none; border-bottom: 1px solid #9ca3af; padding: 2px 5px;
  outline: none; font-size: 0.9rem; background: transparent; width: 150px;
}
.sub-text-input:focus { border-bottom: 2px solid #3b82f6; }

/* 테이블 (ADL) */
.table-wrapper { overflow-x: auto; margin-top: 10px; }
.adl-table { width: 100%; border-collapse: collapse; font-size: 0.9rem; }
.adl-table th { background: #f9fafb; font-weight: 600; color: #374151; padding: 10px; border: 1px solid #e5e7eb; }
.adl-table td { padding: 10px; border: 1px solid #e5e7eb; vertical-align: middle; }
.adl-table .row-head { font-weight: 500; background: #fff; }
.adl-table .center-td { text-align: center; }

.table-radio-label { cursor: pointer; display: inline-block; padding: 5px; }
.table-radio-label input { display: none; }
.custom-radio-sm {
  width: 14px; height: 14px; border: 2px solid #d1d5db; border-radius: 50%;
}
.table-radio-label input:checked + .custom-radio-sm {
  border-color: #3b82f6; background: #3b82f6; box-shadow: inset 0 0 0 2px white;
}

/* 복합 필드 (Compound) - 파란색 배경 톤 */
/* 복합 필드 (Compound) - 스타일 제거 (일반 항목과 통일) */
.compound-wrapper { /* background: #eff6ff; padding: 15px; border-radius: 8px; border: 1px solid #dbeafe; */ margin-top: 5px; }
.compound-main-label { display: block; font-weight: 700; margin-bottom: 10px; color: #1e40af; }
.compound-fields { display: flex; flex-wrap: wrap; gap: 20px; }
.sub-field { display: flex; flex-direction: column; gap: 5px; }
.sub-label { font-size: 0.85rem; color: #4b5563; }
.mini { max-width: 100px; padding: 6px; }
.radio-inline { display: flex; gap: 10px; }
.radio-label.small { font-size: 0.85rem; }

/* 하단 네비게이션 버튼 */
.nav-buttons { display: flex; align-items: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #e5e7eb; }
.spacer { flex: 1; }

.btn-nav {
  padding: 10px 20px; border-radius: 6px; font-weight: 600; cursor: pointer; transition: all 0.2s;
}
.btn-nav.prev { background: white; border: 1px solid #d1d5db; color: #4b5563; }
.btn-nav.prev:hover { background: #f9fafb; }
.btn-nav.next { background: #3b82f6; border: none; color: white; }
.btn-nav.next:hover { background: #2563eb; }

.submit-group { display: flex; gap: 10px; }
.btn-primary { 
  background: #3b82f6; color: white; padding: 10px 25px; 
  border-radius: 6px; border: none; font-weight: 700; cursor: pointer; 
}
.btn-primary:hover { background: #2563eb; }
.btn-secondary {
  background: white; color: #4b5563; padding: 10px 25px;
  border-radius: 6px; border: 1px solid #d1d5db; font-weight: 700; cursor: pointer;
}
.btn-secondary:hover { background: #f9fafb; }

/* Readonly */
.read-only { pointer-events: none; opacity: 0.9; }
input:disabled, textarea:disabled, select:disabled { background: #f3f4f6; cursor: not-allowed; }

@media (max-width: 768px) {
  .info-grid { grid-template-columns: 1fr; }
  .compound-fields { flex-direction: column; }
  .nav-buttons { flex-direction: column; gap: 10px; }
  .btn-nav, .submit-group, .btn-primary, .btn-secondary { width: 100%; }
}
</style>