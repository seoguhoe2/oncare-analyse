<template>
  <div class="product-table-wrap">

    <div class="table-header">
      <span class="total-count">총 <strong>{{ totalItemCount }}</strong>개</span>
      <button class="btn-register" @click="openModal('create')">
        + 신규 등록
      </button>
    </div>

    <table class="product-table">
      <thead>
        <tr>
          <th>용품 코드</th>
          <th>용품명</th>
          <th>카테고리</th>
          <th>단가</th>
          <th>월 임대료</th>
          <th>설명</th>
          <th>액션</th>
        </tr>
      </thead>
      <tbody>
        <tr v-if="totalItemCount === 0">
          <td colspan="6" class="empty">등록된 용품이 없습니다.</td>
        </tr>
        
        <tr v-for="item in visualItems" :key="item.id">
          <td>{{ item.id }}</td>
          <td>{{ item.name }}</td>
          <td>
            <span class="badge badge-blue">{{ item.categoryName }}</span>
          </td>
          <td>{{ formatCurrency(item.amount) }}</td>
          <td>{{ formatCurrency(item.rentalAmount) }}</td>
          <td class="desc">{{ item.explanation }}</td>
          <td class="actions">
            <button type="button" class="icon-btn edit">
                <img :src="editButton" alt="수정" @click="openModal('edit', item)"/>
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

    <ProductRegisterModal 
      v-if="isModalOpen" 
      :categories="categories"
      :is-edit="modalMode === 'edit'"
      :initial-data="selectedItem"
      @close="isModalOpen = false"
      @save="onRegisterProduct"
    />
  </div>
</template>
  
  <script setup>
  import editButton from '@/assets/img/common/editButton.png'
  import { computed ,watch, ref} from 'vue'
  import ProductRegisterModal from '@/components/product/modal/ProductRegisterModal.vue'
  
  const visualPage = ref(0) // 현재 내가 보고 있는 화면 페이지
  const pageSize = 10       // 화면에 보여줄 개수
  const totalItemCount = computed(() => props.products.length) // 전체 아이템 개수
  const isModalOpen = ref(false)  //모달 상태 변수
  const modalMode = ref('create') // 'create' 또는 'edit'
  const selectedItem = ref(null)  // 수정 시 선택된 데이터 담을 곳
  // 아직 마지막 페이지까지 데이터가 없을 경우 부모에게 다음 페이지 API 호출 요청
  const emit = defineEmits(['needMoreData', 'register'])
  
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
      }
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

  const openModal = (mode, item = null) => {
    modalMode.value = mode
    
    if (mode === 'edit' && item) {
      // 수정 모드: 선택된 아이템 복사해서 넘김 (참조 끊기 위해 spread 사용)
      selectedItem.value = { ...item }
    } else {
      // 등록 모드: 데이터 초기화
      selectedItem.value = null
    }
    
    isModalOpen.value = true
  }

  
  const onRegisterProduct = (formData) => {
    if (formData.mode === 'edit') {
      // 수정 API 호출 요청 (부모에게 전달)
      emit('update', formData) 
    } else {
      // 등록 API 호출 요청
      emit('register', formData)
    }
    
    isModalOpen.value = false
  }
  </script>
  
  <style scoped>
  .product-table-wrap { margin-top: 16px; }
  .product-table { width: 100%; border-collapse: collapse; font-size: 14px; }
  .product-table th, .product-table td { padding: 12px 16px; border-bottom: 1px solid #f3f4f6; text-align: left; white-space: nowrap; }
  .product-table thead { background: transparent; }
  .product-table th { font-size: 13px; color: #6b7280; font-weight: 500; }
  .desc { max-width: 320px; white-space: nowrap; text-overflow: ellipsis; overflow: hidden; }
  .actions { display: flex; gap: 8px; }
  .icon-btn { border: none; background: transparent; cursor: pointer; padding: 0; display: inline-flex; align-items: center; justify-content: center; }
  .empty { text-align: center; color: #9ca3af; }
  .pagination-controls { display: flex; justify-content: flex-end; align-items: center; gap: 12px; margin-top: 16px; padding: 0 16px; }
  .page-btn { padding: 6px 16px; border: 1px solid #e5e7eb; background-color: white; border-radius: 6px; font-size: 13px; cursor: pointer; color: #374151; transition: all 0.2s; }
  .page-btn:hover:not(:disabled) { background-color: #f3f4f6; border-color: #d1d5db; }
  .page-btn:disabled { opacity: 0.5; cursor: not-allowed; background-color: #f9fafb; }
  .page-info { font-size: 13px; color: #6b7280; }

  .table-header {display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
  .total-count { font-size: 14px; color: #6b7280; }
  .total-count strong { color: #111827; font-weight: 600; }

  .btn-register {padding: 8px 16px;  background-color: #16a34a; color: white; border: none; border-radius: 6px; font-size: 14px; font-weight: 500; cursor: pointer; transition: background-color 0.2s; }
  .btn-register:hover { background-color: #15803d; }

  .badge { display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 999px; font-size: 12px;}
  .badge-blue { background: #eef2ff; color: #4f46e5; }
  .badge-red { background: #fee2e2; color: #b91c1c; }
  .badge-green {  background: #dcfce7;  color: #166534; }
  </style>