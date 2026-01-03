<template>
  <div class="modal-backdrop" >
    <div class="modal-container">
      
      <div class="modal-header">
        <h3 class="title">
          {{ currentMode === 'FORM' ? '렌탈 계약 등록' : '수급자 검색' }}
        </h3>
        <button class="close-btn" @click="handleClose">×</button>
      </div>

      <div class="modal-body" v-if="currentMode === 'FORM'">
        <div class="form-group">
          <label>담당 직원</label>
          <input type="text" :value="loginEmpName" disabled class="input-disabled" />
        </div>

        <div class="form-group">
          <label>수급자</label>
          <div class="search-input-group">
            <input 
              type="text" 
              placeholder="수급자를 검색하세요" 
              :value="form.beneficiaryName" 
              readonly 
              @click="currentMode = 'SEARCH_USER'"
            />
            <button class="search-btn" @click="currentMode = 'SEARCH_USER'">검색</button>
          </div>
        </div>

        <div class="form-group">
          <label>렌탈 제품 (마스터)</label>
          <div class="search-input-group">
            <input 
              type="text" 
              :value="form.productName" 
              readonly 
              class="input-disabled"
            />
          </div>
        </div>

        <div class="form-row">
          <div class="form-group half">
            <label>희망 배송일</label>
            <input type="date" v-model="form.wantedDate" :min="minDate" />
          </div>
          <div class="form-group half">
            <label>계약 기간 (개월)</label>
            <select v-model="form.termMonth">
              <option :value="12">12개월</option>
              <option :value="24">24개월</option>
              <option :value="36">36개월</option>
              <option :value="48">48개월</option>
            </select>
          </div>
        </div>
      </div>

      <div class="modal-body" v-else-if="currentMode === 'SEARCH_USER'">
        <div class="inner-search-bar">
          <input v-model="userSearchKeyword" @keyup.enter="searchUser" placeholder="수급자 이름 입력" />
          <button @click="searchUser">조회</button>
        </div>
        <ul class="result-list">
          <li v-for="user in userList" :key="user.id" @click="selectUser(user)">
            <span class="name">{{ user.name }}</span>
            <span class="info">({{ user.birthDate }}, {{ user.phone }})</span>
          </li>
          <li v-if="userList.length === 0" class="no-result">검색 결과가 없습니다.</li>
        </ul>
      </div>

      <div class="modal-footer">
        <template v-if="currentMode === 'FORM'">
          <button class="cancel-btn" @click="$emit('close')">취소</button>
          <button class="save-btn" @click="submitContract">계약 등록</button>
        </template>
        <template v-else>
          <button class="cancel-btn" @click="currentMode = 'FORM'">뒤로가기</button>
        </template>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue';
import { createRentalContract } from '@/api/product/rentalAPI';
import { getBeneficaryForRental } from '@/api/product/productAPI';
import { useUserStore } from '@/stores/user'

const userStore = useUserStore();

const props = defineProps({
  initialProduct: {
    type: Object,
    default: null
  }
});

const emit = defineEmits(['close', 'result']);

const currentMode = ref('FORM');
// 로그인 정보 (실제 구현 시 Store 등에서 가져오기)
const loginEmpId = 10; 
const loginEmpName = userStore.name;

const form = reactive({
  beneficiaryId: '',
  beneficiaryName: '',
  productCd: '',
  productName: '',
  wantedDate: '',
  termMonth: 24,
});

// 모달 열릴 때 초기값 세팅
onMounted(() => {
  if (props.initialProduct) {
    form.productCd = props.initialProduct.id;
    form.productName = props.initialProduct.productName;
  }
});

// === 수급자 검색 로직 ===
const userSearchKeyword = ref('');
const userList = ref([]);

const searchUser = async () => {
    const data = await getBeneficaryForRental(userSearchKeyword.value)
    userList.value = data == null ? [] : data ;
};

const selectUser = (user) => {
  form.beneficiaryId = user.id;
  form.beneficiaryName = user.name;
  currentMode.value = 'FORM';
};


const minDate = computed(() => {
  const now = new Date();
  const offset = now.getTimezoneOffset() * 60000;
  const localISOTime = new Date(now - offset).toISOString().split('T')[0];
  return localISOTime;
});

// === 등록 제출 ===
const submitContract = async () => {
  
  
    if (!form.beneficiaryId || !form.productCd || !form.wantedDate) {
    alert("필수 정보를 모두 입력해주세요.");
    return;
  } 

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  // 사용자가 선택한 날짜를 Date 객체로 변환
  const selectedDate = new Date(form.wantedDate);
  selectedDate.setHours(0, 0, 0, 0); // 비교를 위해 시간 초기화

  if (selectedDate < today){
    alert("배송 희망일은 오늘 이후여야 합니다.");
    return;
  }

  const payload = {
    beneficiaryId: form.beneficiaryId,
    empId: loginEmpId,
    productCd: form.productCd, // EM001 같은 마스터 코드 전송
    wantedDate: form.wantedDate,
    termMonth: form.termMonth
  };

  try {
    const data = await createRentalContract(payload);
    if(data !== null)
        emit('result', '성공'); 
    else
        emit('result', '실패'); 

    emit('close');
  } catch (error) {
    console.error(error);
    emit('result', '실패'); 
  }
};

