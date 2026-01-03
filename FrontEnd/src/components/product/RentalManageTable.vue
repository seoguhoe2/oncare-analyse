<template>
  <div class="rental-manage-table">
    <ProductSearchBar
      v-model:searchText="searchValue"
      v-model:selectedStatus="selectedStatus"
      :statusList="statusList"
      :placeholder="'수급자명 또는 담당자로 검색...'"
      @search="handleSearch"
    />

    <div class="table-wrapper">
      <table class="rental-table">
        <thead>
          <tr>
            <th>수급자</th>
            <th>계약담당자</th>
            <th>희망 시작일</th>
            <th>시작일</th>
            <th>종료일</th>
            <th>상태</th>
            <th>월 렌트비</th>
            <th>액션</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="!contracts.length">
            <td colspan="7" class="empty">
              등록된 렌탈 계약이 없습니다.
            </td>
          </tr>

          <tr
            v-for="item in visualItems"
            :key="item.id"
            class="clickable-row"
            :class="{ active: selectedId === item.id }"
            @click="handleRowClick(item)"
          >
            <td>{{ item.beneficiary }}</td>
            <td>{{ item.employee }}</td>
            <td>{{ item.wantedDate }}</td>
            <td>{{ item.startDate }}</td>
            <td>{{ item.endDate || '-' }}</td>
            <td>
              <span
                class="status-badge"
                :class="getClassId(item.statusName)"
              >
                {{ item.statusName }}
              </span>
            </td>
            <td>{{ formatCurrency(item.rentalAmount) }}</td>
            <td>
              <button class="manage-btn" @click.stop="openManageModal(item)">
                관리
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="pagination-controls" v-if="contracts.length > 0 || apiPage > 0">
      <button 
        class="page-btn" 
        :disabled="apiPage === 0"
        @click="prevPage"
      >
        &lt; 이전
      </button>
      
      <span class="page-info">{{ apiPage + 1 }} 페이지</span>

      <button 
        class="page-btn" 
        :disabled="!canGoNext"
        @click="nextPage"
      >
        다음 &gt;
      </button>
    </div>

    <RentalActionModal
      v-if="isManageModalOpen"
      :contract="targetContract"
      @close="isManageModalOpen = false"
      @refresh="handleRefresh"
    />

  </div>
</template>

<script setup>
import { ref, watch, onMounted , computed } from 'vue'
import ProductSearchBar from '@/components/product/ProductSearchBar.vue'
import { getRenal } from '@/api/product/rentalAPI'
import RentalActionModal from '@/components/product/RentalActionModal.vue';

const props = defineProps({
  statusList: {
    type: Array,
    default: () => []
  },
  selectedId: {
    type: [String, Number],
    default: null
  }
})

const emit = defineEmits(['row-click'])

// 로컬 상태 관리
const contracts = ref([]) 
const searchValue = ref('')
const selectedStatus = ref(0) // 전체(0)

// 페이징 관련
const isLastApiBatch = ref(false)
const apiPage = ref(0)
const pageSize = 5 // 페이지당 5개로 설정 
const totalItemCount = computed(() => contracts.value?.length ?? 0) // 전체 아이템 개수

// API 호출 (자식 컴포넌트 내부에서 수행)
const fetchApiBatch = async (pageIdx) => {
    
  try {
    const data = await getRenal({
      page: pageIdx,
      size: pageSize,
      beneficiaryOrEmployee: searchValue.value,
      ...(selectedStatus.value === 0 ? {} : { contractStatus: selectedStatus.value })
    })

    if (data && data.content) {
      contracts.value.push(...data.content); 
      isLastApiBatch.value = data.last
      apiPage.value = data.number

    } else {
      contracts.value = [];
      isLastApiBatch.value = true;
    }
  } catch (error) {
    console.error("렌탈 목록 조회 실패:", error)
    contracts.value = []
  }
}

// 검색 핸들러
const handleSearch = async () => {
  apiPage.value = 0
  isLastApiBatch.value = false
  contracts.value = [];
  emit('row-click', null) // 검색 시 선택 해제
  await fetchApiBatch(0)
}

// 이전 페이지
const prevPage = async () => {
  if (apiPage.value > 0) {
    --apiPage.value;
    // await fetchApiBatch(apiPage.value - 1);
  }
}

