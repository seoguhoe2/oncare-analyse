<template>
  <div v-if="modelValue" class="modal-backdrop" @click.self="close">
    <div class="modal-panel">
      <!-- 헤더 -->
      <header class="modal-header">
        <div class="title-row">
          <h3>상담 이력 상세</h3>
          <button type="button" class="close-btn" @click="close">✕</button>
        </div>

        <!-- 카테고리 배지: 값 있을 때만 -->
        <div class="category-row" v-if="detail?.counselingType">
          <span class="category-pill">
            {{ detail.counselingType }}
          </span>
        </div>

        <!-- 기본 정보 -->
        <div class="info-grid">
          <div class="info-item">
            <div class="label">상담 날짜</div>
            <div class="value">{{ detail?.counselingDate || '-' }}</div>
          </div>

          <div class="info-item" v-if="detail?.attendees">
            <div class="label">참석 가족</div>
            <div class="value">{{ detail.attendees }}</div>
          </div>

          <div class="info-item" v-if="detail?.careWorkerName">
            <div class="label">요양보호사</div>
            <div class="value">{{ detail.careWorkerName }}</div>
          </div>

          <div class="info-item" v-if="detail?.beneficiaryName">
            <div class="label">수급자</div>
            <div class="value">{{ detail.beneficiaryName }}</div>
          </div>
        </div>
      </header>

      <!-- 본문 -->
      <section class="modal-body">
        <div v-if="loading" class="loading-text">상세 정보를 불러오는 중...</div>

        <template v-else>
          <div v-if="errorMsg" class="error-box">
            {{ errorMsg }}
          </div>

          <!-- visitPurpose: 값 있을 때만 -->
          <div class="section-block" v-if="detail?.visitPurpose">
            <div class="section-title">방문 목적</div>
            <div class="textarea-box">{{ detail.visitPurpose }}</div>
          </div>

          <!-- discussionContent: 값 있을 때만 -->
          <div class="section-block" v-if="detail?.discussionContent">
            <div class="section-title">주요 논의사항</div>
            <div class="textarea-box">{{ detail.discussionContent }}</div>
          </div>

          <!-- agreementContent: 값 있을 때만 -->
          <div class="section-block" v-if="detail?.agreementContent">
            <div class="section-title">합의 사항</div>
            <div class="textarea-box">{{ detail.agreementContent }}</div>
          </div>

          <!-- nextVisitDate: 값 있을 때만 -->
          <div class="section-block" v-if="detail?.nextVisitDate">
            <div class="section-title">다음 방문 예정일</div>
            <div class="textarea-box">{{ detail.nextVisitDate }}</div>
          </div>

          <!-- 아무 내용도 없을 때 -->
          <div v-if="!hasAnyDetail && !errorMsg" class="empty-detail">
            표시할 상세 내용이 없습니다.
          </div>
        </template>
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
import { ref, computed, watch } from 'vue'
import api from '@/lib/api'

const props = defineProps({
  modelValue: { type: Boolean, default: false },

  // ✅ 모달이 직접 상세조회에 필요한 값만 받음
  beneficiaryId: { type: [Number, String], required: true },
  counselingId: { type: [Number, String], default: null }
})

const emit = defineEmits(['update:modelValue'])

const detail = ref(null)
const loading = ref(false)
const errorMsg = ref('')

const close = () => {
  emit('update:modelValue', false)
}

// ✅ 상세 조회
const fetchDetail = async () => {
  if (!props.modelValue) return
  if (!props.beneficiaryId || !props.counselingId) return

  loading.value = true
  errorMsg.value = ''
  detail.value = null

  try {
    const { data } = await api.get(
      `/api/beneficiaries/${props.beneficiaryId}/counselings/${props.counselingId}`
    )
    detail.value = data
  } catch (e) {
    console.error('상담 상세 조회 실패:', e)
    errorMsg.value = '상담 상세 정보를 불러오지 못했습니다.'
  } finally {
    loading.value = false
  }
}

// ✅ 모달이 열릴 때 / counselingId가 바뀔 때 자동 조회
watch(
  () => [props.modelValue, props.counselingId, props.beneficiaryId],
  ([open]) => {
    if (open) fetchDetail()
  },
  { immediate: true }
)

const hasAnyDetail = computed(() => {
  const c = detail.value
  if (!c) return false
  return !!(c.visitPurpose || c.discussionContent || c.agreementContent || c.nextVisitDate)
})
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

/* 헤더 */
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

/* 카테고리 배지 */
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
  background: #d1fae5;
  color: #15803d;
}

/* 기본 정보 */
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

.loading-text {
  font-size: 12px;
  color: #6b7280;
  padding: 10px 2px;
}

.empty-detail {
  margin-top: 8px;
  padding: 12px;
  border-radius: 12px;
  background: #f9fafb;
  color: #6b7280;
  font-size: 12px;
}

.error-box {
  padding: 12px;
  border-radius: 12px;
  background: #fef2f2;
  color: #991b1b;
  font-size: 12px;
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
