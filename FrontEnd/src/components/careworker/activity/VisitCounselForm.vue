<script setup>
import { onMounted, ref, watch } from "vue";
import { getMyBeneficiaries } from '@/api/careworker';
import { useUserStore } from '@/stores/user';
import SignaturePad from "@/components/common/SignaturePad.vue";

// Props
const props = defineProps({
  initialData: { type: Object, default: null },
  readOnly: { type: Boolean, default: false }
});

// Emits
const emit = defineEmits(['submit', 'save-draft']);

// Store
const userStore = useUserStore();

// Data
const beneficiaries = ref([]);
const loadingBeneficiaries = ref(false);

// Form Data
const formData = ref({
  beneficiaryId: props.initialData?.beneficiaryId ?? 0,
  recipientName: props.initialData?.recipientName || '',
  careWorkerName: props.initialData?.careWorkerName || userStore.name || '',
  visit_date: props.initialData?.visit_date || new Date().toISOString().slice(0, 16),
  visit_type: props.initialData?.visit_type || 'regular',
  reaction: props.initialData?.reaction || 'normal',
  visit_detail: props.initialData?.visit_detail || '',
  observed_condition: props.initialData?.observed_condition || '',
  subjective_needs: props.initialData?.subjective_needs || '',
  counselor_notes: props.initialData?.counselor_notes || '',
  next_action: props.initialData?.next_action || '',
  counselorSignUrl: props.initialData?.counselorSignUrl || '',
  guardianSignUrl: props.initialData?.guardianSignUrl || '',
});

// Signature Modal State
const showRecipientSign = ref(false);
const showCaregiverSign = ref(false);

const handleRecipientSignSave = (dataUrl) => {
  formData.value.guardianSignUrl = dataUrl;
  showRecipientSign.value = false;
};

const handleCaregiverSignSave = (dataUrl) => {
  formData.value.counselorSignUrl = dataUrl;
  showCaregiverSign.value = false;
};

// Options
const visitTypes = [
  { label: '정기 상담', value: 'regular' },
  { label: '초기 상담', value: 'initial' },
  { label: '긴급 상담', value: 'emergency' },
  { label: '종결 상담', value: 'intermediate' },
  { label: '보호자 상담', value: 'guardian' }
];

const reactions = [
  { label: '매우 만족', value: 'very_good' },
  { label: '만족', value: 'good' },
  { label: '보통', value: 'normal' },
  { label: '불만족', value: 'bad' },
  { label: '매우 불만족', value: 'very_bad' }
];

// Watch initialData
watch(() => props.initialData, (newData) => {
  if (newData) {
    formData.value = { ...formData.value, ...newData };
  }
}, { deep: true });

// Load Beneficiaries
const loadBeneficiaries = async () => {
  try {
    loadingBeneficiaries.value = true;
    const response = await getMyBeneficiaries();
    const data = response?.data ?? response;
    beneficiaries.value = Array.isArray(data) ? data : [];
  } catch (error) {
    console.error(error);
    beneficiaries.value = [];
  } finally {
    loadingBeneficiaries.value = false;
  }
};

// Submit (유효성 검사 추가)
const handleSubmit = () => {
  // 필수값 검증
  if (!formData.value.beneficiaryId) return alert('수급자를 선택해주세요.');
  if (!formData.value.careWorkerName) return alert('상담자 이름을 입력해주세요.');
  if (!formData.value.visit_date) return alert('방문 일시를 입력해주세요.');
  if (!formData.value.visit_detail.trim()) return alert('방문 목적을 입력해주세요.');

  // 서명 필수 검증
  if (!formData.value.guardianSignUrl) return alert('수급자(보호자) 서명을 완료해주세요.');
  if (!formData.value.counselorSignUrl) return alert('요양보호사 서명을 완료해주세요.');
  
  emit('submit', formData.value);
};

const handleSaveDraft = () => {
  emit('save-draft', formData.value);
};

onMounted(async () => {
  await loadBeneficiaries();
});
</script>

