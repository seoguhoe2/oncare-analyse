<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute } from 'vue-router';
import CareLogForm from '@/components/careworker/activity/CareLogForm.vue';
import { getCareLogList, getCareLogDetail, createCareLog, updateCareLog, deleteCareLog } from '@/api/careworker/careLogApi';
import { useScheduleStore } from '@/stores/schedule';

const route = useRoute();
const scheduleStore = useScheduleStore();

// 서브 탭 상태 (작성 / 내역)
const activeTab = ref('write');

// 서비스 유형 매핑
const mapServiceType = (type) => {
  if (!type) return '방문요양';
  const typeStr = type.toString().toLowerCase();
  if (typeStr.includes('요양') || typeStr.includes('care') || typeStr.includes('visit')) return '방문요양';
  if (typeStr.includes('목욕') || typeStr.includes('bath')) return '방문목욕';
  if (typeStr.includes('간호') || typeStr.includes('nursing') || typeStr.includes('nurse')) return '방문간호';
  const validTypes = ['방문요양', '방문목욕', '방문간호'];
  return validTypes.includes(type) ? type : '방문요양';
};

// 근무일정에서 전달받은 정보를 초기 데이터로 사용
const scheduleData = computed(() => {
  if (route.query.beneficiaryId) {
    const mappedServiceType = mapServiceType(route.query.serviceType);
    return {
      beneficiaryId: parseInt(route.query.beneficiaryId, 10) || route.query.beneficiaryId,
      recipientName: route.query.beneficiaryName || '',
      careDate: route.query.serviceDate || new Date().toISOString().split('T')[0],
      startTime: route.query.startTime || '',
      endTime: route.query.endTime || '',
      serviceType: mappedServiceType,
      scheduleId: route.query.scheduleId
    };
  }
  return null;
});

const subTabs = [
  { key: 'write', label: '작성하기', icon: '📝' },
  { key: 'history', label: '작성 내역', icon: '📋' }
];

// 요양일지 내역 데이터
const careLogHistory = ref([]);
const loading = ref(false);

// 요양일지 목록 불러오기
const loadCareLogHistory = async () => {
  try {
    loading.value = true;
    const response = await getCareLogList();
    const data = response?.data ?? response;

    careLogHistory.value = (data || []).map(item => {
      const serviceDate = item.serviceDate || item.careDate || item.date || '';
      const dateObj = serviceDate ? new Date(serviceDate) : new Date();
      const dayNames = ['일', '월', '화', '수', '목', '금', '토'];
      const dayOfWeek = dayNames[dateObj.getDay()];
      const formattedDate = serviceDate ? `${serviceDate} (${dayOfWeek})` : '-';

      const time = item.startTime && item.endTime
        ? `${item.startTime} - ${item.endTime}`
        : item.time || '-';

      const id = item.logId || item.id || item.careLogId || item.care_log_id;
      const specialNotes = item.specialNote || item.specialNotes || item.special_note || item.note || '';
      const isDraftFlag = item.isDraft || item.is_draft || item.draft || false;
      const displayStatus = isDraftFlag ? '임시저장' : (item.status || '제출됨');

      return {
        ...item,
        id,
        logId: id,
        date: formattedDate,
        time,
        recipientName: item.beneficiaryName || item.recipientName || '-',
        address: item.beneficiaryAddress || item.address || item.location || '-',
        serviceType: item.serviceType || '방문요양',
        specialNotes: specialNotes,
        status: displayStatus,
        isDraft: isDraftFlag,
      };
    });
  } catch (error) {
    careLogHistory.value = [];
  } finally {
    loading.value = false;
  }
};

const showDetailModal = ref(false);
const isEditMode = ref(false);
const selectedLog = ref(null);
const editForm = ref(null);

