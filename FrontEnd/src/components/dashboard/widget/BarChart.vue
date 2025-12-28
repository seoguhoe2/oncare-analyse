<script setup>
import ChartCard from './ChartCard.vue';
</script>

<template>
  <ChartCard title="주간 서비스 제공 현황">
    <div class="bar-chart-container">
      <div class="bars">
        <div class="bar-group" v-for="day in ['월', '화', '수', '목', '금', '토', '일']" :key="day">
          <div class="bar" :style="{ height: getHeight(day) }"></div>
          <span class="day-label">{{ day }}</span>
        </div>
      </div>
      <div class="y-lines">
        <div class="line" v-for="i in 5" :key="i"></div>
      </div>
    </div>
  </ChartCard>
</template>

<script>
// 간단한 높이 랜덤/지정 로직
const heights = { '월': '60%', '화': '80%', '수': '50%', '목': '75%', '금': '65%', '토': '20%', '일': '10%' };
const getHeight = (day) => heights[day];
</script>

<style scoped>
.bar-chart-container {
  height: 300px;
  position: relative;
  display: flex;
  align-items: flex-end;
  padding: 0 20px 30px 20px; /* 축 공간 확보 */
}

.bars {
  width: 100%;
  display: flex;
  justify-content: space-around;
  align-items: flex-end;
  height: 100%;
  z-index: 2;
}

.bar-group {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 40px;
  height: 100%;
  justify-content: flex-end;
}

.bar {
  width: 100%;
  background-color: #66bb6a; /* 이미지의 녹색 */
  border-radius: 4px 4px 0 0;
  transition: height 0.5s ease;
}

.day-label {
  margin-top: 10px;
  font-size: 12px;
  color: #666;
}

/* 배경 그리드 라인 */
.y-lines {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 30px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  z-index: 1;
}

.line {
  width: 100%;
  height: 1px;
  background-color: #f0f0f0;
  border-top: 1px dashed #e0e0e0;
}
</style>