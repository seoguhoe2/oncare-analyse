<template>
  <div class="modal-overlay" >
    <div class="modal-content">
      <div class="modal-header">
        <h3>{{ isEdit ? '용품 정보 수정' : '용품 신규 등록' }}</h3>
        <button class="close-btn" @click="$emit('close')">×</button>
      </div>

      <div class="modal-body">
        <div class="form-group">
          <label>용품 코드</label>
          <input v-model="form.id" type="text" placeholder="예: EM009" 
            :disabled="isEdit" 
            :class="{ 'disabled-input': isEdit }"/>
        </div>

        <div class="form-group">
          <label>용품명</label>
          <input v-model="form.name" type="text" placeholder="용품 이름을 입력하세요" />
        </div>

        <div class="form-group">
          <label>카테고리</label>
          <select v-model="form.categoryCd">
            <option v-for="item in categories" :key="item.id"  :value="item.id">
                {{ item.name }}
            </option>
          </select>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>단가 (원)</label>
            <input v-model.number="form.amount" type="number" placeholder="0" />
          </div>
          <div class="form-group">
            <label>월 임대료 (원)</label>
            <input v-model.number="form.rentalAmount" type="number" placeholder="0" />
          </div>
        </div>

        <div class="form-group">
          <label>설명</label>
          <textarea v-model="form.explanation" rows="3" placeholder="상세 설명을 입력하세요"></textarea>
        </div>
      </div>

      <div class="modal-footer">
        <button class="btn-cancel" @click="$emit('close')">취소</button>
        <button class="btn-save" @click="handleSave">
          {{ isEdit ? '수정' : '등록' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, watch } from 'vue'

const props = defineProps({
  categories: { type: Array, default: () => [] },
  isEdit: { type: Boolean, default: false },     // 수정 모드인지 확인
  initialData: { type: Object, default: null }   // 수정할 데이터 받기
})

const emit = defineEmits(['close', 'save'])

// 초기 폼 데이터
const form = reactive({
  id: '',
  name: '',
  categoryCd: '',
  amount: 0,
  rentalAmount: 0,
  explanation: ''
})

watch(() => props.initialData, (newData) => {
  if (newData && props.isEdit) {
    // 수정 모드: 부모가 준 데이터로 덮어쓰기
    Object.assign(form, newData)
  } else {
    // 등록 모드: 폼 초기화
    Object.assign(form, {
      id: '', name: '', categoryCd: '', amount: 0, rentalAmount: 0, explanation: ''
    })
  }
}, { immediate: true }) // 컴포넌트 생성 즉시 실행

const handleSave = () => {
  // 간단한 유효성 검사
  if (!form.name || !form.id || !form.categoryCd) {
    alert('용품 코드,이름, 카테고리 필수입니다.')
    return
  }
  // 부모에게 입력된 데이터 전달
  emit('save', { ...form, mode: props.isEdit ? 'edit' : 'create' })
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  width: 400px;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.modal-header h3 { margin: 0; font-size: 18px; font-weight: 600; }
.close-btn { background: none; border: none; font-size: 24px; cursor: pointer; color: #666; }

.form-group { margin-bottom: 16px; }
.form-group label { display: block; margin-bottom: 6px; font-size: 13px; font-weight: 500; color: #374151; }
.form-group input, .form-group select, .form-group textarea {
  width: 100%; padding: 8px 10px;
  border: 1px solid #d1d5db; border-radius: 6px;
  font-size: 14px; box-sizing: border-box;
}
.form-row { display: flex; gap: 12px; }

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 24px;
}

.btn-cancel {
  padding: 8px 16px; border: 1px solid #d1d5db;
  background: white; border-radius: 6px; cursor: pointer;
}
.btn-save {
  padding: 8px 16px; border: none;
  background: #16a34a; color: white;
  border-radius: 6px; cursor: pointer;
}
.btn-save:hover { background: #15803d; }

.disabled-input {
  background-color: #f3f4f6;
  color: #9ca3af;
  cursor: not-allowed;
}
</style>