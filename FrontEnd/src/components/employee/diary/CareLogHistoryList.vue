<script setup>
import { ref, watch, onMounted, computed } from 'vue';
import { Icon } from '@iconify/vue';
import { getCareLogListByBeneficiary, getCareLogDetail } from '@/api/careworker/careLogApi';
import CareLogForm from '@/components/careworker/activity/CareLogForm.vue';

const props = defineProps({
  beneficiaryId: {
    type: [Number, String],
    required: true
  }
});

const careLogHistory = ref([]);
const loading = ref(false);
const searchQuery = ref('');
const selectedServiceType = ref('');

const showDetailModal = ref(false);
const selectedLog = ref(null);

// 백엔드 데이터를 프론트엔드 폼 데이터로 변환 (DailyCarePage.vue 로직 재사용)
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

const loadCareLogHistory = async () => {
  if (!props.beneficiaryId) return;
  
  try {
    loading.value = true;
    const response = await getCareLogListByBeneficiary(props.beneficiaryId);
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
    
    // 날짜 내림차순 정렬
    careLogHistory.value.sort((a, b) => {
        const dateA = new Date(a.serviceDate || a.date);
        const dateB = new Date(b.serviceDate || b.date);
        return dateB - dateA;
    });

  } catch (error) {
    console.error("요양일지 목록 조회 실패", error);
    careLogHistory.value = [];
  } finally {
    loading.value = false;
  }
};

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

const openDetail = async (item) => {
  try {
    const logId = item.logId || item.id;
    if (!logId) {
      alert('요양일지 ID를 찾을 수 없습니다.');
      return;
    }
    const response = await getCareLogDetail(logId);
    const detailData = response?.data ?? response;
    selectedLog.value = mapBackendToFormData(detailData);
    showDetailModal.value = true;
  } catch (error) {
    alert('요양일지를 불러오는데 실패했습니다.');
  }
};

const closeModal = () => {
  showDetailModal.value = false;
  selectedLog.value = null;
};

watch(() => props.beneficiaryId, loadCareLogHistory, { immediate: true });
</script>

<template>
  <div class="care-log-history">
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
        <!-- 수급자별 조회이므로 이름 검색은 굳이 필요없을 수 있으나 유지 -->
      </div>
    </div>

    <div v-if="loading" class="loading-state">데이터를 불러오는 중...</div>
    
    <div v-else-if="filteredCareLogHistory.length > 0" class="history-list">
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
        </div>

        <div class="row-col note-info">
          <div v-if="item.specialNotes" class="note-preview">
            <span class="note-icon"><Icon icon="line-md:chat" width="16" height="16" /></span>
            <span class="note-text">{{ item.specialNotes }}</span>
          </div>
        </div>
        
        <div class="row-col action-col">
          <span class="chevron"><Icon icon="line-md:chevron-right" width="20" height="20" /></span>
        </div>
      </div>
    </div>
    
    <div v-else class="empty-state">
      <p>요양일지 내역이 없습니다.</p>
    </div>

    <!-- 상세 모달 -->
    <div
      v-if="showDetailModal && selectedLog"
      class="log-modal-overlay"
      @click.self="closeModal"
    >
      <div class="log-modal-card">
        <div class="log-modal-header">
          <div>
            <p class="log-modal-subtitle">요양일지</p>
            <h3 class="log-modal-title">요양일지 상세보기</h3>
          </div>
          <button class="log-close-btn" @click="closeModal">×</button>
        </div>

        <div class="log-modal-body">
          <CareLogForm
            :initialData="selectedLog"
            :readOnly="true"
            :hideActions="true"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.care-log-history {
  width: 100%;
}

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

.type-filter {
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.9rem;
  width: 130px;
  transition: all 0.2s;
  cursor: pointer;
  background-color: white;
}
.type-filter:focus {
  outline: none;
  border-color: #16a34a;
  box-shadow: 0 0 0 2px rgba(22, 163, 74, 0.1);
}

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

.row-col.basic-info { display: flex; align-items: center; }
.name-wrapper { display: flex; flex-direction: column; gap: 4px; }
.recipient-name { font-size: 1rem; font-weight: 700; color: #1f2937; }
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
.status-badge.status-draft { background: #fef3c7; color: #d97706; }

.row-col.time-info { display: flex; flex-direction: column; gap: 2px; }
.row-date { font-size: 0.9rem; color: #374151; font-weight: 600; }
.row-time { font-size: 0.8rem; color: #6b7280; }

.row-col.service-info { display: flex; flex-direction: column; gap: 4px; }
.service-tag {
  font-size: 0.8rem;
  font-weight: 600;
  color: #4b5563;
  background: #f3f4f6;
  padding: 2px 6px;
  border-radius: 4px;
  width: fit-content;
}

.row-col.note-info { color: #6b7280; font-size: 0.85rem; }
.note-preview {
  display: flex;
  align-items: center;
  gap: 6px;
  background: #f9fafb;
  padding: 6px 10px;
  border-radius: 6px;
}
.note-text {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 250px;
}

.action-col { text-align: right; color: #9ca3af; font-size: 1.2rem; }

.loading-state, .empty-state {
  text-align: center;
  padding: 40px;
  color: #6b7280;
  background: #f9fafb;
  border-radius: 12px;
}

/* Modal Styles */
.log-modal-overlay {
  position: fixed; top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex; justify-content: center; align-items: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
}

.log-modal-card {
  background: white;
  width: 90%; max-width: 800px;
  height: 90vh; /* Fixed height ratio */
  max-height: 900px;
  border-radius: 16px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
  display: flex; flex-direction: column;
  overflow: hidden;
}

.log-modal-header {
  padding: 20px 24px;
  border-bottom: 1px solid #e5e7eb;
  display: flex; justify-content: space-between; align-items: flex-start;
  background: #fff;
}
.log-modal-subtitle { font-size: 0.875rem; color: #6b7280; margin: 0 0 4px; }
.log-modal-title { font-size: 1.5rem; font-weight: 700; color: #111; margin: 0; }

.log-close-btn {
  background: transparent; border: none; font-size: 24px; color: #9ca3af; cursor: pointer; padding: 4px;
}
.log-close-btn:hover { color: #4b5563; }

.log-modal-body {
  flex: 1; overflow-y: auto; padding: 24px; background: #f9fafb;
}

/* Scrollbar styling */
.log-modal-body::-webkit-scrollbar { width: 8px; }
.log-modal-body::-webkit-scrollbar-track { background: #f1f1f1; }
.log-modal-body::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 4px; }
.log-modal-body::-webkit-scrollbar-thumb:hover { background: #9ca3af; }

</style>
