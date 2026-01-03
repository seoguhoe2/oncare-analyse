<template>
  <div class="approval-container">
    
    <div class="top-bar">
      <div class="search-box">
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
            <option 
              v-for="cat in categoryList" 
              :key="cat.id" 
              :value="cat.name"
            >
              {{ cat.name }}
            </option>
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
        v-for="item in approvalList" 
        :key="item.id" 
        class="list-item"
        :class="{ 'active': selectedItem && selectedItem.id === item.id }"
        @click="selectItem(item)"
      >
        <div class="item-main">
          <div class="title-row">
            <span class="title">{{ item.title }}</span>
            <span class="badge category">{{ item.categoryName }}</span>
            <span class="badge priority" :class="getPriorityClass(item.priority)">{{ item.priority }}</span>
          </div>
          <div class="info-row">
            <span class="username">{{ item.drafterName }}</span>
          </div>
        </div>
        <div class="item-date">{{ formatDate(item.createdAt) }}</div>
        <div class="item-status">
          <span class="status-badge" :class="getStatusClass(item.status)">
            {{ item.status }}
          </span>
        </div>
      </div>

      <div v-if="approvalList.length === 0 && !isLoading" class="no-result">
        조건에 맞는 결과가 없습니다.
      </div>
       <div v-if="isLoading" class="no-result">
        불러오는 중...
      </div>
    </div>

    <!-- 페이지네이션 컨트롤 -->
    <div class="pagination" v-if="totalPages > 1">
      <button 
        class="page-btn nav" 
        :disabled="currentPage === 1" 
        @click="goToPage(currentPage - 1)"
      >
        &lt;
      </button>
      
      <button 
        v-for="page in totalPages" 
        :key="page" 
        class="page-btn" 
        :class="{ active: currentPage === page }"
        @click="goToPage(page)"
      >
        {{ page }}
      </button>
      
      <button 
        class="page-btn nav" 
        :disabled="currentPage === totalPages" 
        @click="goToPage(currentPage + 1)"
      >
        &gt;
      </button>
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
import { ref, watch, onMounted } from 'vue';
import DetailPanel from '@/components/tasks/approve/DetailPanel.vue'; 
import { getPaymentList, getPaymentDetail, getPaymentCategories, approvePayment, rejectPayment } from '@/api/payment/paymentApi';
import { useUserStore } from '@/stores/user';

const userStore = useUserStore();

// 상태 변수들
const searchQuery = ref('');
const selectedCategory = ref('');
const selectedStatus = ref('');
const selectedItem = ref(null);
const approvalList = ref([]); // 현재 페이지 목록
const categoryList = ref([]);
const isLoading = ref(false);

// 페이지네이션 상태
const currentPage = ref(1);
const itemsPerPage = 10;
const totalPages = ref(1); // 서버 응답에 따라 갱신

// 날짜 포맷팅 함수
const formatDate = (dateString) => {
  if (!dateString) return '-';
  return dateString.split('T')[0];
};

// 카테고리 목록 조회
const fetchCategories = async () => {
    try {
        const data = await getPaymentCategories();
        categoryList.value = data || [];
    } catch (error) {
        console.error('Failed to fetch categories:', error);
    }
};

// 목록 조회 함수 (서버 사이드 페이징)
const fetchList = async () => {
  isLoading.value = true;
  try {
    // 0-based index 적용 및 빈 파라미터 제거
    const params = {
      page: currentPage.value - 1, 
      size: itemsPerPage,
      employeeId: userStore.userId
    };

    if (searchQuery.value) params.search = searchQuery.value;
    if (selectedCategory.value) params.category = selectedCategory.value;
    if (selectedStatus.value) params.status = selectedStatus.value;
    
    const data = await getPaymentList(params);
    
    // 응답 구조 처리
    if (data && data.list) {
        approvalList.value = data.list;
        totalPages.value = data.totalPages || 1;
    } else if (data && data.content) {
        // Fallback for standard Page structure
        approvalList.value = data.content;
        totalPages.value = data.totalPages || 1;
    } else if (Array.isArray(data)) {
        // 페이징 없이 리스트만 온 경우 (fallback)
        approvalList.value = data; 
        totalPages.value = 1;
    } else {
        approvalList.value = [];
        totalPages.value = 1;
    }
  } catch (error) {
    console.error('Failed to fetch payment list:', error);
    approvalList.value = [];
  } finally {
    isLoading.value = false;
  }
};

// 페이지 이동
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
    fetchList();
  }
};

// 필터 변경 감지
watch([searchQuery, selectedCategory, selectedStatus], () => {
    currentPage.value = 1; // 검색 조건 변경 시 1페이지로
    fetchList();
});

// 상세 조회 및 모달 열기
const selectItem = async (item) => {
  try {
    const detailData = await getPaymentDetail(item.id);
    selectedItem.value = detailData;
  } catch (error) {
    console.error('Failed to fetch payment detail:', error);
    alert('상세 정보를 불러오는데 실패했습니다.');
  }
};

const closeDetail = () => {
  selectedItem.value = null;
};

const handleApprove = async (id) => {
  if (!confirm('승인하시겠습니까?')) return;
  try {
    await approvePayment(id);
    alert('승인되었습니다.');
    closeDetail();
    fetchList(); 
  } catch (error) {
    console.error('Approve failed:', error);
    alert('승인 처리 중 오류가 발생했습니다.');
  }
};

const handleReject = async (id) => {
  if (!confirm('반려하시겠습니까?')) return;
  try {
    await rejectPayment(id);
    alert('반려되었습니다.');
    closeDetail();
    fetchList(); 
  } catch (error) {
    console.error('Reject failed:', error);
    alert('반려 처리 중 오류가 발생했습니다.');
  }
};

// 스타일 헬퍼
const getPriorityClass = (p) => {
  if(p === '긴급' || p === 'HIGH') return 'p-high'; 
  if(p === '보통' || p === 'MEDIUM') return 'p-medium';
  return 'p-low';
}
const getStatusClass = (s) => {
  if(s === '승인' || s === 'APPROVED') return 's-approved';
  if(s === '반려' || s === 'REJECTED') return 's-rejected';
  return 's-waiting'; 
}

onMounted(() => {
  fetchCategories();
  fetchList();
});
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
.list-container { display: flex; flex-direction: column; gap: 12px; min-height: 500px; } /* 높이 고정하여 페이징 시 덜렁거림 방지 */
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

/* 페이지네이션 */
.pagination { display: flex; justify-content: center; gap: 8px; margin-top: 20px; padding-bottom: 20px; }
.page-btn { 
  width: 36px; height: 36px; border: 1px solid #e2e8f0; border-radius: 8px; 
  background: white; cursor: pointer; color: #64748b; font-weight: 600; 
  display: flex; align-items: center; justify-content: center;
}
.page-btn:hover:not(:disabled) { background: #f8fafc; color: #4ade80; border-color: #4ade80; }
.page-btn.active { background: #4ade80; color: white; border-color: #4ade80; }
.page-btn.nav { font-size: 12px; }
.page-btn:disabled { cursor: not-allowed; opacity: 0.5; }

/* 상세 패널 슬라이드 애니메이션 & 오버레이 */
.slide-enter-active, .slide-leave-active { transition: transform 0.3s ease; }
.slide-enter-from, .slide-leave-to { transform: translateX(100%); }
.overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.2); z-index: 50; }

@media (max-width: 768px) {
  .top-bar { flex-direction: column; align-items: stretch; }
  .search-box, .filter-box { width: 100%; }
}
</style>