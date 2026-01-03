<template>
  <div class="manage-page">
    <!-- 왼쪽: 검색 + 테이블들 -->
    <div class="manage-main">
      
      <!-- 검색 바 -->
      <ProductSearchBar
        v-model:searchText="searchMasterValue"
        v-model:selectedStatus="selectedCategory"
        :statusList="categoryOptions"
        @search="handleSearchForMaster"
      />

      <!-- 상단 관리 용품 리스트 -->
      <ProductManageTable
        :products="masterProducts"
        :is-last-batch="isLastMasterApiBatch"
        :selected-id="selectedProduct?.id ?? null"
        :categories="categorymaster"
        @needMoreData="fetchNextMasterBatch"
        @row-click="handleRowClick"
        @open-rental="handleOpenRentalModal"
      />

      <br>
      <!-- 검색 바 -->
      <ProductSearchBar
        v-model:selectedStatus="selectedStatus"
        :statusList="productStatusOptions"
        :show-input="false"
      />

      <!-- 하단 상세 현황 -->
      <ProductManageDetailTable
        :products="ProductsDetail"
        :is-last-batch="isLastProductsApiBatch"
        :selected-detail-id="selectedDetailRow?.id ?? null"
        :selected-product-name="selectedMasterName"
        @row-click="handleDetailRowClick"
        @needMoreData="fetchNextProductBatch"
      />
    </div>

    <ProductHistoryPanel
      :product="selectedProduct"
      :detail-row="selectedDetailRow"
      :events="selectedHistoryEvents"
      :is-last-batch="isLastHistoryApiBatch"
      @close="selectedDetailRow = null"
      @needMoreData="fetchNextHistoryBatch"
    />

    <RentalRegisterModal
      v-if="isRentalModalOpen"
      :initial-product="targetRentalProduct"
      @close="isRentalModalOpen = false"
      @result="handleRentalResult"
    />
  </div>
</template>

<script setup>
import { ref, computed ,onMounted, watch} from 'vue'
import searchIcon from '@/assets/img/common/search.png'
import { getMasterDetail, getMasterCategoryCode, getProductStatus, getProducts, getProductHistory } from '@/api/product/productAPI.js'

import ProductSearchBar from '@/components/product/ProductSearchBar.vue'
import { productManageMock } from '@/mock/product/productManageMock.js'
import { productManageDetailMock } from '@/mock/product/productManageDetailMock.js'
import { productHistoryMock } from '@/mock/product/productHistoryMock.js'

import ProductManageTable from '@/components/product/ProductManageTable.vue'
import ProductManageDetailTable from '@/components/product/ProductManageDetailTable.vue'
import ProductHistoryPanel from '@/components/product/ProductHistoryPanel.vue'
import RentalRegisterModal from '@/components/product/RentalRegisterModal.vue'

import { useToast } from '@/lib/toast'
const {success, error : toastError , info} = useToast();

const selectedMasterName = ref('');

// 검색어
const searchMasterValue = ref('')
const searchProductsValue = ref('')

// 선택된 카테고리(드롭다운)
const selectedCategory = ref('C000')
const selectedStatus = ref(0)
const productsApiPage = ref(0)          // 제품 정보 페이지 번호
const masterApiPage = ref(0)          // 마스터 정보 페이지 번호
const historyApiPage = ref(0)          // 제품 이력 정보 페이지 번호
let productMap = new Map(); // key: master, value: List<Product> 제품 정보
let historyMap = new Map(); // key: master, value: List<Product_history> 제품  이력 정보
const masterProducts = ref([]) // 마스터 정보 리스트
const ProductsDetail = ref([]) // 제품 정보 리스트
const historyData = ref([]) // 제품 이력 리스트
const categoryOptions = ref([]);
const productStatusOptions = ref([]);
const categorymaster = ref([]); 
const productStatuses = ref([]);
const isLastMasterApiBatch = ref(false) // 마스터정보 마지막 페이지 상태
const isLastProductsApiBatch = ref(false) // 제품 정보 마지막 페이지 상태
const isLastHistoryApiBatch = ref(false) // 제품 이력 정보 마지막 페이지 상태
const selectedHistoryEvents = ref([]); //하위에서 제품 선택시 해당 제품의 히스토리 데이터

const pageSIze = 5;


onMounted(async() => {
  const master_category = await getMasterCategoryCode();
  categorymaster.value = {...master_category};
  categoryOptions.value = master_category;
  categoryOptions.value.unshift({id:'C000', name:'전체'})

  const product_statusData = await getProductStatus();
  productStatuses.value = {...product_statusData};
  productStatusOptions.value = product_statusData;
  productStatusOptions.value.unshift({id: 0 , name:'전체'})

  await handleSearchForMaster();
})


