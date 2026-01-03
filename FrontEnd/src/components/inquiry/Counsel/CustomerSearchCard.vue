<template>
  <div class="search-container">
    <div class="card-header">
      <div class="header-title">고객 검색</div>
    </div>
    
    <div class="search-controls">
      <div class="search-input-box">
        <div class="search-icon">
          <div class="icon-ring"></div>
          <div class="icon-handle"></div>
        </div>
        <input 
          type="text" 
          class="search-input" 
          placeholder="고객명, 전화번호로 검색..." 
          v-model="searchKeyword"
          @keyup.enter="onEnterKey"
        />
      </div>
      
      <button class="search-btn" @click="handleSearch">검색</button>

      <div class="filter-dropdown" @click="toggleDropdown">
        <span class="selected-text">{{ selectedFilter }}</span>
        <div class="arrow-down"></div>
        
        <div v-if="isDropdownOpen" class="dropdown-menu">
          <div class="dropdown-item" @click.stop="selectFilter('전체 유형')">전체 유형</div>
          <div class="dropdown-item" @click.stop="selectFilter('잠재고객')">잠재고객</div>
          <div class="dropdown-item" @click.stop="selectFilter('기존고객')">기존고객</div>
          <div class="dropdown-item" @click.stop="selectFilter('이탈고객')">이탈고객</div>
        </div>
      </div>
    </div>

    <div class="list-body customer-list">
      <div v-if="isLoading" class="no-result">검색 중...</div>

      <div v-else-if="filteredList.length === 0" class="no-result">
        검색 결과가 없습니다.
      </div>

      <div 
        v-else
        v-for="customer in filteredList" 
        :key="`${customer.customerId}-${customer.customerType}`"
        class="list-item"
        :class="{ 
          'active': isCustomerSelected(customer)
        }"
        @click="selectCustomer(customer)"
      >
        <div class="item-content">
          <span class="name">{{ customer.name }}</span>
          
          <span class="badge" :class="{
            'yellow': customer.customerCategoryName === '잠재고객',
            'green': customer.customerCategoryName === '기존고객',
            'red': customer.customerCategoryName === '이탈고객'
          }">{{ customer.customerCategoryName }}</span>
          
          <div class="info-cell">
            <svg class="icon-svg" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
            </svg>
            <span class="text">{{ customer.phone }}</span>
          </div>

          <div class="info-cell">
            <svg class="icon-svg" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            <span class="text">{{ customer.lastDate }}</span>
          </div>
          
          <span class="count">상담 {{ customer.count }}회</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { searchCustomers } from '@/api/inquiry/counselApi.js';

// --- 상태 관리 ---
const isDropdownOpen = ref(false);
const selectedFilter = ref('전체 유형');

const searchKeyword = ref(''); 
const customerList = ref([]); 
const isLoading = ref(false);
const selectedCustomer = ref(null);

const emit = defineEmits(['select-customer']); 

const toggleDropdown = () => {
  isDropdownOpen.value = !isDropdownOpen.value;
};

const selectFilter = (filterName) => {
  selectedFilter.value = filterName;
  isDropdownOpen.value = false;
};

// --- 백엔드 통신 로직 ---
const handleSearch = async () => {
  try {
    isLoading.value = true;
    const response = await searchCustomers(searchKeyword.value);
    
    console.log('🔍 검색 응답:', response.data);
    
    customerList.value = response.data.map(item => ({
      customerId: item.customerId,           
      name: item.name,               
      customerCategoryName: item.customerCategoryName ? item.customerCategoryName.trim() : '잠재고객',
      phone: item.phone,             
      lastDate: item.consultDate ? item.consultDate.toString().split('T')[0] : '-', 
      count: item.consultCount,
      customerType: item.customerType,
      stages: item.stages || [],
      guardianName: item.guardianName,
      guardianPhone: item.guardianPhone
    }));
    
    console.log('✅ 매핑된 고객 목록:', customerList.value);
    
    // 검색 후 선택 초기화
    selectedCustomer.value = null;
    emit('select-customer', null);

  } catch (error) {
    console.error('고객 검색 실패:', error);
    customerList.value = [];
  } finally {
    isLoading.value = false;
  }
};

const filteredList = computed(() => {
  if (selectedFilter.value === '전체 유형') {
    return customerList.value;
  }
  return customerList.value.filter(c => c.customerCategoryName === selectedFilter.value);
});

// 고객이 선택되었는지 확인
const isCustomerSelected = (customer) => {
  if (!selectedCustomer.value) return false;
  
  return selectedCustomer.value.customerId === customer.customerId && 
         selectedCustomer.value.customerType === customer.customerType;
};

