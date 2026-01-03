<script setup>
import { ref, onMounted } from 'vue';
import api from '@/lib/api'; // axios 인스턴스 import

// 부모 컴포넌트에서 직원 상세로 이동시키는 함수를 받을 수 있음
const emit = defineEmits(['select-employee']);

const alerts = ref([]);

const fetchAlerts = async () => {
  try {
    // 백엔드 API 호출
    const res = await api.get('/api/employees/education/alerts');
    alerts.value = res.data;
  } catch (error) {
    console.warn("보수교육 알림 조회 실패/데이터 없음", error);
  }
};

onMounted(fetchAlerts);

// D-Day 텍스트 변환기
// D-Day 텍스트 변환기
const getDDayText = (item) => {
  const dayVal = item.dday; 
  if (item.status === 'OVERDUE') {
    return `${Math.abs(dayVal)}일 초과`;
  }
  return `${dayVal}일 전`;
};

// 뱃지 스타일 결정
const getBadgeClass = (status) => {
  return status === 'OVERDUE' ? 'badge-red' : 'badge-yellow';
};
</script>

<template>
  <div v-if="alerts.length > 0" class="alert-banner">
    <div class="banner-header">
      <div class="icon-circle">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2">
          <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
          <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
        </svg>
      </div>
      <div class="title-area">
        <span class="title">보수교육 기한 알림</span>
        <span class="count-badge">{{ alerts.length }}명</span>
      </div>
    </div>

    <div class="banner-desc">
      보수교육 기한이 임박하거나 초과된 직원이 있습니다. 해당 직원을 선택하여 자격증 탭에서 확인해주세요.
    </div>

    <div class="chip-container">
      <button 
        v-for="item in alerts" 
        :key="item.employeeId" 
        class="name-chip"
        :class="getBadgeClass(item.status)"
        @click="$emit('select-employee', item.employeeId)"
      >
        <span class="name">{{ item.name }}</span>
        <span class="d-day">({{ getDDayText(item) }})</span>
      </button>
    </div>
  </div>
</template>

<style scoped>
.alert-banner {
  background-color: #fff7ed; /* 연한 오렌지 배경 */
  border: 1px solid #fed7aa; /* 오렌지 테두리 */
  border-radius: 8px;
  padding: 16px 20px;
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.banner-header {
  display: flex;
  align-items: center;
  gap: 10px;
}

.icon-circle {
  width: 32px;
  height: 32px;
  background-color: #f97316; /* 진한 오렌지 */
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.title-area {
  display: flex;
  align-items: center;
  gap: 8px;
}

.title {
  font-weight: 700;
  color: #166534; /* 짙은 녹색 텍스트 */
  font-size: 16px;
}

.count-badge {
  background-color: #ffedd5;
  color: #c2410c;
  font-size: 12px;
  font-weight: 700;
  padding: 2px 8px;
  border-radius: 12px;
}

.banner-desc {
  font-size: 13px;
  color: #9a3412; /* 텍스트 색상 */
  margin-bottom: 4px;
}

.chip-container {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.name-chip {
  border: none;
  border-radius: 16px;
  padding: 4px 12px;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  gap: 4px;
  transition: transform 0.1s;
}

.name-chip:hover {
  transform: scale(1.05);
}

/* 초과 (빨강) */
.badge-red {
  background-color: #fee2e2;
  color: #991b1b;
}

/* 임박 (노랑) */
.badge-yellow {
  background-color: #fef9c3;
  color: #854d0e;
}
</style>
