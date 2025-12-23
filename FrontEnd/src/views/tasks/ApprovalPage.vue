<template>
  <div class="approval-container">
    
    <div class="top-bar">
      <div class="search-box">
        <span class="search-icon">🔍</span>
        <input 
          type="text" 
          v-model="searchQuery" 
          placeholder="제목 또는 요청자 검색..." 
        />
      </div>

      <div class="filter-box">
        <div class="select-wrapper">
          <select v-model="selectedCategory" class="custom-select">
            <option value="">전체 유형</option>
            <option value="급여">급여</option>
            <option value="구매">구매</option>
            <option value="휴가">휴가</option>
            <option value="기타">기타</option>
          </select>
          <span class="arrow-icon">⌵</span>
        </div>
      </div>

      <div class="filter-box">
        <div class="select-wrapper">
          <select v-model="selectedStatus" class="custom-select">
            <option value="">전체 상태</option>
            <option value="대기중">대기중</option>
            <option value="승인">승인</option>
            <option value="반려">반려</option>
          </select>
          <span class="arrow-icon">⌵</span>
        </div>
      </div>
    </div>

    <div class="list-container">
      <div 
        v-for="item in filteredList" 
        :key="item.id" 
        class="list-item"
        :class="{ 'active': selectedItem && selectedItem.id === item.id }"
        @click="selectItem(item)"
      >
        <div class="item-main">
          <div class="title-row">
            <span class="title">{{ item.title }}</span>
            <span class="badge category">{{ item.category }}</span>
            <span class="badge priority" :class="getPriorityClass(item.priority)">{{ item.priority }}</span>
          </div>
          <div class="info-row">
            <span class="user-icon">👤</span>
            <span class="username">{{ item.requestor }}</span>
          </div>
        </div>
        <div class="item-date">📅 {{ item.date }}</div>
        <div class="item-status">
          <span class="status-badge" :class="getStatusClass(item.status)">
            {{ item.status }}
          </span>
        </div>
      </div>

      <div v-if="filteredList.length === 0" class="no-result">
        조건에 맞는 결과가 없습니다.
      </div>
    </div>

    <Transition name="slide">
      <DetailPanel 
        v-if="selectedItem" 
        :item="selectedItem" 
        @close="closeDetail"
        @approve="handleApprove"
        @reject="handleReject"
      />
    </Transition>
    
    <div v-if="selectedItem" class="overlay" @click="closeDetail"></div>

  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
// DetailPanel 컴포넌트 import (경로 확인 필요)
import DetailPanel from '@/components/tasks/approve/DetailPanel.vue'; 

// 상태 변수들
const searchQuery = ref('');
const selectedCategory = ref('');
const selectedStatus = ref('');
const selectedItem = ref(null); // 선택된 항목 저장

// 샘플 데이터 (상세 패널 표시를 위해 amount, content 등 데이터 보강)
const approvalList = ref([
  { 
    id: 1, title: '11월 급여 지급 결재', category: '급여', priority: '긴급', requestor: '김관리', date: '2024-11-27', status: '대기중',
    amount: 42350000, content: '2024년 11월 급여 지급 승인을 요청합니다.', approvalLine: [{ role: '팀장', name: '김팀장' }]
  },
  { 
    id: 2, title: '전동 휠체어 구매 요청', category: '구매', priority: '보통', requestor: '박담당', date: '2024-11-26', status: '승인',
    amount: 2500000, content: '신규 입소 어르신을 위한 휠체어 구매', approvalLine: [{ role: '팀장', name: '김팀장' }]
  },
  { id: 3, title: '휴가 신청 - 이영희', category: '휴가', priority: '낮음', requestor: '이영희', date: '2024-11-25', status: '승인', amount: 0, content: '연차 사용', approvalLine: [] },
  { id: 4, title: '신규 직원 채용 승인', category: '기타', priority: '긴급', requestor: '최인사', date: '2024-11-24', status: '승인', amount: 0, content: '인력 충원', approvalLine: [] },
  { id: 5, title: '시설 보수 공사 승인', category: '구매', priority: '보통', requestor: '김관리', date: '2024-11-23', status: '반려', amount: 1500000, content: '타일 보수', approvalLine: [] },
  { id: 6, title: '교육 프로그램 참가 신청', category: '기타', priority: '낮음', requestor: '박민수', date: '2024-11-22', status: '대기중', amount: 100000, content: '직무 교육', approvalLine: [] },
  { id: 7, title: '신규 용품 구매 계약', category: '구매', priority: '긴급', requestor: '이자재', date: '2024-11-28', status: '대기중', amount: 500000, content: '소모품 구매', approvalLine: [] },
]);

