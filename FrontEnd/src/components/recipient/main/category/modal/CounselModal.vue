<template>
  <div v-if="modelValue" class="modal-backdrop" @click.self="close">
    <div class="modal-panel">
      <!-- 헤더 -->
      <header class="modal-header">
        <div class="title-row">
          <h3>상담 이력 상세</h3>
          <button type="button" class="close-btn" @click="close">✕</button>
        </div>

        <!-- ✅ 상담 카테고리 배지 -->
        <div class="category-row">
          <span class="category-pill">
            {{ counselType }}
          </span>
        </div>

        <!-- 기본 정보 -->
        <div class="info-grid">
          <div class="info-item">
            <div class="label">상담 날짜</div>
            <div class="value">{{ counsel?.date || '-' }}</div>
          </div>
          <div class="info-item">
            <div class="label">참석 가족</div>
            <div class="value">{{ counsel?.family || '-' }}</div>
          </div>
          <div class="info-item">
            <div class="label">요양보호사</div>
            <div class="value">{{ counsel?.careWorker || '-' }}</div>
          </div>
          <div class="info-item">
            <div class="label">수급자</div>
            <div class="value">{{ counsel?.beneficiary || '-' }}</div>
          </div>
        </div>
      </header>

      <!-- 본문 -->
      <section class="modal-body" v-if="counsel">
        <div class="section-block">
          <div class="section-title">방문 목적</div>
          <div class="textarea-box">
            {{ counsel.purpose || '예: 서비스 만족도 확인 및 추가 요구사항 파악' }}
          </div>
        </div>

        <div class="section-block">
          <div class="section-title">주요 논의사항</div>
          <div class="textarea-box">
            {{ counsel.mainDiscussion || '상담 중 논의된 주요 사항을 입력하세요' }}
          </div>
        </div>

        <div class="section-block">
          <div class="section-title">합의 사항</div>
          <div class="textarea-box">
            {{ counsel.agreement || '합의된 사항, 향후 계획 등을 입력하세요' }}
          </div>
        </div>

        <div class="section-block">
          <div class="section-title">다음 방문 예정일</div>
          <div class="textarea-box">
            {{ counsel.nextVisit || '연도-월-일' }}
          </div>
        </div>
      </section>

      <!-- 푸터 -->
      <footer class="modal-footer">
        <button type="button" class="primary-btn" @click="close">
          닫기
        </button>
      </footer>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  counsel: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['update:modelValue'])

const close = () => {
  emit('update:modelValue', false)
}

// 보호자상담 / 면담 / 초기상담 등
const counselType = computed(() => props.counsel?.type || '보호자상담')
</script>

<style scoped>
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 50;
}

.modal-panel {
  width: 520px;
  max-height: 90vh;
  background: #ffffff;
  border-radius: 18px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 40px rgba(15, 23, 42, 0.25);
}

/* 헤더 영역 */
.modal-header {
  padding: 16px 20px 18px;
  background: #ffffff;
}

.title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.title-row h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #166534;
}
.close-btn {
  border: none;
  background: transparent;
  font-size: 18px;
  cursor: pointer;
  color: #6b7280;
}

/* ✅ 카테고리 배지 */
.category-row {
  margin-bottom: 10px;
}
.category-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 4px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
  background: #d1fae5; /* 연한 초록 */
  color: #15803d;      /* 진한 초록 */
}

/* 기본 정보 영역 */
.info-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px 16px;
  margin-top: 4px;
  padding: 10px 12px;
  border-radius: 12px;
  background: #f9fafb;
}
.info-item .label {
  font-size: 11px;
  color: #6b7280;
  margin-bottom: 2px;
}
.info-item .value {
  font-size: 13px;
  color: #111827;
}

/* 본문 */
.modal-body {
  padding: 16px 20px 12px;
  flex: 1;
  overflow-y: auto;
}
.section-block + .section-block {
  margin-top: 12px;
}
.section-title {
  font-size: 12px;
  font-weight: 600;
  margin-bottom: 6px;
  color: #111827;
}
.textarea-box {
  min-height: 60px;
  border-radius: 10px;
  border: 1px solid #e5e7eb;
  padding: 8px 10px;
  font-size: 12px;
  background: #ffffff;
  color: #374151;
  white-space: pre-wrap;
}

/* 푸터 */
.modal-footer {
  padding: 12px 20px 16px;
  border-top: 1px solid #e5e7eb;
}
.primary-btn {
  width: 100%;
  border-radius: 999px;
  padding: 10px 0;
  border: none;
  font-size: 14px;
  font-weight: 600;
  background: #3b82f6;
  color: #ffffff;
  cursor: pointer;
}

@media (max-width: 540px) {
  .modal-panel {
    width: 94vw;
  }
}
</style>
