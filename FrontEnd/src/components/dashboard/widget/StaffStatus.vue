<script setup>
import ChartCard from './ChartCard.vue'; // 기존 ChartCard 재사용

// 데이터 (실제로는 API에서 받아옴)
const staffData = [
  { label: '근무 중', role: '요양보호사', count: '24명', type: 'success' },
  { label: '휴무', role: '요양보호사', count: '4명', type: 'default' },
  { label: '관리직', role: '센터장, 관리자', count: '8명', type: 'primary' },
];

const getTypeStyle = (type) => {
  if (type === 'success') return 'bg-success';
  if (type === 'primary') return 'bg-primary';
  return 'bg-default';
};
</script>

<template>
  <ChartCard title="직원 근무 현황">
    <div class="staff-list">
      <div 
        v-for="(item, index) in staffData" 
        :key="index" 
        class="staff-row"
        :class="getTypeStyle(item.type)"
      >
        <div class="info">
          <span class="label">{{ item.label }}</span>
          <span class="role">{{ item.role }}</span>
        </div>
        <span class="count" :class="item.type">{{ item.count }}</span>
      </div>
    </div>
  </ChartCard>
</template>

<style scoped>
/* ChartCard의 제목 색상을 녹색으로 덮어쓰기 위해 deep 사용 혹은 ChartCard props 수정 필요. 
   여기서는 간단히 CSS로 처리 */
:deep(.chart-header h3) {
  color: #2e7d32; /* 이미지의 진한 녹색 타이틀 */
}

.staff-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.staff-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-radius: 8px;
}

/* 배경색 스타일 */
.bg-success { background-color: #f1f8f1; } /* 연한 녹색 */
.bg-primary { background-color: #f0f7ff; } /* 연한 파란색 */
.bg-default { background-color: #f9f9f9; } /* 연한 회색 */

.info {
  display: flex;
  flex-direction: column;
}

.label {
  font-weight: 700;
  font-size: 15px;
  color: #333;
  margin-bottom: 4px;
}

.role {
  font-size: 13px;
  color: #666;
}

.count {
  font-weight: 700;
  font-size: 16px;
}

.count.success { color: #2e7d32; }
.count.primary { color: #1565c0; }
.count.default { color: #333; }
</style>