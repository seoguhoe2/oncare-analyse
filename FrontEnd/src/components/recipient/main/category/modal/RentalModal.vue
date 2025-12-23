<template>
  <!-- 바깥 영역 클릭 시 닫힘 -->
  <div v-if="modelValue" class="modal-backdrop" @click.self="close">
    <div class="modal-panel" :class="{ current: isCurrent, past: !isCurrent }">
      <!-- 헤더 -->
      <header class="modal-header">
        <div class="title-row">
          <h3>렌탈 용품 상세</h3>
          <button class="close-btn" type="button" @click="close">✕</button>
        </div>

        <div class="item-row">
          <div class="item-name">
            <span class="item-icon">📦</span>
            <span>{{ item?.name }}</span>
          </div>
          <span
            class="status-pill"
            :class="isCurrent ? 'using' : 'done'"
          >
            {{ statusLabel }}
          </span>
        </div>
      </header>

      <!-- 본문 -->
      <section class="modal-body" v-if="item">
        <!-- 계약 정보 -->
        <section class="section-block">
          <h4>계약 정보</h4>
          <div class="grid-2">
            <div class="field">
              <div class="label">계약 번호</div>
              <div class="value">{{ item.code }}</div>
            </div>
            <div class="field">
              <div class="label">계약 체결일</div>
              <div class="value">{{ item.contractDate || item.startDate || '-' }}</div>
            </div>
            <div class="field">
              <div class="label">공급업체</div>
              <div class="value">{{ item.vendor || '메디케어' }}</div>
            </div>
            <div class="field">
              <div class="label">월 렌탈료</div>
              <div class="value">{{ formatCurrency(item.amount) }}</div>
            </div>
          </div>
        </section>

        <!-- 사용 기간 -->
        <section class="section-block">
          <h4>사용 기간</h4>
          <div class="grid-2">
            <div class="field">
              <div class="label">시작일</div>
              <div class="value">{{ item.startDate || '-' }}</div>
            </div>
            <div class="field">
              <div class="label">
                {{ isCurrent ? '만료일' : '반납일' }}
              </div>
              <div class="value">{{ item.endDate || item.returnDate || '-' }}</div>
            </div>
          </div>

          <!-- 현재 계약일 때만 안내 배너 -->
          <div v-if="isCurrent" class="info-banner">
            <span class="dot"></span>
            <span>
              계약 만료
              <strong>{{ item.remainingDays ?? '—' }}일</strong> 전과
              <strong>{{ durationLabel }}</strong> 기준으로 안내됩니다.
            </span>
          </div>
        </section>

        <!-- 비용 정보 -->
        <section class="section-block">
          <h4>비용 정보</h4>
          <div class="cost-box">
            <div class="cost-row">
              <span class="label">사용 기간</span>
              <span class="value">
                {{ durationLabel }}
              </span>
            </div>
            <div class="cost-row">
              <span class="label">월 렌탈료</span>
              <span class="value">{{ formatCurrency(item.amount) }}</span>
            </div>
            <div class="cost-row total">
              <span class="label">총 비용</span>
              <span class="value">
                {{ formatCurrency(item.totalAmount || (item.amount || 0) * (item.durationMonths || item.count || 1)) }}
              </span>
            </div>
          </div>
        </section>

        <!-- 비고 -->
        <section class="section-block">
          <h4>비고</h4>
          <textarea
            class="memo-input"
            rows="2"
            :value="item.memo || ''"
            readonly
          />
        </section>
      </section>

      <!-- 푸터 버튼 -->
      <footer class="modal-footer">
        <button
          v-if="isCurrent"
          type="button"
          class="primary-btn danger"
          @click="onCompleteClick"
        >
          계약 완료로 변경
        </button>
        <button
          v-else
          type="button"
          class="primary-btn"
          @click="close"
        >
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
  // 선택된 렌탈 아이템
  item: {
    type: Object,
    default: null
  },
  // 'current' | 'past'
  type: {
    type: String,
    default: 'current'
  }
})

const emit = defineEmits(['update:modelValue', 'complete'])

const isCurrent = computed(() => props.type === 'current')

const statusLabel = computed(() => {
  if (!props.item) return ''
  // 없으면 기본 라벨
  return props.item.status || (isCurrent.value ? '사용중' : '반납완료')
})

const durationLabel = computed(() => {
  const item = props.item || {}
  if (item.durationLabel) return item.durationLabel
  if (item.durationMonths) return `${item.durationMonths}개월`
  if (item.count) return `${item.count}개월`
  return ''
})

const formatCurrency = (n) =>
  (n ?? 0).toLocaleString('ko-KR') + '원'

const close = () => {
  emit('update:modelValue', false)
}

const onCompleteClick = () => {
  // 부모에게 완료 이벤트 전달 (상태 변경 로직은 부모에서 처리)
  emit('complete', props.item)
  emit('update:modelValue', false)
}
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
  box-shadow: 0 20px 40px rgba(15, 23, 42, 0.25);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 타입별 헤더 배경 */
.modal-panel.current .modal-header {
  background: #ecfdf3;
}
.modal-panel.past .modal-header {
  background: #f9fafb;
}

.modal-header {
  padding: 16px 20px 14px;
  border-bottom: 1px solid #e5e7eb;
}

.title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}

.title-row h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
}

.close-btn {
  border: none;
  background: transparent;
  font-size: 18px;
  cursor: pointer;
  color: #6b7280;
}

.item-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.item-name {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-weight: 500;
}

.item-icon {
  width: 28px;
  height: 28px;
  border-radius: 999px;
  background: #ffffff;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.status-pill {
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 500;
}
.status-pill.using {
  background-color: #dcfce7;
  color: #15803d;
}
.status-pill.done {
  background-color: #e5e7eb;
  color: #4b5563;
}

.modal-body {
  padding: 18px 20px 12px;
  flex: 1;
  overflow-y: auto;
}

.section-block + .section-block {
  margin-top: 16px;
}

.section-block h4 {
  margin: 0 0 8px;
  font-size: 13px;
  font-weight: 600;
  color: #111827;
}

.grid-2 {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px 16px;
}

.field .label {
  font-size: 11px;
  color: #6b7280;
  margin-bottom: 2px;
}
.field .value {
  font-size: 13px;
  color: #111827;
}

.info-banner {
  margin-top: 10px;
  padding: 8px 10px;
  border-radius: 10px;
  background-color: #eef2ff;
  font-size: 11px;
  display: flex;
  align-items: center;
  gap: 6px;
  color: #4f46e5;
}
.info-banner .dot {
  width: 6px;
  height: 6px;
  border-radius: 999px;
  background-color: #4f46e5;
}

.cost-box {
  border-radius: 12px;
  background: #f9fafb;
  padding: 10px 12px;
  font-size: 12px;
}
.cost-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}
.cost-row:last-child {
  margin-bottom: 0;
}
.cost-row .label {
  color: #6b7280;
}
.cost-row .value {
  font-weight: 500;
}
.cost-row.total .label {
  font-weight: 600;
}
.cost-row.total .value {
  font-weight: 700;
}

.memo-input {
  width: 100%;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
  padding: 8px 10px;
  font-size: 12px;
  resize: none;
  background: #f9fafb;
}

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
  background: #2563eb;
  color: #ffffff;
  cursor: pointer;
}
.primary-btn.danger {
  background: #dc2626;
}

@media (max-width: 540px) {
  .modal-panel {
    width: 94vw;
  }
}
</style>
