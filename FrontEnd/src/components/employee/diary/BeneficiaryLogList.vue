<script setup>
import { ref, onMounted, watch } from 'vue';
import { getAssignedBeneficiaries } from '@/api/employee/employeeApi';

const props = defineProps({
  employeeId: { type: [Number, String], required: true }
});

const list = ref([]);

const fetchData = async () => {
  if (!props.employeeId) return;
  try {
    const data = await getAssignedBeneficiaries(props.employeeId);
    list.value = data || [];
  } catch (error) {
    console.error("담당 수급자 목록 조회 실패", error);
    list.value = [];
  }
};

// 수급자 카드 클릭 시 상세 페이지로 이동 (구현 필요 시 사용)
const goToDetail = (beneficiaryId) => {
  console.log(`수급자 ID ${beneficiaryId}의 일지 상세로 이동`);
  // router.push(...)
};

onMounted(fetchData);
watch(() => props.employeeId, fetchData);
</script>

<template>
  <div class="journal-section">
    <h3 class="section-title">요양일지 (수급자별)</h3>
    
    <div class="card-list">
      <div 
        v-for="item in list" 
        :key="item.beneficiaryId" 
        class="log-card"
        @click="goToDetail(item.beneficiaryId)"
      >
        <div class="card-left">
          <div class="info">
            <div class="name">{{ item.name }}</div>
            <div class="details">
              <!-- API 미지원으로 등급/주소 대신 생년월일 표기 -->
              <span class="grade" v-if="item.grade">{{ item.grade }}</span>
              <span class="separator" v-if="item.grade">·</span>
              <span class="address">{{ item.address || item.birthDate || '정보 없음' }}</span>
            </div>
          </div>
        </div>

        <div class="card-right">
          <!-- API 미지원으로 건수 미표시 (또는 추후 추가) -->
          <div v-if="item.logCount" class="count-badge">{{ item.logCount }}건</div>
          <div class="arrow-icon">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="m9 18 6-6-6-6"/>
            </svg>
          </div>
        </div>
      </div>

      <div v-if="list.length === 0" class="empty-state">
        담당 수급자가 없습니다.
      </div>
    </div>
  </div>
</template>

<style scoped>
.journal-section {
  width: 100%;
  font-family: 'Pretendard', sans-serif;
}

.section-title {
  font-size: 16px;
  font-weight: 700;
  color: #166534; /* 초록색 톤 */
  margin-bottom: 12px;
}

.card-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* 카드 스타일 */
.log-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 16px 20px;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
}

.log-card:hover {
  border-color: #22c55e;
  transform: translateY(-1px);
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
}

/* 왼쪽 영역 */
.card-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.name {
  font-size: 16px;
  font-weight: 700;
  color: #111;
}

.details {
  font-size: 13px;
  color: #666;
  display: flex;
  align-items: center;
  gap: 6px;
}

.grade {
  font-weight: 500;
  color: #333;
}

.separator {
  color: #ccc;
}

.address {
  color: #6b7280;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 200px; /* 긴 주소 말줄임 */
}

/* 오른쪽 영역 */
.card-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.count-badge {
  background-color: #dbeafe; /* 연한 파란 배경 */
  color: #1e40af;           /* 진한 파란 글씨 */
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
}

.arrow-icon {
  display: flex;
  align-items: center;
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: #999;
  background: #f9fafb;
  border-radius: 12px;
}
</style>