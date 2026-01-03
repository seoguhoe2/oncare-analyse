<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';

const props = defineProps({
  isOpen: Boolean
});

const emit = defineEmits(['close', 'submit']);

// 키보드 이벤트 핸들러
const handleKeydown = (e) => {
  if (!props.isOpen) return;

  if (e.key === 'Escape') {
    emit('close');
  } else if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
    // Ctrl+Enter 또는 Cmd+Enter로 제출
    handleSubmit();
  }
};

onMounted(() => {
  window.addEventListener('keydown', handleKeydown);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown);
});

// API 함수 import
// API 함수 import
import { getCertificateTypes, getCertificateHolders, registerBulkEducation, getEducationAlerts } from '@/api/employee/employeeApi';


// 1. 자격증 종류 조회 (API)
const certTypes = ref([]);
const isLoadingTypes = ref(false);

const fetchCertTypes = async () => {
  isLoadingTypes.value = true;
  try {
    const response = await getCertificateTypes();
    console.log('Certificate Types API Response:', response);

    let rawData = [];
    if (Array.isArray(response)) {
      rawData = response;
    } else if (response && Array.isArray(response.data)) {
      rawData = response.data; // { data: [...] } Wrapper support
    } else if (response && Array.isArray(response.content)) {
      rawData = response.content; // Page wrapper support
    }

    // 데이터 매핑 (문자열 리스트 or 객체 리스트 대응)
    certTypes.value = rawData.map((item, index) => {
      // 1. 단순 문자열인 경우 (예: ["요양보호사", "사회복지사"])
      if (typeof item === 'string') {
        return { id: item, name: item };
      }
      // 2. 객체인 경우 (예: { id: 1, name: "..." } or { code: "...", value: "..." })
      return {
        id: item.id || item.code || item.certificateId || index, 
        name: item.name || item.certificateName || item.value || '이름 없음'
      };
    });
    
  } catch (error) {
    console.error('자격증 종류 조회 실패:', error);
    certTypes.value = []; 
  } finally {
    isLoadingTypes.value = false;
  }
};

watch(() => props.isOpen, (newVal) => {
  if (newVal) {
    fetchCertTypes();
    // 초기화
    form.value = {
      targetCertId: '',
      eduName: '',
      institution: '',
      eduDate: '',
      nextEduDate: ''
    };
    holders.value = [];
    selectedIds.value = [];
  }
});

const form = ref({
  targetCertId: '',
  eduName: '',
  institution: '',
  eduDate: '',
  nextEduDate: ''
});

// 오늘 날짜를 'YYYY-MM-DD' 형식으로 구하기
const today = computed(() => {
  return new Date().toISOString().split('T')[0];
});

const selectedIds = ref([]);
const onlyExpired = ref(false); // 필터 상태
const alertsMap = ref({}); // 직원 ID -> 알림 객체 매핑

// 2. 보유자 조회 (API)
const holders = ref([]);
const isLoadingHolders = ref(false);

const fetchHolders = async (certId) => {
  if (!certId) return;
  isLoadingHolders.value = true;
  try {
    const data = await getCertificateHolders(certId);
    // data가 [{ id(employeeId), name, cwc_id, ... }, ...] 형태라고 가정
    // 혹은 data가 [{ cwc_id, employeeName: ..., }, ...] 일 수도 있음.
    // 여기서는 data를 그대로 holders에 넣고, template에서 필드를 맞춰씀.
    holders.value = Array.isArray(data) ? data : [];
  } catch (error) {
    console.error('보유자 조회 실패:', error);
    holders.value = [];
  } finally {
    isLoadingHolders.value = false;
  }
};



// 알림 정보 가져오기
const fetchAlertsData = async () => {
  try {
    const alerts = await getEducationAlerts();
    const map = {};
    if (Array.isArray(alerts)) {
      alerts.forEach(a => {
        map[a.employeeId] = a;
      });
    }
    alertsMap.value = map;
  } catch (e) {
    console.error('Failed to fetch alerts:', e);
  }
};

watch(() => form.value.targetCertId, (newId) => {
  selectedIds.value = [];
  if (newId) {
    fetchHolders(newId);
    fetchAlertsData(); // 자격증 선택 시 알림 정보도 갱신
  } else {
    holders.value = [];
    alertsMap.value = {};
  }
});

