<script setup>
import { computed } from 'vue';

const props = defineProps({
  title: { type: String, default: '장기요양 등급별 현황' },
  apiData: { type: Array, default: () => [] } 
});

const emit = defineEmits(['remove', 'toggleSize']);

// --- 데이터 가공 ---
const sortedData = computed(() => {
  if (!props.apiData) return [];
  // grade 기준 정렬 (1등급 -> 2등급 ... 인지지원등급)
  // 문자열 정렬이지만 "1등급", "2등급" 형식이므로 localeCompare로 어느정도 정렬됨.
  // 필요 시 커스텀 정렬 로직 추가 가능.
  return [...props.apiData].sort((a, b) => a.grade.localeCompare(b.grade));
});

const chartSeries = computed(() => {
  return sortedData.value.map(item => item.count);
});

const chartLabels = computed(() => {
  return sortedData.value.map(item => item.grade);
});

// --- 차트 옵션 (도넛 그래프) ---
const chartOptions = computed(() => ({
  chart: {
    type: 'donut',
    fontFamily: 'Pretendard, sans-serif',
  },
  labels: chartLabels.value,
  colors: ['#6366F1', '#8B5CF6', '#EC4899', '#F43F5E', '#F59E0B', '#10B981'], // 다양한 색상
  plotOptions: {
    pie: {
      donut: {
        size: '55%',
        labels: {
          show: true,
          name: { show: true, fontSize: '14px' },
          value: { 
            show: true, 
            fontSize: '16px', 
            fontWeight: 600,
            formatter: (val) => val + "명"
          },
          total: {
            show: true,
            label: 'Total',
            fontSize: '14px',
            color: '#6b7280',
            formatter: (w) => {
              const total = w.globals.seriesTotals.reduce((a, b) => a + b, 0);
              return total + "명";
            }
          }
        }
      }
    }
  },
  dataLabels: {
    enabled: false // 도넛 내부에 숫자가 너무 많으면 복잡하므로 끔 (hover 시 확인)
  },
  legend: {
    position: 'bottom',
    fontSize: '13px',
    markers: { width: 10, height: 10 }
  },
  tooltip: {
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
        <!-- 도넛 차트는 크기 변경보다는 삭제만 주로 사용되는 편이나 기능 유지 -->
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
        type="donut"
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

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
  min-height: 28px;
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
