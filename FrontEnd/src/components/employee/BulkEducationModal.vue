<script setup>
import { ref, computed, watch } from 'vue';

const props = defineProps({
  isOpen: Boolean,
  employees: { type: Array, default: () => [] }
});

const emit = defineEmits(['close', 'submit']);

// 1. 전체 직원들이 가진 자격증 이름 추출 (중복 제거)
const certOptions = computed(() => {
  console.log('BulkModal employees:', props.employees.length);
  if (props.employees.length > 0) {
    console.log('First employee certs:', props.employees[0].certificates);
  }

  const names = new Set();
  props.employees.forEach(emp => {
    if (emp.certificates) {
      emp.certificates.forEach(cert => {
        const name = cert.certificateName || cert.name;
        if (name) names.add(name);
      });
    }
  });
  
  const result = Array.from(names).sort();
  console.log('Extracted Cert Options:', result);
  
  // [Fallback] 만약 추출된 자격증이 하나도 없다면, 기본 옵션이라도 제공 (데이터 누락 대비)
  if (result.length === 0) {
    return ['요양보호사 1급', '사회복지사 1급', '간호조무사'];
  }
  
  return result;
});

const form = ref({ 
  targetCertName: '', 
  eduName: '', 
  institution: '', 
  eduDate: '', 
  nextEduDate: '', 
  status: 0 
});

const selectedIds = ref([]);

// 2. 선택된 자격증을 가진 직원 필터링
const filteredEmployees = computed(() => {
  if (!form.value.targetCertName) return [];
  return props.employees.filter(emp => {
    if (!emp.certificates) return false;
    return emp.certificates.some(cert => {
      const name = cert.certificateName || cert.name;
      // 정확히 일치하거나 포함되는 경우 (여기선 편의상 포함으로 처리하되, Select라면 정확 일치 권장)
      return name === form.value.targetCertName;
    });
  });
});

// 자격증 변경 시 선택 초기화
watch(() => form.value.targetCertName, () => {
  selectedIds.value = [];
});

// 이수일 변경 시 다음 교육 예정일(2년 뒤) 자동 계산
watch(() => form.value.eduDate, (newDate) => {
  if (newDate) {
    const date = new Date(newDate);
    if (!isNaN(date.getTime())) {
      date.setFullYear(date.getFullYear() + 2);
      const yyyy = date.getFullYear();
      const mm = String(date.getMonth() + 1).padStart(2, '0');
      const dd = String(date.getDate()).padStart(2, '0');
      form.value.nextEduDate = `${yyyy}-${mm}-${dd}`;
    }
  }
});

const toggleAll = (e) => {
  if (e.target.checked) selectedIds.value = filteredEmployees.value.map(c => c.id);
  else selectedIds.value = [];
};

const handleSubmit = () => {
  if (!form.value.targetCertName) return alert('대상 자격증을 선택해주세요.');
  if (selectedIds.value.length === 0) return alert('교육을 등록할 직원을 선택해주세요.');
  if (!form.value.eduName || !form.value.institution || !form.value.eduDate) {
    return alert('필수 정보(교육명, 기관, 이수일)를 입력해주세요.');
  }

  emit('submit', { ids: selectedIds.value, data: form.value });
};
</script>

<template>
  <div v-if="isOpen" class="modal-overlay">
    <div class="modal-box">
      <div class="modal-header">
        <h3 class="header-title">보수교육 일괄 등록</h3>
        <button @click="$emit('close')" class="close-btn">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
        </button>
      </div>

      <div class="modal-body">
        
        <!-- 1. 자격증 선택 영역 (가장 먼저 선택) -->
        <div class="mb-6">
          <label class="block-label mb-2">대상 자격증 선택</label>
          <select v-model="form.targetCertName" class="input highlight-input">
            <option value="" disabled>자격증을 선택하세요</option>
            <option v-for="name in certOptions" :key="name" :value="name">{{ name }}</option>
          </select>
          <p class="guide-text" v-if="!form.targetCertName">☝️ 자격증을 선택하면 해당 자격증을 보유한 직원이 표시됩니다.</p>
        </div>

        <div class="section-title-row" :class="{ 'opacity-50': !form.targetCertName }">
          <svg class="icon-blue" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
          <span class="main-title">대상 직원 선택</span>
          <span class="count-badge" v-if="form.targetCertName">{{ selectedIds.length }} / {{ filteredEmployees.length }}명</span>
        </div>

        <div class="selection-box" v-if="form.targetCertName">
          <div class="check-row header-row">
            <input type="checkbox" @change="toggleAll" :checked="selectedIds.length === filteredEmployees.length && filteredEmployees.length > 0" class="checkbox" />
            <label class="check-label">전체 선택</label>
          </div>
          <div class="list-scroll custom-scrollbar">
            <div v-for="emp in filteredEmployees" :key="emp.id" class="check-row item-row" @click="selectedIds.includes(emp.id) ? selectedIds = selectedIds.filter(id => id !== emp.id) : selectedIds.push(emp.id)">
              <input type="checkbox" :value="emp.id" v-model="selectedIds" class="checkbox" @click.stop />
              <div class="item-info">
                <div class="info-top">
                  <span class="name">{{ emp.name }}</span>
                  <span class="status-tag" :class="emp.status === '활동중' ? 'tag-green' : 'tag-yellow'">{{ emp.status }}</span>
                </div>
                <p class="phone">{{ emp.phone }}</p>
              </div>
            </div>
            <div v-if="filteredEmployees.length === 0" class="empty-list">
              해당 자격증을 보유한 직원이 없습니다.
            </div>
          </div>
        </div>
        <div v-else class="empty-state-box">
          자격증을 선택해주세요.
        </div>

        <h4 class="form-title mt-6">교육 정보</h4>
        <div class="form-container">
          <!-- targetCertName 입력 필드 제거 (위에서 선택함) -->

          <div class="form-group"><label>교육명</label><input v-model="form.eduName" type="text" class="input" placeholder="예: 2025 직무교육" /></div>
          <div class="form-group"><label>교육기관</label><input v-model="form.institution" type="text" class="input" /></div>
          
          <div class="form-group"><label>이수일</label><input v-model="form.eduDate" type="date" class="input" /></div>
          <div class="form-group"><label>다음 교육 예정일</label><input v-model="form.nextEduDate" type="date" class="input" /></div>
          
          <div class="form-group full-width">
            <label>상태</label>
            <select v-model="form.status" class="input">
              <option :value="0">이수 완료</option>
              <option :value="1">미이수</option>
              <option :value="2">예정</option>
            </select>
          </div>
        </div>
      </div>

      <div class="modal-footer">
        <button @click="$emit('close')" class="btn-cancel">취소</button>
        <button @click="handleSubmit" class="btn-submit">{{ selectedIds.length }}명 교육 등록</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 50; }
