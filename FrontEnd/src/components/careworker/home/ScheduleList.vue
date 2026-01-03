<script setup>
import { ref, onMounted, watch, onActivated } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { getTodaySchedules, startVisit, completeVisit } from '@/api/careworker';
import { getCareLogList } from '@/api/careworker/careLogApi';
import { useScheduleStore } from '@/stores/schedule';
import BeneficiaryDetailModal from './BeneficiaryDetailModal.vue';

const router = useRouter();
const route = useRoute();
const scheduleStore = useScheduleStore();

const scheduleItems = ref([]);
const loading = ref(true);
const showBeneficiaryModal = ref(false);
const selectedBeneficiaryId = ref(null);
const selectedServiceType = ref(null);

// 오늘 일정 로드
const loadSchedules = async () => {
  try {
    const response = await getTodaySchedules();
    console.log('일정 응답 데이터:', response);
    console.log('response.data 타입:', typeof response.data, Array.isArray(response.data));

    const dataArray = response.data || [];
    console.log('데이터 배열 길이:', dataArray.length);

    // 모든 요양일지를 한 번에 가져오기
    let careLogsMap = new Map(); // vsId -> reportId 매핑
    try {
      console.log('📋 요양일지 목록 조회 중...');
      const careLogsResponse = await getCareLogList();
      console.log('📋 요양일지 목록 응답:', careLogsResponse);
      console.log('📋 요양일지 데이터 배열:', careLogsResponse?.data);

      if (careLogsResponse && careLogsResponse.data && Array.isArray(careLogsResponse.data)) {
        console.log(`📋 총 ${careLogsResponse.data.length}개의 요양일지 발견`);

        // vsId를 키로 하는 Map 생성 (가장 최근 요양일지만 저장)
        careLogsResponse.data.forEach((log, index) => {
          console.log(`📋 요양일지 [${index}]:`, log);
          console.log(`📋 요양일지 [${index}] 키:`, Object.keys(log));

          const vsId = log.vsId || log.scheduleId || log.vs_id || log.schedule_id;
          const logId = log.logId || log.id || log.careLogId || log.care_log_id || log.log_id;

          console.log(`📋 요양일지 [${index}] 추출: vsId=${vsId}, logId=${logId}`);

          if (vsId && logId) {
            // 이미 있는 경우 나중 것으로 덮어쓰기 (최신 것 유지)
            careLogsMap.set(vsId, logId);
            console.log(`✅ 요양일지 매핑 성공: vsId=${vsId} -> logId=${logId}`);
          } else {
            console.warn(`⚠️ 요양일지 [${index}] 매핑 실패: vsId 또는 logId 없음`);
          }
        });
        console.log(`📋 총 ${careLogsMap.size}개의 요양일지 매핑 완료`);
        console.log('📋 매핑된 Map:', Array.from(careLogsMap.entries()));
      }
    } catch (error) {
      console.warn('⚠️ 요양일지 목록 조회 실패:', error);
    }

    // 일정 데이터 매핑
    scheduleItems.value = dataArray.map(schedule => {
      console.log('개별 일정 데이터:', schedule);
      console.log('schedule의 모든 키:', Object.keys(schedule));
      console.log('schedule 전체 구조:', JSON.stringify(schedule, null, 2));

      const scheduleId = schedule.vsId || schedule.scheduleId || schedule.id;

      // beneficiaryId 추출 시도 (여러 가능 필드 확인)
      let beneficiaryId = schedule.beneficiaryId
        || schedule.recipientId
        || schedule.beneficiary_id
        || schedule.beneficiary?.id
        || schedule.recipient?.id;

      // beneficiaryId가 없으면 scheduleId 사용 (임시)
      if (!beneficiaryId) {
        console.warn('beneficiaryId를 찾을 수 없어 scheduleId를 사용합니다.');
        beneficiaryId = scheduleId;
      }

      console.log('추출된 scheduleId:', scheduleId);
      console.log('추출된 beneficiaryId:', beneficiaryId);

      // Map에서 reportId 조회
      let reportId = schedule.reportId || schedule.careLogId || schedule.report_id;

      if (schedule.status === 'DONE' && scheduleId) {
        const mappedReportId = careLogsMap.get(scheduleId);
        if (mappedReportId) {
          reportId = mappedReportId;
          console.log(`✅ 일정 ${scheduleId}에 대한 요양일지 발견! reportId: ${reportId}`);
        } else {
          console.log(`ℹ️ 일정 ${scheduleId}에 대한 요양일지 없음`);
        }
      }

      console.log('📋 최종 reportId 확인:', {
        scheduleId,
        reportId,
        status: schedule.status,
        originalReportId: schedule.reportId,
        careLogId: schedule.careLogId
      });

      return {
        id: scheduleId,
        beneficiaryId: beneficiaryId,
        name: schedule.beneficiaryName || schedule.recipientName || '이름 없음',
        grade: schedule.grade || '등급 정보 없음',
        tags: schedule.tags || [],
        time: `${schedule.startTime || schedule.visitTime?.split(' - ')[0] || '시작시간 미정'} - ${schedule.endTime || schedule.visitTime?.split(' - ')[1] || '종료시간 미정'}`,
        service: schedule.serviceType || schedule.serviceLabel || schedule.service_type || schedule.service || '서비스 정보 없음',
        address: schedule.address || '주소 정보 없음',
        status: getStatusText(schedule.status),
        statusColor: getStatusColor(schedule.status),
        showAttendance: schedule.status === 'SCHEDULED',
        buttons: getButtons(schedule.status, reportId),
        originalStatus: schedule.status,
        actualStartTime: schedule.actualStartTime,
        actualEndTime: schedule.actualEndTime,
        reportId: reportId
      };
    });

    console.log('최종 scheduleItems:', scheduleItems.value);
    console.log('scheduleItems 길이:', scheduleItems.value.length);
  } catch (error) {
    console.error('오늘의 일정 불러오기 실패:', error);
  } finally {
    loading.value = false;
  }
};

