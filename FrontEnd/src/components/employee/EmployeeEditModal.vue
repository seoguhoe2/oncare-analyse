<script setup>
import { ref, watch } from 'vue';

const props = defineProps({
  employee: { type: Object, required: true }, 
  isOpen: { type: Boolean, required: true }
});

const emit = defineEmits(['close', 'submit']);

// [설정] 서비스 목록 (문자열 전문분야와 매핑하기 위한 메뉴판)
const serviceOptions = [
  { id: 1, name: '방문요양' },
  { id: 2, name: '방문목욕' },
  { id: 3, name: '방문간호' }
];

// 폼 데이터
const form = ref({});
// 체크박스 상태 (ID 배열)
const selectedServiceIds = ref([]); 

// 경력 입력용 임시 변수
const newCareer = ref({
  companyName: '', start: '', end: '', task: ''
});

// --- [1] 총 경력 계산 함수 ---
const calculateTotalCareer = () => {
  let totalMonths = 0;
  if (form.value.careers) {
    form.value.careers.forEach(item => {
      // API 응답 필드명 대응 (start/end 또는 startDate/endDate)
      const sDate = item.start || item.startDate;
      const eDate = item.end || item.endDate;

      if (sDate && eDate) {
        const [sY, sM] = sDate.split('-').map(Number);
        const [eY, eM] = eDate.split('-').map(Number);
        const startDate = new Date(sY, sM - 1);
        const endDate = new Date(eY, eM - 1);
        const months = (endDate.getFullYear() - startDate.getFullYear()) * 12 + (endDate.getMonth() - startDate.getMonth()) + 1;
        if (months > 0) totalMonths += months;
      }
    });
  }
  const years = Math.floor(totalMonths / 12);
  const months = totalMonths % 12;
  
  let result = '';
  if (years > 0) result += `${years}년 `;
  if (months > 0) result += `${months}개월`;
  if (totalMonths === 0) result = '신입';
  
  form.value.career = result.trim();
};

// --- [2] 데이터 동기화 (모달 열릴 때 실행) ---
watch(() => props.employee, (newVal) => {
  if (!newVal) return;

  // 1. 기본 정보 복사 (Basic Info 탭 내용 반영)
  form.value = {
    ...newVal,
    
    // [중요] null 방지 처리
    gender: newVal.gender || 'F', 
    hireDate: newVal.hireDate || '',
    birth: newVal.birth || '',
    deptCode: newVal.deptCode || 1, // 없으면 영업팀 기본
    jobCode: newVal.jobCode || 5,   // 없으면 요양보호사 기본
    
    // 배열 데이터 깊은 복사 (수정 시 원본 오염 방지)
    careers: newVal.careers ? JSON.parse(JSON.stringify(newVal.careers)) : [],
    certificates: newVal.certificates ? JSON.parse(JSON.stringify(newVal.certificates)) : [],
    // specialties는 문자열 배열로 옴 (예: ["방문요양"])
    specialties: Array.isArray(newVal.specialties) ? [...newVal.specialties] : []
  };

  // 2. 전문 분야 매핑 로직 (문자열 -> ID 체크박스)
  selectedServiceIds.value = []; 

  // Case A: 서버가 문자열 배열(["방문요양"])로 줄 때 -> 이름으로 ID 찾기
  if (newVal.specialties && Array.isArray(newVal.specialties)) {
    newVal.specialties.forEach(name => {
      const found = serviceOptions.find(opt => opt.name === name);
      if (found) selectedServiceIds.value.push(found.id);
    });
  }
  // Case B: 혹시 객체 배열([{id:1...}])로 줄 때 -> ID 추출
  else if (newVal.serviceTypes && Array.isArray(newVal.serviceTypes)) {
    selectedServiceIds.value = newVal.serviceTypes.map(item => item.id);
  }

  // 3. 경력 재계산
  calculateTotalCareer();
}, { deep: true, immediate: true });


// --- [3] 핸들러 ---
const addCareer = () => {
  if (!newCareer.value.companyName || !newCareer.value.start || !newCareer.value.end) {
    alert('필수 정보를 입력해주세요.'); return;
  }
  if (newCareer.value.start > newCareer.value.end) {
    alert('종료일 오류'); return;
  }
  
  const workPeriod = `${newCareer.value.start.replace('-', '.')} - ${newCareer.value.end.replace('-', '.')}`;
  
  if (!form.value.careers) form.value.careers = [];
  form.value.careers.push({
    companyName: newCareer.value.companyName,
    workPeriod: workPeriod,
    task: newCareer.value.task,
    start: newCareer.value.start,
    end: newCareer.value.end
  });
  calculateTotalCareer();
  newCareer.value = { companyName: '', start: '', end: '', task: '' };
};

