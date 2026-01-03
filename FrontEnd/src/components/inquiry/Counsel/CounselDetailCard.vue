<template>
  <div class="counsel-detail-card">
    <div class="card-title">
      <span class="title-text">{{ title || '상담 상세 정보' }}</span>
    </div>

    <div class="card-content">
      <div class="info-header">
        <div class="badge">
          <span class="badge-text">{{ category }}</span>
        </div>
        <div class="date">{{ date }}</div>
      </div>

      <div class="manager-info">
        <span class="manager-text">담당자: {{ manager }}</span>
      </div>

      <div class="description-box">
        <p class="description-text">{{ content }}</p>
      </div>

      <!-- Summary 표시 -->
      <div v-if="summary" class="additional-info">
        <div class="info-label">요약</div>
        <div class="info-content">{{ summary }}</div>
      </div>

      <!-- Follow Up 표시 -->
      <div v-if="followUp" class="additional-info">
        <div class="info-label">후속 조치</div>
        <div class="info-content">{{ followUp }}</div>
      </div>

      <!-- Churn Reason 표시 -->
      <div v-if="churnReason" class="additional-info churn">
        <div class="info-label">해지 사유</div>
        <div class="info-content">{{ churnReason }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  title: {
    type: String,
    default: ''
  },
  category: {
    type: String,
    default: '-'
  },
  date: {
    type: String,
    default: '-'
  },
  manager: {
    type: String,
    default: '-'
  },
  content: {
    type: String,
    default: '상담 내용이 없습니다.'
  },
  summary: {
    type: String,
    default: null
  },
  followUp: {
    type: String,
    default: null
  },
  churnReason: {
    type: String,
    default: null
  }
});
</script>

<style scoped>
.counsel-detail-card {
  width: 100%;
  padding: 20px;
  background: #EFF6FF;
  border-radius: 14px;
  border: 1px solid #DBEAFE;
  display: flex;
  flex-direction: column;
  gap: 12px;
  box-sizing: border-box;
  height: 100%;
  overflow-y: auto; /* 내용이 길어지면 스크롤 생성 */
}

.card-title {
  height: 20px;
  display: flex;
  align-items: center;
}

.title-text {
  color: #364153;
  font-size: 14px;
  font-weight: 600;
}

.card-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.info-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 24px;
}

.badge {
  padding: 4px 8px;
  background: #DBEAFE;
  border-radius: 4px;
  display: flex;
  align-items: center;
}

.badge-text {
  color: #1E40AF;
  font-size: 12px;
  font-weight: 500;
}

.date {
  color: #6B7280;
  font-size: 12px;
}

.manager-info {
  display: flex;
  align-items: center;
}

.manager-text {
  color: #4B5563;
  font-size: 12px;
}

.description-box {
  background-color: rgba(255, 255, 255, 0.6); /* 가독성을 위해 옅은 흰색 배경 추가 */
  padding: 12px;
  border-radius: 8px;
}

.description-text {
  color: #374151;
  font-size: 14px;
  line-height: 1.6;
  margin: 0;
  word-break: break-word;
  white-space: pre-wrap; /* [핵심] 줄바꿈 문자(\n)를 화면에 반영 */
}

/* 추가 정보 스타일 */
.additional-info {
  background-color: rgba(255, 255, 255, 0.8);
  padding: 12px;
  border-radius: 8px;
  border-left: 3px solid #3B82F6;
}

.additional-info.churn {
  border-left-color: #DC2626;
  background-color: rgba(254, 226, 226, 0.5);
}

.info-label {
  color: #6B7280;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 6px;
}

.info-content {
  color: #374151;
  font-size: 14px;
  line-height: 1.6;
  word-break: break-word;
  white-space: pre-wrap;
}
</style>