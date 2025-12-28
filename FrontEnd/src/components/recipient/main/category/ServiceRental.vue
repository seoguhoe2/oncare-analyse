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

    <!-- ✅ 서비스 내역 -->
    <ServiceView
      v-if="activeSubTab === 'service'"
      :key="`service-${beneficiaryId}`"
      :beneficiary-id="beneficiaryId"
    />

    <!-- ✅ 렌탈 용품 -->
    <RentalView
      v-else
      :key="`rental-${beneficiaryId}`"
      :beneficiary-id="beneficiaryId"
    />
  </div>
</template>

<script setup>
import { ref,watch } from 'vue'
import ServiceView from './servicerental/Service.vue'
import RentalView from './servicerental/Rental.vue'

const props = defineProps({
  beneficiaryId: { type: Number, default: null },
  refreshKey: Number})

const subTabs = [
  { key: 'service', label: '서비스 내역' },
  { key: 'rental', label: '렌탈 용품' }
]
const activeSubTab = ref('service')

/*  수급자 정보 변경 감지 */
watch(
  () => props.refreshKey,
  () => {
    // 하위 View들이 beneficiaryId 기준으로 fetch 하므로
    // 여기서는 탭만 유지
    console.log('[ServiceRental] refresh')
  }
)
</script>

<style scoped>
.service-subtabs {
  display: flex;
  gap: 24px;
  border-bottom: 1px solid #e5e7eb;
  margin-bottom: 12px;
}

.service-subtab-btn {
  position: relative;
  border: none;
  background: transparent;
  padding: 8px 0;
  font-size: 13px;
  color: #6b7280;
  cursor: pointer;
}

.service-subtab-btn.active {
  color: #16a34a;
  font-weight: 600;
}

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