const selectCustomer = (customer) => {
  console.log('🎯 고객 선택:', customer);
  
  // 이미 선택된 고객을 다시 클릭하면 선택 해제
  if (isCustomerSelected(customer)) {
    console.log('❌ 선택 해제');
    selectedCustomer.value = null;
    emit('select-customer', null);
  } else {
    console.log('✅ 새로운 고객 선택');
    selectedCustomer.value = customer;
    emit('select-customer', customer);
  }
};

const onEnterKey = () => {
  handleSearch();
};

onMounted(() => {
  handleSearch();
});
</script>

<style scoped>
/* 전체 컨테이너 */
.search-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

/* --- 헤더 스타일 --- */
.card-header {
  padding: 16px;
  display: flex;
  align-items: center;
  min-height: 60px;
  box-sizing: border-box;
}

.header-title {
  color: #388E3C;
  font-size: 20px;
  font-weight: 600;
  line-height: 28px;
}

/* --- 검색 컨트롤 영역 --- */
.search-controls {
  padding: 0 16px 12px 16px;
  display: flex;
  gap: 8px;
  border-bottom: 1px solid #E5E7EB;
}

.search-input-box {
  position: relative;
  flex: 1;
}

.search-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  width: 16px;
  height: 16px;
}

.icon-ring {
  width: 10px; height: 10px;
  border: 1.33px solid #99A1AF;
  border-radius: 50%;
  position: absolute; top: 0; left: 0;
}

.icon-handle {
  width: 3px; height: 3px;
  border-top: 1.33px solid #99A1AF;
  position: absolute; bottom: 1px; right: 1px;
  transform: rotate(45deg);
}

.search-input {
  width: 100%;
  height: 40px;
  padding: 8px 16px 8px 40px;
  border-radius: 8px;
  border: 1px solid #E5E7EB;
  font-size: 14px;
  color: #2E3440;
  outline: none;
  box-sizing: border-box;
}
.search-input::placeholder { color: rgba(46, 52, 64, 0.5); }

.search-btn {
  height: 40px;
  padding: 0 16px;
  background-color: #388E3C; 
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  white-space: nowrap; 
  transition: background-color 0.2s;
}

.search-btn:hover {
  background-color: #2E7D32; 
}

/* --- 필터 드롭다운 스타일 --- */
.filter-dropdown {
  position: relative;
  width: 120px;
  height: 40px;
  background: white;
  border: 1px solid #CCCCCC;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 12px;
  cursor: pointer;
  box-sizing: border-box;
}

.selected-text {
  font-size: 14px;
  color: #6F6F6F;
  font-family: 'Noto Sans KR', sans-serif;
}

.arrow-down {
  width: 0; height: 0;
  border-left: 5px solid transparent;
  border-right: 5px solid transparent;
  border-top: 5px solid black;
}

.dropdown-menu {
  position: absolute;
  top: 105%;
  left: 0;
  width: 100%;
  background: white;
  border: 1px solid #E5E7EB;
  border-radius: 6px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  z-index: 10;
  overflow: hidden;
}

.dropdown-item {
  padding: 10px 12px;
  font-size: 14px;
  color: #333;
}
.dropdown-item:hover {
  background-color: #F3F4F6;
  color: #388E3C;
}

/* --- 리스트 영역 --- */
.list-body {
  flex: 1;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  overflow-y: auto;
}

.list-item {
  padding: 11px;
  border-radius: 10px;
  border: 1px solid #E5E7EB;
  cursor: pointer;
  transition: all 0.2s;
}
.list-item:hover { border-color: #00C950; }
.list-item.active { background: #F0FDF4; border-color: #00C950; }

.item-content { display: flex; align-items: center; gap: 12px; font-size: 14px; }
.name { color: #008236; font-weight: 500; min-width: 50px; }
.badge { padding: 2px 8px; border-radius: 4px; font-size: 12px; white-space: nowrap; }
.badge.yellow { background: #FEF9C2; color: #A65F00; }
.badge.green { background: #DCFCE7; color: #008236; }
.badge.red { background: #FEE2E2; color: #DC2626; }

.info-cell { display: flex; align-items: center; gap: 4px; color: #4A5565; flex: 1; }

.icon-svg {
  width: 14px; height: 14px;
  color: #4A5565;
}

.text { color: #4A5565; font-size: 12px; line-height: 16px; }
.count { color: #6A7282; font-size: 12px; margin-left: auto; }
.no-result { padding: 20px; text-align: center; color: #999; font-size: 14px; }
</style>
