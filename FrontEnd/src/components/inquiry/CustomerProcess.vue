<template>
  <div class="process-section">
    <div class="stepper-container">
      <div class="step-item completed">
        <div class="step-circle"><span class="check-icon"></span></div>
        <div class="step-label">신규접수</div>
      </div>
      <div class="step-line completed"></div>
      
      <div class="step-item completed">
        <div class="step-circle"><span class="check-icon"></span></div>
        <div class="step-label">등급확인</div>
      </div>
      <div class="step-line completed"></div>

      <div class="step-item completed">
        <div class="step-circle"><span class="check-icon"></span></div>
        <div class="step-label">사전정보</div>
      </div>
      <div class="step-line completed"></div>

      <div class="step-item completed">
        <div class="step-circle"><span class="check-icon"></span></div>
        <div class="step-label">계약완료</div>
      </div>
      <div class="step-line completed"></div>

      <div class="step-item active">
        <div class="step-circle orange">5</div>
        <div class="step-label active-text">계약진행</div>
      </div>
      <div class="step-line"></div>

      <div class="step-item">
        <div class="step-circle gray">6</div>
        <div class="step-label gray-text">계약종료</div>
      </div>
    </div>

    <div class="progress-container">
      <div class="progress-header">
        <span class="label">계약 진행 현황</span>
        <span class="percentage">80%</span>
      </div>
      <div class="progress-track">
        <div class="progress-fill" style="width: 80%"></div>
      </div>
    </div>
  </div>
</template>

<script setup>

</script>

<style scoped>
.process-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.stepper-container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
}

.step-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  position: relative;
  z-index: 1;
}

.step-circle {
  width: 48px; height: 48px;
  border-radius: 50%;
  display: flex; justify-content: center; align-items: center;
  font-size: 16px; font-weight: 500; color: white;
}

.step-item.completed .step-circle {
  background: #00C950;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.check-icon {
  width: 16px; height: 11px;
  border-bottom: 2px solid white;
  border-left: 2px solid white;
  transform: rotate(-45deg) translate(2px, -2px);
  display: block;
}

.step-circle.orange { background: #FF8A3C; }
.step-circle.gray { background: #E5E7EB; color: #99A1AF; }

.step-label { font-size: 14px; color: #101828; white-space: nowrap; }
.step-label.active-text { color: #101828; font-weight: 600; }
.step-label.gray-text { color: #99A1AF; }

.step-line {
  flex: 1;
  height: 2px;
  background: #E5E7EB;
  margin: 0 10px;
  transform: translateY(-14px);
}
.step-line.completed { background: #00C950; }

.progress-container {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.progress-header {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
}

.percentage { color: #2B7FFF; font-weight: 600; }

.progress-track {
  width: 100%;
  height: 12px;
  background: #F3F4F6;
  border-radius: 999px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #2B7FFF 0%, #51A2FF 100%);
  border-radius: 999px;
}

@media (max-width: 1200px) {
  .process-section { width: 100%; }
  .stepper-container { overflow-x: auto; padding-bottom: 10px; }
}
</style>