<script setup>
import { ref, onMounted, watch } from 'vue';
import { getAssignedBeneficiaries } from '@/api/employee/employeeApi';
import axios from 'axios';
import BeneficiaryDetailModal from './BeneficiaryDetailModal.vue';
import { Icon } from '@iconify/vue';

const props = defineProps({
  employeeId: {
    type: [Number, String],
    required: true
  }
});

const beneficiaries = ref([]);
const loading = ref(false);

// Modal State
const isModalOpen = ref(false);
const selectedBeneficiary = ref({});

// 1. 목록 조회 (기존 유지)
const fetchBeneficiaries = async () => {
  if (!props.employeeId) return;

  loading.value = true;
  try {
    const data = await getAssignedBeneficiaries(props.employeeId);
    beneficiaries.value = data || [];
  } catch (error) {
    console.error('담당 수급자 조회 실패:', error);
    beneficiaries.value = [];
  } finally {
    loading.value = false;
  }
};

// 2. [수정] 상세 조회 (백엔드 API 연결)
const openDetailModal = async (person) => {
  // person 객체 안에 beneficiaryId가 있다고 가정 (리스트 조회 시 받아온 ID)
  if (!person.beneficiaryId) {
    console.error("수급자 ID가 없습니다.");
    return;
  }

  try {
    // 백엔드 상세 조회 API 호출
    // (설정된 proxy가 있다면 '/api/beneficiaries/...' 로 줄여도 됨)
    const response = await axios.get(`http://localhost:5000/api/beneficiaries/${person.beneficiaryId}`);
    
    // 받아온 상세 데이터를 모달용 변수에 저장
    selectedBeneficiary.value = response.data;
    
    // 모달 열기
    isModalOpen.value = true;
  } catch (error) {
    console.error("수급자 상세 정보 조회 실패:", error);
    alert("상세 정보를 불러오지 못했습니다.");
  }
};

watch(() => props.employeeId, () => {
  fetchBeneficiaries();
});

onMounted(() => {
  fetchBeneficiaries();
});
</script>

<template>
  <div class="assigned-beneficiaries-container">
    <div class="header-area">
      <h3 class="section-title">담당 수급자</h3>
      <span class="count">총 {{ beneficiaries.length }}명</span>
    </div>

    <div v-if="loading" class="loading-state">
      로딩 중...
    </div>

    <div v-else-if="beneficiaries.length === 0" class="empty-state">
      담당 수급자가 없습니다.
    </div>

    <div v-else class="beneficiary-list">
      <div 
        v-for="person in beneficiaries" 
        :key="person.beneficiaryId" 
        class="beneficiary-item"
        @click="openDetailModal(person)"
      >
        <div class="profile-section">
          <div class="info-main">
            <span class="name">{{ person.name }}</span>
            <span class="sub-info" v-if="person.grade">{{ person.grade }}</span>
          </div>
          <div class="info-sub">
            <span v-if="person.address" class="address">{{ person.address }}</span>
            <span v-else class="birthdate">{{ person.birthDate ? person.birthDate : '정보 없음' }}</span>
          </div>
        </div>

        <button class="detail-link">
          클릭하여 상세정보 보기 <Icon icon="line-md:arrow-right" width="16" height="16" style="vertical-align: middle;" />
        </button>
      </div>
    </div>

    <BeneficiaryDetailModal 
      :isOpen="isModalOpen"
      :beneficiary="selectedBeneficiary"
      @close="isModalOpen = false"
    />
  </div>
</template>

<style scoped>
/* 스타일은 기존과 동일 */
.assigned-beneficiaries-container {
  padding: 24px;
  background: white;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  min-height: 400px;
}

.header-area {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.section-title {
  font-size: 18px;
  font-weight: 700;
  color: #1a5928;
  margin: 0;
}

.count {
  font-size: 13px;
  color: #64748b;
}

.beneficiary-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.beneficiary-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border: 1px solid #f1f5f9;
  border-radius: 12px;
  background-color: #ffffff;
  transition: all 0.2s;
  cursor: pointer;
}

.beneficiary-item:hover {
  border-color: #e2e8f0;
  box-shadow: 0 4px 12px rgba(0,0,0,0.02);
  transform: translateY(-2px);
}

.profile-section {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.info-main {
  display: flex;
  align-items: center;
  gap: 8px;
}

.name {
  font-size: 16px;
  font-weight: 700;
  color: #1e293b;
}

.sub-info {
  font-size: 13px;
  color: #64748b;
}

.info-sub {
  font-size: 14px;
  color: #475569;
}

.detail-link {
  font-size: 13px;
  color: #22c55e;
  background: none;
  border: none;
  cursor: pointer;
  font-weight: 500;
}

.detail-link:hover {
  text-decoration: underline;
}

.empty-state {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 200px;
  color: #94a3b8;
  font-size: 14px;
}

.loading-state {
  text-align: center;
  padding: 40px;
  color: #64748b;
}
</style>