const handleClose = () => {
  emit('close');
}
</script>

<style scoped>
/* 1. 모달 배경 및 컨테이너 */
.modal-backdrop {
  position: fixed; top: 0; left: 0;
  width: 100vw; height: 100vh;
  background: rgba(0, 0, 0, 0.4);
  display: flex; justify-content: center; align-items: center;
  z-index: 9999;
  backdrop-filter: blur(2px);
}

.modal-container {
  background: white;
  width: 480px;
  border-radius: 16px;
  box-shadow: 0 10px 25px rgba(0,0,0,0.15);
  overflow: hidden;
  display: flex; flex-direction: column;
  max-height: 85vh;
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from { transform: translateY(20px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

/* 2. 헤더 */
.modal-header {
  padding: 20px 24px;
  border-bottom: 1px solid #f3f4f6;
  display: flex; justify-content: space-between; align-items: center;
  background-color: #ffffff;
}
.title {
  font-size: 18px; font-weight: 700; color: #111827; margin: 0;
}
.close-btn {
  background: none; border: none; font-size: 24px; cursor: pointer; color: #9ca3af;
  transition: color 0.2s;
}
.close-btn:hover { color: #4b5563; }

/* 3. 본문 공통 */
.modal-body {
  padding: 24px;
  overflow-y: auto;
  background-color: #fff;
}

/* 4. 폼 스타일 (여기가 빠져서 깨졌던 것입니다) */
.form-group { margin-bottom: 20px; }
.form-group label {
  display: block; font-size: 13px; font-weight: 600; color: #4b5563; margin-bottom: 8px;
}
.form-group input, .form-group select {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-size: 14px;
  box-sizing: border-box;
  outline: none;
  transition: border-color 0.2s;
}
.form-group input:focus, .form-group select:focus {
  border-color: #3b82f6;
}
.input-disabled {
  background-color: #f3f4f6; color: #6b7280; cursor: not-allowed;
}

.search-input-group {
  display: flex; gap: 8px; width: 100%;
}
.search-btn {
  padding: 0 16px;
  background: #3b82f6; color: white;
  border: none; border-radius: 8px;
  font-size: 14px; font-weight: 600;
  cursor: pointer; white-space: nowrap;
}
.form-row {
  display: flex; gap: 16px;
}
.half { flex: 1; }

/* 5. 내부 검색창 (수급자 검색용) */
.inner-search-bar {
  display: flex; gap: 10px; margin-bottom: 20px;
  background-color: #f9fafb; padding: 8px;
  border-radius: 12px; border: 1px solid #e5e7eb;
}
.inner-search-bar input {
  flex: 1; border: none; background: transparent; padding: 8px 12px;
  font-size: 14px; outline: none;
}
.inner-search-bar button {
  background-color: #3b82f6; color: white; border: none; border-radius: 8px;
  padding: 8px 16px; font-size: 14px; font-weight: 600; cursor: pointer;
}

/* 6. 검색 결과 리스트 */
.result-list {
  list-style: none; padding: 0; margin: 0;
  border: 1px solid #e5e7eb; border-radius: 12px;
  max-height: 320px; overflow-y: auto;
}
.result-list li {
  padding: 14px 16px; border-bottom: 1px solid #f3f4f6;
  cursor: pointer; display: flex; justify-content: space-between; align-items: center;
}
.result-list li:last-child { border-bottom: none; }
.result-list li:hover { background-color: #eff6ff; }
.result-list .name { font-weight: 600; color: #374151; font-size: 15px; }
.result-list .info { font-size: 13px; color: #6b7280; }
.no-result { padding: 40px 0; text-align: center; color: #9ca3af; font-size: 14px; }

/* 7. 푸터 버튼 */
.modal-footer {
  padding: 20px 24px; border-top: 1px solid #f3f4f6;
  display: flex; justify-content: flex-end; gap: 10px;
  background-color: #ffffff;
}
.cancel-btn {
  padding: 10px 18px; background-color: white; border: 1px solid #d1d5db;
  border-radius: 8px; color: #4b5563; font-weight: 500; font-size: 14px; cursor: pointer;
}
.cancel-btn:hover { background-color: #f9fafb; }
.save-btn {
  padding: 10px 18px; background-color: #16a34a; color: white; border: none;
  border-radius: 8px; font-weight: 600; font-size: 14px; cursor: pointer;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
.save-btn:hover { background-color: #15803d; }
</style>