// 상태 텍스트 변환
const getStatusText = (status) => {
  const statusMap = {
    'SCHEDULED': '예정',
    'IN_PROGRESS': '진행중',
    'DONE': '완료',
    'CANCELLED': '취소'
  };
  return statusMap[status] || '예정';
};

// 상태 색상 변환
const getStatusColor = (status) => {
  const colorMap = {
    'SCHEDULED': 'gray',
    'IN_PROGRESS': 'blue',
    'DONE': 'green',
    'CANCELLED': 'red'
  };
  return colorMap[status] || 'gray';
};

// 버튼 구성 - 상태에 따라 버튼만 표시
const getButtons = (status, reportId) => {
  console.log('🔘 버튼 결정:', { status, reportId, hasReportId: !!reportId });

  if (status === 'SCHEDULED') {
    return [
      { text: '서비스 시작', type: 'primary', color: 'green', action: 'start' }
    ];
  } else if (status === 'IN_PROGRESS') {
    return [
      { text: '서비스 완료', type: 'primary', color: 'blue', action: 'finish' }
    ];
  } else if (status === 'DONE') {
    // 요양일지가 작성되었으면 확인으로 변경
    if (reportId) {
      console.log('✅ reportId 있음 -> 요양일지 보기 버튼');
      return [
        { text: '요양일지 보기', type: 'primary', color: 'orange', action: 'viewLog' }
      ];
    } else {
      console.log('❌ reportId 없음 -> 요양일지 작성 버튼');
      return [
        { text: '요양일지 작성', type: 'primary', color: 'purple', action: 'writeLog' }
      ];
    }
  }
  return [];
};

// 시간 포맷 함수
const formatTime = (timeString) => {
  if (!timeString) return '';
  const date = new Date(timeString);
  return date.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: false });
};

// 수급자 상세 정보 보기
const showBeneficiaryDetail = (item) => {
  console.log('수급자 상세 보기 클릭:', item);
  console.log('beneficiaryId:', item.beneficiaryId);

  if (!item.beneficiaryId) {
    console.error('beneficiaryId가 없습니다. item:', item);
    alert('수급자 정보를 찾을 수 없습니다.');
    return;
  }
  selectedBeneficiaryId.value = item.beneficiaryId;
  selectedServiceType.value = item.service; // 서비스 유형 정보 전달
  showBeneficiaryModal.value = true;
  console.log('모달 오픈 - beneficiaryId:', selectedBeneficiaryId.value);
  console.log('모달 오픈 - serviceType:', selectedServiceType.value);
};

// 모달 닫기
const closeBeneficiaryModal = () => {
  showBeneficiaryModal.value = false;
  selectedBeneficiaryId.value = null;
  selectedServiceType.value = null;
};

