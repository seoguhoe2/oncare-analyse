<script setup>
import { ref, onMounted, watch } from 'vue';
import { Icon } from '@iconify/vue';
import { getAssignedBeneficiaries } from '@/api/employee/employeeApi';
import { getCounselingLogListByBeneficiary } from '@/api/careworker/counselingLogApi';

import CareLogHistoryList from '@/components/employee/diary/CareLogHistoryList.vue';
import EvaluationHistoryList from '@/components/employee/diary/EvaluationHistoryList.vue';
import VisitCounselHistoryList from '@/components/careworker/activity/VisitCounselHistoryList.vue';

const props = defineProps({
  employeeId: { type: [Number, String], required: true }
});

const list = ref([]);
// 선택된 수급자 객체를 저장
const selectedBeneficiary = ref(null);
// 선택된 탭 (summary | basic | council)
const selectedTab = ref('summary');

// 방문상담 내역
const counselHistory = ref([]);

const fetchData = async () => {
  if (!props.employeeId) return;
  try {
    const data = await getAssignedBeneficiaries(props.employeeId);
    list.value = data || [];
  } catch (error) {
    console.error("담당 수급자 목록 조회 실패", error);
    list.value = [];
  }
};

// 방문상담 내역 조회
const fetchCounselHistory = async () => {
  if (!selectedBeneficiary.value) return;
  
  const beneficiaryId = selectedBeneficiary.value.beneficiaryId || selectedBeneficiary.value.id;
  if (!beneficiaryId) return;

  try {
    // 수급자 ID로 방문상담 목록 조회
    const response = await getCounselingLogListByBeneficiary(beneficiaryId);
    
    // 응답 객체에서 실제 데이터 추출 (response.data 혹은 response 자체가 배열일 수 있음)
    const rawData = response?.data ?? response;
    // 배열인지 확인 후 처리 (아닌 경우 빈 배열)
    const data = Array.isArray(rawData) ? rawData : [];

    // 백엔드 응답 데이터를 프론트엔드 형식으로 변환 (VisitCounselPage.vue 로직 적용)
    counselHistory.value = data.map(item => {
      // 날짜 포맷 변환
      const visitDate = item.counselingDate || item.visitDate || item.visit_date || '';
      const dateObj = visitDate ? new Date(visitDate) : new Date();
      const dayNames = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
      const dayOfWeek = dayNames[dateObj.getDay()];
      const formattedDate = visitDate ? `${visitDate.split('T')[0]} (${dayOfWeek})` : '-';

      // 상담 유형 레이블 변환
      const counselTypeMap = {
        '초기상담': '초기 상담',
        '정기상담': '정기 상담',
        '긴급상담': '긴급 상담',
        '종결상담': '종결 상담',
        '보호자상담': '보호자 상담',
        '초기': '초기 상담',
        '정기': '정기 상담',
        '긴급': '긴급 상담',
        '종결': '종결 상담',
        '보호자': '보호자 상담',
        'initial': '초기 상담',
        'regular': '정기 상담',
        'emergency': '긴급 상담',
        'intermediate': '종결 상담',
        'guardian': '보호자 상담'
      };

      // 만족도 레이블 변환
      const reactionMap = {
        '매우만족': '매우 만족',
        '만족': '만족',
        '보통': '보통',
        '불만족': '불만족',
        '매우불만족': '매우 불만족',
        'very_good': '매우 만족',
        'good': '만족',
        'normal': '보통',
        'bad': '불만족',
        'very_bad': '매우 불만족'
      };

      return {
        id: item.counselingId || item.id,
        counselingId: item.counselingId || item.id,
        beneficiaryId: item.beneficiaryId,
        date: formattedDate,
        visitDate: visitDate,
        recipientName: item.beneficiaryName || item.recipientName || selectedBeneficiary.value.name,
        counselType: counselTypeMap[item.counselingType] || item.counselingType || '-',
        reaction: reactionMap[item.satisfaction] || item.satisfaction || '-',
        // 상세 필드 (초기엔 로드 안 됨)
        visitPurpose: item.visitPurpose || null,
        observedCondition: item.attendees || null,
        subjectiveNeeds: item.discussionContent || null,
        counselorNotes: item.agreementContent || null,
        nextVisit: item.nextVisitDate ? item.nextVisitDate.split('T')[0] : null,
        
        // 서명 이미지 URL
        guardianSignUrl: item.guardianSignUrl || null,
        counselorSignUrl: item.counselorSignUrl || null,
        
        detailsLoaded: false,
        showDetails: false,
        status: item.status || '완료',
        recipientSigned: !!item.guardianSignUrl,
        caregiverSigned: !!item.counselorSignUrl,
      };
    });
  } catch (error) {
    console.error("방문상담 내역 조회 실패", error);
    counselHistory.value = [];
  }
};

// 탭 변경 감지 -> 방문상담 탭일 때 데이터 조회
watch(selectedTab, (newTab) => {
  if (newTab === 'council') {
    fetchCounselHistory();
  }
});

// 카드 클릭 시 실행: 상세 화면으로 전환
const goToDetail = (item) => {
  selectedBeneficiary.value = item; 
  selectedTab.value = 'summary'; // 기본 탭: 요양일지
};

// 뒤로가기 버튼: 목록 화면으로 복귀
const goBack = () => {
  selectedBeneficiary.value = null;
};

onMounted(fetchData);
watch(() => props.employeeId, fetchData);
</script>

