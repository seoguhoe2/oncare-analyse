<template>
  <div class="rental-page">
    <div class="manage-main">
      
      <RentalManageTable 
        v-if="contractStatusOptions.length > 0"
        :status-list="contractStatusOptions"
        :selected-id="selectedContract?.id"
        @row-click="handleContractSelect"
      />

      <div class="detail-filter-row">
        <ProductSearchBar
          v-if="itemStatusOptions.length > 0"
          v-model:selectedStatus="selectedItemStatus"
          :statusList="itemStatusOptions"
          :show-input="false"
        />
      </div>

      <RentalItemTable 
        v-if="selectedContract"
        :contract-id="selectedContract.id"
        :item-status-filter="selectedItemStatus"
      />
      
      <div v-else class="empty-detail-placeholder">
        상단 목록에서 계약을 선택하면 상세 렌탈 제품 현황이 표시됩니다.
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import RentalManageTable from '@/components/product/RentalManageTable.vue'
import RentalItemTable from '@/components/product/RentalItemTable.vue'
import ProductSearchBar from '@/components/product/ProductSearchBar.vue'
import { getContractStatus, getRentalStatus } from '@/api/product/rentalAPI'

const contractStatusOptions = ref([]) 
const itemStatusOptions = ref([])     
const selectedContract = ref(null)    
const selectedItemStatus = ref(0)     

onMounted(async () => {
  try {
    // 1. 계약 상태 로드 (상단 테이블용)
    const contractData = await getContractStatus()
    // 데이터 구조 확인: [{id:1, name:'...'}, ...] 형태여야 함
    contractStatusOptions.value = [{ id: 0, name: '전체' }, ...contractData]

    // 2. 제품 상태 로드 (하단 필터용)
    const itemData = await getRentalStatus()
    itemStatusOptions.value = [{ id: 0, name: '전체' }, ...itemData]
    
    console.log("옵션 로드 완료:", contractStatusOptions.value); // 로그 확인용
  } catch (error) {
    console.error("마스터 데이터 로드 실패", error);
  }
})

const handleContractSelect = (contract) => {
  selectedContract.value = contract
  selectedItemStatus.value = 0 
}
</script>

<style scoped>
/* 스타일은 기존 유지 */
.rental-page {
  padding: 24px 32px 32px;
  box-sizing: border-box;
  width: 100%;
}
.manage-main { width: 100%; }
.detail-filter-row {
  margin: 32px 0 12px;
  display: flex;
  justify-content: flex-end;
}
.empty-detail-placeholder {
  padding: 80px;
  text-align: center;
  background: #f9fafb;
  border: 1px dashed #e5e7eb;
  border-radius: 12px;
  color: #9ca3af;
  font-size: 14px;
}
</style>