// 검색 
const fetchMasterApiBatch = async (pageIdx) => {
  const data = await getMasterDetail({
      page: pageIdx,
      size: pageSIze, // 50개씩 요청
      codeOrName: searchMasterValue.value,
      ...(selectedCategory.value === 'C000' ? {} : { categoryCode: selectedCategory.value })
    })

  if (data && data.content) {
      // 검색 할 때마다 데이터를 뒤에 이어 붙임
      masterProducts.value.push(...data.content)
      
      // 상태 업데이트
      isLastMasterApiBatch.value = data.last
      masterApiPage.value = data.number
  }
  console.log('masterProducts',masterProducts.value);
}

//  자식 컴포넌트에서 서버에 다음페이지 요청 시 
const fetchNextMasterBatch = async () => {
  if (!isLastMasterApiBatch.value) {
    await fetchMasterApiBatch(masterApiPage.value + 1)
  }
}

const searchTerm = ref('')
const stockFilter = ref('all')

// 전체 데이터
const allItems = ref(productManageMock)

// 상단 리스트 필터링
const filteredItems = computed(() => {
  let list = allItems.value

  // 재고 필터
  if (stockFilter.value === 'hasStock') {
    list = list.filter((i) => i.totalStock > 0)
  } else if (stockFilter.value === 'zero') {
    list = list.filter((i) => i.totalStock === 0)
  }

  // 검색
  if (searchTerm.value) {
    const keyword = searchTerm.value.toLowerCase()
    list = list.filter(
      (i) =>
        i.name.toLowerCase().includes(keyword) ||
        i.code.toLowerCase().includes(keyword)
    )
  }

  return list
})

// 선택된 상단 용품
const selectedProduct = ref(null)

const handleRowClick = (item) => {
  selectedProduct.value = item

  selectedDetailRow.value = null
  selectedHistoryEvents.value = []
  productsApiPage.value = 0
  selectedMasterName.value = selectedProduct.value.name;

  const productCode = selectedProduct.value.id
  
    if(!productMap.has(productCode)) 
      fetchProductApiBatch(productsApiPage);
    else {
      const savedState = productMap.get(productCode);
    
      ProductsDetail.value = [...savedState.content];    // 데이터 복구
      productsApiPage.value = savedState.page;           // 페이지 번호 복구
      isLastProductsApiBatch.value = savedState.isLast;  // 마지막 여부 복구
    }
}

// 선택된 용품의 상세 데이터
const selectedDetailItems = computed(() => {
  if (!selectedProduct.value) return []

  if(!productMap.has(selectedProduct.value.id)) {
    
  }

  return productManageDetailMock.filter(
    (row) => row.productCode === selectedProduct.value.code
  )
})



//  자식 컴포넌트에서 서버에 다음페이지 요청 시 
const fetchNextProductBatch = async () => {
  if (!isLastProductsApiBatch.value) {
    await fetchProductApiBatch(masterApiPage.value + 1)
  }
}


// 검색 
const fetchProductApiBatch = async (pageIdx) => {
  
  const productCode = selectedProduct.value.id;


  const data = await getProducts({
      page: pageIdx,
      size: pageSIze, // 50개씩 요청
      productCode : productCode,
      productStatus: selectedStatus.value,
    })

  if (data && data.content) {
    // 해당 제품의 데이터 공간이 없으면 초기화 (객체 형태)
    if(!productMap.has(productCode)) {
        productMap.set(productCode, {
        content: [],      // 상세 리스트 데이터
        page: 0,          // 현재 페이지 번호
        isLast: false     // 마지막 페이지 여부
      });
    }

    // Map에서 상태 객체 가져오기
    const targetState = productMap.get(productCode);

    // 데이터 누적 및 상태 업데이트
    targetState.content.push(...data.content);
    targetState.page = data.number;
    targetState.isLast = data.last;

    // 화면에 반영 (전역 변수 업데이트)
    ProductsDetail.value = [...targetState.content];
    isLastProductsApiBatch.value = targetState.isLast; // 전역 상태 업데이트
    productsApiPage.value = targetState.page;          // 전역 페이지 업데이트
  }
}

// 상세 행 선택 + 히스토리 패널
const selectedDetailRow = ref(null)
const isHistoryOpen = ref(false)


const handleDetailRowClick = async (row) => {
  const productCode = row.id;
  selectedDetailRow.value = row

    if(!historyMap.has(productCode)) {
      historyApiPage.value = 0; // 페이지 번호 초기화
      isLastHistoryApiBatch.value = false;
      await fetchHistory(0);
    }
    else {
      const savedState = historyMap.get(productCode);
    
      selectedHistoryEvents.value = [...savedState.content]; // 데이터 복구
      historyApiPage.value = savedState.page;                // 페이지 번호 복구
      isLastHistoryApiBatch.value = savedState.isLast;       // 마지막 여부 상태 복구
      
      // selectedHistoryEvents.value = historyMap.get(productCode);
    }
  
}


