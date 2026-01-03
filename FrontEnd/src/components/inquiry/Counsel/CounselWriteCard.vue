<template>
  <div class="card write-section">
    <div class="card-header simple flex-between">
      <div class="header-title">상담 작성</div>
      
      <div class="right-group">
        <button class="btn-new-green" @click="resetForm">신규 상담</button>

        <div class="dropdown-trigger" @click="toggleDropdown">
          <span>{{ form.category }}</span>
          <div class="arrow-down"></div>
          
          <div v-if="isDropdownOpen" class="dropdown-menu">
            <div class="dropdown-item" @click.stop="selectCategory('유형선택')">유형선택</div>
            <div class="dropdown-item" @click.stop="selectCategory('가입상담')">가입상담</div>
            <div class="dropdown-item" @click.stop="selectCategory('렌탈상담')">렌탈상담</div>
            <div class="dropdown-item" @click.stop="selectCategory('문의상담')">문의상담</div>
            <div class="dropdown-item" @click.stop="selectCategory('컴플레인')">컴플레인</div>
            <div class="dropdown-item" @click.stop="selectCategory('해지상담')">해지상담</div>
          </div>
        </div>
      </div>
    </div>
    
    <div class="form-body">
      <div class="form-group">
        <div class="sub-title">고객 정보</div>
        <div class="info-grid">
          <div class="info-row">
            <span class="label">수급자 이름</span>
            <div v-if="selectedCustomer" class="value">{{ selectedCustomer.name }}</div>
            <input 
              v-else 
              v-model="form.name" 
              class="compact-input" 
              placeholder="" 
            />
          </div>
          <div class="info-row">
            <span class="label">전화번호</span>
            <div v-if="selectedCustomer" class="value">{{ selectedCustomer.phone }}</div>
            <input 
              v-else 
              v-model="form.phone" 
              class="compact-input" 
              placeholder="" 
            />
          </div>
        </div>
      </div>

      <div class="form-group">
        <div class="checkbox-row" @click="toggleChurn">
          <div class="checkbox" :class="{ checked: isChurned }">
            <div v-if="isChurned" class="check-mark"></div>
          </div>
          <span class="check-label">고객 이탈 여부</span>
        </div>
        <div v-if="isChurned" class="churn-reason-box">
          <textarea 
            class="churn-input" 
            placeholder="이탈 사유를 상세히 입력해주세요."
          ></textarea>
        </div>
      </div>

      <div class="form-group">
        <div class="checkbox-row2" @click="toggleNecessary">
          <div class="checkbox blue" :class="{ checked: isNecessary }">
            <div v-if="isNecessary" class="check-mark"></div>
          </div>
          <span class="check-label">후속 조치 여부</span>
        </div>
        <div v-if="isNecessary" class="follow-up-box">
          <textarea 
            class="follow-up-input" 
            placeholder="필요한 후속 조치를 입력해주세요."
          ></textarea>
        </div>
      </div>

      <div class="form-group">
        <div class="sub-title">상담 내용</div>
        <div class="memo-area">
          <textarea class="memo-input" placeholder="상담 내용을 자유롭게 기록해주세요"></textarea>
          <button class="counsel-save-btn">상담 내용 저장</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, watch } from 'vue';

const props = defineProps({
  selectedCustomer: {
    type: Object,
    default: null
  }
});

// 부모에게 이벤트를 보낼 정의
const emit = defineEmits(['update:category', 'reset']);
// 신규 고객일 때 입력할 데이터를 담을 form 객체 (반응형)
const form = reactive({
  category: '유형선택',
  name: '',
  phone: ''
});

// [추가] selectedCustomer 변경 감지하여 form 데이터 동기화
watch(() => props.selectedCustomer, (newCustomer) => {
  if (newCustomer) {
    form.name = newCustomer.name;
    form.phone = newCustomer.phone;
  } else {
    // 고객 선택이 해제되면 폼도 비워주거나 유지(여기서는 비움)
    form.name = '';
    form.phone = '';
  }
}, { immediate: true });

const resetForm = () => {
  form.category = '가입상담';
  form.name = '';
  form.phone = '';
  isChurned.value = false;
  isNecessary.value = false;
  emit('reset');
};

const isDropdownOpen = ref(false);

const toggleDropdown = () => {
  isDropdownOpen.value = !isDropdownOpen.value;
};

const selectCategory = (label) => {
  form.category = label; // 화면 표시용 업데이트
  isDropdownOpen.value = false;
  emit('update:category', label);
};

const isChurned = ref(false);
const toggleChurn = () => {
  isChurned.value = !isChurned.value;
};
const isNecessary = ref(false);
const toggleNecessary = () => {
  isNecessary.value = !isNecessary.value;
};
</script>