.modal-box { background: white; width: 480px; border-radius: 12px; overflow: hidden; box-shadow: 0 10px 25px rgba(0,0,0,0.1); max-height: 90vh; display: flex; flex-direction: column; }
.modal-header { padding: 16px 20px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; }
.header-title { font-size: 18px; font-weight: 700; color: #166534; margin: 0; }
.close-btn { background: none; border: none; cursor: pointer; color: #9ca3af; }
.modal-body { padding: 20px; overflow-y: auto; flex: 1; }
.modal-footer { padding: 16px 20px; border-top: 1px solid #f0f0f0; display: flex; justify-content: flex-end; background: #fff; gap: 8px; }

/* 아이콘 및 타이틀 */
.icon-blue { color: #2563eb; }
.section-title-row { display: flex; align-items: center; gap: 8px; margin-bottom: 12px; }
.main-title { font-weight: 700; color: #1f2937; }
.count-badge { padding: 2px 8px; background-color: #dbeafe; color: #2563eb; font-size: 12px; font-weight: 700; border-radius: 9999px; }

/* 선택 리스트 */
.selection-box { border: 1px solid #e5e7eb; border-radius: 12px; overflow: hidden; margin-bottom: 24px; }
.check-row { display: flex; align-items: center; gap: 12px; padding: 12px; }
.header-row { background-color: #f9fafb; border-bottom: 1px solid #e5e7eb; }
.item-row { cursor: pointer; transition: background 0.2s; }
.item-row:hover { background-color: #f9fafb; }
.check-label { font-size: 14px; font-weight: 500; color: #374151; }
.list-scroll { max-height: 180px; overflow-y: auto; }
.checkbox { width: 16px; height: 16px; border-radius: 4px; border: 1px solid #d1d5db; cursor: pointer; accent-color: #2563eb; }

/* 아이템 정보 */
.item-info { flex: 1; display: flex; justify-content: space-between; align-items: center; }
.info-top { display: flex; align-items: center; gap: 8px; }
.name { font-size: 14px; font-weight: 700; color: #1f2937; }
.status-tag { font-size: 10px; padding: 2px 6px; border-radius: 4px; }
.tag-green { background-color: #dcfce7; color: #15803d; }
.tag-yellow { background-color: #fef9c3; color: #a16207; }
.phone { font-size: 12px; color: #6b7280; margin: 0; }

/* 폼 */
.form-title { font-size: 14px; font-weight: 700; color: #1f2937; margin: 0 0 12px 0; }
.form-container { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-group.full-width { grid-column: 1 / -1; }
.form-group label { font-size: 13px; font-weight: 500; color: #4b5563; }
.input { width: 100%; padding: 10px 12px; border: 1px solid #e5e7eb; border-radius: 8px; font-size: 14px; outline: none; transition: border-color 0.2s; box-sizing: border-box; }
.input:focus { border-color: #3b82f6; }

/* 버튼 */
.btn-cancel { padding: 10px 24px; background-color: #6b7280; color: white; border-radius: 8px; font-size: 14px; font-weight: 500; border: none; cursor: pointer; }
.btn-cancel:hover { background-color: #4b5563; }
.btn-submit { flex: 1; padding: 10px; background-color: #3b82f6; color: white; border-radius: 8px; font-size: 14px; font-weight: 700; border: none; cursor: pointer; }
.btn-submit:hover { background-color: #2563eb; }

/* 추가된 스타일 */
.mb-2 { margin-bottom: 8px; }
.mb-6 { margin-bottom: 24px; }
.mt-6 { margin-top: 24px; }
.opacity-50 { opacity: 0.5; pointer-events: none; }

.highlight-input { border: 2px solid #3b82f6; background-color: #eff6ff; font-weight: 600; color: #1e40af; }
.guide-text { font-size: 13px; color: #2563eb; margin-top: 8px; font-weight: 500; }

.empty-state-box { border: 1px dashed #cbd5e1; border-radius: 12px; background-color: #f8fafc; color: #94a3b8; text-align: center; padding: 32px; font-size: 14px; margin-bottom: 24px; }
.empty-list { text-align: center; padding: 20px; color: #94a3b8; font-size: 13px; }

.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 2px; }
</style>