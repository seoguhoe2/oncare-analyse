<script setup>
import { ref, watch } from 'vue';
import { getBeneficiaryDetail } from '@/api/careworker';

const props = defineProps({
  isOpen: Boolean,
  beneficiaryId: {
    type: [String, Number],
    default: null
  }
});

const emit = defineEmits(['close']);

const beneficiary = ref(null);
const loading = ref(false);
const error = ref(null);

// 수급자 상세 정보 로드
const loadBeneficiaryDetail = async () => {
  if (!props.beneficiaryId) {
    console.warn('beneficiaryId가 없습니다.');
    return;
  }

  loading.value = true;
  error.value = null;

  try {
    console.log('수급자 상세 정보 요청 - beneficiaryId:', props.beneficiaryId);
    const response = await getBeneficiaryDetail(props.beneficiaryId);
    console.log('수급자 상세 정보 응답:', response);
    console.log('응답 구조:', {
      response,
      responseData: response?.data,
      responseDataData: response?.data?.data,
    });

    // API 응답 구조에 따라 데이터 추출 (여러 패턴 대응)
    const data = response?.data?.data || response?.data || response;
    console.log('추출된 beneficiary 데이터:', data);
    beneficiary.value = data;
  } catch (err) {
    console.error('수급자 상세 정보 로드 실패:', err);
    console.error('에러 상세:', {
      message: err.message,
      response: err.response,
      status: err.response?.status,
      data: err.response?.data
    });
    error.value = `수급자 정보를 불러오는데 실패했습니다. (${err.message})`;
  } finally {
    loading.value = false;
  }
};

// 모달이 열릴 때마다 데이터 로드
watch(() => props.isOpen, (isOpen) => {
  if (isOpen && props.beneficiaryId) {
    loadBeneficiaryDetail();
  }
});

const onClose = () => {
  emit('close');
};
</script>

