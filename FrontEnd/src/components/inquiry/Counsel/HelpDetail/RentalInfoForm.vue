<template>
    <div class="rental-info-container">
    <div class="info-header">
      <div class="main-text">렌탈 계약 성사 가능성을 높일 수 있습니다</div>
      <div class="sub-text">렌탈 서비스 제공을 위한 필요 정보입니다</div>
    </div>

    <div class="questions-list">
      
      <div class="question-row border-bottom">
        <div class="question-text">거동이 불편하신가요?</div>
        <div class="answer-group">
          <div class="radio-item">
            <div class="radio-box"></div>
            <span class="label">예</span>
          </div>
          <div class="radio-item">
            <div class="radio-box"></div>
            <span class="label">아니요</span>
          </div>
        </div>
      </div>

      <div class="question-row border-bottom">
        <div class="question-text">휠체어를 사용하시나요?</div>
        <div class="answer-group">
          <div class="radio-item">
            <div class="radio-box"></div>
            <span class="label">예</span>
          </div>
          <div class="radio-item">
            <div class="radio-box"></div>
            <span class="label">아니요</span>
          </div>
        </div>
      </div>

      <div class="question-row border-bottom">
        <div class="question-text">목욕 중 불편한 요소가 존재하나요?</div>
        <div class="answer-group">
          <div class="radio-item">
            <div class="radio-box"></div>
            <span class="label">예</span>
          </div>
          <div class="radio-item">
            <div class="radio-box"></div>
            <span class="label">아니요</span>
          </div>
        </div>
      </div>

      <div class="question-row">
        <div class="question-text">거주 환경 중 불편한 요소가 존재하나요?</div>
        <div class="answer-group">
          <div class="radio-item">
            <div class="radio-box"></div>
            <span class="label">예</span>
          </div>
          <div class="radio-item">
            <div class="radio-box"></div>
            <span class="label">아니요</span>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>

</script>

<style scoped>
.rental-info-container {
  width: 100%;
  /* 고정 높이 제거 -> 내용에 따라 늘어남 */
  padding: 24px;
  background: #F9FAFB;
  border-radius: 14px;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: flex-start;
  gap: 24px;
  box-sizing: border-box; /* 패딩 포함 크기 계산 */
}

/* 헤더 */
.info-header {
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
  gap: 16px; /* 질문 사이 간격 */
}

.question-row {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding-bottom: 24px; /* 아래 여백 */
}

.question-row.border-bottom {
  border-bottom: 0.8px solid #E5E7EB;
  margin-bottom: 8px; /* 보더와 다음 요소 사이 간격 미세 조정 */
}

.question-text {
  color: #101828;
  font-size: 16px;
  font-family: 'Arimo', sans-serif;
  line-height: 24px;
}

/* 답변 그룹 (예/아니요) */
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

.radio-box {
  width: 16px;
  height: 16px;
  background: #F3F3F5;
  border: 0.8px solid rgba(0, 0, 0, 0.10);
  border-radius: 4px;
  box-shadow: 0px 1px 2px rgba(0, 0, 0, 0.05);
}

/* 선택된 상태 스타일 예시 (필요시 사용) */
/* .radio-box.checked { background: #00A63E; border-color: #00A63E; } */

.label {
  color: #0A0A0A;
  font-size: 14px;
  font-family: 'Arimo', sans-serif;
  line-height: 14px;
}
</style>