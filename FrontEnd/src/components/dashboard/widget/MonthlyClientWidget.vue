<script setup>
import { computed } from 'vue';

const props = defineProps({
  title: { type: String, default: '월별 잠재고객 및 계약 현황' },
  apiData: { type: Array, default: () => [] } 
});

const emit = defineEmits(['remove', 'toggleSize']);

// --- 데이터 가공 ---
// 날짜 오름차순 정렬
const sortedData = computed(() => {
  if (!props.apiData) return [];
  // apiData 복사 후 정렬 (YYYY-MM 문자열 비교)
  return [...props.apiData].sort((a, b) => a.month.localeCompare(b.month));
});

const chartSeries = computed(() => {
  if (!sortedData.value.length) return [];

  return [
    {
      name: '잠재고객 수',
      type: 'column',
      data: sortedData.value.map(item => item.potentialCount)
    },
    {
      name: '계약 성사 수',
      type: 'line',
      data: sortedData.value.map(item => item.contractCount)
    }
  ];
});

const chartCategories = computed(() => {
  return sortedData.value.map(item => item.month); // "2023-05", ...
});

// --- 차트 옵션 ---
const chartOptions = computed(() => ({
  chart: {
    type: 'line',
    toolbar: { show: false },
    fontFamily: 'Pretendard, sans-serif',
    zoom: { enabled: false }
  },
  stroke: {
    width: [0, 3], // 첫번째(column)는 0, 두번째(line)는 3
    curve: 'smooth'
  },
  plotOptions: {
    bar: {
      columnWidth: '40%',
      borderRadius: 4
    }
  },
  dataLabels: {
    enabled: true,
    enabledOnSeries: [1] // 선 그래프(계약 수)에만 라벨 표시
  },
  xaxis: {
    categories: chartCategories.value,
    axisBorder: { show: false },
    axisTicks: { show: false }
  },
  yaxis: [
    {
      title: { text: '잠재고객 (명)' },
    },
    {
      opposite: true, // 오른쪽 축 사용
      title: { text: '계약성사 (명)' }
    }
  ],
  colors: ['#A78BFA', '#10B981'], // 보라색(잠재), 초록색(계약)
  grid: {
    borderColor: '#f1f1f1',
    padding: { top: 10 }
  },
  legend: { position: 'bottom' },
  tooltip: {
    shared: true,
    intersect: false,
    y: {
      formatter: (val) => val + " 명"
    }
  }
}));
</script>

<template>
  <div class="chart-card">
    <div class="chart-header">
      <div class="header-left">
        <h4>{{ title }}</h4>
      </div>

      <div class="control-buttons">
        <button class="icon-btn" @click.stop="$emit('toggleSize')" title="크기 변경">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="15 3 21 3 21 9"></polyline>
            <polyline points="9 21 3 21 3 15"></polyline>
            <line x1="21" y1="3" x2="14" y2="10"></line>
            <line x1="3" y1="21" x2="14" y2="10"></line>
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
        v-if="sortedData.length"
        width="100%" 
        height="100%" 
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
