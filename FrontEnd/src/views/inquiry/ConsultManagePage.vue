<template>
    <div>
      <h2>상담 관리</h2>
    </div>

    <div class="dashboard-container">
    
    <div class="card search-section">
        <CustomerSearchCard />
    </div>

    <CounselList />

    <CounselWriteCard @update:category="handleCategoryChange" />

    <CounselHelpDetail :category="currentCategory" />

  </div>

  </template>
  
  <script setup>
  import { ref } from 'vue';
  import CustomerSearchCard from '@/components/inquiry/Counsel/CustomerSearchCard.vue';
  import CounselList from '@/components/inquiry/Counsel/CounselList.vue';
  import CounselWriteCard from '@/components/inquiry/Counsel/CounselWriteCard.vue';
  import CounselHelpDetail from '@/components/inquiry/Counsel/CounselHelpDetail.vue';

  // 현재 선택된 카테고리를 저장하는 변수
const currentCategory = ref('');

// 작성 카드에서 카테고리가 변경되었을 때 실행되는 함수
const handleCategoryChange = (newCategory) => {
  console.log('카테고리 변경됨:', newCategory);
  currentCategory.value = newCategory;
};
  </script>

<style scoped>
.dashboard-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
  width: 100%;
  max-width: 1600px;
  margin: 0 auto;
}

/* 카드 공통 스타일 */
.card {
  background: white;
  border-radius: 10px;
  border: 1px solid #E5E7EB;
  display: flex;
  flex-direction: column;
  overflow: hidden; /* 내부 컨텐츠 넘침 방지 */
  min-height: 340px; /* 최소 높이 보장 */
}

/* 카드 헤더 */
.card-header {
  padding: 16px;
  border-bottom: 1px solid #E5E7EB;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.card-header.simple {
  padding-bottom: 15px; /* 보정 */
}

.card-header.flex-between {
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
}

.header-title {
  color: #388E3C;
  font-size: 20px;
  font-weight: 600;
  line-height: 28px;
}

/* 검색 영역 */
.search-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.search-input-box {
  position: relative;
  width: 100%;
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
  height: 42px;
  padding: 8px 16px 8px 40px;
  border-radius: 10px;
  border: 1px solid #E5E7EB;
  font-size: 16px;
  color: #2E3440;
  outline: none;
}
.search-input::placeholder { color: rgba(46, 52, 64, 0.5); }

/* 필터 탭 */
.filter-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.simple-tabs {
  padding: 12px 16px; /* 헤더 밖 리스트 위에 위치 */
}

.filter-tab {
  background: none;
  border: none;
  font-size: 16px;
  color: #2E3440;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 6px;
}
.filter-tab:hover { background-color: #f3f4f6; }

/* 리스트 스타일 */
.list-body {
  flex: 1;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  overflow-y: auto; /* 내용 많으면 스크롤 */
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
.list-item.active-blue { background: #EFF6FF; border-color: #2B7FFF; }

.item-content {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 14px;
}

/* 리스트 내부 요소 */
.name { color: #008236; font-weight: 500; min-width: 50px;}
.badge { padding: 2px 8px; border-radius: 4px; font-size: 12px; white-space: nowrap; }
.badge.yellow { background: #FEF9C2; color: #A65F00; }
.badge.green { background: #DCFCE7; color: #008236; }

.pill { padding: 2px 8px; border-radius: 4px; font-size: 12px; white-space: nowrap; }
.pill.purple { background: #F3E8FF; color: #8200DB; border: 1px solid #E9D4FF; }
.pill.orange { background: #FFEDD4; color: #CA3500; border: 1px solid #FFD6A7; }
.pill.blue { background: #DBEAFE; color: #1447E6; border: 1px solid #BEDBFF; }

.info-cell { display: flex; align-items: center; gap: 4px; color: #4A5565; flex: 1; }
.icon-sq, .icon-sq-sm {
  width: 10px; height: 10px; border: 1px solid #4A5565; display: inline-block;
}
.icon-sq-sm { width: 9px; height: 9px; }

.count { color: #6A7282; font-size: 12px; margin-left: auto; }

/* 작성 폼 스타일 (Overlay 제거 후 Flex Flow로 변경) */
.form-body {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  background-color: #F9FAFB;
  flex: 1;
}

.sub-title {
  color: #6A7282;
  font-size: 14px;
  margin-bottom: 12px;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px 24px;
}

.info-row {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.label { color: #6A7282; font-size: 12px; }
.value { color: #101828; font-size: 16px; }
.value.placeholder { color: #9CA3AF; font-size: 14px; }

.checkbox-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: #FEF2F2;
  border: 1px solid #FFE2E2;
  border-radius: 14px;
}
.checkbox { width: 16px; height: 16px; background: #F3F3F5; border: 1px solid rgba(0,0,0,0.1); border-radius: 4px; }
.check-label { color: #364153; font-size: 14px; }

.memo-area {
  background: #FFFBEB;
  border: 1px solid #FEF3C6;
  border-radius: 14px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.memo-input {
  width: 100%;
  height: 100px;
  padding: 12px;
  border: none;
  border-radius: 8px;
  resize: none;
  font-family: inherit;
}

.save-btn {
  width: 100%;
  height: 32px;
  background: #FF8A3C;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
}

/* 상세 페이지 스타일 */
.detail-body {
  padding: 20px;
  flex: 1;
}

.history-box {
  background: #EFF6FF;
  border: 1px solid #DBEAFE;
  border-radius: 14px;
  padding: 20px;
}

.history-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.history-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px; }
.history-badge { background: #DBEAFE; padding: 4px 8px; border-radius: 4px; font-size: 12px; color: #4A5565; }
.history-date { font-size: 12px; color: #4A5565; }
.history-manager { font-size: 12px; color: #6A7282; }
.history-desc { font-size: 14px; color: #4A5565; line-height: 1.5; margin: 0; }

.dropdown-trigger {
  display: flex;
  align-items: center;
  gap: 8px;
  border: 1px solid #CCCCCC;
  border-radius: 6px;
  padding: 6px 12px;
  font-size: 14px;
  color: #6F6F6F;
  cursor: pointer;
}
.arrow-down {
  width: 0; height: 0; 
  border-left: 5px solid transparent;
  border-right: 5px solid transparent;
  border-top: 5px solid black;
}

/* 반응형 (화면이 좁을 때 1열로 변경) */
@media (max-width: 1200px) {
  .dashboard-container {
    grid-template-columns: 1fr;
  }
}
</style>