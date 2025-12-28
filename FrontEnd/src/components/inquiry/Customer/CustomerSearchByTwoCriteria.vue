<template>
  <div class="search-filter-card">
    <div class="filter-groups">
      
      <div class="dropdown-wrapper" @click="toggleDropdown('type')">
        <div class="dropdown-box" :class="{ active: openDropdown === 'type' }">
          <span class="selected-text">{{ filters.type || '고객 유형 선택' }}</span>
          <div class="arrow-down"></div>
        </div>
        <div v-if="openDropdown === 'type'" class="dropdown-menu">
          <div class="dropdown-item" @click.stop="selectOption('type', '잠재고객')">잠재고객</div>
          <div class="dropdown-item" @click.stop="selectOption('type', '기존고객')">기존고객</div>
        </div>
      </div>

      <div class="dropdown-wrapper" @click="toggleDropdown('status')">
        <div class="dropdown-box" :class="{ active: openDropdown === 'status' }">
          <span class="selected-text">{{ filters.status || '고객 상태 선택' }}</span>
          <div class="arrow-down"></div>
        </div>
        <div v-if="openDropdown === 'status'" class="dropdown-menu">
          <div class="dropdown-item" @click.stop="selectOption('status', '이탈고객')">이탈고객</div>
        </div>
      </div>

      <div class="dropdown-wrapper" @click="toggleDropdown('risk')">
        <div class="dropdown-box" :class="{ active: openDropdown === 'risk' }">
          <span class="selected-text">{{ filters.risk || '분류 기준 선택' }}</span>
          <div class="arrow-down"></div>
        </div>
        <div v-if="openDropdown === 'risk'" class="dropdown-menu">
          <div class="dropdown-item" @click.stop="selectOption('risk', '이탈징후 포착')">이탈징후 포착</div>
          <div class="dropdown-item" @click.stop="selectOption('risk', '계약 만료 임박')">계약 만료 임박</div>
        </div>
      </div>

      <div class="dropdown-wrapper" 
           :class="{ disabled: !filters.risk }" 
           @click="filters.risk && toggleDropdown('detail')">
        <div class="dropdown-box" :class="{ active: openDropdown === 'detail' }">
          <span class="selected-text">{{ filters.detail || '상세 상태 선택' }}</span>
          <div class="arrow-down"></div>
        </div>
        <div v-if="openDropdown === 'detail'" class="dropdown-menu">
          <div 
            v-for="option in dynamicDetailOptions" 
            :key="option" 
            class="dropdown-item" 
            @click.stop="selectOption('detail', option)"
          >
            {{ option }}
          </div>
        </div>
      </div>

    </div>

    <div class="search-box">
      <div class="search-icon">
        <div class="icon-ring"></div>
        <div class="icon-handle"></div>
      </div>
      <input type="text" class="search-input" placeholder="고객 이름 또는 전화번호로 검색" />
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue';

const filters = reactive({
  type: '',
  status: '',
  risk: '',
  detail: ''
});

const openDropdown = ref(null);

const toggleDropdown = (name) => {
  if (openDropdown.value === name) {
    openDropdown.value = null;
  } else {
    openDropdown.value = name;
  }
};

const selectOption = (key, value) => {
  filters[key] = value;
  openDropdown.value = null; // 선택 후 닫기

  // [로직] 3번(risk)이 변경되면 4번(detail) 초기화
  if (key === 'risk') {
    filters.detail = '';
  }
};

const dynamicDetailOptions = computed(() => {
  if (filters.risk === '이탈징후 포착') {
    return ['이탈위험기간도달', '컴플레인접수'];
  } else if (filters.risk === '계약 만료 임박') {
    return ['렌탈용품', '장기요양등급', '재가요양서비스'];
  }
  return [];
});
</script>

<style scoped>
.search-filter-card {
  background: white;
  border-radius: 14px;
  border: 1px solid #F3F4F6;
  box-shadow: 0px 1px 2px rgba(0,0,0,0.1);
  padding: 24px 38px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 24px;
  flex-wrap: wrap;
}

/* 필터 그룹 그리드 */
.filter-groups {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px 24px;
}

/* 드롭다운 래퍼 */
.dropdown-wrapper {
  position: relative;
  width: 260px; /* 기존 디자인에 맞춰 너비 설정 */
}

.dropdown-wrapper.disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 드롭다운 박스 디자인 */
.dropdown-box {
  border: 1px solid #E5E7EB;
  border-radius: 10px;
  padding: 8px 12px;
  font-size: 14px;
  color: #717182;
  cursor: pointer;
  background: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 40px;
  box-sizing: border-box;
}

.dropdown-box.active {
  border-color: #00A63E; /* 활성화 시 포인트 컬러 */
  color: #101828;
}

.selected-text {
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
}

/* 화살표 아이콘 */
.arrow-down {
  width: 0; 
  height: 0; 
  border-left: 5px solid transparent;
  border-right: 5px solid transparent;
  border-top: 5px solid #99A1AF;
}

/* 드롭다운 메뉴 리스트 */
.dropdown-menu {
  position: absolute;
  top: 105%;
  left: 0;
  width: 100%;
  background: white;
  border: 1px solid #E5E7EB;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  z-index: 20;
  overflow: hidden;
}

.dropdown-item {
  padding: 10px 12px;
  font-size: 14px;
  color: #333;
  cursor: pointer;
}

.dropdown-item:hover {
  background-color: #F3F4F6;
  color: #00A63E;
}

/* 검색창 */
.search-box {
  flex: 1;
  min-width: 300px;
  position: relative;
}

.search-input {
  width: 100%;
  height: 48px; /* 높이 약간 키움 */
  padding: 12px 40px 12px 40px; /* 아이콘 공간 확보 */
  background: #F3F3F5;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  color: #717182;
  outline: none;
  box-sizing: border-box;
}

/* 검색 아이콘 */
.search-icon {
  position: absolute;
  left: 14px;
  top: 50%;
  transform: translateY(-50%);
  width: 16px;
  height: 16px;
}

.icon-ring {
  width: 10px; height: 10px;
  border: 1.5px solid #99A1AF;
  border-radius: 50%;
  position: absolute; top: 0; left: 0;
}

.icon-handle {
  width: 3px; height: 3px;
  border-top: 1.5px solid #99A1AF;
  position: absolute; bottom: 1px; right: 1px;
  transform: rotate(45deg);
}
</style>