const removeCareer = (index) => {
  form.value.careers.splice(index, 1);
  calculateTotalCareer();
};

const handleSubmit = () => {
  const payload = {
    ...form.value,
    
    // 1. 체크된 서비스 ID 배열 전송 ([1, 2] 형태)
    serviceTypeIds: selectedServiceIds.value,
    
    // 2. 배열 데이터 전송
    careers: form.value.careers,
    certificates: form.value.certificates
  };

  // 백엔드 전송 시 불필요한 필드 제거
  delete payload.specialties; 
  delete payload.serviceTypes; 
  
  emit('submit', payload);
};
</script>

<template>
  <div v-if="isOpen" class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-box">
      <div class="modal-header">
        <h3>직원 정보 수정</h3>
        <button class="close-btn" @click="$emit('close')">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
      </div>
      
      <div class="modal-body custom-scrollbar">
        
        <div class="form-section green-theme">
          <h4 class="section-title">기본 정보</h4>
          <div class="grid-2">
            <div class="form-group"><label>이름</label><input v-model="form.name" type="text" class="input" /></div>
            
            <div class="form-group">
              <label>성별</label>
              <select v-model="form.gender" class="input">
                <option value="F">여성</option>
                <option value="M">남성</option>
              </select>
            </div>
            
            <div class="form-group"><label>생년월일</label><input v-model="form.birth" type="date" class="input" /></div>
            <div class="form-group"><label>연락처</label><input v-model="form.phone" type="text" class="input" /></div>
            <div class="form-group"><label>이메일</label><input v-model="form.email" type="email" class="input" /></div>
            <div class="form-group full-width"><label>주소</label><input v-model="form.address" type="text" class="input" /></div>
          </div>
        </div>

        <div class="form-section blue-theme">
          <h4 class="section-title">직무 정보</h4>
          <div class="grid-2">
            <div class="form-group"><label>입사일</label><input v-model="form.hireDate" type="date" class="input" /></div>
            
            <div class="form-group">
              <label>부서</label>
              <select v-model="form.deptCode" class="input">
                <option :value="1">영업팀</option>
                <option :value="2">자재팀</option>
              </select>
            </div>

            <div class="form-group">
              <label>직급 (Job)</label>
              <select v-model="form.jobCode" class="input">
                <option :value="1">센터장</option>
                <option :value="2">관리자</option>
                <option :value="3">사원</option>
                <option :value="4">영업상담</option>
                <option :value="5">요양보호사</option>
              </select>
            </div>

            <div class="form-group">
              <label>상태</label>
               <select v-model="form.statusId" class="input">
                <option :value="1">재직</option>
                <option :value="2">휴직</option>
                <option :value="3">퇴사</option>
              </select>
            </div>
            
            <div class="form-group">
              <label>총 경력</label>
              <input v-model="form.career" type="text" class="input readonly-input" readonly />
            </div>
          </div>
        </div>

        <div class="form-section purple-theme">
          <h4 class="section-title">제공 서비스 및 경력</h4>
          
          <div class="form-group">
            <label class="sub-label">제공 서비스 (선택)</label>
            <div class="checkbox-group">
              <label v-for="service in serviceOptions" :key="service.id" class="checkbox-label">
                <input type="checkbox" :value="service.id" v-model="selectedServiceIds" />
                {{ service.name }}
              </label>
            </div>
          </div>

          <div class="career-input-box mt-4">
            <label class="sub-label">경력 사항 관리</label>
            <div class="form-group">
              <input v-model="newCareer.companyName" type="text" class="input" placeholder="회사명" />
            </div>
            <div class="grid-2-mini">
              <input v-model="newCareer.start" type="month" class="input" title="시작년월" />
              <input v-model="newCareer.end" type="month" class="input" title="종료년월" />
            </div>
             <div class="form-group">
              <input v-model="newCareer.task" type="text" class="input" placeholder="담당 업무" />
            </div>
            <button class="btn-full purple-btn" @click="addCareer">경력 추가</button>
          </div>

          <div class="history-list">
            <div v-for="(career, idx) in form.careers" :key="idx" class="history-item purple-item">
              <div class="history-content">
                <span class="history-company">{{ career.companyName }}</span>
                <span class="history-date">{{ career.workPeriod }}</span>
                <span class="history-task">{{ career.task }}</span>
              </div>
              <button class="btn-remove" @click="removeCareer(idx)">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
              </button>
            </div>
            <div v-if="!form.careers || form.careers.length === 0" class="empty-text">
              등록된 경력이 없습니다.
            </div>
          </div>
        </div>

      </div>

      <div class="modal-footer">
        <button class="btn-lg btn-green" @click="handleSubmit">수정 완료</button>
        <button class="btn-lg btn-white" @click="$emit('close')">취소</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 기존 스타일 그대로 유지 (변경 없음) */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.4); display: flex; align-items: center; justify-content: center; z-index: 100; }