// 액션 처리
const handleAction = async (action, item) => {
  try {
    // vsId가 없으면 에러 메시지 표시
    if (!item.id) {
      console.error('일정 ID가 없습니다:', item);
      alert('일정 정보를 불러올 수 없습니다.');
      return;
    }

    if (action === 'start') {
      await startVisit(item.id, {
        actualStartTime: new Date().toISOString()
      });
      await loadSchedules();
      // 일정 상태 변경 알림 (캘린더 자동 새로고침용)
      scheduleStore.notifyScheduleUpdate();
    } else if (action === 'finish') {
      await completeVisit(item.id, {
        actualEndTime: new Date().toISOString()
      });
      await loadSchedules();
      // 일정 상태 변경 알림 (캘린더 자동 새로고침용)
      scheduleStore.notifyScheduleUpdate();
    } else if (action === 'detail') {
      console.log('상세보기:', item.name);
    } else if (action === 'writeLog') {
      // 돌봄일지 작성 페이지로 이동 - 일정 정보를 query로 전달
      router.push({
        name: 'activity-care',
        query: {
          beneficiaryId: item.beneficiaryId,
          beneficiaryName: item.name,
          serviceDate: new Date().toISOString().split('T')[0], // 오늘 날짜
          startTime: item.time.split(' - ')[0]?.trim() || '',
          endTime: item.time.split(' - ')[1]?.trim() || '',
          serviceType: item.service,
          scheduleId: item.id
        }
      });
    } else if (action === 'viewLog') {
      // 돌봄일지 확인 페이지로 이동 - reportId를 query로 전달
      console.log('요양일지 확인:', item.reportId);
      router.push({
        name: 'activity-care',
        query: {
          viewLogId: item.reportId,
          tab: 'history'
        }
      });
    }
  } catch (error) {
    console.error('액션 처리 실패:', error);
    alert(`작업 실패: ${error.message || '알 수 없는 오류'}`);
  }
};

// 일정 업데이트 감지 시 자동 새로고침
watch(() => scheduleStore.scheduleUpdateCounter, async (newValue, oldValue) => {
  console.log('🔄 홈 화면: 일정 업데이트 감지!', { oldValue, newValue });
  console.log('🔄 홈 화면: 일정 새로고침 시작... (요양일지 작성/삭제 후)');
  await loadSchedules();
  console.log('🔄 홈 화면: 일정 새로고침 완료!');
}, { immediate: false });

// 라우트 변경 감지 (홈 페이지로 이동 시 새로고침)
watch(() => route.path, (newPath, oldPath) => {
  console.log('🔄 라우트 변경:', { oldPath, newPath });
  if (newPath === '/home') {
    console.log('📅 홈 페이지로 이동: 일정 새로고침');
    // 약간의 지연을 두고 새로고침 (DOM 업데이트 대기)
    setTimeout(() => {
      loadSchedules();
    }, 50);
  }
});

// 컴포넌트 활성화 시에도 새로고침 (keep-alive 사용 시)
onActivated(() => {
  console.log('📅 홈 화면 활성화: 일정 새로고침');
  loadSchedules();
});

onMounted(() => {
  console.log('📅 ScheduleList 마운트: 초기 일정 로드');
  loadSchedules();
});
</script>

<template>
  <section class="schedule-section">
    <div class="header-row">
      <h2 class="section-title">📅 오늘의 일정</h2>
    </div>

    <div v-if="loading" class="empty-state">
      일정을 불러오는 중..
    </div>
    <div v-else-if="scheduleItems.length === 0" class="empty-state">
      오늘 예정된 일정이 없습니다.
    </div>
    <div v-else class="schedule-grid">
      <div v-for="item in scheduleItems" :key="item.id" class="schedule-card">
        <div class="card-header" @click="showBeneficiaryDetail(item)">
          <div class="user-profile clickable">
            <div class="avatar-placeholder">{{ item.name?.charAt(0) || '?' }}</div>
            <div>
              <h3 class="user-name">{{ item.name }}</h3>
              <p class="user-grade">{{ item.grade }}</p>
            </div>
          </div>
          <div class="status-wrapper">
            <span :class="['status-badge', item.statusColor]">{{ item.status }}</span>
          </div>
        </div>

        <div v-if="item.tags" class="tag-list">
          <span v-for="(tag, index) in item.tags" :key="index" class="tag">
            💊 {{ tag }}
          </span>
        </div>

        <div class="info-list">
          <div class="info-item">
            <span class="info-icon">🕒</span>
            <span class="info-text">{{ item.time }}</span>
          </div>
          <div v-if="item.actualStartTime" class="info-item time-badge">
            <span class="info-icon">⏱</span>
            <span class="info-text">시작: {{ formatTime(item.actualStartTime) }}</span>
          </div>
          <div v-if="item.actualEndTime" class="info-item time-badge">
            <span class="info-icon">🏁</span>
            <span class="info-text">종료: {{ formatTime(item.actualEndTime) }}</span>
          </div>
          <div class="info-item">
            <span class="info-icon">📋</span>
            <span class="info-text">{{ item.service }}</span>
          </div>
          <div class="info-item">
            <span class="info-icon">📍</span>
            <span class="info-text address">{{ item.address }}</span>
          </div>
        </div>

        <div class="action-buttons">
          <button v-for="(btn, index) in item.buttons" :key="index"
            :class="['main-btn', btn.type, btn.color]"
            @click="handleAction(btn.action, item)">
            {{ btn.text }}
          </button>
        </div>
      </div>
    </div>

    <!-- 수급자 상세 정보 모달 -->
    <BeneficiaryDetailModal
      :isOpen="showBeneficiaryModal"
      :beneficiaryId="selectedBeneficiaryId"
      :serviceType="selectedServiceType"
      @close="closeBeneficiaryModal"
    />
  </section>