<template>
  <div v-if="isOpen" class="modal-overlay" @click.self="onClose">
    <div class="modal-container">
      <!-- 헤더 -->
      <div class="modal-header">
        <h3 class="modal-title">👤 수급자 상세 정보</h3>
        <button class="close-btn" @click="onClose">
          <span class="close-icon">&times;</span>
        </button>
      </div>

      <!-- 바디 -->
      <div class="modal-body">
        <!-- 로딩 중 -->
        <div v-if="loading" class="loading-state">
          <span class="loading-spinner">⏳</span>
          <p>수급자 정보를 불러오는 중...</p>
        </div>

        <!-- 에러 -->
        <div v-else-if="error" class="error-state">
          <span class="error-icon">⚠️</span>
          <p>{{ error }}</p>
        </div>

        <!-- 수급자 정보 -->
        <div v-else-if="beneficiary" class="beneficiary-info">
          <!-- 기본 정보 -->
          <div class="info-section">
            <h4 class="section-title">기본 정보</h4>
            <div class="info-grid">
              <div class="info-item">
                <span class="info-label">이름</span>
                <span class="info-value">{{ beneficiary.name || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">등급</span>
                <span class="info-value">{{ beneficiary.careLevel || beneficiary.grade || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">생년월일</span>
                <span class="info-value">{{ beneficiary.birthdate || beneficiary.birthDate || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">나이</span>
                <span class="info-value">{{ beneficiary.age ? `${beneficiary.age}세` : '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">성별</span>
                <span class="info-value">{{ beneficiary.gender === 'M' ? '남성' : beneficiary.gender === 'F' ? '여성' : beneficiary.gender || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">장기요양인정번호</span>
                <span class="info-value">{{ beneficiary.careLevelNumber || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">인정기간 시작일</span>
                <span class="info-value">{{ beneficiary.careLevelStartDate || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">인정기간 종료일</span>
                <span class="info-value">{{ beneficiary.careLevelEndDate || '-' }}</span>
              </div>
              <div class="info-item full-width">
                <span class="info-label">연락처</span>
                <span class="info-value">{{ beneficiary.phone || '-' }}</span>
              </div>
              <div class="info-item full-width">
                <span class="info-label">주소</span>
                <span class="info-value address">{{ beneficiary.address || '-' }}</span>
              </div>
            </div>
          </div>

          <!-- 보호자 정보 -->
          <div v-if="beneficiary.guardians && beneficiary.guardians.length > 0" class="info-section">
            <h4 class="section-title">보호자 정보</h4>
            <div v-for="(guardian, index) in beneficiary.guardians" :key="index" class="guardian-item">
              <div class="info-grid">
                <div class="info-item">
                  <span class="info-label">보호자명</span>
                  <span class="info-value">{{ guardian.name || '-' }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">연락처</span>
                  <span class="info-value">{{ guardian.phone || '-' }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 위험요인 -->
          <div v-if="beneficiary.riskFactors && beneficiary.riskFactors.length > 0" class="info-section">
            <h4 class="section-title">⚠️ 위험요인</h4>
            <div class="tags-container">
              <span v-for="(risk, index) in beneficiary.riskFactors" :key="index" class="tag tag-warning">
                {{ risk }}
              </span>
            </div>
          </div>

          <!-- 특이사항 -->
          <div v-if="beneficiary.significants && beneficiary.significants.length > 0" class="info-section">
            <h4 class="section-title">📌 특이사항</h4>
            <div class="tags-container">
              <span v-for="(item, index) in beneficiary.significants" :key="index" class="tag tag-info">
                {{ item }}
              </span>
            </div>
          </div>

          <!-- 태그 -->
          <div v-if="beneficiary.tags && beneficiary.tags.length > 0" class="info-section">
            <h4 class="section-title">🏷️ 태그</h4>
            <div class="tags-container">
              <span v-for="(tag, index) in beneficiary.tags" :key="index" class="tag tag-default">
                {{ tag }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- 푸터 -->
      <div class="modal-footer">
        <button class="btn-close" @click="onClose">닫기</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
  animation: overlay-fade 0.3s ease-out;
}

@keyframes overlay-fade {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal-container {
  background-color: white;
  width: 90%;
  max-width: 600px;
  max-height: 80vh;
  border-radius: 16px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  animation: modal-pop 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes modal-pop {
  from {
    opacity: 0;
    transform: scale(0.9) translateY(20px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
  border-bottom: 2px solid #93c5fd;
}

.modal-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: #1e40af;
  margin: 0;
}

.close-btn {
  background: white;
  border: 2px solid #bfdbfe;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
}

.close-btn:hover {
  background: #fee2e2;
  border-color: #fecaca;
  transform: rotate(90deg);
}

.close-icon {
  font-size: 1.5rem;
  color: #6b7280;
  line-height: 1;
}

.close-btn:hover .close-icon {
  color: #ef4444;
}

.modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem;
}

.loading-state,
.error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem 1.5rem;
  gap: 1rem;
  color: #6b7280;
}

.loading-spinner {
  font-size: 2rem;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.error-state {
  color: #dc2626;
}

.error-icon {
  font-size: 2rem;
}

.beneficiary-info {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.info-section {
  background: #f9fafb;
  border-radius: 12px;
  padding: 1.25rem;
  border: 1px solid #e5e7eb;
}

.section-title {
  font-size: 1rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 1rem 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

@media (max-width: 768px) {
  .info-grid {
    grid-template-columns: 1fr;
  }
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.info-item.full-width {
  grid-column: 1 / -1;
}

.info-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.025em;
}

.info-value {
  font-size: 0.9375rem;
  font-weight: 500;
  color: #1f2937;
  word-break: break-word;
}

.info-value.address {
  line-height: 1.5;
}

.notes-content {
  font-size: 0.9375rem;
  color: #4b5563;
  line-height: 1.6;
  white-space: pre-wrap;
  word-break: break-word;
}

.guardian-item {
  padding: 0.75rem;
  background: white;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  margin-bottom: 0.75rem;
}

.guardian-item:last-child {
  margin-bottom: 0;
}

.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.tag {
  display: inline-block;
  padding: 0.5rem 0.875rem;
  border-radius: 9999px;
  font-size: 0.875rem;
  font-weight: 600;
  white-space: nowrap;
}

.tag-warning {
  background-color: #fef2f2;
  color: #dc2626;
  border: 1px solid #fecaca;
}

.tag-info {
  background-color: #eff6ff;
  color: #2563eb;
  border: 1px solid #bfdbfe;
}

.tag-default {
  background-color: #f3f4f6;
  color: #4b5563;
  border: 1px solid #d1d5db;
}

.modal-footer {
  padding: 1rem 1.5rem;
  background: #f9fafb;
  border-top: 1px solid #e5e7eb;
  display: flex;
  justify-content: flex-end;
}

.btn-close {
  padding: 0.75rem 1.5rem;
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 0.9375rem;
  font-weight: 600;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
  transition: all 0.2s ease;
}

.btn-close:hover {
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
  transform: translateY(-2px);
}

.btn-close:active {
  transform: translateY(0);
}
</style>
