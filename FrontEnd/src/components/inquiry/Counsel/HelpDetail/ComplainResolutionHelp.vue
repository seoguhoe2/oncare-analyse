<template>
  <div class="complain-help-container">
    <div class="help-header">
      <div class="main-text">고객 컴플레인 해결에 도움이 될 수 있습니다.</div>
      <div class="sub-text">컴플레인 대응에 있어 도움이 될 만한 정보입니다</div>
    </div>

    <div class="questions-list">
      
      <div class="question-row border-bottom">
        <div class="question-text">동물 털 알레르기가 존재하나요?</div>
        <div class="answer-group">
          <div class="radio-item" @click="setAnswer('allergy', 'yes')">
            <div class="radio-box" :class="{ checked: answers.allergy === 'yes' }">
              <div v-if="answers.allergy === 'yes'" class="check-mark"></div>
            </div>
            <span class="label">예</span>
          </div>
          <div class="radio-item" @click="setAnswer('allergy', 'no')">
            <div class="radio-box" :class="{ checked: answers.allergy === 'no' }">
              <div v-if="answers.allergy === 'no'" class="check-mark"></div>
            </div>
            <span class="label">아니요</span>
          </div>
        </div>
      </div>

      <div class="question-row border-bottom">
        <div class="question-text">서비스 제공에 있어 요양사와의 성격이 우선되나요?</div>
        <div class="answer-group">
          <div class="radio-item" @click="setAnswer('personality', 'yes')">
            <div class="radio-box" :class="{ checked: answers.personality === 'yes' }">
              <div v-if="answers.personality === 'yes'" class="check-mark"></div>
            </div>
            <span class="label">예</span>
          </div>
          <div class="radio-item" @click="setAnswer('personality', 'no')">
            <div class="radio-box" :class="{ checked: answers.personality === 'no' }">
              <div v-if="answers.personality === 'no'" class="check-mark"></div>
            </div>
            <span class="label">아니요</span>
          </div>
        </div>
      </div>

      <div class="question-row">
        <div class="question-text">서비스 제공에 있어 금액적 요소가 우선되나요?</div>
        <div class="answer-group">
          <div class="radio-item" @click="setAnswer('cost', 'yes')">
            <div class="radio-box" :class="{ checked: answers.cost === 'yes' }">
              <div v-if="answers.cost === 'yes'" class="check-mark"></div>
            </div>
            <span class="label">예</span>
          </div>
          <div class="radio-item" @click="setAnswer('cost', 'no')">
            <div class="radio-box" :class="{ checked: answers.cost === 'no' }">
              <div v-if="answers.cost === 'no'" class="check-mark"></div>
            </div>
            <span class="label">아니요</span>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

// 각 질문에 대한 답변 상태 관리 (기본값: null)
const answers = ref({
  allergy: null,
  personality: null,
  cost: null
});

// 답변 선택 함수
const setAnswer = (questionKey, value) => {
  answers.value[questionKey] = value;
};
</script>

<style scoped>
.complain-help-container {
  width: 100%;
  padding: 24px;
  background: #F9FAFB;
  border-radius: 14px;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: flex-start;
  gap: 24px;
  box-sizing: border-box;
}

/* 헤더 */
.help-header {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.main-text {
  color: #101828;
  font-size: 16px;
  font-family: 'Arimo', sans-serif;
  line-height: 24px;
}

.sub-text {
  color: #6A7282;
  font-size: 14px;
  font-family: 'Arimo', sans-serif;
  line-height: 20px;
}

/* 리스트 */
.questions-list {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.question-row {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding-bottom: 24px;
}

.question-row.border-bottom {
  border-bottom: 0.8px solid #E5E7EB;
  margin-bottom: 8px;
}

.question-text {
  color: #101828;
  font-size: 16px;
  font-family: 'Arimo', sans-serif;
  line-height: 24px;
}

/* 답변 그룹 */
.answer-group {
  display: flex;
  gap: 24px;
}

.radio-item {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
}

/* 체크박스 디자인 (파란색 테마 적용 가능) */
.radio-box {
  width: 16px;
  height: 16px;
  background: #F3F3F5;
  border: 0.8px solid rgba(0, 0, 0, 0.10);
  border-radius: 4px;
  box-shadow: 0px 1px 2px rgba(0, 0, 0, 0.05);
  display: flex;
  justify-content: center;
  align-items: center;
}

/* 선택되었을 때 스타일 */
.radio-box.checked {
  background: #3B82F6; /* 파란색 */
  border-color: #3B82F6;
}

.check-mark {
  width: 4px;
  height: 8px;
  border: solid white;
  border-width: 0 2px 2px 0;
  transform: rotate(45deg);
  margin-bottom: 2px;
}

.label {
  color: #0A0A0A;
  font-size: 14px;
  font-family: 'Arimo', sans-serif;
  line-height: 14px;
}
</style>