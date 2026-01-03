<script setup>
import { computed } from 'vue';

const props = defineProps({
  title: { type: String, default: '' },
  chartType: { type: String, default: 'bar' }, // line, bar, area, donut, pie
  categories: { type: Array, default: () => [] }, // X축 라벨 또는 파이차트 라벨
  series: { type: Array, default: () => [] },     // 데이터
  colors: { type: Array, default: () => ['#10B981', '#3B82F6', '#F59E0B', '#EF4444', '#8B5CF6'] }
});

// 부모 컴포넌트(DashboardPage)로 신호를 보내기 위한 설정
const emit = defineEmits(['remove', 'toggleSize']);

const chartOptions = computed(() => {
  // 파이/도넛 차트인지 확인
  const isPie = props.chartType === 'donut' || props.chartType === 'pie';

  return {
    chart: {
      id: 'erp-chart',
      toolbar: { show: false }, // 상단 툴바 숨김
      fontFamily: 'Pretendard, sans-serif',
      zoom: { enabled: false }
    },
    // [중요] 파이/도넛 차트는 'labels', 막대/선 차트는 'xaxis.categories'를 사용
    labels: isPie ? props.categories : [], 
    xaxis: {
      categories: isPie ? [] : props.categories, 
      axisBorder: { show: false },
      axisTicks: { show: false }
    },
    colors: props.colors,
    dataLabels: { enabled: false }, // 그래프 위 숫자 숨김 (깔끔하게)
    stroke: {
      curve: 'smooth',
      width: isPie ? 0 : 3 // 파이는 선 없음, 꺾은선은 두께 3
    },
    plotOptions: {
      bar: { borderRadius: 4, columnWidth: '50%' },
      pie: { donut: { size: '70%' } } // 도넛 두께 조절
    },
    grid: {
      borderColor: '#f1f1f1',
      padding: { top: 10 }
    },
    legend: { position: 'bottom' }
  };
});
</script>

<template>
  <div class="chart-card">
    <div class="chart-header">
      <h4>{{ title }}</h4>

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
        width="100%" 
        height="100%" 
        :type="chartType" 
        :options="chartOptions" 
        :series="series" 
      />
    </div>
  </div>
</template>

<style scoped>
.chart-card {
  background: white;
  border-radius: 16px; /* 둥글게 */
  padding: 24px;
  height: 100%;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
  display: flex;
  flex-direction: column;
  position: relative;
  transition: box-shadow 0.3s ease;
}

/* 카드에 마우스를 올렸을 때 그림자 효과 강화 */
.chart-card:hover {
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
  min-height: 28px; /* 버튼 공간 확보 */
}

.chart-header h4 {
  margin: 0;
  font-size: 1.15rem;
  font-weight: 700;
  color: #1f2937;
  /* 제목이 길어질 경우 말줄임표 처리 */
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* 컨트롤 버튼 그룹 */
.control-buttons {
  display: flex;
  gap: 6px;
  opacity: 0; /* 평소에는 숨김 */
  transition: opacity 0.2s ease-in-out;
}

/* 카드에 마우스 올렸을 때만 버튼 보이기 */
.chart-card:hover .control-buttons {
  opacity: 1;
}

/* 개별 버튼 스타일 */
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

/* 삭제 버튼 호버 시 빨간색 강조 */
.icon-btn.remove:hover {
  background-color: #fee2e2;
  color: #ef4444;
}

.chart-body {
  flex-grow: 1;
  min-height: 250px; /* 차트 최소 높이 확보 */
}
</style>