<template>
  <div class="service-tab">
    <!-- 세부 탭 -->
    <div class="service-subtabs">
      <button
        v-for="tab in subTabs"
        :key="tab.key"
        type="button"
        class="service-subtab-btn"
        :class="{ active: activeSubTab === tab.key }"
        @click="activeSubTab = tab.key"
      >
        {{ tab.label }}
      </button>
    </div>

    <!-- 서비스 내역 -->
    <ServiceView
      v-if="activeSubTab === 'service'"
      :service-history="serviceHistory"
    />

    <!-- 렌탈 용품 -->
    <RentalView
      v-else
      :rental-items="rentalItems"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import ServiceView from './servicerental/Service.vue'
import RentalView from './servicerental/Rental.vue'

const props = defineProps({
  serviceHistory: {
    type: Array,
    default: () => []
  },
  rentalItems: {
    type: Array,
    default: () => []
  }
})

const subTabs = [
  { key: 'service', label: '서비스 내역' },
  { key: 'rental', label: '렌탈 용품' }
]
const activeSubTab = ref('service')
</script>

<style scoped>
/* 서브탭 전체 영역 */
.service-subtabs {
  display: flex;
  gap: 24px;
  border-bottom: 1px solid #e5e7eb;
  margin-bottom: 12px;
}

/* 서브탭 버튼 기본 */
.service-subtab-btn {
  position: relative;
  border: none;
  background: transparent;
  padding: 8px 0;
  font-size: 13px;
  color: #6b7280;
  cursor: pointer;
}

/* 활성 탭 */
.service-subtab-btn.active {
  color: #16a34a;      /* 초록 텍스트 */
  font-weight: 600;
}

/* 활성 탭 언더라인 */
.service-subtab-btn.active::after {
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