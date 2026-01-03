<template>
  <div class="process-section">
    <div class="stepper-container">
      <div 
        class="step-item active clickable" 
        @click="selectComponent(NewPotentialRegist)"
      >
        <div class="step-circle orange">1</div>
        <div class="step-label active-text">신규접수</div>
      </div>
      <div class="step-line"></div>
      
      <div class="step-item">
        <div class="step-circle gray">2</div>
        <div class="step-label">등급확인</div>
      </div>
      <div class="step-line"></div>

      <div class="step-item">
        <div class="step-circle gray">3</div>
        <div class="step-label">사전정보</div>
      </div>
      <div class="step-line"></div>

      <div class="step-item">
        <div class="step-circle gray">4</div>
        <div class="step-label">계약완료</div>
      </div>
      <div class="step-line"></div>

      <div class="step-item active">
        <div class="step-circle gray">5</div>
        <div class="step-label">계약진행</div>
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
import { shallowRef } from 'vue';
import NewPotentialRegist from '@/components/inquiry/Counsel/Process/subscript/NewPotentialRegist.vue';


const currentComponent = shallowRef(null);

// 컴포넌트 변경 함수
const selectComponent = (component) => {
  // 이미 열려있는 걸 다시 누르면 닫기 기능 (선택사항 logic)
  if (currentComponent.value === component) {
    currentComponent.value = null;
  } else {
    currentComponent.value = component;
  }
};

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

/* [추가] 클릭 가능한 아이템 스타일 */
.step-item.clickable {
  cursor: pointer;
  transition: transform 0.2s;
}

.step-item.clickable:hover {
  transform: translateY(-2px); /* 살짝 위로 떠오르는 효과 */
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

/* [추가] 컴포넌트 렌더링 영역 스타일 */
.component-view-area {
  margin-top: 20px;
  padding: 20px;
  border: 1px solid #E5E7EB;
  border-radius: 12px;
  background-color: #fff;
  /* 부드러운 등장을 위한 애니메이션 효과 (선택사항) */
  animation: fadeIn 0.3s ease-in-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

@media (max-width: 1200px) {
  .process-section { width: 100%; }
  .stepper-container { overflow-x: auto; padding-bottom: 10px; }
}
</style>