// 다음 페이지
const nextPage = async () => {
  if (!isLastApiBatch.value ) {
    await fetchApiBatch(++apiPage.value);
  } else if((apiPage.value + 1) * pageSize < contracts.value.length) {
    ++apiPage.value;
  }
}


const canGoNext = computed(() => {
    const hasMoreInMemory = (apiPage.value + 1) * pageSize < totalItemCount.value
    const hasMoreInServer = !isLastApiBatch.value

    return hasMoreInMemory || hasMoreInServer
})

const visualItems = computed(() => {
    if (!contracts.value || !Array.isArray(contracts.value)) {
        return [];
    }

    const start = apiPage.value * pageSize
    const end = start + pageSize
    
    return contracts.value.slice(start, end)
})

// 행 클릭 핸들러
const handleRowClick = (item) => {
  emit('row-click', item)
}

// 필터 변경 감지 -> 자동 검색
watch(selectedStatus, handleSearch)

// 마운트 시 초기 조회
onMounted(() => {
  fetchApiBatch(0)
})

// 유틸리티 함수들
const getClassId = (status) => {
  if(status === '유지') return 'status-active'
  if(status === '접수') return 'status-contract'
  if(status === '종료') return 'status-ended'
  return ''
}

const formatCurrency = (value) => {
  if (value == null) return '-'
  return `₩${value.toLocaleString()}`
}

watch(() => props.statusList, (newList) => {
  console.log("상태 리스트 업데이트:", newList);
}, { immediate: true });

// 모달 상태
const isManageModalOpen = ref(false);
const targetContract = ref(null);

const openManageModal = (item) => {
  targetContract.value = item;
  isManageModalOpen.value = true;
};

const handleRefresh = () => {
  // 목록 새로고침 (부모 함수 재사용)
  // emit('refresh')를 부모에게 보내거나, 여기서 직접 fetchApiBatch(0) 호출
  fetchApiBatch(apiPage.value); 
};
</script>

<style scoped>
/* 기존 스타일 유지 */
.rental-manage-table {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.table-wrapper {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
}

.rental-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;
}

.rental-table th {
  background-color: #f9fafb;
  padding: 14px 16px;
  font-weight: 600;
  color: #4b5563;
  text-align: left;
  border-bottom: 1px solid #e5e7eb;
}

.rental-table td {
  padding: 14px 16px;
  border-bottom: 1px solid #f3f4f6;
  color: #1f2937;
}

.rental-table tbody tr {
  cursor: pointer;
  transition: background-color 0.15s;
}

.rental-table tbody tr:hover {
  background-color: #f3f4f6;
}

.rental-table tbody tr.active {
  background-color: #f0fdf4;
}

.rental-table tbody tr.active td {
  font-weight: 500;
  color: #15803d;
}

.empty {
  text-align: center;
  color: #9ca3af;
  padding: 60px 0;
}

.status-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 48px;
  padding: 4px 12px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
}

.status-active { background: #dcfce7; color: #166534; }
.status-ended { background: #fee2e2; color: #991b1b; }
.status-contract { background: #f3f4f6; color: #374151; }

.history-btn {
  padding: 6px 12px;
  background-color: #ffffff;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 12px;
  color: #374151;
  cursor: pointer;
  transition: all 0.2s;
}

.history-btn:hover {
  background-color: #f9fafb;
  border-color: #9ca3af;
}

.pagination-controls { 
  display: flex; 
  justify-content: flex-end; 
  align-items: center; 
  gap: 12px; 
  padding: 0 16px; 
}
.page-btn { 
  padding: 6px 16px; 
  border: 1px solid #e5e7eb; 
  background-color: white; 
  border-radius: 6px; 
  font-size: 13px; 
  cursor: pointer; 
  color: #374151; 
  transition: all 0.2s; 
}
.page-btn:hover:not(:disabled) { 
  background-color: #f3f4f6; 
  border-color: #d1d5db; 
}
.page-btn:disabled { 
  opacity: 0.5; 
  cursor: not-allowed; 
  background-color: #f9fafb; 
}
.page-info { 
  font-size: 13px; 
  color: #6b7280; 
}


.manage-btn {
  padding: 4px 10px;
  background-color: #ffffff;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 12px;
  color: #374151;
  cursor: pointer;
  transition: all 0.2s;
}
.manage-btn:hover {
  background-color: #f3f4f6;
  border-color: #9ca3af;
  color: #111827;
}
</style>