<template>
  <div class="visit-counsel-form">
    
    <section class="form-section basic-info">
      <div class="section-header">
        <h2>방문상담 일지</h2>
        <p class="section-desc">수급자 가정 방문 상담 내역을 기록합니다.</p>
      </div>

      <div class="info-grid">
        <div class="info-row">
          <label>수급자명 <span class="required">*</span></label>
          <input
            v-if="readOnly"
            v-model="formData.recipientName"
            type="text"
            disabled
            class="readonly-field"
          />
          <select v-else v-model.number="formData.beneficiaryId" :disabled="loadingBeneficiaries">
            <option :value="0">{{ loadingBeneficiaries ? '로딩중...' : '선택하세요' }}</option>
            <option v-for="b in beneficiaries" :key="b.beneficiaryId" :value="b.beneficiaryId">{{ b.name }}</option>
          </select>
        </div>
        <div class="info-row">
          <label>상담자 <span class="required">*</span></label>
          <input v-model="formData.careWorkerName" type="text" :disabled="readOnly" placeholder="입력하세요" />
        </div>
        <div class="info-row">
          <label>방문 일시 <span class="required">*</span></label>
          <input v-model="formData.visit_date" type="datetime-local" :disabled="readOnly" />
        </div>
      </div>
    </section>

    <section class="form-section table-section">
      <h3 class="section-title">상담 개요</h3>
      
      <div class="custom-table">
        <div class="table-row">
          <div class="row-label">상담 유형 <span class="required">*</span></div>
          <div class="row-choices">
            <div
              v-for="type in visitTypes"
              :key="type.value"
              class="choice-cell"
              :class="{ 
                active: formData.visit_type === type.value, 
                'read-only': readOnly 
              }"
              @click="!readOnly && (formData.visit_type = type.value)"
            >
              <div class="radio-circle" :class="{ checked: formData.visit_type === type.value }"></div>
              <span class="choice-text">{{ type.label }}</span>
            </div>
          </div>
        </div>

        <div class="table-row">
          <div class="row-label">수급자 반응 <span class="required">*</span></div>
          <div class="row-choices">
            <div
              v-for="react in reactions"
              :key="react.value"
              class="choice-cell"
              :class="{ 
                active: formData.reaction === react.value, 
                'read-only': readOnly 
              }"
              @click="!readOnly && (formData.reaction = react.value)"
            >
              <div class="radio-circle" :class="{ checked: formData.reaction === react.value }"></div>
              <span class="choice-text">{{ react.label }}</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="form-section content-section">
      <h3 class="section-title">상담 상세 내용</h3>

      <div class="content-grid">
        <div class="input-group">
          <label>방문 목적 <span class="required">*</span></label>
          <textarea 
            v-model="formData.visit_detail" 
            :disabled="readOnly"
            placeholder="예: 정기 방문, 건강 상태 확인 등"
          ></textarea>
        </div>
        <div class="input-group">
          <label>관찰 사항 (건강, 심리 등)</label>
          <textarea v-model="formData.observed_condition" :disabled="readOnly"></textarea>
        </div>
        <div class="input-group">
          <label>주요 욕구 및 호소 내용</label>
          <textarea v-model="formData.subjective_needs" :disabled="readOnly"></textarea>
        </div>
        <div class="input-group highlight">
          <label>조치 사항 및 결과</label>
          <textarea v-model="formData.counselor_notes" :disabled="readOnly"></textarea>
        </div>
        <div class="input-group">
          <label>다음 방문 계획</label>
          <input type="date" v-model="formData.next_action" :disabled="readOnly" class="date-input" />
        </div>
      </div>
    </section>

    <!-- 서명 섹션 -->
    <section class="form-section signature-section">
      <h3 class="section-title">서명</h3>
      <div class="signatures-container">
        
        <!-- 수급자 서명 -->
        <div class="signature-box" @click="!readOnly && (showRecipientSign = true)">
          <div class="sig-label">수급자(보호자) 서명 <span class="required">*</span></div>
          <div v-if="formData.guardianSignUrl" class="sig-img-wrapper">
             <img :src="formData.guardianSignUrl" alt="수급자 서명" class="sig-img" />
          </div>
          <div v-else class="sig-placeholder">
             {{ readOnly ? '서명 없음' : '서명하기 ✍️' }}
          </div>
        </div>

        <!-- 요양보호사 서명 -->
        <div class="signature-box" @click="!readOnly && (showCaregiverSign = true)">
          <div class="sig-label">요양보호사 서명 <span class="required">*</span></div>
          <div v-if="formData.counselorSignUrl" class="sig-img-wrapper">
             <img :src="formData.counselorSignUrl" alt="요양보호사 서명" class="sig-img" />
          </div>
          <div v-else class="sig-placeholder">
             {{ readOnly ? '서명 없음' : '서명하기 ✍️' }}
          </div>
        </div>



      </div>
    </section>

    <!-- 서명 모달 컴포넌트 -->
    <SignaturePad 
      v-if="showRecipientSign" 
      title="수급자 서명" 
      @close="showRecipientSign = false" 
      @save="handleRecipientSignSave" 
    />
    <SignaturePad 
      v-if="showCaregiverSign" 
      title="요양보호사 서명" 
      @close="showCaregiverSign = false" 
      @save="handleCaregiverSignSave" 
    />

    <div v-if="!readOnly" class="form-actions">
      <button class="btn-secondary" @click="handleSaveDraft">임시저장</button>
      <button class="btn-primary" @click="handleSubmit">저장</button>
    </div>

  </div>
</template>

<style scoped>
.visit-counsel-form {
  max-width: 1200px; margin: 0 auto; padding: 1.5rem; font-family: 'Noto Sans KR', sans-serif;
}

