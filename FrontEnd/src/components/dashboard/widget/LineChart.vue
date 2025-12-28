<script setup>
import ChartCard from './ChartCard.vue';
</script>

<template>
  <ChartCard title="월별 서비스 현황">
    <div class="chart-placeholder">
      <div class="y-axis">
        <span>1000</span><span>750</span><span>500</span><span>250</span><span>0</span>
      </div>
      <div class="graph-area">
        <svg viewBox="0 0 1000 200" class="line-svg">
          <polyline points="0,100 200,80 400,90 600,60 800,50 1000,40" fill="none" stroke="#42a5f5" stroke-width="3" />
        </svg>
        <svg viewBox="0 0 1000 200" class="line-svg secondary">
          <polyline points="0,180 200,175 400,180 600,170 800,168 1000,165" fill="none" stroke="#66bb6a" stroke-width="3" />
        </svg>
        <div class="x-axis">
          <span>6월</span><span>7월</span><span>8월</span><span>9월</span><span>10월</span><span>11월</span>
        </div>
      </div>
    </div>
    <div class="legend">
      <span class="dot blue"></span>서비스 건수
      <span class="dot green"></span>서비스 시간
    </div>
  </ChartCard>
</template>

<style scoped>
.chart-placeholder {
  display: flex;
  height: 300px;
  position: relative;
}
.y-axis {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  color: #999;
  font-size: 12px;
  padding-right: 10px;
}
.graph-area {
  flex-grow: 1;
  border-left: 1px solid #eee;
  border-bottom: 1px solid #eee;
  position: relative;
}
.line-svg {
  position: absolute;
  width: 100%;
  height: 100%;
  bottom: 0;
  left: 0;
}
.x-axis {
  position: absolute;
  bottom: -25px;
  width: 100%;
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #666;
}
.legend {
  display: flex;
  justify-content: center;
  gap: 15px;
  margin-top: 10px;
  font-size: 13px;
  color: #666;
}
.dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  display: inline-block;
  margin-right: 5px;
}
.blue { background: #42a5f5; }
.green { background: #66bb6a; }
</style>