// 백엔드 데이터를 프론트엔드 폼 데이터로 변환
const mapBackendToFormData = (data) => {
  return {
    logId: data.logId || data.id || data.careLogId || data.care_log_id,
    id: data.logId || data.id || data.careLogId || data.care_log_id,
    beneficiaryId: data.beneficiaryId || '',
    recipientName: data.beneficiaryName || '',
    careWorkerName: data.careWorkerName || '',
    careDate: data.serviceDate || data.careDate || '',
    startTime: data.startTime || '',
    endTime: data.endTime || '',
    serviceType: data.serviceType || '방문요양',
    isBreakfast: data.isBreakfast || false,
    isLunch: data.isLunch || false,
    isDinner: data.isDinner || false,
    isSnack: data.isSnack || false,
    diaperCount: data.diaperCount || 0,
    toiletCount: data.toiletCount || 0,
    isPortableToilet: data.isPortableToilet || false,
    isUrine: data.isUrine || false,
    isStool: data.isStool || false,
    stoolNormal: data.stoolNormal || false,
    stoolDiarrhea: data.stoolDiarrhea || false,
    stoolConstipation: data.stoolConstipation || false,
    isFaceWash: data.isFaceWash || false,
    isOralCare: data.isOralCare || false,
    isHairWash: data.isHairWash || false,
    isBodyWash: data.isBodyWash || false,
    isChangeClothes: data.isChangeClothes || false,
    isMealPrep: data.isMealPrep || false,
    isBedCare: data.isBedCare || false,
    isPositionChange: data.isPositionChange || false,
    isGetUpHelp: data.isGetUpHelp || false,
    isIndoorMove: data.isIndoorMove || false,
    isWalkHelp: data.isWalkHelp || false,
    isEmotionalTalk: data.isEmotionalTalk || false,
    isCommunication: data.isCommunication || false,
    isCounseling: data.isCounseling || false,
    isCognitiveCare: data.isCognitiveCare || false,
    isBehaviorCare: data.isBehaviorCare || false,
    isHealthGood: data.isHealthGood || false,
    isPain: data.isPain || false,
    isEdema: data.isEdema || false,
    isSkinIssue: data.isSkinIssue || false,
    isBodyEtc: data.isBodyEtc || false,
    isMoodCalm: data.isMoodCalm || false,
    isMoodAnxious: data.isMoodAnxious || false,
    isMoodDepressed: data.isMoodDepressed || false,
    isMoodAngry: data.isMoodAngry || false,
    isMoodEtc: data.isMoodEtc || false,
    isExcretionMistake: data.isExcretionMistake || false,
    isSleepLack: data.isSleepLack || false,
    isNapExcess: data.isNapExcess || false,
    specialNotes: data.specialNote || data.specialNotes || ''
  };
};

const openDetail = async (item) => {
  try {
    const logId = item.logId || item.id || item.careLogId || item.care_log_id;
    if (!logId) {
      alert('요양일지 ID를 찾을 수 없습니다.');
      return;
    }
    const response = await getCareLogDetail(logId);
    const detailData = response?.data ?? response;
    selectedLog.value = mapBackendToFormData(detailData);
    editForm.value = null;
    isEditMode.value = false;
    showDetailModal.value = true;
  } catch (error) {
    alert('요양일지를 불러오는데 실패했습니다.');
  }
};

const openEdit = async (item) => {
  if (!selectedLog.value || !selectedLog.value.careWorkerName) {
    await openDetail(item);
  }
  isEditMode.value = true;
};

const closeModal = () => {
  showDetailModal.value = false;
  isEditMode.value = false;
  editForm.value = null;
};

// 수정 데이터 준비 함수
const prepareUpdateData = (formData, isDraft) => {
  return {
    beneficiaryId: parseInt(formData.beneficiaryId, 10),
    serviceDate: formData.careDate,
    startTime: formData.startTime,
    endTime: formData.endTime,
    serviceType: formData.serviceType,
    isDraft: isDraft,
    isBreakfast: formData.isBreakfast,
    isLunch: formData.isLunch,
    isDinner: formData.isDinner,
    isSnack: formData.isSnack,
    diaperCount: formData.diaperCount,
    toiletCount: formData.toiletCount,
    isPortableToilet: formData.isPortableToilet,
    isUrine: formData.isUrine,
    isStool: formData.isStool,
    stoolNormal: formData.stoolNormal,
    stoolDiarrhea: formData.stoolDiarrhea,
    stoolConstipation: formData.stoolConstipation,
    isFaceWash: formData.isFaceWash,
    isOralCare: formData.isOralCare,
    isHairWash: formData.isHairWash,
    isBodyWash: formData.isBodyWash,
    isChangeClothes: formData.isChangeClothes,
    isMealPrep: formData.isMealPrep,
    isBedCare: formData.isBedCare,
    isPositionChange: formData.isPositionChange,
    isGetUpHelp: formData.isGetUpHelp,
    isIndoorMove: formData.isIndoorMove,
    isWalkHelp: formData.isWalkHelp,
    isEmotionalTalk: formData.isEmotionalTalk,
    isCommunication: formData.isCommunication,
    isCounseling: formData.isCounseling,
    isCognitiveCare: formData.isCognitiveCare,
    isBehaviorCare: formData.isBehaviorCare,
    isHealthGood: formData.isHealthGood,
    isPain: formData.isPain,
    isEdema: formData.isEdema,
    isSkinIssue: formData.isSkinIssue,
    isBodyEtc: formData.isBodyEtc,
    isMoodCalm: formData.isMoodCalm,
    isMoodAnxious: formData.isMoodAnxious,
    isMoodDepressed: formData.isMoodDepressed,
    isMoodAngry: formData.isMoodAngry,
    isMoodEtc: formData.isMoodEtc,
    isExcretionMistake: formData.isExcretionMistake,
    isSleepLack: formData.isSleepLack,
    isNapExcess: formData.isNapExcess,
    specialNote: formData.specialNotes
  };
};

