<script setup>
import { computed } from 'vue';

const props = defineProps({
  title: { type: String, default: '장기요양등급 만료 임박' },
  apiData: { type: Object, default: () => null } // { days90: 1, days60: 0, days45: 2 }
});

const emit = defineEmits(['remove', 'toggleSize']);

// --- 데이터 가공 ---
const chartSeries = computed(() => {
  if (!props.apiData) return [];

  return [
    {
      name: '수급자 수',
      data: [
        props.apiData.days90 || 0,
        props.apiData.days60 || 0,
        props.apiData.days45 || 0
      ]
    }
  ];
});

const chartCategories = ['90일 전', '60일 전', '45일 전'];

// --- 차트 옵션 ---
const chartOptions = computed(() => ({
  chart: {
    type: 'bar', // colum chart
    toolbar: { show: false },
    fontFamily: 'Pretendard, sans-serif',
    zoom: { enabled: false }
  },
  plotOptions: {
    bar: {
      horizontal: false, 
      columnWidth: '20%', // 막대가 너무 두꺼워지지 않도록 조정 (항목이 적을 때 유용)
      borderRadius: 4,
      distributed: true 
    },
  },
  dataLabels: { enabled: false },
  stroke: {
    show: true,
    width: 2,
    colors: ['transparent']
  },
  xaxis: {
    categories: chartCategories,
    axisBorder: { show: false },
    axisTicks: { show: false }
  },
  yaxis: {
    labels: {
      formatter: (value) => value.toFixed(0) // 명수니까 정수
    }
  },
  // 색상 설정 (90일, 60일, 45일 순서대로 다르게 줄 수도 있고, 단색으로 갈 수도 있음)
  // 여기서는 임박할수록 진한 색이 되도록 설정 예시
  colors: ['#3B82F6', '#F59E0B', '#EF4444'], 
  grid: {
    borderColor: '#f1f1f1',
    padding: { top: 10 }
  },
  legend: { show: false }, // distributed: true일 때 자동으로 범례가 생기는데 필요 없으면 false
  tooltip: {
    y: {
      formatter: function (val) {
        return val + " 명";
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
