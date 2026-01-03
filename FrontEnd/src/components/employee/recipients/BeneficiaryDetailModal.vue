<script setup>
import { computed, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';

const props = defineProps({
  isOpen: {
    type: Boolean,
    required: true
  },
  beneficiary: {
    type: Object,
    default: () => ({})
  }
});

const emit = defineEmits(['close']);
const router = useRouter();

// 키보드 이벤트 핸들러
const handleKeydown = (e) => {
  if (!props.isOpen) return;

  if (e.key === 'Escape') {
    close();
  }
};

onMounted(() => {
  window.addEventListener('keydown', handleKeydown);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown);
});

const close = () => {
  emit('close');
};

// [수정] 수급자 상세 페이지로 이동 함수
const goToBeneficiaryDetail = () => {
  // API 응답에 있는 beneficiaryId 사용
  if (props.beneficiary.beneficiaryId) {
    close(); // 모달 닫기
    // 라우터 경로는 프로젝트 설정에 맞춰 수정해주세요 (예: /beneficiaries/1)
    router.push({ name: 'recipient-list', query: { id: props.beneficiary.beneficiaryId } });
  } else {
    alert("수급자 ID 정보가 없습니다.");
  }
};

// 사용률 계산
const usagePercentage = computed(() => {
  if (props.beneficiary.usedRate !== undefined) {
    return props.beneficiary.usedRate;
  }
  if (!props.beneficiary.monthlyLimit || !props.beneficiary.usedAmount) return 0;
  return Math.min(100, Math.round((props.beneficiary.usedAmount / props.beneficiary.monthlyLimit) * 100));
});

// 금액 포맷팅
const formatCurrency = (value) => {
  return value ? value.toLocaleString() : '0';
};
</script>

<template>
  <div v-if="isOpen" class="modal-overlay" @click.self="close">
    <div class="modal-content">
      
      <button 
        class="detail-link-btn" 
        @click="goToBeneficiaryDetail"
        title="수급자 관리 페이지로 이동" 
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;">
          <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path>
          <polyline points="15 3 21 3 21 9"></polyline>
          <line x1="10" y1="14" x2="21" y2="3"></line>
        </svg>
        수급자 관리 페이지로 이동
      </button>
      <button class="close-btn" @click="close">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
      </button>

      <div class="modal-header">
        <div class="title-row">
          <h2 class="name">{{ beneficiary.name }}</h2>
          <div class="badges">
            <span class="badge badge-risk" v-if="beneficiary.riskLevel === '고위험'">고위험</span>
            <span class="badge badge-service">{{ beneficiary.status }}</span>
          </div>
        </div>
        
        <div class="grade-info">
          {{ beneficiary.careLevel || '등급 정보 없음' }} | 만료일: {{ beneficiary.careLevelEndDate || '-' }}
        </div>
      </div>

      <div class="info-grid">
        <div class="info-item">
          <span class="label">👤 생년월일</span>
          <span class="value">{{ beneficiary.birthdate }}</span>
        </div>
        <div class="info-item">
          <span class="label">📞 연락처</span>
          <span class="value">{{ beneficiary.phone || '-' }}</span>
        </div>
        
        <div class="info-item">
          <span class="label">📍 주소</span>
          <span class="value">{{ beneficiary.address || '정보 없음' }}</span>
        </div>
        <div class="info-item">
          <span class="label">👤 담당 요양보호사</span>
          <span class="value">{{ beneficiary.managerName || '정보 없음' }}</span>
        </div>
        
        <div class="info-item">
          <span class="label">👤 보호자</span>
          <span class="value">{{ beneficiary.guardianName }} ({{ beneficiary.guardianRelation }})</span>
        </div>
        <div class="info-item">
          <span class="label">📞 보호자 연락처</span>
          <span class="value">{{ beneficiary.guardianPhone || '-' }}</span>
        </div>
      </div>

      <div class="financial-card">
        <div class="financial-row">
          <div class="fin-item">
            <span class="fin-label">월 지원금</span>
            <span class="fin-value">₩{{ formatCurrency(beneficiary.monthlyLimit) }}</span>
          </div>
          <div class="fin-item">
            <span class="fin-label">사용액</span>
            <span class="fin-value">₩{{ formatCurrency(beneficiary.usedAmount) }}</span>
          </div>
          <div class="fin-item">
            <span class="fin-label">잔액</span>
            <span class="fin-value text-blue">₩{{ formatCurrency(beneficiary.remainingAmount) }}</span>
          </div>
        </div>
        
        <div class="progress-section">
          <span class="usage-label">사용률</span>
          <span class="usage-percent">{{ usagePercentage }}%</span>
        </div>
        <div class="progress-bar-bg">
          <div class="progress-bar-fill" :style="{ width: `${usagePercentage}%` }"></div>
        </div>
      </div>

      <div class="health-section">
        <div class="health-col">
          <h4 class="section-subtitle">주요 질환 / 태그</h4>
          <div class="tags">
            <span v-for="(tag, index) in beneficiary.tags" :key="index" class="tag tag-purple">
              {{ tag }}
            </span>
          </div>
        </div>
        <div class="health-col">
          <h4 class="section-subtitle">위험 요인</h4>
          <div class="tags">
            <span v-for="risk in beneficiary.riskFactors" :key="risk.id" class="tag tag-red">
              {{ risk.name }}
            </span>
          </div>
        </div>
      </div>

      <div class="modal-footer">
        <button class="confirm-btn" @click="close">확인</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background-color: white;
  border-radius: 16px;
  width: 600px;
  padding: 32px;
  position: relative; /* 버튼 배치를 위해 relative 필수 */
  box-shadow: 0 10px 25px rgba(0,0,0,0.1);
}

