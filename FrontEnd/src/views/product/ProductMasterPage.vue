<template>
  <div class="product-page">
    <!-- 검색 바 -->
    <ProductSearchBar
      v-model:searchText="searchValue"
      v-model:selectedStatus="selectedCategory"
      :statusList="categoryOptions"
      @search="handleSearch"
    />

    <!-- 테이블 -->
    <ProductTable
      :products="products"
      :is-last-batch="isLastApiBatch"
      :categories="categories"
      @needMoreData="fetchNextBatch"
      @register="registMasterData"
      @update="updateMasterData"
    />
  </div>
</template>

<script setup>
import { ref, computed , onMounted, watch} from 'vue'
import ProductSearchBar from '@/components/product/ProductSearchBar.vue'
import ProductTable from '@/components/product/ProductMasterTable.vue'
import { getProductMaster, getMasterCategoryCode , registMaster, updateMaster} from '@/api/product/productMasterAPI.js'

// 검색어
const searchValue = ref('')

// 선택된 카테고리(드롭다운)
const selectedCategory = ref('C000')
const apiPage = ref(0)          // API 요청용 페이지 번호
const products = ref([]) // 전체 상품 데이터
const categoryOptions = ref([]);
const categories = ref([]); 
const isLastApiBatch = ref(false) // API 마지막 페이지 상태

// 검색 
const fetchApiBatch = async (pageIdx) => {
  const data = await getProductMaster({
      page: pageIdx,
      size: 50, // 50개씩 요청
      codeOrName: searchValue.value,
      ...(selectedCategory.value === 'C000' ? {} : { categoryCode: selectedCategory.value })
    })

  if (data && data.content) {
      // 검색 할 때마다 데이터를 뒤에 이어 붙임
      products.value.push(...data.content)
      
      // 상태 업데이트
      isLastApiBatch.value = data.last
      apiPage.value = data.number
  }
}

onMounted(async() => {
  const master_category = await getMasterCategoryCode();
  categories.value = {...master_category};

  categoryOptions.value = master_category;
  categoryOptions.value.unshift({id:'C000', name:'전체'})
  await handleSearch();
})

//  자식 컴포넌트에서 서버에 다음페이지 요청 시 
const fetchNextBatch = async () => {
  if (!isLastApiBatch.value) {
    await fetchApiBatch(apiPage.value + 1)
  }
}

//  검색 (초기화) 
const handleSearch = async () => {
  products.value = []
  apiPage.value = 0
  isLastApiBatch.value = false
  
  await fetchApiBatch(0)
}

const registMasterData = async (masterData) => {
 await registMaster(masterData);
 handleSearch();
}


const updateMasterData = async (masterData) => {
 await updateMaster(masterData);
 handleSearch();
}

watch(selectedCategory,handleSearch );
</script>

<style scoped>
.product-page {
  padding: 24px 32px 32px;
  box-sizing: border-box;
}
</style>