// 수정 저장 (제출됨)
const handleCareLogUpdate = async (formData) => {
  try {
    const logId = selectedLog.value.logId || selectedLog.value.id;
    if (!logId) return alert('요양일지 ID를 찾을 수 없습니다.');

    const submitData = prepareUpdateData(formData, false);

    await updateCareLog(logId, submitData);
    alert('요양일지가 성공적으로 수정되었습니다.');
    closeModal();
    await loadCareLogHistory();
  } catch (error) {
    console.error('❌ 요양일지 수정 실패:', error);
    alert('요양일지 수정에 실패했습니다.');
  }
};

// 임시저장으로 수정
const handleCareLogDraftUpdate = async (formData) => {
  try {
    const logId = selectedLog.value.logId || selectedLog.value.id;
    if (!logId) return alert('요양일지 ID를 찾을 수 없습니다.');

    const submitData = prepareUpdateData(formData, true);

    await updateCareLog(logId, submitData);
    alert('요양일지가 임시저장되었습니다.');
    closeModal();
    await loadCareLogHistory();
  } catch (error) {
    console.error('❌ 요양일지 임시저장 실패:', error);
    alert('요양일지 임시저장에 실패했습니다.');
  }
};

const deleteLog = async (id) => {
  const targetId = id ?? selectedLog.value?.id;
  if (!targetId) return;
  if (!confirm('이 요양일지를 삭제하시겠습니까?')) return;

  try {
    await deleteCareLog(targetId);
    scheduleStore.notifyScheduleUpdate();
    await loadCareLogHistory();
    if (selectedLog.value?.id === targetId) {
      closeModal();
      selectedLog.value = null;
    }
    alert('삭제되었습니다.');
  } catch (error) {
    alert('요양일지 삭제에 실패했습니다.');
  }
};

const submitCareLogData = async (formData, isDraft = false) => {
  const submitData = {
    beneficiaryId: parseInt(formData.beneficiaryId, 10),
    serviceDate: formData.careDate,
    startTime: formData.startTime,
    endTime: formData.endTime,
    serviceType: formData.serviceType,
    isDraft: isDraft,

    // 식사
    isBreakfast: formData.isBreakfast,
    isLunch: formData.isLunch,
    isDinner: formData.isDinner,
    isSnack: formData.isSnack,

    // 배설
    diaperCount: formData.diaperCount,
    toiletCount: formData.toiletCount,
    isPortableToilet: formData.isPortableToilet,
    isUrine: formData.isUrine,
    isStool: formData.isStool,
    stoolNormal: formData.stoolNormal,
    stoolDiarrhea: formData.stoolDiarrhea,
    stoolConstipation: formData.stoolConstipation,

    // 위생
    isFaceWash: formData.isFaceWash,
    isOralCare: formData.isOralCare,
    isHairWash: formData.isHairWash,
    isBodyWash: formData.isBodyWash,
    isChangeClothes: formData.isChangeClothes,

    // 활동
    isMealPrep: formData.isMealPrep,
    isBedCare: formData.isBedCare,
    isPositionChange: formData.isPositionChange,
    isGetUpHelp: formData.isGetUpHelp,
    isIndoorMove: formData.isIndoorMove,
    isWalkHelp: formData.isWalkHelp,

    // 인지/정서
    isEmotionalTalk: formData.isEmotionalTalk,
    isCommunication: formData.isCommunication,
    isCounseling: formData.isCounseling,
    isCognitiveCare: formData.isCognitiveCare,
    isBehaviorCare: formData.isBehaviorCare,

    // 신체상태
    isHealthGood: formData.isHealthGood,
    isPain: formData.isPain,
    isEdema: formData.isEdema,
    isSkinIssue: formData.isSkinIssue,
    isBodyEtc: formData.isBodyEtc,

    // 기분/행동
    isMoodCalm: formData.isMoodCalm,
    isMoodAnxious: formData.isMoodAnxious,
    isMoodDepressed: formData.isMoodDepressed,
    isMoodAngry: formData.isMoodAngry,
    isMoodEtc: formData.isMoodEtc,

    // 기타 관찰
    isExcretionMistake: formData.isExcretionMistake,
    isSleepLack: formData.isSleepLack,
    isNapExcess: formData.isNapExcess,

    // 특이사항
    specialNote: formData.specialNotes
  };

  const result = await createCareLog(submitData);
  
  return true;
};

