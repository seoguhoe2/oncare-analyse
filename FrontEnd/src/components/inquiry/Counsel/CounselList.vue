<template>
  <div class="card consultation-section">
    <div class="card-header">
      <div class="header-title">김미영님의 상담 리스트</div>
    </div>
    
    <div class="filter-dropdown-area">
      <div class="filter-dropdown" @click="toggleDropdown">
        <span class="selected-text">{{ selectedFilter }}</span>
        <div class="arrow-down"></div>
        
        <div v-if="isDropdownOpen" class="dropdown-menu">
          <div class="dropdown-item" @click.stop="selectFilter('전체유형')">전체유형</div>
          <div class="dropdown-item" @click.stop="selectFilter('가입상담')">가입상담</div>
          <div class="dropdown-item" @click.stop="selectFilter('렌탈상담')">렌탈상담</div>
          <div class="dropdown-item" @click.stop="selectFilter('문의상담')">문의상담</div>
          <div class="dropdown-item" @click.stop="selectFilter('컴플레인')">컴플레인</div>
          <div class="dropdown-item" @click.stop="selectFilter('해지상담')">해지상담</div>
        </div>
      </div>
    </div>

    <div class="list-body consultation-list">
      <div class="list-item">
        <div class="item-content">
          <span class="pill purple">렌탈상담</span>
          <div class="info-cell">
            <span class="icon-sq-sm"></span>
            <span class="text">2024-11-26</span>
          </div>
          <div class="info-cell">
            <span class="text">15:30</span>
          </div>
          <div class="info-cell">
            <span class="text">박상담</span>
          </div>
        </div>
      </div>

      <div class="list-item active-blue">
        <div class="item-content">
          <span class="pill orange">요청상담</span>
          <div class="info-cell">
            <span class="icon-sq-sm"></span>
            <span class="text">2024-11-20</span>
          </div>
          <div class="info-cell">
            <span class="text">11:00</span>
          </div>
          <div class="info-cell">
            <span class="text">최상담</span>
          </div>
        </div>
      </div>

      <div class="list-item">
        <div class="item-content">
          <span class="pill blue">신규가입</span>
          <div class="info-cell">
            <span class="icon-sq-sm"></span>
            <span class="text">2024-09-15</span>
          </div>
          <div class="info-cell">
            <span class="text">14:00</span>
          </div>
          <div class="info-cell">
            <span class="text">김상담</span>
          </div>
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
/* 카드 기본 스타일 */
.card {
  background: white;
  border-radius: 10px;
  border: 1px solid #E5E7EB;
  display: flex;
  flex-direction: column;
  overflow: visible; /* 드롭다운 메뉴가 잘리지 않도록 visible 설정 권장 */
  height: 100%;
  min-height: 340px;
}

/* 헤더 스타일 */
.card-header {
  padding: 16px;
  display: flex;
  align-items: center;
  min-height: 60px; /* 헤더 높이 통일 */
  box-sizing: border-box;
}

.header-title {
  color: #388E3C;
  font-size: 20px;
  font-weight: 600;
  line-height: 28px;
}

/* 필터 드롭다운 영역 */
.filter-dropdown-area {
  padding: 0 16px 12px 16px;
  border-bottom: 1px solid #E5E7EB;
}

/* 드롭다운 스타일 (CustomerSearchBar와 동일) */
.filter-dropdown {
  position: relative;
  width: 140px; /* 텍스트 길이에 따라 조금 더 넓게 */
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
  color: #388E3C; /* 상담 리스트에 맞는 포인트 컬러 */
}

/* 리스트 본문 */
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
.list-item:hover { border-color: #2B7FFF; }
.list-item.active-blue { background: #EFF6FF; border-color: #2B7FFF; }

.item-content { display: flex; align-items: center; gap: 12px; font-size: 14px; }

.pill { padding: 2px 8px; border-radius: 4px; font-size: 12px; white-space: nowrap; border: 1px solid transparent; }
.pill.purple { background: #F3E8FF; border-color: #E9D4FF; color: #8200DB; }
.pill.orange { background: #FFEDD4; border-color: #FFD6A7; color: #CA3500; }
.pill.blue { background: #DBEAFE; border-color: #BEDBFF; color: #1447E6; }

.info-cell { display: flex; align-items: center; gap: 4px; color: #4A5565; flex: 1; }
.icon-sq-sm { width: 9px; height: 9px; border: 1px solid #4A5565; display: inline-block; }
.text { color: #4A5565; font-size: 12px; line-height: 16px; }
</style>