/* 섹션 공통 (보라색 테마) */
.form-section {
  background: white; border-radius: 8px; padding: 20px; margin-bottom: 20px;
  border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.section-header h2 {
  color: #6b21a8; font-size: 1.5rem; font-weight: 700; margin-bottom: 5px; text-align: center;
}
.section-desc { text-align: center; color: #718096; font-size: 0.9rem; margin-bottom: 20px; }

.section-title {
  font-size: 1.1rem; font-weight: 700; color: #4a5568; margin-bottom: 15px;
  background: #faf5ff; padding: 10px; border-left: 4px solid #8b5cf6;
}

/* 필수 항목 표시 스타일 */
.required { color: #ef4444; margin-left: 4px; font-weight: bold; }

/* 정보 입력 그리드 */
.info-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; }
.info-row { display: flex; flex-direction: column; gap: 5px; }
.info-row label { font-size: 0.85rem; font-weight: 600; color: #4a5568; }
.info-row input, .info-row select { padding: 8px; border: 1px solid #cbd5e0; border-radius: 4px; font-size: 0.9rem; }
.info-row input:focus, .info-row select:focus { outline: none; border-color: #8b5cf6; }

/* 테이블 스타일 */
.custom-table { border: 1px solid #e2e8f0; border-radius: 6px; overflow: hidden; margin-bottom: 20px; }
.table-row { display: grid; grid-template-columns: 150px 1fr; border-bottom: 1px solid #e2e8f0; }
.table-row:last-child { border-bottom: none; }

.row-label {
  padding: 12px; font-weight: 600; display: flex; align-items: center; 
  background: #f9fafb; border-right: 1px solid #e2e8f0; font-size: 0.9rem; color: #374151;
}
.row-choices { display: flex; flex-wrap: wrap; padding: 5px; }

/* 선택 셀 */
.choice-cell {
  padding: 10px 15px; margin: 5px; border: 1px solid #e2e8f0; border-radius: 6px;
  display: flex; align-items: center; cursor: pointer; transition: all 0.2s; font-size: 0.85rem;
}
.choice-cell:hover:not(.read-only) { background: #faf5ff; }
.choice-cell.active { background: #f3e8ff; border-color: #8b5cf6; color: #581c87; font-weight: 600; }

.radio-circle { width: 14px; height: 14px; border: 2px solid #cbd5e0; border-radius: 50%; margin-right: 6px; }
.choice-cell.active .radio-circle { border-color: #8b5cf6; background: #8b5cf6; box-shadow: inset 0 0 0 2px white; }

/* 상세 내용 */
.content-grid { display: flex; flex-direction: column; gap: 15px; }
.input-group { display: flex; flex-direction: column; gap: 5px; }
.input-group label { font-weight: 600; font-size: 0.9rem; color: #2d3748; }
.input-group textarea {
  width: 100%; height: 80px; padding: 10px; border: 1px solid #cbd5e0; 
  border-radius: 4px; resize: vertical; font-size: 0.9rem;
}
.input-group textarea:focus { outline: none; border-color: #8b5cf6; }
.date-input { width: 200px; padding: 8px; border: 1px solid #cbd5e0; border-radius: 4px; }

/* 버튼 */
.form-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; }
.btn-primary { background: #8b5cf6; color: white; padding: 10px 25px; border-radius: 4px; border: none; font-weight: 700; cursor: pointer; }
.btn-primary:hover { background: #7c3aed; }
.btn-secondary { background: white; color: #4a5568; padding: 10px 25px; border-radius: 4px; border: 1px solid #cbd5e0; font-weight: 600; cursor: pointer; }
.btn-secondary:hover { background: #f9fafb; }

/* ReadOnly */
.choice-cell.read-only { cursor: default; opacity: 0.9; }
input:disabled, select:disabled, textarea:disabled { background: #f7fafc; cursor: not-allowed; }

@media (max-width: 768px) {
  .info-grid { grid-template-columns: 1fr; }
  .table-row { grid-template-columns: 1fr; }
  .row-label { border-right: none; border-bottom: 1px solid #e2e8f0; }
  .signatures-container { flex-direction: column; }
}

/* 서명 스타일 */
.signatures-container { display: flex; gap: 20px; margin-top: 10px; }
.signature-box {
  flex: 1; border: 2px dashed #d1d5db; border-radius: 8px; padding: 15px;
  text-align: center; cursor: pointer; transition: all 0.2s; min-height: 120px;
  display: flex; flex-direction: column; justify-content: center; align-items: center;
}
.signature-box:hover:not(.read-only) { border-color: #8b5cf6; background: #faf5ff; }
.sig-label { font-size: 0.9rem; font-weight: 700; color: #6b7280; margin-bottom: 10px; }
.sig-placeholder { font-size: 1rem; color: #9ca3af; font-weight: 600; }
.sig-img-wrapper { width: 100%; height: 100px; display: flex; justify-content: center; align-items: center; }
.sig-img { max-width: 100%; max-height: 100%; object-fit: contain; }
</style>