//  자식 컴포넌트(이력조회)에서 서버에 다음페이지 요청 시 
const fetchNextHistoryBatch = async () => {
  if (!isLastHistoryApiBatch.value) {
    await fetchHistory(historyApiPage.value + 1)
  }
}


const fetchHistory = async (pageIdx = 0) => {
  const productCode = selectedDetailRow.value.id;

  try {
    const data = await getProductHistory({
      page: pageIdx,
      size: pageSIze,
      productId: productCode,
    });
    
    if (data && data.content) {
      if(!historyMap.has(productCode)) {
        historyMap.set(productCode, {
          content: [],      // 리스트 데이터
          page: 0,          // 현재 페이지 번호
          isLast: false     // 마지막 페이지 여부
        });
      }

      // Map에서 해당 제품의 상태 객체 가져오기
      const targetState = historyMap.get(productCode);

      // 데이터 누적 및 상태 업데이트
      targetState.content.push(...data.content);
      targetState.page = data.number;
      targetState.isLast = data.last;

      // 화면에 반영 (반응형 변수 업데이트)
      selectedHistoryEvents.value = [...targetState.content];
      historyApiPage.value = targetState.page;
      isLastHistoryApiBatch.value = targetState.isLast;
    }
  } catch (error) {
    // selectedHistoryEvents.value = [];
  }
  
};




//  검색 (초기화) 
const handleSearchForMaster = async () => {
  masterProducts.value = []
  masterApiPage.value = 0
  isLastMasterApiBatch.value = false
  
  selectedDetailRow.value = null; 
  selectedHistoryEvents.value = [];
  selectedProduct.value = null;

  handleSearchForProduct()
  await fetchMasterApiBatch(0)
}


//  검색 (초기화) 
const handleSearchForProduct = async () => {
  productMap = new Map(); 
  historyMap = new Map();
  ProductsDetail.value = [];
  selectedHistoryEvents.value = [];
  productsApiPage.value = 0
  isLastProductsApiBatch.value = false;

  historyApiPage.value = 0;
  isLastHistoryApiBatch.value = false;
  
  // await fetchProductApiBatch(0)
}




watch(selectedCategory, handleSearchForMaster );

// watch(selectedStatus, handleSearchForMaster );

watch(selectedStatus, async () => {
  // 제품이 선택되어 있을 때만 상세 리스트를 갱신
  if (selectedProduct.value) {
    const productCode = selectedProduct.value.id;

    // 1. 페이지 번호 초기화
    productsApiPage.value = 0; 
    
    // 필터가 바뀌었으므로 기존에 저장된 캐시 삭제
    if(productMap.has(productCode)) {
       productMap.delete(productCode); 
    }
    ProductsDetail.value = []; 

    //데이터 다시 요청
    await fetchProductApiBatch(0);
  }
});


// 모달 관련 변수
const isRentalModalOpen = ref(false);
const targetRentalProduct = ref(null);


// 렌탈 등록 버튼 클릭 핸들러
const handleOpenRentalModal = (masterItem) => {
  console.log("렌탈 계약 시도:", masterItem);
  
  // 모달에 넘겨줄 마스터 제품 정보
  targetRentalProduct.value = {
    id: masterItem.id,        // 예: EM001
    productName: masterItem.name // 예: 전동침대
  };
  
  isRentalModalOpen.value = true;
};

// 등록 성공 시 처리
const handleRentalResult = (result) => {
  // 재고 수량이 변경되었을 수 있으므로 마스터 리스트 새로고침
  // handleSearchForMaster()를 호출하면 검색어 등 조건 유지한 채 리로드
  if(result === '성공')
  {
    success('렌탈 등록',{description: '렌탈 계약 등록에 성공 했습니다.' });
    handleSearchForMaster();
  } else {
    toastError('렌탈 등록',{description: '렌탈 계약 등록에 실패 했습니다.' });
  }

};


</script>

<style scoped>
.manage-page {
  padding: 24px 2px 32px;
  box-sizing: border-box;
  display: flex;
  align-items: flex-start;
  gap: 10px;
  width: 100%;       
  overflow-x: hidden; 
}

/* 왼쪽 영역은 남는 공간 전부 */
.manage-main {
  flex: 1;
  min-width: 0;
}

:deep(.product-history-panel) { 
  width: 360px;      
  flex-shrink: 0;    
  position: sticky;  
  top: 24px;
}

/* 검색 / 셀렉트 영역 */
.top-filter-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.search-input-wrap {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
  background: #ffffff;
}

.search-icon {
  width: 18px;
  height: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.search-icon img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.search-input-wrap input {
  flex: 1;
  border: none;
  outline: none;
  background: transparent;
  font-size: 14px;
}

.stock-select {
  min-width: 120px;
  padding: 10px 12px;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
  background: #ffffff;
  font-size: 14px;
}
</style>