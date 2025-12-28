<!-- src/components/recipient/main/RecipientCategory.vue -->
<template>
  <div class="card">
    <!-- 상단 탭 -->
    <nav class="bottom-tabs">
      <button
        v-for="tab in tabs"
        :key="tab.key"
        type="button"
        class="bottom-tab-btn"
        :class="{ active: activeTab === tab.key }"
        @click="activeTab = tab.key"
      >
        {{ tab.label }}
      </button>
    </nav>

    <!-- 탭 컨텐츠 -->
    <div class="bottom-content">
      <!-- 일정 관리 -->
      <Calender
        v-if="activeTab === 'calender'"
        :beneficiary-id="beneficiaryId"
        :refresh-key="refreshKey"
      />

      <!-- 서비스 / 렌탈 -->
      <ServiceRental
        v-else-if="activeTab === 'service'"
        :beneficiary-id="beneficiaryId"
        :refresh-key="refreshKey"
      />

      <!-- 기록 관리 -->
      <Record
        v-else-if="activeTab === 'record'"
        :monthly-summary-list="monthlySummaryList"
        :beneficiary-id="beneficiaryId"
        :refresh-key="refreshKey"
      />

      <!-- 상담 -->
      <Counsel
        v-else-if="activeTab === 'counsel'"
        :beneficiary-id="beneficiaryId"
        :refresh-key="refreshKey"
      />

      <!-- 문의 이력 -->
      <Inquiry
        v-else-if="activeTab === 'inquiry'"
        :beneficiary-id="beneficiaryId"
        :refresh-key="refreshKey"
      />

      <!-- 서류 관리 -->
      <Document
        v-else-if="activeTab === 'document'"
        :beneficiary-id="beneficiaryId"
        :refresh-key="refreshKey"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, watch  } from 'vue'

import Calender from '@/components/recipient/main/category/Calender.vue'
import ServiceRental from '@/components/recipient/main/category/ServiceRental.vue'
import Record from '@/components/recipient/main/category/Record.vue'
import Inquiry from '@/components/recipient/main/category/Inquiry.vue'
import Counsel from '@/components/recipient/main/category/Counsel.vue'
import Document from '@/components/recipient/main/category/Document.vue'

const props = defineProps({
  beneficiaryId: { type: Number, default: null },
  refreshKey: Number,   // 하위 탭들이 새로고침 없이 수급자 정보 변경되면 자동 반영
  monthlySummaryList: { type: Array, default: () => [] }
})

const tabs = [
  { key: 'calender', label: '일정 관리' },
  { key: 'service', label: '서비스/렌탈' },
  { key: 'record', label: '기록 관리' },
  { key: 'counsel', label: '상담' },
  { key: 'inquiry', label: '문의이력' },
  { key: 'document', label: '서류관리' }
]

const activeTab = ref('calender')

/*  수급자 정보 변경 감지 */
watch(
  () => props.refreshKey,
  () => {
    // 탭은 유지, 내부 컴포넌트들만 새로 반응하게
    console.log('수급자 정보 변경 감지')
  }
)

</script>

<style scoped>
.card {
  background-color: #fff;
  border-radius: 12px;
  padding: 14px 16px;
  box-shadow: 0 0 0 1px rgba(15, 23, 42, 0.04);
}
.bottom-tabs {
  display: flex;
  gap: 24px;
  border-bottom: 1px solid #e5e7eb;
  margin: 0 -16px 8px;
  padding: 0 16px;
}
.bottom-tab-btn {
  position: relative;
  border: none;
  background: transparent;
  padding: 10px 0 8px;
  font-size: 13px;
  cursor: pointer;
  color: #6b7280;
  border-radius: 0;
}
.bottom-tab-btn.active {
  background: transparent;
  color: #16a34a;
  font-weight: 600;
}
.bottom-tab-btn.active::after {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  bottom: -1px;
  height: 2px;
  background-color: #16a34a;
  border-radius: 999px;
}
.bottom-content {
  font-size: 13px;
  padding-top: 8px;
}
</style>