// 검색어 상태
const searchQuery = ref('');
const selectedServiceType = ref('');

// 검색 필터링된 목록
const filteredCareLogHistory = computed(() => {
  let result = careLogHistory.value;

  if (selectedServiceType.value) {
    result = result.filter(item => item.serviceType === selectedServiceType.value);
  }

  if (searchQuery.value) {
    const query = searchQuery.value.trim().toLowerCase();
    result = result.filter(item => 
      item.recipientName.toLowerCase().includes(query)
    );
  }
  
  return result;
});

const handleCareLogDraft = async (formData) => {
  try {
    const success = await submitCareLogData(formData, true);
    if (!success) return;

    alert('요양일지가 임시저장되었습니다.');

    // 작성 내역 탭으로 전환하고 목록 새로고침
    activeTab.value = 'history';
    await loadCareLogHistory();
  } catch (error) {
    console.error('❌ 요양일지 임시저장 실패:', error);
    
    const status = error.response?.status;
    const msg = error.response?.data?.message || '';

    if (status === 404 || status === 500 || msg.includes('Schedule') || msg.includes('일정')) {
      alert('해당 날짜에 등록된 근무 일정이 없습니다.\n일정을 먼저 등록한 후 요양일지를 작성해주세요.');
    } else {
      alert('요양일지 임시저장에 실패했습니다.\nERROR: ' + (msg || '알 수 없는 오류'));
    }
  }
};

const handleCareLogSubmit = async (formData) => {
  try {
    const success = await submitCareLogData(formData, false);
    if (!success) return;

    alert('요양일지가 성공적으로 제출되었습니다.');

    // 일정 새로고침 (버튼 상태 업데이트)
    scheduleStore.notifyScheduleUpdate();

    // 작성 내역 탭으로 전환하고 목록 새로고침
    activeTab.value = 'history';
    await loadCareLogHistory();
  } catch (error) {
    console.error('❌ 요양일지 제출 실패:', error);
    
    const status = error.response?.status;
    const msg = error.response?.data?.message || '';

    if (status === 404 || status === 500 || msg.includes('Schedule') || msg.includes('일정')) {
      alert('해당 날짜에 등록된 근무 일정이 없습니다.\n일정을 먼저 등록한 후 요양일지를 작성해주세요.');
    } else {
      alert('요양일지 제출에 실패했습니다.\nERROR: ' + (msg || '알 수 없는 오류'));
    }
  }
};

onMounted(async () => {
  await loadCareLogHistory();
  if (route.query.viewLogId) {
    const logId = parseInt(route.query.viewLogId, 10);
    const logItem = careLogHistory.value.find(item => (item.logId || item.id) === logId);
    if (logItem) {
      if (route.query.tab === 'history') activeTab.value = 'history';
      await openDetail(logItem);
    }
  }
});
</script>

