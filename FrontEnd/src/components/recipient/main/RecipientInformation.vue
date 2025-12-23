<!-- src/components/recipient/RecipientInformation.vue -->
<template>
  <div v-if="recipient" class="card">
    <div class="detail-header">
      <div>
        <div class="name-row">
          <h3>{{ recipient.name }}</h3>
          <span class="badge risk" :class="riskClass(recipient.risk)">
            {{ recipient.risk }}
          </span>
          <span class="badge state">서비스 중</span>
        </div>
        <p class="small">
          {{ recipient.careLevel }}등급 | 만료일:
          {{ recipient.registeredAt }}
        </p>
      </div>
    </div>

    <!-- 상단 기본 정보 -->
    <div class="detail-body">
      <div class="detail-col">
        <div class="info-row">
          <span class="info-label">📅 생년월일</span>
          <span class="info-value">{{ recipient.birth }}</span>
        </div>
        <div class="info-row">
          <span class="info-label">📍 주소</span>
          <span class="info-value">{{ recipient.address }}</span>
        </div>
        <div class="info-row">
          <span class="info-label">👨‍👩‍👧 보호자</span>
          <span class="info-value">
            {{ recipient.guardianName }} ({{ recipient.guardianRelation }})
          </span>
        </div>
      </div>

      <div class="detail-col">
        <div class="info-row">
          <span class="info-label">📞 연락처</span>
          <span class="info-value">{{ recipient.phone }}</span>
        </div>
        <div class="info-row">
          <span class="info-label">🧑‍⚕️ 담당 요양보호사</span>
          <span class="info-value">{{ recipient.careWorker }}</span>
        </div>
        <div class="info-row">
          <span class="info-label">📱 보호자 연락처</span>
          <span class="info-value">{{ recipient.guardianPhone }}</span>
        </div>
      </div>
    </div>

    <!-- 월 지급금 바 -->
    <div class="benefit-wrapper">
      <div class="benefit-bar-top">
        <span>월 지급금</span>
        <span class="amount">{{ formatCurrency(recipient.limitAmount) }}</span>
      </div>
      <div class="benefit-bar">
        <div
          class="benefit-fill used"
          :style="{ width: usedPercent + '%' }"
        ></div>
        <div
          class="benefit-fill remain"
          :style="{ width: remainPercent + '%' }"
        ></div>
      </div>
      <div class="benefit-bar-bottom">
        <span>사용액 {{ formatCurrency(recipient.usedAmount) }}</span>
        <span>잔액 {{ formatCurrency(remainingAmount) }}</span>
        <span>{{ usedPercent.toFixed(1) }}%</span>
      </div>
    </div>

    <!-- 하단 : 태그 / 위험 요소 두 컬럼 -->
    <div class="bottom-tags">
      <!-- 태그 -->
      <div class="tag-section">
        <div class="tag-title">태그</div>
        <div class="chip-row" v-if="recipient.tags?.length">
          <span
            v-for="chip in recipient.tags"
            :key="chip"
            class="chip chip-disease"
          >
            {{ chip }}
          </span>
        </div>
      </div>

      <!-- 위험 요소 -->
      <div class="tag-section">
        <div class="tag-title">위험 요소</div>
        <div class="chip-row" v-if="recipient.riskTags?.length">
          <span
            v-for="chip in recipient.riskTags"
            :key="chip"
            class="chip chip-risk"
          >
            {{ chip }}
          </span>
        </div>
      </div>
    </div>
  </div>

  <div v-else class="card empty">
    수급자를 선택하면 상세 정보를 확인할 수 있습니다.
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  recipient: {
    type: Object,
    default: null
  }
})

const remainingAmount = computed(() => {
  if (!props.recipient) return 0
  return props.recipient.limitAmount - props.recipient.usedAmount
})
const usedPercent = computed(() => {
  if (!props.recipient) return 0
  const { usedAmount, limitAmount } = props.recipient
  return Math.min(100, (usedAmount / limitAmount) * 100)
})
const remainPercent = computed(() => 100 - usedPercent.value)

const formatCurrency = (n) =>
  (n ?? 0).toLocaleString('ko-KR') + '원'

const riskClass = (risk) => ({
  'risk-high': risk === '고위험',
  'risk-mid': risk === '중위험',
  'risk-low': risk === '저위험'
})
</script>

<style scoped>
.card {
  background-color: #fff;
  border-radius: 12px;
  padding: 14px 16px;
  box-shadow: 0 0 0 1px rgba(15, 23, 42, 0.04);
}
.empty {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 160px;
  color: #9ca3af;
  font-size: 14px;
}
.detail-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}
.name-row {
  display: flex;
  align-items: center;
  gap: 6px;
}
.name-row h3 {
  margin: 0;
  font-size: 18px;
}
.small {
  margin: 2px 0 0;
  font-size: 12px;
  color: #9ca3af;
}

.detail-body {
  display: flex;
  gap: 32px;
  margin-top: 10px;
}
.detail-col {
  flex: 1;
}
.info-row {
  display: flex;
  margin-bottom: 4px;
  font-size: 12px;
}
.info-label {
  width: 120px;
  color: #6b7280;
}
.info-value {
  flex: 1;
}

/* 급여 바 */
.benefit-wrapper {
  margin-top: 14px;
}
.benefit-bar-top {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 4px;
}
.benefit-bar-top .amount {
  font-weight: 600;
}
.benefit-bar {
  width: 100%;
  height: 18px;
  border-radius: 999px;
  overflow: hidden;
  display: flex;
  background-color: #f3f4f6;
}
.benefit-fill.used {
  background-color: #a7f3d0;
}
.benefit-fill.remain {
  background-color: #dcfce7;
}
.benefit-bar-bottom {
  display: flex;
  justify-content: space-between;
  margin-top: 4px;
  font-size: 11px;
  color: #6b7280;
}

/* 배지 */
.badge {
  padding: 2px 8px;
  border-radius: 999px;
  font-size: 10px;
}
.risk-high {
  background-color: #fee2e2;
  color: #b91c1c;
}
.risk-mid {
  background-color: #fef3c7;
  color: #92400e;
}
.risk-low {
  background-color: #e0f2fe;
  color: #1d4ed8;
}
.state {
  background-color: #dcfce7;
  color: #15803d;
}

/* 하단 태그 / 위험요인 섹션 */
.bottom-tags {
  margin-top: 14px;
  display: flex;
  gap: 32px;
}
.tag-section {
  flex: 1;
}
.tag-title {
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 6px;
}
.chip-row {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

/* 칩 공통 */
.chip {
  padding: 2px 8px;
  border-radius: 999px;
  font-size: 10px;
  border: 1px solid transparent;
}

/* 태그 칩 (보라 톤) */
.chip-disease {
  background-color: #f3e8ff;
  color: #6b21a8;
  border-color: #e9d5ff;
}

/* 위험 요인 칩 (연한 빨강 톤) */
.chip-risk {
  background-color: #fee2e2;
  color: #b91c1c;
  border-color: #fecaca;
}

@media (max-width: 960px) {
  .detail-body {
    flex-direction: column;
  }
  .bottom-tags {
    flex-direction: column;
  }
}
</style>
