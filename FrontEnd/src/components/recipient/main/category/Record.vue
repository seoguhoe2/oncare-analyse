<template>
  <div class="record-tab">
    <!-- 상단 세부 탭 -->
    <div class="subtab-bar">
      <button
        v-for="tab in subTabs"
        :key="tab.key"
        type="button"
        class="subtab-btn"
        :class="{ active: activeSubTab === tab.key }"
        @click="activeSubTab = tab.key"
      >
        {{ tab.label }}
      </button>
    </div>

    <!-- 요약일지 -->
    <SummaryRecord v-if="activeSubTab === 'summary'" />

    <!-- 기초평가 -->
    <BasicTest v-else />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import SummaryRecord from './record/SummaryRecord.vue'
import BasicTest from './record/BasicTest.vue'

const subTabs = [
  { key: 'summary', label: '요약일지' },
  { key: 'baseline', label: '기초평가' }
]
const activeSubTab = ref('summary')
</script>

<style>
/* 상단 서브탭 영역 */
.subtab-bar {
  display: flex;
  gap: 24px;
  border-bottom: 1px solid #e5e7eb;
  margin-bottom: 12px;
}

/* 서브탭 버튼 기본 */
.subtab-btn {
  position: relative;
  border: none;
  background: transparent;
  padding: 8px 0;
  font-size: 13px;
  color: #6b7280;
  cursor: pointer;
}

/* 활성 탭 */
.subtab-btn.active {
  color: #16a34a;
  font-weight: 600;
}

/* 활성 탭 언더라인 */
.subtab-btn.active::after {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  bottom: -1px;
  height: 2px;
  background-color: #16a34a;
  border-radius: 999px;
}
</style>