// 필터링된 목록
const filteredHolders = computed(() => {
  let list = holders.value;

  if (onlyExpired.value) {
    list = list.filter(emp => {
      const alert = alertsMap.value[emp.employeeId];
      return alert && alert.status === 'OVERDUE';
    });
  }
  return list;
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
  // cwc_id를 사용한다고 가정.
  if (e.target.checked) selectedIds.value = filteredHolders.value.map(c => c.cwc_id || c.id);
  else selectedIds.value = [];
};

const handleSubmit = async () => {
  if (!form.value.targetCertId) return alert('대상 자격증을 선택해주세요.');
  if (selectedIds.value.length === 0) return alert('교육을 등록할 직원을 선택해주세요.');
  if (!form.value.eduName || !form.value.institution || !form.value.eduDate) {
    return alert('필수 정보(교육명, 기관, 이수일)를 입력해주세요.');
  }

  // 날짜 검증 - 이수일이 미래인지 체크
  if (form.value.eduDate > today.value) {
    return alert('보수교육 이수일은 미래일 수 없습니다.');
  }

  try {
    // API 명세: 선택된 직원들의 보유 ID(careWorkerCertIds)와 교육 정보(educationInfo)
    const payload = {
      careWorkerCertIds: selectedIds.value.map(id => Number(id)),
      educationInfo: {
        eduName: form.value.eduName,
        institution: form.value.institution,
        eduDate: form.value.eduDate,
        nextEduDate: form.value.nextEduDate
      }
    };

    console.log('Sending Bulk Payload:', payload);

    await registerBulkEducation(payload);

    alert('보수교육이 일괄 등록되었습니다.');
    emit('submit'); // 부모에게 알림 (새로고침 등)
    emit('close');
  } catch (error) {
    console.error('일괄 등록 실패:', error);
    alert('등록 중 오류가 발생했습니다.');
  }
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
          <select v-model="form.targetCertId" class="input highlight-input" :disabled="isLoadingTypes">
            <option value="" disabled>자격증을 선택하세요</option>
            <!-- 서버에서 주는 { id, name } 구조 가정 -->
            <option v-for="cert in certTypes" :key="cert.id" :value="cert.id">
              {{ cert.name }}
            </option>
          </select>
          <p class="guide-text" v-if="!form.targetCertId">☝️ 자격증을 선택하면 해당 자격증을 보유한 직원이 표시됩니다.</p>
        </div>

        <div class="section-title-row" :class="{ 'opacity-50': !form.targetCertId }">
          <svg class="icon-blue" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
          <span class="main-title">대상 직원 선택</span>
          <span class="count-badge" v-if="form.targetCertId">{{ selectedIds.length }} / {{ filteredHolders.length }}명</span>
        </div>

        <div class="selection-box" v-if="form.targetCertId">
          <div class="check-row header-row" style="justify-content: space-between;">
            <div class="flex items-center gap-2">
              <input type="checkbox" @change="toggleAll" :checked="filteredHolders.length > 0 && selectedIds.length === filteredHolders.length" class="checkbox" />
              <label class="check-label">전체 선택</label>
            </div>
            <div class="flex items-center gap-2">
               <input type="checkbox" id="onlyExpired" v-model="onlyExpired" class="checkbox" />
               <label for="onlyExpired" class="check-label text-red-600 font-bold cursor-pointer">기한 초과자만</label>
            </div>
          </div>
          <div class="list-scroll custom-scrollbar">
            <div v-if="isLoadingHolders" class="empty-list">로딩 중...</div>
            <div v-else v-for="emp in filteredHolders" :key="emp.cwc_id || emp.id" class="check-row item-row" 
                 @click="(selectedIds.includes(emp.cwc_id || emp.id)) ? selectedIds = selectedIds.filter(id => id !== (emp.cwc_id || emp.id)) : selectedIds.push(emp.cwc_id || emp.id)">
              <input type="checkbox" :value="emp.cwc_id || emp.id" v-model="selectedIds" class="checkbox" @click.stop />
              <div class="item-info">
                <div class="info-top">
                  <span class="name">{{ emp.employeeName || emp.name }}</span>
                  <!-- 직책이나 다른 정보가 있다면 표시 -->
                  <span v-if="emp.status" class="status-tag" :class="emp.status === '활동중' ? 'tag-green' : 'tag-yellow'">{{ emp.status }}</span>
                  <span v-if="alertsMap[emp.employeeId] && alertsMap[emp.employeeId].status === 'OVERDUE'" class="status-tag tag-red">
                    {{ Math.abs(alertsMap[emp.employeeId].dday) }}일 초과
                  </span>
                </div>
                <!-- 핸드폰 번호가 없을 수도 있음 -->
                <p v-if="emp.phone" class="phone">{{ emp.phone }}</p>
              </div>
            </div>
            <div v-if="!isLoadingHolders && holders.length === 0" class="empty-list">
              해당 자격증을 보유한 직원이 없습니다.
            </div>
          </div>
        </div>
        <div v-else class="empty-state-box">
          자격증을 선택해주세요.
        </div>

        <h4 class="form-title mt-6">교육 정보</h4>
        <div class="form-container">
          <!-- targetCertId 입력 필드 제거 (위에서 선택함) -->

          <div class="form-group"><label>교육명 *</label><input v-model="form.eduName" type="text" class="input" placeholder="예: 2025 직무교육" /></div>
          <div class="form-group"><label>교육기관 *</label><input v-model="form.institution" type="text" class="input" /></div>

          <div class="form-group"><label>이수일 *</label><input v-model="form.eduDate" type="date" class="input" :max="today" /></div>
          <div class="form-group"><label>다음 교육 예정일</label><input v-model="form.nextEduDate" type="date" class="input" /></div>
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
.tag-red { background-color: #fee2e2; color: #991b1b; font-weight: 700; }
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

.btn-submit:hover { background-color: #2563eb; }

/* 유틸리티 */
.flex { display: flex; }
.items-center { align-items: center; }
.gap-2 { gap: 8px; }
.text-red-600 { color: #dc2626; }
.font-bold { font-weight: 700; }
.cursor-pointer { cursor: pointer; }
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