// 3단 필터링 로직
const filteredList = computed(() => {
  return approvalList.value.filter(item => {
    const matchSearch = item.title.includes(searchQuery.value) || item.requestor.includes(searchQuery.value);
    const matchCategory = selectedCategory.value === '' || item.category === selectedCategory.value;
    const matchStatus = selectedStatus.value === '' || item.status === selectedStatus.value;

    return matchSearch && matchCategory && matchStatus;
  });
});

// 상세 패널 관련 함수
const selectItem = (item) => {
  selectedItem.value = item;
};
const closeDetail = () => {
  selectedItem.value = null;
};
const handleApprove = (id) => {
  alert('승인되었습니다.');
  closeDetail();
};
const handleReject = (id) => {
  alert('반려되었습니다.');
  closeDetail();
};

// 스타일 헬퍼
const getPriorityClass = (p) => {
  if(p === '긴급') return 'p-high';
  if(p === '보통') return 'p-medium';
  return 'p-low';
}
const getStatusClass = (s) => {
  if(s === '승인') return 's-approved';
  if(s === '반려') return 's-rejected';
  return 's-waiting';
}
</script>

<style scoped>
/* 상단 툴바 */
.top-bar { display: flex; align-items: center; margin-bottom: 20px; gap: 12px; }
.search-box { position: relative; flex: 2; min-width: 200px; }
.search-icon { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #94a3b8; font-size: 16px; }
.search-box input { width: 100%; padding: 10px 10px 10px 40px; border: 1px solid #e2e8f0; border-radius: 8px; outline: none; font-size: 14px; transition: border-color 0.2s; box-sizing: border-box; }
.search-box input:focus { border-color: #4ade80; }

.filter-box { flex: 1; min-width: 130px; }
.select-wrapper { position: relative; display: flex; align-items: center; }
.custom-select { width: 100%; padding: 10px 32px 10px 12px; font-size: 14px; color: #334155; background-color: white; border: 1px solid #e2e8f0; border-radius: 8px; outline: none; appearance: none; cursor: pointer; box-sizing: border-box; }
.custom-select:focus { border-color: #4ade80; }
.arrow-icon { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); color: #64748b; font-size: 12px; pointer-events: none; }

/* 리스트 스타일 */
.list-container { display: flex; flex-direction: column; gap: 12px; }
.list-item { display: flex; align-items: center; justify-content: space-between; background: white; padding: 20px 24px; border-radius: 12px; border: 1px solid #e2e8f0; cursor: pointer; transition: all 0.2s; }
.list-item:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
/* 선택된 아이템 강조 */
.list-item.active { border-color: #4ade80; background-color: #f0fdf4; }

.item-main { flex: 2; display: flex; flex-direction: column; gap: 6px; }
.title-row { display: flex; align-items: center; gap: 8px; }
.title { font-weight: 600; color: #1e293b; font-size: 15px; }
.info-row { display: flex; align-items: center; gap: 6px; color: #64748b; font-size: 13px; }
.item-date { flex: 1; text-align: center; color: #64748b; font-size: 14px; }
.item-status { flex: 1; display: flex; justify-content: flex-end; }

.badge { padding: 4px 8px; border-radius: 6px; font-size: 12px; font-weight: 500; }
.category { background: #eef2ff; color: #6366f1; }
.p-high { background: #fee2e2; color: #ef4444; }
.p-medium { background: #ffedd5; color: #f97316; }
.p-low { background: #f1f5f9; color: #64748b; }
.status-badge { padding: 6px 14px; border-radius: 99px; font-size: 13px; font-weight: 600; }
.s-waiting { background: #fef9c3; color: #d97706; }
.s-approved { background: #dcfce7; color: #16a34a; }
.s-rejected { background: #fee2e2; color: #dc2626; }
.no-result { text-align: center; padding: 40px; color: #94a3b8; }

/* 상세 패널 슬라이드 애니메이션 & 오버레이 */
.slide-enter-active, .slide-leave-active { transition: transform 0.3s ease; }
.slide-enter-from, .slide-leave-to { transform: translateX(100%); }
.overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.2); z-index: 50; }

@media (max-width: 768px) {
  .top-bar { flex-direction: column; align-items: stretch; }
  .search-box, .filter-box { width: 100%; }
}
</style>