.close-btn {
  position: absolute;
  top: 20px;
  right: 20px;
  background: none;
  border: none;
  cursor: pointer;
  color: #64748b;
  z-index: 10;
}

/* ▼▼▼ [추가된 부분] 상세 페이지 이동 버튼 스타일 ▼▼▼ */
.detail-link-btn {
  position: absolute;
  top: 20px;
  right: 60px; /* 닫기 버튼(20px) + 간격 확보 */
  
  display: flex;
  align-items: center;
  gap: 4px;
  
  background-color: #f0fdf4; /* 연한 초록색 배경 */
  color: #166534;           /* 짙은 초록색 글씨 */
  border: 1px solid #bbf7d0;
  border-radius: 6px;
  padding: 6px 12px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  z-index: 10;
}

.detail-link-btn:hover {
  background-color: #dcfce7;
  transform: translateY(-1px);
}
/* ▲▲▲ [추가된 부분] 끝 ▲▲▲ */

.modal-header {
  margin-bottom: 24px;
}

.title-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.name {
  font-size: 28px;
  font-weight: 700;
  color: #1a5928;
  margin: 0;
}

.badges {
  display: flex;
  gap: 8px;
}

.badge {
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
}

.badge-risk {
  background-color: #fee2e2;
  color: #dc2626;
}

.badge-service {
  background-color: #dbeafe;
  color: #2563eb;
}

.grade-info {
  background-color: #f8fafc;
  padding: 12px;
  border-radius: 8px;
  color: #475569;
  font-size: 14px;
  border: 1px solid #e2e8f0;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px 40px;
  margin-bottom: 32px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.label {
  font-size: 13px;
  color: #64748b;
}

.value {
  font-size: 15px;
  color: #1e293b;
  font-weight: 500;
}

.financial-card {
  background-color: #f0fdf4;
  border: 1px solid #dcfce7;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 24px;
}

.financial-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
}

.fin-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.fin-label { font-size: 13px; color: #475569; }
.fin-value { font-size: 16px; font-weight: 700; color: #1e293b; }
.text-blue { color: #2563eb; }

.progress-section {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #64748b;
  margin-bottom: 6px;
}

.progress-bar-bg {
  width: 100%;
  height: 8px;
  background-color: #e2e8f0;
  border-radius: 4px;
  overflow: hidden;
}

.progress-bar-fill {
  background-color: #22c55e;
  height: 100%;
  border-radius: 4px;
}

.health-section {
  display: flex;
  gap: 32px;
  margin-bottom: 32px;
}

.health-col {
  flex: 1;
}

.section-subtitle {
  font-size: 14px;
  color: #475569;
  margin: 0 0 12px 0;
}

.tags {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.tag {
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 500;
}

.tag-purple { background-color: #f3e8ff; color: #9333ea; }
.tag-red { background-color: #fee2e2; color: #dc2626; }

.modal-footer {
  display: flex;
  justify-content: flex-end;
}

.confirm-btn {
  background-color: #22c55e;
  color: white;
  border: none;
  padding: 10px 24px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  font-size: 15px;
}

.confirm-btn:hover {
  background-color: #16a34a;
}
</style>