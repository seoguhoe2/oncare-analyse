<template>
    <!-- 선택된 용품이 있을 때만 보이도록 -->
    <div v-if="totalItemCount" class="detail-card">
      <!-- 연두색 헤더 영역 -->
      <!-- <div class="detail-header">
        <h2 class="title">
          {{ selectedItem }} - 상세 현황
        </h2>
      </div> -->
  
      <!-- 안쪽 테이블만 스크롤 -->
      <div class="detail-table-inner">
        <table class="detail-table">
          <thead>
            <tr>
              <th>관리코드</th>
              <th>구매일</th>
              <th>상태</th>
              <th>렌탈비용</th>
              <th>수입 현황</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="totalItemCount.length <=0">
              <td colspan="6" class="empty">
                해당 용품의 상세 데이터가 없습니다.
              </td>
            </tr>
  
            <tr
              v-for="row in visualItems"
              :key="row.id"
              :class="{ 'row-selected': row.id === selectedDetailId }"
              @click="$emit('row-click', row)"
            >
              <td>
                <span class="badge code-badge">{{ row.id }}</span>
              </td>
              <td>{{ row.boughtDate }}</td>
              <td>
                <span
                  class="badge"
                  :class="statusClassMap[row.productStatus]"
                >
                  {{ row.statusName }}
                </span>
              </td>
              <td>{{ formatCurrency(row.rentalAmount) }}</td>
              <td>
                <span v-if="row.cumulativeRevenue >= 0">{{ formatCurrency(row.cumulativeRevenue) }}</span>
                <span v-else>-</span>
              </td>
              <!-- <td>
                <span
                  class="badge as-badge"
                  :class="row.asCount > 0 ? 'as-exist' : 'as-none'"
                >
                  {{ row.asCount > 0 ? `${row.asCount}회` : '없음' }}
                </span>
              </td> -->
            </tr>
          </tbody>
        </table>
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
    </div>
  
    <!-- 아무 것도 선택 안됐을 때 -->
    <div v-else class="detail-empty-card">
      용품을 선택하면 상세 현황이 표시됩니다.
    </div>
  </template>
  
  <script setup>
  import { computed ,watch, ref} from 'vue'

  const statusClassMap = {
    1: 'status-storage',
    2: 'status-rent',
    3: 'status-discard',
  };

  let productMasterName = "";
  
  const visualPage = ref(0) // 현재 내가 보고 있는 화면 페이지
  const pageSize = 5      // 화면에 보여줄 개수
  const totalItemCount = computed(() => props.products?.length ?? 0) // 전체 아이템 개수

  const props = defineProps({
    products: {
      type: Object,
      default: () => [],
    },
    // 어떤 상세 행이 선택됐는지 (히스토리 패널에서 사용)
    selectedDetailId: {
      type: [Number, String],
      default: null,
    },
      isLastBatch: { // 서버에 더 가져올 데이터가 없는지 여부 (API의 last 값)
        type: Boolean,
        default: false
      },
    // 어떤 상세 행이 선택됐는지 (히스토리 패널에서 사용)
    selectedItem: {
      type: String,
      default: null,
    },
    selectedProductName: {
      type: String,
      default: '',
    }
  })
  
  const emit = defineEmits(['row-click','needMoreData'])

  // 현재 페이지에 보여줄 pageSize만큼 slice
  const visualItems = computed(() => {
    if(props.selectedProductName !==  productMasterName ) {
      productMasterName = props.selectedProductName;
      visualPage.value = 0;
    }
    
    // products가 없거나 배열이 아니면 빈 배열 반환
    if (!props.products || !Array.isArray(props.products)) {
        return [];
      }

      const start = visualPage.value * pageSize
      const end = start + pageSize
      
      // 안전하게 slice 호출
      return props.products.slice(start, end)
    })

    //  다음 페이지로 갈 수 있는지 여부 
  const canGoNext = computed(() => {
    // 메모리에 이미 다음 장 데이터가 있거나
    const hasMoreInMemory = (visualPage.value + 1) * pageSize < totalItemCount.value
    // 아니면 서버에 데이터가 더 남아있거나 (last가 false)
    const hasMoreInServer = !props.isLastBatch
    
    return hasMoreInMemory || hasMoreInServer
  })

  const prevPage = () => {
    if (visualPage.value > 0) visualPage.value--
  }

  const nextPage = async () => {
    // 다음 장을 보여주려면 데이터가 몇 개 필요한지 계산
    const nextIndexStart = (visualPage.value + 1) * pageSize
    
    // 메모리에 데이터가 부족하면 부모에게 요청해야 함
    if (nextIndexStart >= totalItemCount.value) {
      if (props.isLastBatch) return; // 더 이상 없으면 중단
      
      // 부모에게 데이터 요청 (비동기)
      emit('needMoreData')
    } else {
      // 메모리에 데이터가 있으면 그냥 페이지 넘김
      visualPage.value++
    }
  }

  watch(() => props.products?.length, (newLen, oldLen) => {
    // console.log("새로운 watch... props,내부.....",props.selectedProductName, "::::" , productMasterName)
    if (newLen === 0) {
      visualPage.value = 0;
      return;
    }

    if (props.selectedProductName === productMasterName && 
      oldLen > 0 && newLen > oldLen && newLen > (visualPage.value + 1) * pageSize) {
      visualPage.value++;
    }
  })

  // watch(() => props.selectedDetailId, (newData , oldData) => {
  //   visualPage.value = 0;
  // });

  watch(() => props.selectedProductName, () => {
    // 상단 제품이 바뀌면(이름 변경) 상세 페이지 0으로 초기화
    visualPage.value = 0;
  });
  
  const formatCurrency = (value) => {
    if (value == null) return '-'
    return `₩${value.toLocaleString()}`
  }
  </script>
  
  <style scoped>
  .detail-card {
    margin-top: 24px;
    border-radius: 16px;
    border: 1px solid #bbf7d0;
    background: #ffffff;
    overflow: hidden;
  }
  
  /* 헤더 */
  .detail-header {
    background: #ecfdf5;
    padding: 14px 20px;
    border-bottom: 1px solid #bbf7d0;
  }
  
  .title {
    margin: 0;
    font-size: 18px;
    font-weight: 600;
    color: #16a34a;
  }
  
  /* 안쪽 스크롤 */
  .detail-table-inner {
    /* max-height: 260px; */
    overflow-y: auto;
  }
  
  .detail-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
  }
  
  .detail-table th,
  .detail-table td {
    padding: 10px 16px;
    border-bottom: 1px solid #f3f4f6;
    text-align: left;
    white-space: nowrap;
  }
  
  .detail-table thead th {
    font-size: 13px;
    color: #6b7280;
    font-weight: 500;
    background: #f9fafb;
  }
  
  /* 선택된 상세 행 하이라이트 */
  .row-selected {
    background: #f9fafb;
  }
  
  .empty {
    text-align: center;
    color: #9ca3af;
  }
  
  /* 뱃지 */
  .badge {
    display: inline-flex;
    align-items: center;
    padding: 3px 10px;
    border-radius: 999px;
    font-size: 12px;
  }
  
  .code-badge {
    background: #f5f3ff;
    color: #7c3aed;
  }
  
  .status-rent {
    background: #f3e8ff; 
    color: #6b21a8;
  }
  
  .status-storage {
    background: #e5e7eb;
    color: #374151;
  }
  .status-discard {
    background: #ffedd5;
    color: #c2410c;
  }
  
  .as-badge {
    min-width: 40px;
    justify-content: center;
  }
  
  .as-exist {
    background: #fee2e2;
    color: #b91c1c;
  }
  
  .as-none {
    background: #e5e7eb;
    color: #4b5563;
  }
  
  /* 아무 것도 선택 안 됐을 때 */
  .detail-empty-card {
    margin-top: 24px;
    border-radius: 16px;
    border: 1px dashed #d1d5db;
    background: #f9fafb;
    padding: 20px;
    font-size: 14px;
    color: #6b7280;
  }
  
  .pagination-controls { display: flex; justify-content: flex-end; align-items: center; gap: 12px; margin-top: 10px;  margin-bottom: 10px; padding: 0 16px; }
  .page-btn { padding: 6px 16px; border: 1px solid #e5e7eb; background-color: white; border-radius: 6px; font-size: 13px; cursor: pointer; color: #374151; transition: all 0.2s; }
  .page-btn:hover:not(:disabled) { background-color: #f3f4f6; border-color: #d1d5db; }
  .page-btn:disabled { opacity: 0.5; cursor: not-allowed; background-color: #f9fafb; }
  .page-info { font-size: 13px; color: #6b7280; }
  </style>