<template>
  <div class="daily-care-page">
    <main class="main-content">

      <div class="sub-tabs">
        <button
          v-for="tab in subTabs"
          :key="tab.key"
          class="sub-tab-btn"
          :class="{ active: activeTab === tab.key }"
          @click="activeTab = tab.key"
        >
          <span class="tab-icon">{{ tab.icon }}</span>
          <span>{{ tab.label }}</span>
        </button>
      </div>

      <div class="tab-content">
        <div v-if="activeTab === 'write'" class="write-section">
          <CareLogForm :initialData="scheduleData" @submit="handleCareLogSubmit" @draft="handleCareLogDraft" />
        </div>

        <div v-else class="history-section">
          <div class="history-header">
            <div class="header-top">
              <h2 class="history-title">요양일지 작성내역</h2>
              <p class="history-count">총 {{ filteredCareLogHistory.length }}건</p>
            </div>
            <div class="search-bar">
              <select v-model="selectedServiceType" class="type-filter">
                <option value="">전체 유형</option>
                <option value="방문요양">방문요양</option>
                <option value="방문목욕">방문목욕</option>
                <option value="방문간호">방문간호</option>
              </select>
              <input 
                type="text" 
                :value="searchQuery"
                @input="searchQuery = $event.target.value"
                placeholder="수급자 검색..." 
                class="search-input"
              />
            </div>
          </div>

          <div class="history-list">
            <div 
              v-for="item in filteredCareLogHistory" 
              :key="item.id" 
              class="care-log-row" 
              @click="openDetail(item)"
            >
              <div class="row-col basic-info">
                <div class="name-wrapper">
                  <span class="recipient-name">{{ item.recipientName }}</span>
                  <span class="status-badge" :class="{ 'status-draft': item.isDraft }">{{ item.status }}</span>
                </div>
              </div>

              <div class="row-col time-info">
                <span class="row-date">{{ item.date }}</span>
                <span class="row-time">{{ item.time }}</span>
              </div>

              <div class="row-col service-info">
                <span class="service-tag">{{ item.serviceType }}</span>
                <span class="address-text">{{ item.address }}</span>
              </div>

              <div class="row-col note-info">
                <div v-if="item.specialNotes" class="note-preview">
                  <span class="note-icon">💬</span>
                  <span class="note-text">{{ item.specialNotes }}</span>
                </div>
              </div>
              
              <div class="row-col action-col">
                <span class="chevron">›</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <div
      v-if="showDetailModal && selectedLog"
      class="log-modal-overlay"
      @click.self="closeModal"
    >
      <div class="log-modal-card">
        <div class="log-modal-header">
          <div>
            <p class="log-modal-subtitle">요양일지</p>
            <h3 class="log-modal-title">
              {{ isEditMode ? '요양일지 수정' : '요양일지 상세보기' }}
            </h3>
          </div>
          <button class="log-close-btn" @click="closeModal">×</button>
        </div>

        <div class="log-modal-body">
          <CareLogForm
            :initialData="selectedLog"
            :readOnly="!isEditMode"
            :hideActions="!isEditMode"
            @submit="handleCareLogUpdate"
            @draft="handleCareLogDraftUpdate"
          />
        </div>

        <div class="log-modal-footer">
          <button class="btn-secondary" @click="closeModal">닫기</button>
          <template v-if="!isEditMode">
            <button class="btn-secondary" @click="openEdit(selectedLog)">수정</button>
            <button class="btn-danger" @click="deleteLog(selectedLog.id)">삭제</button>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 페이지 기본 설정 */
.daily-care-page {
  background-color: transparent;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.main-content {
  flex: 1;
  width: 100%;
  padding-bottom: 3rem;
}

/* 탭 스타일 */
.sub-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  border-bottom: 2px solid #e5e7eb;
}

.sub-tab-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  border: none;
  background: transparent;
  color: #6b7280;
  font-weight: 600;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s;
  border-bottom: 3px solid transparent;
}

.sub-tab-btn.active {
  color: #16a34a;
  border-bottom-color: #16a34a;
  background: #f0fdf4;
}

.tab-icon { font-size: 1.125rem; }

/* 작성 내역 섹션 */
.history-section { padding: 0; }

.history-header {
  margin-bottom: 1.5rem;
  padding: 1.5rem;
  background: white;
  border-radius: 0.75rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
}

.header-top { display: flex; flex-direction: column; gap: 4px; }

.history-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.history-count {
  font-size: 0.875rem;
  color: #6b7280;
  margin: 0;
}

.search-bar { display: flex; align-items: center; }

.search-input {
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.9rem;
  width: 200px;
  transition: all 0.2s;
}
.search-input:focus {
  outline: none;
  border-color: #16a34a;
  box-shadow: 0 0 0 2px rgba(22, 163, 74, 0.1);
}

.type-filter {
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.9rem;
  width: 130px;
  transition: all 0.2s;
  margin-right: 8px;
  cursor: pointer;
  background-color: white;
}
.type-filter:focus {
  outline: none;
  border-color: #16a34a;
  box-shadow: 0 0 0 2px rgba(22, 163, 74, 0.1);
}

