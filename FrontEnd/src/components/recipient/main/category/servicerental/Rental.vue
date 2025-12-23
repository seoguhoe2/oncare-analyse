<!-- src/components/recipient/category/servicerental/Rental.vue -->
<template>
  <div class="rental-wrapper">
    <!-- 현재 사용 중인 용품 -->
    <section class="rental-section current">
      <div class="rental-header">
        <h4>현재 사용 중인 용품</h4>
        <span class="rental-count">
          총 {{ currentRentalItems.length }}개
        </span>
      </div>
      <ul class="svc-card-list">
        <li
          v-for="item in currentRentalItems"
          :key="item.code"
          class="svc-card rental-card current"
          @click="openModal(item, 'current')"
        >
          <div class="svc-left">
            <span class="pill code-pill">{{ item.code }}</span>
            <span class="svc-name">{{ item.name }}</span>
            <span class="pill status-pill using">
              {{ item.status || '계약중' }}
            </span>
          </div>
          <div class="svc-right">
            <span class="rental-meta">
              {{ item.startDate || item.period }}
            </span>
            <span class="svc-amount">
              {{ formatCurrency(item.amount) }}
            </span>
            <span class="pill month-pill">
              {{ item.durationLabel || (item.count ? item.count + '개월' : '') }}
            </span>
            <span class="svc-status">
              {{ item.memo || '1년 계약' }}
            </span>
          </div>
        </li>
      </ul>
    </section>

    <!-- 과거 렌탈 이력 -->
    <section class="rental-section past">
      <div class="rental-header">
        <h4>과거 렌탈 이력</h4>
        <span class="rental-count">
          총 {{ pastRentalItems.length }}개
        </span>
      </div>
      <ul class="svc-card-list">
        <li
          v-for="item in pastRentalItems"
          :key="item.code"
          class="svc-card rental-card"
          @click="openModal(item, 'past')"
        >
          <div class="svc-left">
            <span class="pill code-pill">{{ item.code }}</span>
            <span class="svc-name">{{ item.name }}</span>
            <span class="pill status-pill done">
              {{ item.status || '계약완료' }}
            </span>
          </div>
          <div class="svc-right">
            <span class="rental-meta">
              {{ item.startDate || item.period }}
            </span>
            <span class="svc-amount">
              {{ formatCurrency(item.amount) }}
            </span>
            <span class="pill month-pill">
              {{ item.durationLabel || (item.count ? item.count + '개월' : '') }}
            </span>
            <span class="svc-status">
              {{ item.memo || '' }}
            </span>
          </div>
        </li>
      </ul>
    </section>

    <!-- ✅ 모달 -->
    <RentalModal
      v-model="showModal"
      :item="selectedRental"
      :type="selectedType"
      @complete="handleComplete"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import RentalModal from '../modal/RentalModal.vue'

const props = defineProps({
  rentalItems: {
    type: Array,
    default: () => []
  }
})

const showModal = ref(false)
const selectedRental = ref(null)
const selectedType = ref('current')

const currentRentalItems = computed(() =>
  props.rentalItems.filter((item) => item.status === '계약중' || item.status === '사용중')
)
const pastRentalItems = computed(() =>
  props.rentalItems.filter((item) => item.status === '계약완료' || item.status === '반납완료')
)

const formatCurrency = (n) =>
  (n ?? 0).toLocaleString('ko-KR') + '원'

const openModal = (item, type) => {
  selectedRental.value = item
  selectedType.value = type
  showModal.value = true
}

const handleComplete = (item) => {
  // 여기서 계약 완료 처리(API 호출 등) 넣으면 됨
  console.log('계약 완료로 변경 클릭:', item)
}
</script>

<style scoped>
.rental-wrapper {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

/* 공통 카드 스타일 (Service.vue와 동일) */
.svc-card-list {
  list-style: none;
  margin: 0;
  padding: 0;
}
.svc-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 10px;
  border-radius: 10px;
  background-color: #f9fafb;
  font-size: 12px;
  margin-bottom: 6px;
  cursor: pointer;
}
.svc-card:hover {
  background-color: #e5f2ff;
}
.svc-left {
  display: flex;
  align-items: center;
  gap: 8px;
}
.svc-right {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 11px;
}
.svc-name {
  font-weight: 500;
}
.svc-amount {
  font-weight: 600;
}
.svc-status {
  color: #6b7280;
}

/* pill 공통 */
.pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  padding: 2px 8px;
  font-size: 11px;
}
.code-pill {
  background-color: #f3e8ff;
  color: #7c3aed;
}
.month-pill {
  background-color: #eef2ff;
  color: #4f46e5;
}
.status-pill.using {
  background-color: #dcfce7;
  color: #15803d;
}
.status-pill.done {
  background-color: #e5e7eb;
  color: #4b5563;
}

.rental-section.current .svc-card {
  background-color: #ecfdf3;
}
.rental-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 4px 2px 6px;
}
.rental-header h4 {
  margin: 0;
  font-size: 13px;
}
.rental-count {
  font-size: 11px;
  color: #6b7280;
}
.rental-meta {
  color: #6b7280;
  font-size: 11px;
}

@media (max-width: 1200px) {
  .svc-card {
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
  }
  .svc-right {
    flex-wrap: wrap;
    justify-content: flex-start;
  }
}
</style>