<style scoped>
/* Card & Header Styles from previous context */
.card { background: white; border-radius: 10px; border: 1px solid #E5E7EB; display: flex; flex-direction: column; overflow: visible; /* 드롭다운 위해 visible */ min-height: 340px; }
.card-header { padding: 16px; border-bottom: 1px solid #E5E7EB; display: flex; gap: 12px; }
.simple { padding-bottom: 15px; }
.flex-between { flex-direction: row; justify-content: space-between; align-items: center; }
.header-title { color: #388E3C; font-size: 20px; font-weight: 600; line-height: 28px; }

/* Dropdown */
.dropdown-trigger { position: relative; display: flex; align-items: center; gap: 8px; border: 1px solid #CCCCCC; border-radius: 6px; padding: 6px 12px; font-size: 14px; color: #6F6F6F; cursor: pointer; }
.arrow-down { width: 0; height: 0; border-left: 5px solid transparent; border-right: 5px solid transparent; border-top: 5px solid black; }
.dropdown-menu { position: absolute; top: 100%; right: 0; background: white; border: 1px solid #E5E7EB; border-radius: 6px; width: 120px; z-index: 10; margin-top: 4px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
.dropdown-item { padding: 8px 12px; font-size: 14px; color: #333; }
.dropdown-item:hover { background-color: #F3F4F6; }

/* Form Styles */
.form-body { padding: 20px; display: flex; flex-direction: column; gap: 20px; background-color: #F9FAFB; flex: 1; }
.sub-title { color: #6A7282; font-size: 14px; margin-bottom: 12px; }
.info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px 24px; }
.info-row { display: flex; flex-direction: column; gap: 4px; }
.label { color: #6A7282; font-size: 12px; }
.value { color: #101828; font-size: 16px; }
/* [수정됨] 체크박스 스타일 */
.checkbox-row { display: flex; align-items: center; gap: 12px; padding: 16px; background: #FEF2F2; border: 1px solid #FFE2E2; border-radius: 14px; cursor: pointer; transition: background 0.2s; }
.checkbox-row:hover { background: #fee2e2; } /* 호버 효과 */
.checkbox-row2 {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: #EFF6FF; /* 파란색 배경 (기존 #FEF2F2에서 변경) */
  border: 1px solid #BFDBFE; /* 파란색 테두리 (기존 #FFE2E2에서 변경) */
  border-radius: 14px;
  cursor: pointer;
  transition: background 0.2s;
}
.checkbox-row2:hover {
  background: #DBEAFE; /* 호버 시 진한 파란색 (기존 #fee2e2에서 변경) */
}
.checkbox { 
  width: 18px; height: 18px; 
  background: white; 
  border: 1px solid #D1D5DB; 
  border-radius: 4px; 
  display: flex; justify-content: center; align-items: center;
}

/* 체크되었을 때 스타일 */
.checkbox.checked {
  background: #EF4444; /* 빨간색 (이탈 느낌) */
  border-color: #EF4444;
}

/* 체크 아이콘 (흰색 체크) */
.check-mark {
  width: 5px; height: 9px;
  border: solid white;
  border-width: 0 2px 2px 0;
  transform: rotate(45deg);
  margin-bottom: 2px; /* 위치 미세 조정 */
}

.check-label { color: #364153; font-size: 14px; user-select: none; }

/* [추가됨] 이탈 사유 입력창 스타일 */
.churn-reason-box {
  margin-top: 12px; /* 체크박스와 간격 */
  background: #FFF5F5; /* 연한 빨간색 배경 */
  border: 1px solid #FECACA;
  border-radius: 14px;
  padding: 12px;
}

.churn-input {
  width: 100%;
  height: 60px; /* 상담 내용보다는 조금 작게 */
  padding: 8px;
  border: 1px solid #E5E7EB;
  border-radius: 8px;
  resize: none;
  font-family: inherit;
  font-size: 14px;
  outline: none;
  box-sizing: border-box;
}
.churn-input:focus { border-color: #EF4444; } /* 포커스 시 빨간색 테두리 */
.check-label { color: #364153; font-size: 14px; }
.memo-area { background: #FFFBEB; border: 1px solid #FEF3C6; border-radius: 14px; padding: 20px; display: flex; flex-direction: column; gap: 12px; }
.memo-input { width: 100%; height: 100px; padding: 12px; border: none; border-radius: 8px; resize: none; font-family: inherit; box-sizing: border-box; }
.counsel-save-btn { width: 100%; height: 32px; background: #FF8A3C; color: white; border: none; border-radius: 8px; font-size: 14px; cursor: pointer; }
.follow-up-box {
  margin-top: 12px;
  background: #EFF6FF; /* 아주 연한 파란색 배경 */
  border: 1px solid #BFDBFE; /* 연한 파란색 테두리 */
  border-radius: 14px;
  padding: 12px;
  display: flex;
  flex-direction: column;
  gap: 8px; /* 입력창과 버튼 사이 간격 */
}

.follow-up-input {
  width: 100%;
  height: 60px;
  padding: 8px;
  border: 1px solid #E5E7EB;
  border-radius: 8px;
  resize: none;
  font-family: inherit;
  font-size: 14px;
  outline: none;
  box-sizing: border-box;
  background-color: white;
}

.follow-up-input:focus {
  border-color: #3B82F6; /* 포커스 시 진한 파란색 */
}


.checkbox.blue.checked {
  background: #3B82F6;
  border-color: #3B82F6;
}

.compact-input { 
  height: 32px; 
  border: 1px solid #E5E7EB; 
  border-radius: 6px; 
  padding: 0 8px; 
  font-size: 14px; 
  width: 100%; 
  box-sizing: border-box; 
  background: white; 
}
.compact-input:focus { border-color: #3B82F6; outline: none; }

/* [추가] 우측 요소 그룹화 */
.right-group {
  display: flex;
  align-items: center;
  gap: 8px; /* 버튼과 드롭다운 사이 간격 */
}

/* [추가] 옅은 초록색 버튼 스타일 */
.btn-new-green {
  padding: 6px 12px;
  background-color: #ECFDF5; /* 옅은 초록 배경 */
  border: 1px solid #6EE7B7; /* 연한 초록 테두리 */
  border-radius: 6px;
  color: #059669; /* 짙은 초록 텍스트 */
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  white-space: nowrap;
  transition: background-color 0.2s;
}

.btn-new-green:hover {
  background-color: #D1FAE5; /* 호버 시 조금 더 진하게 */
}
</style>