/* 리스트 스타일 (Row Layout) */
.history-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.care-log-row {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 16px 24px;
  display: grid;
  /* 그리드 정의: 이름 | 날짜 | 서비스 | 노트 | 화살표 */
  grid-template-columns: 1.2fr 1.5fr 1.2fr 2fr 40px;
  align-items: center;
  gap: 16px;
  transition: all 0.2s;
  cursor: pointer;
}

.care-log-row:hover {
  border-color: #16a34a;
  box-shadow: 0 4px 12px rgba(22, 163, 74, 0.1);
  transform: translateX(4px);
}

/* 1. 기본 정보 (이름/상태) */
.row-col.basic-info {
  display: flex;
  align-items: center;
}

.name-wrapper {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.recipient-name {
  font-size: 1rem;
  font-weight: 700;
  color: #1f2937;
}

.status-badge {
  display: inline-block;
  padding: 2px 8px;
  background: #dcfce7;
  color: #16a34a;
  font-size: 0.7rem;
  font-weight: 600;
  border-radius: 4px;
  width: fit-content;
}

.status-badge.status-draft {
  background: #fef3c7;
  color: #d97706;
}

/* 2. 시간 정보 */
.row-col.time-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.row-date {
  font-size: 0.9rem;
  color: #374151;
  font-weight: 600;
}

.row-time {
  font-size: 0.8rem;
  color: #6b7280;
}

/* 3. 서비스 정보 */
.row-col.service-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.service-tag {
  font-size: 0.8rem;
  font-weight: 600;
  color: #4b5563;
  background: #f3f4f6;
  padding: 2px 6px;
  border-radius: 4px;
  width: fit-content;
}

.address-text {
  font-size: 0.75rem;
  color: #9ca3af;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
}

/* 4. 노트 (특이사항) */
.row-col.note-info {
  color: #6b7280;
  font-size: 0.85rem;
}

.note-preview {
  display: flex;
  align-items: center;
  gap: 6px;
  background: #fffbeb;
  padding: 6px 10px;
  border-radius: 6px;
  border-left: 3px solid #f59e0b;
  overflow: hidden;
}

.note-text {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  color: #92400e;
}

/* 5. 액션 (화살표) */
.row-col.action-col {
  text-align: right;
  color: #d1d5db;
  font-size: 1.5rem;
  font-weight: 300;
}

/* 모바일 반응형: 가로 리스트 -> 세로 카드형으로 변환 */
@media (max-width: 768px) {
  .care-log-row {
    grid-template-columns: 1fr; /* 1열로 변경 */
    gap: 12px;
    padding: 16px;
  }

  .name-wrapper {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    width: 100%;
  }

  .status-badge {
    margin-top: 0;
  }

  .row-col.time-info,
  .row-col.service-info {
    flex-direction: row;
    align-items: center;
    gap: 8px;
  }

  .row-col.action-col {
    display: none; /* 모바일에서 화살표 숨김 */
  }
  
  .address-text {
      max-width: 200px;
  }
}

/* 모달 스타일 (기존 유지) */
.log-modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  z-index: 2000;
}

.log-modal-card {
  width: min(1200px, 95%);
  background: white;
  border-radius: 0.75rem;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.18);
  overflow: hidden;
  border: 1px solid #e5e7eb;
}

.log-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem 1.5rem;
  border-bottom: 1px solid #e5e7eb;
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
}

.log-modal-title { margin: 0; font-size: 1.25rem; font-weight: 800; color: #166534; }
.log-modal-subtitle { margin: 0; font-size: 0.75rem; color: #16a34a; font-weight: 700; }

.log-close-btn {
  border: none; background: white; width: 36px; height: 36px;
  border-radius: 50%; font-size: 1.25rem; color: #6b7280;
  cursor: pointer; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12);
}

.log-modal-body { padding: 0; max-height: 75vh; overflow-y: auto; }
.log-modal-body .care-log-form { padding: 1.5rem; }

.log-modal-footer {
  display: flex; justify-content: flex-end; gap: 0.5rem;
  padding: 1rem 1.25rem 1.25rem; border-top: 1px solid #e5e7eb; background: #f9fafb;
}

.btn-secondary { padding: 0.75rem 1.25rem; border-radius: 0.65rem; background: white; border: 1px solid #d1d5db; cursor: pointer; }
.btn-danger { padding: 0.75rem 1.25rem; border-radius: 0.65rem; background: #ef4444; color: white; border: none; cursor: pointer; }
</style>