<template>
  <div class="container">
    
    <div v-if="selectedBeneficiary" class="detail-view">
      <!-- 상단 네비게이션 -->
      <div class="nav-header">
        <button class="back-btn" @click="goBack">
          <Icon icon="line-md:chevron-left" width="20" height="20" />
          전체 수급자 목록
        </button>
        <span class="divider">|</span>
        <span class="current-name">{{ selectedBeneficiary.name }} 님</span>
      </div>

      <!-- 탭 메뉴 -->
      <div class="sub-tabs">
        <button 
          class="sub-tab-btn" 
          :class="{ active: selectedTab === 'summary' }"
          @click="selectedTab = 'summary'"
        >
          요양일지
        </button>
        <button 
          class="sub-tab-btn" 
          :class="{ active: selectedTab === 'basic' }"
          @click="selectedTab = 'basic'"
        >
          기초평가
        </button>
        <button 
          class="sub-tab-btn" 
          :class="{ active: selectedTab === 'council' }"
          @click="selectedTab = 'council'"
        >
          방문상담
        </button>
      </div>

      <!-- 탭 컨텐츠 -->
      <div class="tab-content-area">
        <CareLogHistoryList 
          v-if="selectedTab === 'summary'" 
          :beneficiaryId="selectedBeneficiary.beneficiaryId || selectedBeneficiary.id" 
        />
        
        <EvaluationHistoryList 
          v-else-if="selectedTab === 'basic'" 
          :beneficiaryId="selectedBeneficiary.beneficiaryId || selectedBeneficiary.id" 
        />

        <!-- 방문상담: 공통 컴포넌트 사용 -->
        <div v-else-if="selectedTab === 'council'" class="council-history-wrap">
          <VisitCounselHistoryList :items="counselHistory" />
        </div>
      </div>
    </div>


    <div v-else class="journal-section">
      <h3 class="section-title">요양일지 (수급자별)</h3>
      <p class="section-desc">수급자를 선택하여 요양일지, 기초평가, 방문상담 내역을 확인하세요.</p>
      
      <div class="card-list">
        <div 
          v-for="item in list" 
          :key="item.beneficiaryId" 
          class="log-card"
          @click="goToDetail(item)"
        >
          <div class="card-left">
            <div class="info">
              <div class="name">{{ item.name }}</div>
              <div class="details">
                <span class="grade" v-if="item.grade">{{ item.grade }}</span>
                <span class="separator" v-if="item.grade">·</span>
                <span class="address">{{ item.address || item.birthDate || '정보 없음' }}</span>
              </div>
            </div>
          </div>

          <div class="card-right">
            <div v-if="item.logCount" class="count-badge">{{ item.logCount }}건</div>
            <div class="arrow-icon">
              <Icon icon="line-md:chevron-right" width="20" height="20" style="color:#999;" />
            </div>
          </div>
        </div>

        <div v-if="list.length === 0" class="empty-state">
          담당 수급자가 없습니다.
        </div>
      </div>
    </div>

  </div>
</template>

<style scoped>
/* --- 상세 화면 네비게이션 스타일 --- */
.container {
  width: 100%;
}
.nav-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 1px solid #f3f4f6;
}
.back-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  background: none;
  border: none;
  color: #6b7280;
  cursor: pointer;
  font-size: 14px;
  font-weight: 600;
  padding: 4px 0;
}
.back-btn:hover {
  color: #166534; /* 초록색 포인트 */
}
.divider {
  color: #e5e7eb;
}
.current-name {
  font-size: 16px;
  font-weight: 700;
  color: #111;
}

/* --- 서브 탭 스타일 --- */
.sub-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 20px;
  border-bottom: 1px solid #e5e7eb;
}
.sub-tab-btn {
  padding: 10px 16px;
  background: none;
  border: none;
  border-bottom: 2px solid transparent;
  font-size: 14px;
  font-weight: 600;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.2s;
}
.sub-tab-btn:hover {
  color: #16a34a;
  background-color: #f0fdf4;
}
.sub-tab-btn.active {
  color: #16a34a;
  border-bottom-color: #16a34a;
}

.tab-content-area {
  min-height: 300px;
}

/* --- 방문상담 스타일 (래퍼만 유지) --- */
.council-history-wrap {
  padding-bottom: 40px;
}

/* --- 기존 목록 스타일 유지 --- */
.journal-section {
  width: 100%;
  font-family: 'Pretendard', sans-serif;
}
.section-title {
  font-size: 16px;
  font-weight: 700;
  color: #166534;
  margin-bottom: 4px;
}
.section-desc {
  font-size: 13px;
  color: #6b7280;
  margin-bottom: 16px;
}
.card-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.log-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 16px 20px;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
}
.log-card:hover {
  border-color: #22c55e;
  transform: translateY(-1px);
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
}
.card-left {
  display: flex;
  align-items: center;
  gap: 16px;
}
.info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.name {
  font-size: 16px;
  font-weight: 700;
  color: #111;
}
.details {
  font-size: 13px;
  color: #666;
  display: flex;
  align-items: center;
  gap: 6px;
}
.grade { font-weight: 500; color: #333; }
.separator { color: #ccc; }
.address {
  color: #6b7280;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 200px;
}
.card-right {
  display: flex;
  align-items: center;
  gap: 12px;
}
.count-badge {
  background-color: #dbeafe;
  color: #1e40af;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
}
.empty-state {
  text-align: center;
  padding: 40px;
  color: #999;
  background: #f9fafb;
  border-radius: 12px;
}
</style>