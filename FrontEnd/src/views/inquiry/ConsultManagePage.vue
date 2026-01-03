<template>
  <div class="page-container">
    <div class="page-header">
      <h2>상담 관리</h2>
    </div>

    <div class="upper-column">
      
      <div class="grid-item">
        <div class="card search-card">
          <CustomerSearchCard @select-customer="handleSelectCustomer" />
        </div>
      </div>

      <div class="grid-item list-wrapper">
        <CounselList 
          :selected-customer="currentCustomer" 
          @select-counsel-detail="handleSelectCounselDetail"
        />
      </div>
      
    </div>

    <div class="bottom-column">
      
      <div class="grid-item">
        <CounselWriteCard
        :selected-customer="currentCustomer"
        @update:category="handleCategoryChange" 
        @reset="handleResetCustomer" />
      </div>

      <div class="grid-item detail-container">
        <div class="help-wrapper">
          <CounselHelpDetail
          :category="currentCategory"
          :counsel-detail="currentCounselDetail"
          :customer="currentCustomer"
          />
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import CustomerSearchCard from '@/components/inquiry/Counsel/CustomerSearchCard.vue';
import CounselList from '@/components/inquiry/Counsel/CounselList.vue';
import CounselWriteCard from '@/components/inquiry/Counsel/CounselWriteCard.vue';
import CounselHelpDetail from '@/components/inquiry/Counsel/CounselHelpDetail.vue';
import CounselDetailCard from '@/components/inquiry/Counsel/CounselDetailCard.vue';
import SubscriptProcess from '@/components/inquiry/Counsel/Process/SubscriptProcess.vue';

// 상태 관리
const currentCustomer = ref(null);
const currentCounselDetail = ref(null);
const currentCategory = ref('');

// 이벤트 핸들러
const handleSelectCustomer = (customer) => {
  console.log('선택된 고객:', customer);
  currentCustomer.value = customer;
  currentCounselDetail.value = null; 
};

const handleSelectCounselDetail = (detailData) => {
  console.log('선택된 상담 상세:', detailData);
  currentCounselDetail.value = detailData;
};

const handleCategoryChange = (newCategory) => {
  console.log('작성 카테고리 변경됨:', newCategory);
  currentCategory.value = newCategory;
};

const handleResetCustomer = () => {
  console.log('고객 선택 초기화');
  currentCustomer.value = null;
  currentCounselDetail.value = null;
};
</script>

<style scoped>
/* ✅ 페이지는 스크롤 가능해야 하므로 "고정 height"를 없애고 min-height로 처리 */
.page-container {
  width: 100%;
  max-width: 1600px;
  margin: 0 auto;
  padding: 0 0 40px;
  display: flex;
  flex-direction: column;
  gap: 24px;
  box-sizing: border-box;

  /* 핵심: 고정 높이 제거 */
  min-height: 100vh;
}

.page-header {
  flex: 0 0 auto;
}

/* ✅ [1] upper-column: 무한 스크롤을 위한 "고정 높이" 영역 */
.upper-column {
  /* 고정 높이(뷰포트 기반) + 최소/최대 */
  height: clamp(420px, 45vh, 560px);
  min-height: 420px;

  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
  gap: 24px;

  /* 내부 스크롤(리스트)만 허용하기 위해 영역 자체는 넘침 숨김 */
  overflow: hidden;
  align-items: stretch; /* 각 칸이 높이를 꽉 채우게 */
}

/* ✅ upper 내부의 카드/래퍼는 "부모 높이를 100%"로 꽉 채우도록 */
.grid-item {
  min-width: 0;
  min-height: 0; /* 중요: grid 자식 overflow 안정화 */
}

/* 카드 공통 */
.card {
  background: white;
  border-radius: 10px;
  border: 1px solid #E5E7EB;
  display: flex;
  flex-direction: column;
  overflow: hidden;

  height: 100%;     /* upper에서 칸 높이 꽉 채우기 */
  min-height: 0;    /* 중요 */
}

/* 검색 카드도 동일하게 */
.search-card {
  height: 100%;
  min-height: 0;
}

/* ✅ 리스트 래퍼: 여기(또는 CounselList 내부)에서만 스크롤이 일어나게 */
.list-wrapper {
  height: 100%;
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden; /* 스크롤은 내부(실제 리스트)에 맡김 */
}

/* (권장) CounselList의 최상위 컨테이너에 아래처럼 적용되면 가장 깔끔합니다.
   - 부모(list-wrapper)가 flex column이므로 CounselList 루트가 flex:1로 늘어나야 함
   - 그 내부에서 overflow:auto 로 스크롤
*/
/*
.list-wrapper :deep(.counsel-list-root) {
  flex: 1;
  min-height: 0;
  overflow: auto;
}
*/

/* ✅ [2] bottom-column: 내용에 따라 자연스럽게 늘어나는 영역 */
.bottom-column {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
  gap: 24px;

  /* 핵심: 높이/overflow로 막지 않기 */
  align-items: start;      /* 내용 위쪽부터 자연스럽게 쌓이게 */
  align-content: start;
}

/* 우측 하단: 상세 + 도움말 스택 */
.detail-container {
  display: flex;
  flex-direction: column;
  gap: 20px;

  min-height: 0; /* 내부 overflow 안정화 */
}

.detail-card-wrapper {
  /* 내용만큼 */
}

.help-wrapper {
  /* 내용만큼 */
}

/* ✅ 반응형 */
@media (max-width: 1200px) {
  .upper-column {
    grid-template-columns: 1fr;
    height: clamp(520px, 55vh, 720px); /* 모바일에서 upper 조금 더 확보 */
  }

  .bottom-column {
    grid-template-columns: 1fr;
  }
}
</style>