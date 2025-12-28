<!-- src/components/recipient/main/category/modal/InquiryModal.vue -->
<template>
  <div v-if="modelValue" class="modal-backdrop" @click.self="close">
    <div class="modal-panel">
      <!-- 헤더 -->
      <header class="modal-header">
        <div class="title-row">
          <h3>문의 이력 상세</h3>
          <button type="button" class="close-btn" @click="close">✕</button>
        </div>

        <div class="info-wrapper">
          <!-- ✅ 문의 유형 배지: summary 사용(정기상담 등) -->
          <div class="badge-row" v-if="detail?.summary">
            <span class="type-pill">
              {{ detail.summary }}
            </span>
          </div>

          <!-- 기본 정보 -->
          <div class="info-grid">
            <div class="info-item">
              <div class="label">상담 날짜</div>
              <div class="value">{{ detail?.consultDate || '-' }}</div>
            </div>

            <!-- ✅ 상담 시간 제거 -->

            <div class="info-item">
              <div class="label">상담사</div>
              <div class="value">{{ detail?.counselorName || '-' }}</div>
            </div>

            <div class="info-item">
              <div class="label">수급자</div>
              <div class="value">{{ detail?.beneficiaryName || '-' }}</div>
            </div>
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

          <!-- ✅ 상담 내용: detail -->
          <div class="section-block" v-if="detail?.detail">
            <div class="section-title">상담 내용</div>
            <div class="textarea-box">
              {{ detail.detail }}
            </div>
          </div>

          <!-- ✅ 후속 조치: followUp -->
          <div class="section-block" v-if="detail?.followUp">
            <div class="section-title">후속 조치</div>
            <div class="followup-box">
              {{ detail.followUp }}
            </div>
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

  beneficiaryId: { type: [Number, String], required: true },
  counselHistoryId: { type: [Number, String], default: null }
})

const emit = defineEmits(['update:modelValue'])

const detail = ref(null)
const loading = ref(false)
const errorMsg = ref('')

const close = () => {
  emit('update:modelValue', false)
}

// ✅ 상세 조회 API만
const fetchDetail = async () => {
  if (!props.modelValue) return
  if (!props.beneficiaryId || !props.counselHistoryId) return

  loading.value = true
  errorMsg.value = ''
  detail.value = null

  try {
    const { data } = await api.get(
      `/api/beneficiaries/${props.beneficiaryId}/counsel-histories/${props.counselHistoryId}`
    )
    detail.value = data
  } catch (e) {
    console.error('문의이력 상세 조회 실패:', e)
    errorMsg.value = '문의이력 상세 정보를 불러오지 못했습니다.'
  } finally {
    loading.value = false
  }
}

// ✅ 모달 열릴 때 / id 변경될 때 자동 조회
watch(
  () => [props.modelValue, props.counselHistoryId, props.beneficiaryId],
  ([open]) => {
    if (open) fetchDetail()
  },
  { immediate: true }
)

const hasAnyDetail = computed(() => {
  const c = detail.value
  if (!c) return false
  return !!(c.detail || c.followUp)
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
  width: 480px;
  max-height: 90vh;
  background: #ffffff;
  border-radius: 18px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 40px rgba(15, 23, 42, 0.25);
}

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
  color: #111827;
}
.close-btn {
  border: none;
  background: transparent;
  font-size: 18px;
  cursor: pointer;
  color: #6b7280;
}

.info-wrapper {
  padding: 10px 12px;
  border-radius: 12px;
  background: #f9fafb;
}

.badge-row {
  margin-bottom: 8px;
}
.type-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  padding: 3px 10px;
  font-size: 11px;
  background: #bbf7d0;
  color: #15803d;
  font-weight: 600;
}

.info-grid {
  margin-top: 4px;
  border-radius: 12px;
  background: #f9fafb;
  padding: 10px 12px;
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px 16px;
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
  min-height: 70px;
  border-radius: 10px;
  border: 1px solid #e5e7eb;
  padding: 8px 10px;
  font-size: 12px;
  background: #ffffff;
  color: #374151;
  white-space: pre-wrap;
}
.followup-box {
  min-height: 40px;
  border-radius: 10px;
  padding: 8px 10px;
  font-size: 12px;
  background: #fef9c3;
  border: 1px solid #fde68a;
  color: #854d0e;
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
