<script setup>
import { ref, onMounted, watch } from 'vue';
import { getAssignedBeneficiaries } from '@/api/employee/employeeApi';

const props = defineProps({
  employeeId: {
    type: [Number, String],
    required: true
  }
});

const beneficiaries = ref([]);
const loading = ref(false);

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
      >
        <div class="profile-section">
          <div class="info-main">
            <span class="name">{{ person.name }}</span>
            <span class="sub-info" v-if="person.grade">{{ person.grade }}</span>
          </div>
          <div class="info-sub">
            <!-- 주소 정보가 없으면 생년월일 표시 (API 한계 대응) -->
            <span v-if="person.address" class="address">{{ person.address }}</span>
            <span v-else class="birthdate">{{ person.birthDate ? person.birthDate : '정보 없음' }}</span>
          </div>
        </div>

        <button class="detail-link">
          클릭하여 상세정보 보기 →
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
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
}

.beneficiary-item:hover {
  border-color: #e2e8f0;
  box-shadow: 0 4px 12px rgba(0,0,0,0.02);
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
