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
        <input type="text" class="search-input" placeholder="고객명, 전화번호로 검색..." />
      </div>
      
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
      <div class="list-item">
        <div class="item-content">
          <span class="name">홍길동</span>
          <span class="badge yellow">잠재고객</span>
          <div class="info-cell">
            <span class="icon-sq"></span>
            <span class="text">010-9999-0000</span>
          </div>
          <div class="info-cell">
            <span class="icon-sq-sm"></span>
            <span class="text">2024-11-20</span>
          </div>
          <span class="count">상담 2회</span>
        </div>
      </div>

      <div class="list-item active">
        <div class="item-content">
          <span class="name">김미영</span>
          <span class="badge green">기존고객</span>
          <div class="info-cell">
            <span class="icon-sq"></span>
            <span class="text">010-8888-1111</span>
          </div>
          <div class="info-cell">
            <span class="icon-sq-sm"></span>
            <span class="text">2024-09-15</span>
          </div>
          <span class="count">상담 3회</span>
        </div>
      </div>

      <div class="list-item">
        <div class="item-content">
          <span class="name">박재현</span>
          <span class="badge yellow">잠재고객</span>
          <div class="info-cell">
            <span class="icon-sq"></span>
            <span class="text">010-7777-2222</span>
          </div>
          <div class="info-cell">
            <span class="icon-sq-sm"></span>
            <span class="text">2024-11-26</span>
          </div>
          <span class="count">상담 1회</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const isDropdownOpen = ref(false);
const selectedFilter = ref('전체 유형');

const toggleDropdown = () => {
  isDropdownOpen.value = !isDropdownOpen.value;
};

const selectFilter = (filterName) => {
  selectedFilter.value = filterName;
  isDropdownOpen.value = false;
};
</script>

<style scoped>
/* 전체 컨테이너 */
.search-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

/* --- 헤더 스타일 (CounselList와 패딩값 100% 일치) --- */
.card-header {
  padding: 16px;
  /* CounselList의 simple 클래스와 동일한 하단 여백 처리를 위해 높이 보장 */
  display: flex;
  align-items: center;
  min-height: 60px; /* 헤더 높이 강제 통일 */
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
  gap: 8px; /* 검색창과 드롭다운 사이 간격 */
  border-bottom: 1px solid #E5E7EB;
}

.search-input-box {
  position: relative;
  flex: 1; /* 검색창이 남은 공간 차지 */
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
  height: 40px; /* 높이 조정 */
  padding: 8px 16px 8px 40px;
  border-radius: 8px;
  border: 1px solid #E5E7EB;
  font-size: 14px;
  color: #2E3440;
  outline: none;
  box-sizing: border-box;
}
.search-input::placeholder { color: rgba(46, 52, 64, 0.5); }

/* --- 필터 드롭다운 스타일 --- */
.filter-dropdown {
  position: relative;
  width: 120px; /* 드롭다운 너비 고정 */
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

/* --- 리스트 영역 (기존 유지) --- */
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
.info-cell { display: flex; align-items: center; gap: 4px; color: #4A5565; flex: 1; }
.icon-sq, .icon-sq-sm { width: 10px; height: 10px; border: 1px solid #4A5565; display: inline-block; }
.icon-sq-sm { width: 9px; height: 9px; }
.text { color: #4A5565; font-size: 12px; line-height: 16px; }
.count { color: #6A7282; font-size: 12px; margin-left: auto; }
</style>