<script setup>
import ChartCard from './ChartCard.vue';
</script>

<template>
  <ChartCard title="렌탈 장비 분포">
    <div class="pie-container">
      <div class="pie-chart"></div>
      <div class="labels">
        <span class="label item-1">휠체어: 45</span>
        <span class="label item-2">전동침대: 32</span>
        <span class="label item-3">보행기: 28</span>
        <span class="label item-4">욕창방지매트: 18</span>
        <span class="label item-5">기타: 12</span>
      </div>
    </div>
  </ChartCard>
</template>

<style scoped>
.pie-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 300px;
  position: relative;
}

/* CSS 원형 차트 (Conic Gradient 사용) */
.pie-chart {
  width: 200px;
  height: 200px;
  border-radius: 50%;
  background: conic-gradient(
    #4CAF50 0% 35%,   /* 휠체어 (녹색) */
    #42A5F5 35% 60%,  /* 전동침대 (파랑) */
    #FFA726 60% 80%,  /* 보행기 (주황) */
    #EF5350 80% 92%,  /* 매트 (빨강) */
    #AB47BC 92% 100%  /* 기타 (보라) */
  );
  position: relative;
}

/* 도넛 차트 효과를 위해 가운데 구멍 뚫기 (선택사항) */
.pie-chart::after {
  content: "";
  position: absolute;
  top: 50%; left: 50%;
  transform: translate(-50%, -50%);
  width: 0px; /* 도넛형을 원하면 값을 늘리세요 */
  height: 0px;
  background: white;
  border-radius: 50%;
}

/* 라벨 위치 (단순화를 위해 절대값 배치, 실제론 라이브러리 사용 권장) */
.label {
  position: absolute;
  font-size: 12px;
  font-weight: 500;
  color: #555;
}
.item-1 { top: 20px; right: 20%; color: #4CAF50; }
.item-2 { top: 80px; left: 15%; color: #42A5F5; }
.item-3 { bottom: 50px; left: 20%; color: #FFA726; }
.item-4 { bottom: 50px; right: 20%; color: #EF5350; }
.item-5 { top: 100px; right: 10%; color: #AB47BC; }
</style>