.modal-box { background: white; width: 600px; border-radius: 12px; overflow: hidden; box-shadow: 0 10px 25px rgba(0,0,0,0.1); max-height: 90vh; display: flex; flex-direction: column; }
.modal-header { padding: 20px 24px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }
.modal-header h3 { font-size: 20px; font-weight: 700; color: #166534; margin: 0; }
.close-btn { background: none; border: none; cursor: pointer; color: #999; }
.modal-body { padding: 24px; overflow-y: auto; flex: 1; display: flex; flex-direction: column; gap: 24px; }
.form-section { padding: 20px; border-radius: 8px; border: 1px solid transparent; }
.green-theme { background-color: #f0fdf4; border-color: #dcfce7; }
.green-theme .section-title { color: #166534; }
.blue-theme { background-color: #eff6ff; border-color: #dbeafe; }
.blue-theme .section-title { color: #1e40af; }
.purple-theme { background-color: #faf5ff; border-color: #f3e8ff; }
.purple-theme .section-title { color: #6b21a8; }
.section-title { margin: 0 0 16px 0; font-size: 16px; font-weight: 700; }
.grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.full-width { grid-column: 1 / -1; }
.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-group label { font-size: 13px; font-weight: 600; color: #4b5563; }
.sub-label { font-size: 13px; font-weight: 600; color: #4b5563; display: block; margin-bottom: 4px; }
.input { width: 100%; padding: 10px 12px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 14px; outline: none; box-sizing: border-box; background: white; }
.input:focus { border-color: #22c55e; }
.readonly-input { background-color: #f3f4f6; color: #6b7280; cursor: not-allowed; border-color: #e5e7eb; }
.checkbox-group { display: flex; gap: 15px; flex-wrap: wrap; padding: 12px; background-color: white; border: 1px solid #e5e7eb; border-radius: 6px; }
.checkbox-label { display: flex; align-items: center; gap: 6px; font-size: 14px; cursor: pointer; user-select: none; color: #4b5563; }
.checkbox-label input[type="checkbox"] { width: 16px; height: 16px; accent-color: #a855f7; }
.career-input-box { display: flex; flex-direction: column; gap: 8px; }
.grid-2-mini { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
.mt-4 { margin-top: 16px; }
.history-list { display: flex; flex-direction: column; gap: 8px; margin-top: 10px; }
.history-item { display: flex; justify-content: space-between; align-items: center; padding: 10px 12px; border-radius: 8px; font-size: 14px; }
.purple-item { background-color: #f3e8ff; color: #6b21a8; }
.history-content { display: flex; flex-direction: column; gap: 2px; }
.history-company { font-weight: bold; }
.history-date { font-size: 12px; color: #666; }
.history-task { font-size: 12px; color: #555; font-style: italic; }
.btn-remove { background: none; border: none; cursor: pointer; color: currentColor; opacity: 0.6; }
.empty-text { font-size: 13px; color: #999; text-align: center; }
.btn-full { width: 100%; padding: 10px; border-radius: 6px; border: none; font-weight: 600; cursor: pointer; color: white; margin-top: 8px; }
.purple-btn { background-color: #a855f7; }
.purple-btn:hover { background-color: #9333ea; }
.modal-footer { padding: 20px 24px; border-top: 1px solid #f0f0f0; display: flex; gap: 12px; background: #fff; }
.btn-lg { flex: 1; padding: 12px; border-radius: 8px; font-size: 15px; font-weight: 700; cursor: pointer; text-align: center; }
.btn-green { background-color: #22c55e; color: white; border: none; }
.btn-white { background-color: white; color: #374151; border: 1px solid #d1d5db; }
.custom-scrollbar::-webkit-scrollbar { width: 6px; }
.custom-scrollbar::-webkit-scrollbar-thumb { background-color: #d1d5db; border-radius: 3px; }
</style>