</template>

<style scoped>
.schedule-section {
  background-color: white;
  padding: 1.5rem;
  border-radius: 24px;
  border: 1px solid #d7f3dd;
  box-shadow: 0 4px 16px rgba(15, 23, 42, 0.05);
}

.header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.25rem;
}

.section-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: #388e3c;
  margin: 0;
}

.schedule-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
  grid-auto-rows: auto;
}

/* Limit desktop view to first 4 cards */
.schedule-card:nth-child(n+5) {
  display: none;
}

/* Responsive: single column on mobile */
@media (max-width: 768px) {
  .schedule-grid {
    grid-template-columns: 1fr;
    grid-template-rows: auto;
  }

  .schedule-card:nth-child(n+5) {
    display: flex;
  }
}

.schedule-card {
  background-color: white; padding: 1.25rem; border-radius: 0.75rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1); display: flex; flex-direction: column; gap: 1rem;
  border: 1px solid #f3f4f6;
}

/* Header */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
  transition: background-color 0.2s ease;
  padding: 0.5rem;
  margin: -0.5rem;
  border-radius: 0.5rem;
}

.card-header:hover {
  background-color: #f3f4f6;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.user-profile.clickable {
  flex: 1;
}
.avatar-placeholder { 
  width: 2.5rem; height: 2.5rem; background-color: #e5e7eb; border-radius: 50%; 
  display: flex; align-items: center; justify-content: center; font-weight: 700; color: #6b7280;
}

.user-name { font-size: 1rem; font-weight: 700; color: #1f2937; margin: 0; }
.user-grade { font-size: 0.75rem; color: #6b7280; margin: 0; }

.status-wrapper { display: flex; align-items: center; gap: 0.5rem; }

.status-badge { padding: 0.25rem 0.6rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 700; }
.status-badge.green { background-color: #dcfce7; color: #16a34a; }
.status-badge.blue { background-color: #dbeafe; color: #2563eb; }
.status-badge.gray { background-color: #f3f4f6; color: #4b5563; }

/* Tags */
.tag-list { display: flex; gap: 0.5rem; flex-wrap: wrap; }
.tag { padding: 0.25rem 0.6rem; background-color: #fee2e2; color: #dc2626; border-radius: 9999px; font-size: 0.75rem; font-weight: 600; }

/* Info List */
.info-list { display: flex; flex-direction: column; gap: 0.5rem; }
.info-item { display: flex; align-items: center; gap: 0.5rem; font-size: 0.875rem; color: #4b5563; }
.info-icon { width: 1.25rem; text-align: center; }
.info-text.address { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

/* Buttons */
.action-buttons {
  display: flex;
  gap: 0.5rem;
  margin-top: auto;
}

.main-btn {
  width: 100%;
  padding: 0.875rem;
  border-radius: 0.75rem;
  font-size: 0.9375rem;
  font-weight: 700;
  border: none;
  cursor: pointer;
  text-align: center;
  white-space: nowrap;
  transition: all 0.2s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
.main-btn.primary.green {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  color: white;
}
.main-btn.primary.green:hover {
  background: linear-gradient(135deg, #16a34a 0%, #15803d 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.4);
}

.main-btn.primary.blue {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  color: white;
}
.main-btn.primary.blue:hover {
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(37, 99, 235, 0.4);
}

.main-btn.primary.purple {
  background: linear-gradient(135deg, #a855f7 0%, #9333ea 100%);
  color: white;
}
.main-btn.primary.purple:hover {
  background: linear-gradient(135deg, #9333ea 0%, #7e22ce 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(168, 85, 247, 0.4);
}

.main-btn.primary.orange {
  background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
  color: white;
}
.main-btn.primary.orange:hover {
  background: linear-gradient(135deg, #ea580c 0%, #c2410c 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(249, 115, 22, 0.4);
}

/* Time badge styling */
.info-item.time-badge {
  background-color: #f0fdf4;
  padding: 0.5rem;
  border-radius: 0.5rem;
  font-weight: 600;
  color: #15803d;
}
</style>
