<template>
  <div class="rental-item-table-container">
    <div class="section-header">
      <h3 class="title">렌탈 제품 변동 이력</h3>
      </div>

    <div class="table-wrapper">
      <table class="item-table">
        <thead>
          <tr>
            <th>관리코드</th>
            <th>상태</th>
            <th>사용 시작일</th>
            <th>사용 종료일</th>
            <th>비고</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading" class="info-row">
            <td colspan="5">데이터를 불러오는 중입니다...</td>
          </tr>
          <tr v-else-if="!visualItems.length" class="info-row">
            <td colspan="5">해당 계약에 연결된 제품 이력이 없습니다.</td>
          </tr>
          
          <tr v-for="item in visualItems" :key="item.id" class="item-row">
            <td>
              <span class="code-text">{{ item.productId }}</span>
            </td>
            <td>
              <span class="status-tag" :class="getStatusClass(item.rentalStatusId)">
                {{ getStatusName(item.rentalStatusId) }}
              </span>
            </td>
            <td>{{ formatDate(item.startDate) }}</td>
            <td>{{ item.endDate ? formatDate(item.endDate) : '사용 중' }}</td>
            <td class="memo">
              {{ item.endDate ? '제품 변경/반납' : '현재 사용 제품' }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>

     <div class="pagination-controls" v-if="totalItemCount > 0">
        <button 
        class="page-btn" 
        :disabled="visualPage === 0"
        @click="prevPage"
        >
        &lt; 이전
        </button>
        
        <span class="page-info">{{ visualPage + 1 }} 페이지</span>

        <button 
        class="page-btn" 
        :disabled="!canGoNext"
        @click="nextPage"
        >
        다음 &gt;
        </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import { getRentalItems, getRentalStatus } from '@/api/product/rentalAPI';

const props = defineProps({
  contractId: {
    type: [Number, String],
    required: true
  },
  itemStatusFilter: {
    type: [Number, String],
    default: 0
  }
});

const loading = ref(false);
const rawItems = ref([]);
const statusOptions = ref([]);

// 페이징 관련 상태 변수
const visualPage = ref(0);
const pageSize = 5;

// 상태 명칭 매핑용
const getStatusName = (id) => {
  const status = statusOptions.value.find(s => s.id === id);
  return status ? status.name : '알 수 없음';
};

// 상태별 클래스
const getStatusClass = (id) => {
  if (id === 1) return 'st-apply';  // 접수
  if (id === 2) return 'st-active'; // 유지
  if (id === 3) return 'st-end';    // 종료
  return '';
};

// 날짜 포맷팅
const formatDate = (dateStr) => {
  if (!dateStr) return '-';
  return dateStr.split('T')[0];
};

// 데이터 로드 함수
const loadData = async () => {
  if (!props.contractId) return;
  loading.value = true;
  visualPage.value = 0; // 데이터 로드 시 페이지 초기화
  try {
    const data = await getRentalItems(props.contractId);
    rawItems.value = data || [];
  } catch (error) {
    console.error("아이템 로드 실패", error);
    rawItems.value = [];
  } finally {
    loading.value = false;
  }
};

// 상태값 마스터 정보 로드
const loadStatusOptions = async () => {
  const data = await getRentalStatus();
  statusOptions.value = data || [];
};

// [수정] 1단계: 필터링된 전체 목록
const filteredAllItems = computed(() => {
  if (Number(props.itemStatusFilter) === 0) return rawItems.value;
  return rawItems.value.filter(item => item.rentalStatusId === Number(props.itemStatusFilter));
});

const visualItems = computed(() => {
  const list = filteredAllItems.value;
  const start = visualPage.value * pageSize;
  const end = start + pageSize;
  return list.slice(start, end);
});

const totalItemCount = computed(() => filteredAllItems.value.length);

const canGoNext = computed(() => {
  return (visualPage.value + 1) * pageSize < totalItemCount.value;
});


const prevPage = () => {
  if (visualPage.value > 0) visualPage.value--;
};

const nextPage = () => {
  if (canGoNext.value) visualPage.value++;
};

// 필터가 바뀌면 페이지 초기화
watch(() => props.itemStatusFilter, () => {
  visualPage.value = 0;
});

// 부모가 넘겨준 ID가 바뀌면 데이터 다시 가져오기
watch(() => props.contractId, () => {
  loadData();
}, { immediate: true });

onMounted(() => {
  loadStatusOptions();
});
</script>

<style scoped>
/* 전체 카드 컨테이너 */
.rental-item-table-container {
  background: #ffffff;
  border: 1px solid #e5e7eb; /* 테두리 */
  border-radius: 12px;       /* 둥근 모서리 */
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

/* 헤더 영역 (제목 + 필터) */
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #e5e7eb;
  background-color: #ffffff;
}

.title {
  font-size: 16px;
  font-weight: 700;
  color: #111827;
  margin: 0;
}

/* 테이블 래퍼 (패딩 제거하여 테두리에 딱 붙게) */
.table-wrapper {
  width: 100%;
}

.item-table {
  width: 100%;
  border-collapse: collapse;
}

/* 테이블 헤더 스타일 통일 */
.item-table th {
  background: #f9fafb;
  padding: 12px 20px;
  font-size: 13px;
  font-weight: 600;
  color: #6b7280;
  text-align: left;
  border-bottom: 1px solid #e5e7eb;
}

.item-table td {
  padding: 14px 20px;
  border-bottom: 1px solid #f3f4f6;
  font-size: 14px;
  color: #374151;
}

/* 마지막 줄 테두리 제거 */
.item-table tbody tr:last-child td {
  border-bottom: none;
}

.info-row td {
  text-align: center;
  color: #9ca3af;
  padding: 60px 0;
}

.code-text {
  font-family: monospace;
  background-color: #f3f4f6;
  padding: 2px 6px;
  border-radius: 4px;
  color: #4b5563;
  font-weight: 600;
}

.status-tag {
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
}

/* 뱃지 색상 통일 */
.st-apply { background: #eff6ff; color: #1d4ed8; }
.st-active { background: #ecfdf5; color: #047857; }
.st-end { background: #f3f4f6; color: #4b5563; }

.memo {
  color: #6b7280;
  font-size: 13px;
}


  .pagination-controls { display: flex; justify-content: flex-end; align-items: center; gap: 12px; margin-top: 10px;  margin-bottom: 10px; padding: 0 16px; }
  .page-btn { padding: 6px 16px; border: 1px solid #e5e7eb; background-color: white; border-radius: 6px; font-size: 13px; cursor: pointer; color: #374151; transition: all 0.2s; }
  .page-btn:hover:not(:disabled) { background-color: #f3f4f6; border-color: #d1d5db; }
  .page-btn:disabled { opacity: 0.5; cursor: not-allowed; background-color: #f9fafb; }
  .page-info { font-size: 13px; color: #6b7280; }

</style>