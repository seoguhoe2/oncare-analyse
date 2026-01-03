<template>
    <div class="manage-table-wrap">
      <div class="table-inner">
        <table class="manage-table">
          <thead>
            <tr>
              <th>용품 코드</th>
              <th>용품명</th>
              <th>카테고리</th>
              <th>구매가</th>
              <th>월 임대료</th>
              <th>총 재고</th>
              <th>가용</th>
              <th>렌탈중</th>
              <th>예약</th>
              <th>폐기</th>
              <th>관리</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="!totalItemCount === 0">
              <td colspan="9" class="empty">등록된 용품이 없습니다.</td>
            </tr>
  
            <tr
              v-for="item in visualItems"
              :key="item.id"
              :class="{ 'row-selected': item.id === selectedId }"
              @click="$emit('row-click', item)"
            >
              <td>
                <span class="badge code-badge">{{ item.id }}</span>
              </td>
              <td>{{ item.name }}</td>
              <td>
                <span class="badge badge-blue">{{ item.categoryName }}</span>
              </td>
              <td>{{ formatCurrency(item.purchasePrice) }}</td>
              <td>{{ formatCurrency(item.monthlyRenalFee) }}</td>
  
              <td>
                <span class="pill pill-total">
                  {{ item.totalProducts }}
                </span>
              </td>
              <td>
                <span
                  class="pill"
                  :class="item.usable === 0 ? 'pill-red' : 'pill-green'"
                >
                  {{ item.availableProducts }}
                </span>
              </td>
              <td>
                <span class="pill pill-purple">
                  {{ item.rentalProducts }}
                </span>
              </td>
              <td>
                <span class="pill pill-blue">
                  {{ item.reservedProducts }}
                </span>
              </td>
              <td>
                <span class="pill pill-orange">
                  {{ item.discardProducts }}
                </span>
              </td>
              <td @click.stop>
                <button 
                  class="action-btn"
                  :disabled="item.availableProducts <= 0"
                  @click="$emit('open-rental', item)"
                >
                  계약
                </button>
              </td>
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
  </template>
  
  <script setup>
  import { computed ,watch, ref} from 'vue'

const emit = defineEmits(['needMoreData', 'row-click', 'open-rental'])

  
  const visualPage = ref(0) // 현재 내가 보고 있는 화면 페이지
  const pageSize = 6      // 화면에 보여줄 개수
  const totalItemCount = computed(() => props.products.length) // 전체 아이템 개수
  const isModalOpen = ref(false)  //모달 상태 변수
  const modalMode = ref('create') // 'create' 또는 'edit'
  const selectedItem = ref(null)  // 수정 시 선택된 데이터 담을 곳
  
  const props = defineProps({
      products: {
        type: Array,
        default: () => [],
      },
      isLastBatch: { // 서버에 더 가져올 데이터가 없는지 여부 (API의 last 값)
        type: Boolean,
        default: false
      },
      categories: {
        type: Array,
        default: () => [],
      },
      // 어떤 행이 선택됐는지
      selectedId: {
        type: [Number, String],
        default: null,
      },
    })


  // 현재 페이지에 보여줄 pageSize만큼 slice
  const visualItems = computed(() => {
    // products가 없거나 배열이 아니면 빈 배열 반환
    if (!props.products || !Array.isArray(props.products)) {
        return [];
      }

      const start = visualPage.value * pageSize
      const end = start + pageSize
      
      // 안전하게 slice 호출
      return props.products.slice(start, end)
  })

  const canGoNext = computed(() => {
    const hasMoreInMemory = (visualPage.value + 1) * pageSize < totalItemCount.value
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

  watch(() => props.products.length, (newLen, oldLen) => {
    if (newLen === 0) {
      visualPage.value = 0;
      return;
    }

    if (oldLen > 0 && newLen > oldLen && newLen > (visualPage.value + 1) * pageSize) {
      visualPage.value++;
    }
  })


    
  const formatCurrency = (value) => {
    if (value == null) return '-'
    return `₩${value.toLocaleString()}`
  }

  
  
  </script>
  
  <style scoped>
  .manage-table-wrap {
    border-radius: 16px;
    border: 1px solid #e5e7eb;
    background: #ffffff;
    overflow: hidden;
  }
  
  /* 상단 리스트는 바깥은 흰 박스, 안쪽만 스크롤 */
  .table-inner {
    max-height: 420px;
    overflow-y: auto;
  }
  
  .manage-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
  }
  
  .manage-table th,
  .manage-table td {
    padding: 12px 16px;
    border-bottom: 1px solid #f3f4f6;
    text-align: left;
    white-space: nowrap;
  }
  
  .manage-table thead th {
    font-size: 13px;
    color: #6b7280;
    font-weight: 500;
    background: #f9fafb;
  }
  
  .manage-table tbody tr:hover {
    background: #f9fafb;
    cursor: pointer;
  }
  
  /* 선택된 행 하이라이트 */
  .row-selected {
    background: #ecfdf5;
  }
  
  .empty {
    text-align: center;
    color: #9ca3af;
  }
  
  /* 뱃지 공통 */
  .badge {
    display: inline-flex;
    align-items: center;
    padding: 4px 10px;
    border-radius: 999px;
    font-size: 12px;
  }
  
  .code-badge {
    background: #f5f3ff;
    color: #7c3aed;
  }
  
  .badge-blue {
    background: #eef2ff;
    color: #4f46e5;
  }
  
  /* 숫자 pill */
  .pill {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 28px;
    padding: 2px 8px;
    border-radius: 999px;
    font-size: 12px;
  }
  
  .pill-total {
    background: #f3f4f6;
    color: #4b5563;
  }
  
  .pill-green {
    background: #dcfce7;
    color: #166534;
  }
  
  .pill-red {
    background: #fee2e2;
    color: #b91c1c;
  }
  
  .pill-blue {
    background: #dbeafe; 
    color: #1e40af;      
  }

  .pill-orange {
    background: #ffedd5;
    color: #c2410c;
  }

  .pill-purple {
  background: #f3e8ff; 
  color: #6b21a8;
}
  
  .pagination-controls { display: flex; justify-content: flex-end; align-items: center; gap: 12px; margin-top: 10px;  margin-bottom: 10px; padding: 0 16px; }
  .page-btn { padding: 6px 16px; border: 1px solid #e5e7eb; background-color: white; border-radius: 6px; font-size: 13px; cursor: pointer; color: #374151; transition: all 0.2s; }
  .page-btn:hover:not(:disabled) { background-color: #f3f4f6; border-color: #d1d5db; }
  .page-btn:disabled { opacity: 0.5; cursor: not-allowed; background-color: #f9fafb; }
  .page-info { font-size: 13px; color: #6b7280; }

  .action-btn {
    padding: 4px 10px;
    background-color: #ffffff;
    border: 1px solid #d1d5db;
    border-radius: 4px;
    font-size: 12px;
    color: #374151;
    cursor: pointer;
    transition: all 0.2s;
  }
  .action-btn:hover:not(:disabled) {
    background-color: #166534;
    color: white;
    border-color: #166534;
  }
  .action-btn:disabled {
    background-color: #f3f4f6;
    color: #9ca3af;
    cursor: not-allowed;
    border-color: #e5e7eb;
  }

  </style>