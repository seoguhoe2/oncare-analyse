<script setup>
import { ref, computed } from 'vue';

const props = defineProps({
  title: { type: String, default: '제품 수익률 분석' },
  apiData: { type: Object, default: () => null } // Dashboard.vue에서 받아올 전체 데이터
});

const emit = defineEmits(['remove', 'toggleSize']);

// --- 상태 관리 ---
const currentTab = ref('highReturnProducts'); // 'highReturnProducts', 'lowReturnProducts', 'allProductStats'

// --- 데이터 가공 (ApexCharts 형식으로 변환) ---
const chartSeries = computed(() => {
  if (!props.apiData || !props.apiData[currentTab.value]) return [];

  const targetList = props.apiData[currentTab.value];

  // 요건: 그래프는 "총 수익" (또는 수익률)으로 표시
  return [
    {
      name: '총 수익',
      data: targetList.map(item => item.totalRevenue)
    }
  ];
});

const chartCategories = computed(() => {
  if (!props.apiData || !props.apiData[currentTab.value]) return [];
  return props.apiData[currentTab.value].map(item => item.productName);
});

// --- 차트 옵션 (BaseChart 스타일 적용) ---
const chartOptions = computed(() => ({
  chart: {
    type: 'bar',
    toolbar: { show: false },
    fontFamily: 'Pretendard, sans-serif',
    zoom: { enabled: false }
  },
  plotOptions: {
    bar: {
      horizontal: false,
      columnWidth: '50%',
      borderRadius: 4,
    },
  },
  dataLabels: { enabled: false },
  stroke: {
    show: true,
    width: 2,
    colors: ['transparent']
  },
  xaxis: {
    categories: chartCategories.value,
    axisBorder: { show: false },
    axisTicks: { show: false }
  },
  yaxis: {
    labels: {
      formatter: (value) => {
        return value.toLocaleString(); 
      }
    }
  },
  // 색상 설정
  colors: ['#3B82F6'], 
  grid: {
    borderColor: '#f1f1f1',
    padding: { top: 10 }
  },
  fill: { opacity: 1 },
  legend: { position: 'bottom' },
  tooltip: {
    y: {
      formatter: function (val, { dataPointIndex }) {
        if (props.apiData && props.apiData[currentTab.value]) {
          const item = props.apiData[currentTab.value][dataPointIndex];
          if (item) {
            const purchase = item.totalPurchaseAmount;
            const rate = item.returnRate || 0;
            // 백엔드에서 이미 퍼센트 값으로 내려오므로 * 100 제외
            return `${val.toLocaleString()}원 (${Number(rate).toFixed(1)}%) / 구입: ${purchase.toLocaleString()}원`;
          }
        }
        return val.toLocaleString() + " 원";
      }
    }
  }
}));
</script>

<template>
  <div class="chart-card">
    <div class="chart-header">
      <div class="header-left">
        <h4>{{ title }}</h4>
        <div class="tab-buttons">
          <button 
            :class="{ active: currentTab === 'highReturnProducts' }" 
            @click="currentTab = 'highReturnProducts'"
          >
            수익 상위 5
          </button>
          <button 
            :class="{ active: currentTab === 'lowReturnProducts' }" 
            @click="currentTab = 'lowReturnProducts'"
          >
            수익 하위 5
          </button>
          <button 
            :class="{ active: currentTab === 'allProductStats' }" 
            @click="currentTab = 'allProductStats'"
          >
            전체 제품
          </button>
        </div>
      </div>

      <div class="control-buttons">
        <button class="icon-btn" @click.stop="$emit('toggleSize')" title="크기 변경">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="15 3 21 3 21 9"></polyline>
            <polyline points="9 21 3 21 3 15"></polyline>
            <line x1="21" y1="3" x2="14" y2="10"></line>
            <line x1="3" y1="21" x2="10" y2="14"></line>
          </svg>
        </button>
        <button class="icon-btn remove" @click.stop="$emit('remove')" title="위젯 삭제">
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </button>
      </div>
    </div>

    <div class="chart-body">
      <apexchart 
        v-if="props.apiData"
        width="100%" 
        height="100%" 
        type="bar" 
        :options="chartOptions" 
        :series="chartSeries" 
      />
      <div v-else class="loading-state">
        데이터를 불러오는 중입니다...
      </div>
    </div>
  </div>
</template>

<style scoped>
/* BaseChart.vue의 스타일을 그대로 가져오되, 탭 관련 스타일 추가 */
.chart-card {
  background: white;
  border-radius: 16px;
  padding: 24px;
  height: 100%;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
  display: flex;
  flex-direction: column;
  position: relative;
  transition: box-shadow 0.3s ease;
}

.chart-card:hover {
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
  min-height: 28px;
}

.header-left {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.chart-header h4 {
  margin: 0;
  font-size: 1.15rem;
  font-weight: 700;
  color: #1f2937;
}

/* 탭 버튼 스타일 */
.tab-buttons {
  display: flex;
  gap: 5px;
}

.tab-buttons button {
  border: 1px solid #e5e7eb;
  background: #f9fafb;
  color: #6b7280;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 0.8rem;
  cursor: pointer;
  transition: all 0.2s;
}

.tab-buttons button.active {
  background: #3B82F6;
  color: white;
  border-color: #3B82F6;
  font-weight: 600;
}

.tab-buttons button:hover:not(.active) {
  background: #e5e7eb;
}

/* 컨트롤 버튼 그룹 */
.control-buttons {
  display: flex;
  gap: 6px;
  opacity: 0;
  transition: opacity 0.2s ease-in-out;
}

.chart-card:hover .control-buttons {
  opacity: 1;
}

.icon-btn {
  background: transparent;
  border: none;
  cursor: pointer;
  color: #9ca3af;
  padding: 6px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.icon-btn:hover {
  background-color: #f3f4f6;
  color: #4b5563;
}

.icon-btn.remove:hover {
  background-color: #fee2e2;
  color: #ef4444;
}

.chart-body {
  flex-grow: 1;
  min-height: 250px;
}

.loading-state {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #9ca3af;
  font-size: 0.9rem;
}
</style>