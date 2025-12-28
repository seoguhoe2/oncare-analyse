<script setup>
import { ref, onMounted, onActivated, computed, watch } from 'vue';
import { useRoute } from 'vue-router';
import { useUserStore } from '@/stores/user';
import { useScheduleStore } from '@/stores/schedule';
import ScheduleHeader from '@/components/careworker/schedule/ScheduleHeader.vue';
import CalendarView from '@/components/careworker/schedule/CalendarView.vue';
import WeekView from '@/components/careworker/schedule/WeekView.vue';
import MonthView from '@/components/careworker/schedule/MonthView.vue';
import ScheduleDetail from '@/components/careworker/schedule/ScheduleDetail2.vue';
import { getSchedules, getScheduleDetail, getPersonalTypes } from '@/api/careworker';
import { createVisitSchedule, createPersonalSchedule, updateVisitSchedule, updatePersonalSchedule, deleteVisitSchedule, deletePersonalSchedule } from '@/api/careworker';
import { getMyBeneficiaries } from '@/api/careworker';

const route = useRoute();
const scheduleStore = useScheduleStore();

// 선택된 일정 객체 (null이면 placeholder 노출)
const selectedSchedule = ref(null);

// 현재 뷰 타입 ('day', 'week', 'month')
const currentView = ref('day');

// 현재 선택된 날짜 (기본값: 오늘)
const currentDate = ref(new Date());

// 컴포넌트 강제 리렌더링을 위한 키
const componentKey = ref(0);

// 일정 데이터
const schedules = ref([]);
const loading = ref(false);

// 개인 일정 유형 목록
const personalTypes = ref([]);

// 내 담당 수급자 목록
const myBeneficiaries = ref([]);

// 날짜 범위 계산
const dateRange = computed(() => {
  const date = new Date(currentDate.value); // 원본 날짜 복사
  let startDate, endDate;

  if (currentView.value === 'day') {
    // 일간: 선택된 날짜만
    startDate = new Date(date);
    endDate = new Date(date);
  } else if (currentView.value === 'week') {
    // 주간: 선택된 날짜가 속한 주의 월요일 ~ 일요일
    const day = date.getDay();
    const diff = day === 0 ? -6 : 1 - day;
    startDate = new Date(date);
    startDate.setDate(date.getDate() + diff);
    endDate = new Date(startDate);
    endDate.setDate(startDate.getDate() + 6);
  } else {
    // 월간: 선택된 날짜가 속한 달의 1일 ~ 말일
    startDate = new Date(date.getFullYear(), date.getMonth(), 1);
    endDate = new Date(date.getFullYear(), date.getMonth() + 1, 0);
  }

  // 날짜 포맷팅 함수 (YYYY-MM-DD, 로컬 기준)
  const formatLocal = (d) => {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
  };

  return {
    startDate: formatLocal(startDate),
    endDate: formatLocal(endDate),
  };
});

// 백엔드 일정 데이터를 프론트엔드 형식으로 변환
const transformSchedule = (schedule) => {
  // timeRange 파싱 ("14:00-16:00" -> {startTime: "14:00", endTime: "16:00"})
  let startTime = schedule.startTime;
  let endTime = schedule.endTime;
  if (schedule.timeRange && schedule.timeRange.includes('-')) {
    const [start, end] = schedule.timeRange.split('-');
    startTime = start.trim();
    endTime = end.trim();
  }

  // 백엔드 캘린더 리스트 응답 구조 처리 (selectSchedulesByPeriod)
  if (schedule.hasOwnProperty('isPersonal')) {
    const isPersonal = schedule.isPersonal;

    if (isPersonal) {
      // 개인 일정
      return {
        id: schedule.scheduleId,
        scheduleId: schedule.scheduleId,
        scheduleType: 'PERSONAL',
        date: schedule.date,
        startTime: schedule.startTime,
        endTime: schedule.endTime,
        recipient: schedule.title || '개인일정',
        serviceLabel: schedule.type || '개인',
        service: 'PERSONAL',
        status: schedule.status || 'SCHEDULED',
        statusColor: getStatusColor(schedule.status),
        colorClass: 'bg-gray',
        address: schedule.location || '',
        notes: schedule.notes || '',
        duration: calculateDuration(schedule.startTime, schedule.endTime),
        title: schedule.title,
        location: schedule.location,
        personalTypeId: schedule.personalTypeId, // 수정에 필요
      };
    } else {
      // 방문 일정
      return {
        id: schedule.scheduleId,
        scheduleId: schedule.scheduleId,
        scheduleType: 'VISIT',
        date: schedule.date,
        startTime: schedule.startTime,
        endTime: schedule.endTime,
        recipient: schedule.recipientName || '수급자',
        serviceLabel: schedule.type || '방문요양',
        service: 'VISIT',
        status: schedule.status || 'SCHEDULED',
        statusColor: getStatusColor(schedule.status),
        colorClass: 'bg-blue',
        address: schedule.location || '',
        notes: schedule.notes || '',
        duration: calculateDuration(schedule.startTime, schedule.endTime),
        recipientName: schedule.recipientName,
        location: schedule.location,
      };
    }
  }

  // 백엔드 상세 조회 응답 구조 처리
  if (schedule.recipient && typeof schedule.recipient === 'object') {
    // 수급자 정보
    const recipientInfo = schedule.recipient;

    return {
      id: schedule.scheduleId || schedule.vsId || schedule.id,
      scheduleId: schedule.scheduleId || schedule.vsId || schedule.id,
      scheduleType: 'VISIT', // 상세 조회 데이터는 방문 일정
      date: schedule.date,
      startTime: startTime,
      endTime: endTime,
      recipient: recipientInfo.name || '수급자',
      beneficiaryId: recipientInfo.recipientId,
      serviceLabel: schedule.serviceContent || '방문요양',
      service: 'VISIT',
      status: schedule.status || 'SCHEDULED',
      statusColor: getStatusColor(schedule.status),
      colorClass: 'bg-blue',
      address: recipientInfo.address || '',

      // 상세 정보
      duration: calculateDuration(startTime, endTime),
      caregiver: schedule.caregiverName || '',

      // 서비스 내용 (문자열 또는 배열)
      serviceContent: Array.isArray(schedule.serviceContent)
        ? schedule.serviceContent.join(', ')
        : schedule.serviceContent || '',

      // 질환 (배열)
      disease: Array.isArray(schedule.diseases)
        ? schedule.diseases
        : (schedule.diseases ? [schedule.diseases] : []),

      // 위험 요소 (배열)
      riskFactors: Array.isArray(schedule.riskFactors)
        ? schedule.riskFactors
        : (schedule.riskFactors ? [schedule.riskFactors] : []),

      // 특이사항 (배열)
      significants: Array.isArray(schedule.significants)
        ? schedule.significants
        : (schedule.significants ? [schedule.significants] : []),

      // 개인 태그 (배열)
      personalTags: Array.isArray(schedule.personalTags)
        ? schedule.personalTags
        : (schedule.personalTags ? [schedule.personalTags] : []),

      // 메모/노트
      notes: schedule.specialNotes || schedule.notes || '',

      // 보호자 정보
      emergencyContact: recipientInfo.guardianPhone
        ? `${recipientInfo.guardianPhone} (${recipientInfo.guardianName || '보호자'})`
        : '',
      careGrade: recipientInfo.careGrade || '',
      guardianName: recipientInfo.guardianName || '',
      guardianPhone: recipientInfo.guardianPhone || '',
      relation: recipientInfo.relation || '',
    };
  }

  // 방문 일정 (visitSchedule)
  if (schedule.scheduleType === 'VISIT' || schedule.visitDate) {
    return {
      id: schedule.vsId || schedule.scheduleId || schedule.id,
      scheduleId: schedule.vsId || schedule.scheduleId || schedule.id,
      scheduleType: 'VISIT',
      date: schedule.visitDate || schedule.date,
      startTime: startTime || schedule.startTime,
      endTime: endTime || schedule.endTime,
      recipient: schedule.beneficiaryName || '수급자',
      beneficiaryId: schedule.beneficiaryId,
      serviceLabel: schedule.serviceContent || '방문요양',
      service: 'VISIT',
      status: schedule.status || 'SCHEDULED',
      statusColor: getStatusColor(schedule.status),
      colorClass: 'bg-blue',
      address: schedule.address || '',
      // 상세 정보
      duration: calculateDuration(startTime || schedule.startTime, endTime || schedule.endTime),
      caregiver: schedule.caregiverName || '',
      serviceContent: schedule.serviceContent || '',
      disease: schedule.diseases || [],
      riskFactors: schedule.riskFactors || [],
      notes: schedule.specialNotes || schedule.notes || '',
      emergencyContact: schedule.emergencyContact || '',
    };
  }

  // 개인 일정 (personalSchedule)
  if (schedule.scheduleType === 'PERSONAL' || schedule.personalTypeId) {
    return {
      id: schedule.psId || schedule.scheduleId || schedule.id,
      scheduleId: schedule.psId || schedule.scheduleId || schedule.id,
      scheduleType: 'PERSONAL',
      date: schedule.visitDate || schedule.date,
      startTime: startTime || schedule.startTime,
      endTime: endTime || schedule.endTime,
      recipient: schedule.personalTypeName || '개인일정',
      serviceLabel: schedule.personalTypeName || '개인',
      service: 'PERSONAL',
      status: '개인',
      statusColor: 'gray',
      colorClass: 'bg-gray',
      content: schedule.content || '',
      duration: calculateDuration(startTime || schedule.startTime, endTime || schedule.endTime),
    };
  }

  // 기본 형식 (fallback)
  // ID가 없는 경우 임시 ID 생성 (날짜 + 시간 기반)
  // temp-로 시작해야 onSelectSchedule에서 감지 가능
  const fallbackId = schedule.id || schedule.vsId || schedule.psId ||
                     `temp-${schedule.date || ''}-${schedule.startTime || ''}`.replace(/:/g, '');

  return {
    ...schedule,
    id: fallbackId,
    scheduleId: fallbackId,
    date: schedule.visitDate || schedule.date,
    recipient: schedule.beneficiaryName || schedule.personalTypeName || schedule.title || '일정',
    serviceLabel: schedule.serviceType || schedule.type || '일정',
    colorClass: schedule.colorClass || 'bg-green',
  };
};

// 상태에 따른 색상 반환
const getStatusColor = (status) => {
  const colorMap = {
    'SCHEDULED': 'gray',
    'IN_PROGRESS': 'blue',
    'DONE': 'green',
    'CANCELLED': 'red'
  };
  return colorMap[status] || 'gray';
};

// 시간 차이 계산 (duration)
const calculateDuration = (start, end) => {
  if (!start || !end) return '';
  const [startHour, startMin] = start.split(':').map(Number);
  const [endHour, endMin] = end.split(':').map(Number);
  const totalMin = (endHour * 60 + endMin) - (startHour * 60 + startMin);
  const hours = Math.floor(totalMin / 60);
  const mins = totalMin % 60;
  return `${hours}시간${mins > 0 ? ` ${mins}분` : ''}`;
};

// 일정 데이터 로드
const loadSchedules = async () => {
  loading.value = true;
  try {
    const userStore = useUserStore();
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📅 일정 조회 요청');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📆 날짜 범위:', dateRange.value);
    console.log('👤 사용자 ID:', userStore.userId);
    console.log('🔑 토큰 존재 여부:', !!userStore.token);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    const response = await getSchedules(dateRange.value);

    console.log('✅ 일정 조회 성공');
    console.log('📦 응답 데이터:', response);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // API 응답 구조에 맞게 데이터 파싱
    const data = response?.data || response || [];
    const rawSchedules = Array.isArray(data) ? data : [];

    console.log('📝 원본 일정 개수:', rawSchedules.length);
    if (rawSchedules.length > 0) {
      console.log('📋 첫 번째 일정 샘플:', rawSchedules[0]);
    }

    // 백엔드 데이터를 프론트엔드 형식으로 변환
    schedules.value = rawSchedules.map(transformSchedule);
    console.log('✨ 변환된 일정 개수:', schedules.value.length);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  } catch (error) {
    console.error('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.error('❌ 일정 불러오기 실패');
    console.error('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.error('에러 메시지:', error.message);
    console.error('HTTP 상태:', error.response?.status);
    console.error('응답 데이터:', error.response?.data);
    console.error('전체 에러:', error);

    // 백엔드 오류 시 임시 빈 배열 설정 (500 에러는 백엔드 문제)
    if (error.response?.status === 500) {
      console.error('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.error('⚠️  백엔드 500 에러 디버깅 가이드');
      console.error('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.error('1️⃣  Network 탭에서 요청 헤더 확인:');
      console.error('   - Authorization: Bearer <token>');
      console.error('   - Care-Worker-Id:', useUserStore().userId);
      console.error('');
      console.error('2️⃣  백엔드 콘솔에서 에러 로그 확인:');
      console.error('   - ScheduleQueryService.getSchedules()');
      console.error('   - CalendarScheduleDto 매핑 과정');
      console.error('');
      console.error('3️⃣  DB 데이터 확인:');
      console.error('   - employee_id =', useUserStore().userId, '의 일정 데이터 존재 여부');
      console.error('   - visit_schedule, personal_schedule 테이블 조회');
      console.error('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }

    // 에러 발생 시에도 빈 배열로 설정 (UI가 깨지지 않도록)
    schedules.value = [];
  } finally {
    loading.value = false;
  }
};

// 개인 일정 유형 목록 로드
const loadPersonalTypes = async () => {
  try {
    const response = await getPersonalTypes();
    console.log('개인 일정 유형:', response);
    personalTypes.value = response?.data || response || [];
  } catch (error) {
    console.error('개인 일정 유형 불러오기 실패:', error);
  }
};

// 내 담당 수급자 목록 로드
const loadMyBeneficiaries = async () => {
  try {
    const response = await getMyBeneficiaries();
    console.log('내 담당 수급자 목록:', response);
    const data = response?.data || response || [];
    const beneficiaries = Array.isArray(data) ? data : [];

    // 백엔드 데이터의 serviceTypes를 배열로 변환
    myBeneficiaries.value = beneficiaries.map(beneficiary => {
      // serviceTypes가 문자열이면 배열로 변환
      if (beneficiary.serviceTypes && typeof beneficiary.serviceTypes === 'string') {
        return {
          ...beneficiary,
          serviceTypes: beneficiary.serviceTypes
            .split(',')
            .map(s => s.trim())
            .filter(s => s.length > 0)
        };
      }
      return beneficiary;
    });

    console.log('변환된 담당 수급자 목록:', myBeneficiaries.value);
  } catch (error) {
    console.error('담당 수급자 목록 불러오기 실패:', error);
    myBeneficiaries.value = [];
  }
};

// 일정 등록/수정 모달 상태
const showAddModal = ref(false);
const isEditMode = ref(false); // 수정 모드 여부
const editingScheduleId = ref(null); // 수정 중인 일정 ID
const isPersonalSchedule = ref(false); // 개인일정 체크박스 상태
const newSchedule = ref({
  // 공통
  date: '',
  startTime: '',
  endTime: '',
  location: '', // 장소/주소
  notes: '', // 특이사항

  // 방문 일정용
  beneficiaryId: null,
  beneficiaryName: '',
  serviceTypes: [], // 배열로 변경 (다중 선택 지원)
  address: '', // 수급자 주소

  // 개인 일정용
  personalTypeId: null,
  title: '', // 일정 제목
});

// 개인일정 체크박스 변경 시 방문 일정 정보 초기화
const onPersonalScheduleChange = () => {
  if (isPersonalSchedule.value) {
    // 개인일정으로 전환 시 방문 일정 정보 초기화
    newSchedule.value.beneficiaryId = null;
    newSchedule.value.beneficiaryName = '';
    newSchedule.value.serviceTypes = [];
    newSchedule.value.address = '';
    newSchedule.value.location = '';
  } else {
    // 방문일정으로 전환 시 개인 일정 정보 초기화
    newSchedule.value.personalTypeId = null;
    newSchedule.value.title = '';
  }
};

// 수급자 선택 시 자동 입력
const onBeneficiarySelect = () => {
  if (!newSchedule.value.beneficiaryId) {
    newSchedule.value.beneficiaryName = '';
    newSchedule.value.address = '';
    newSchedule.value.location = '';
    newSchedule.value.serviceTypes = [];
    return;
  }

  const selected = myBeneficiaries.value.find(
    b => (b.recipientId || b.beneficiaryId || b.id) === newSchedule.value.beneficiaryId
  );

  if (selected) {
    newSchedule.value.beneficiaryName = selected.name || selected.recipientName || '';
    newSchedule.value.address = selected.address || '';
    newSchedule.value.location = selected.address || '';

    // 서비스 유형 자동 입력 (여러 필드명 대응)
    const serviceType = selected.serviceType || selected.serviceTypes || selected.service ||
                       selected.type || selected.serviceContent || selected.careType || '';

    if (serviceType) {
      // 배열이면 그대로, 문자열이면 쉼표로 분리하여 배열로 변환
      if (Array.isArray(serviceType)) {
        newSchedule.value.serviceTypes = [...serviceType];
      } else if (typeof serviceType === 'string') {
        // "방문목욕, 방문요양" 형태의 문자열을 배열로 변환
        newSchedule.value.serviceTypes = serviceType
          .split(',')
          .map(s => s.trim())
          .filter(s => s.length > 0);
      } else {
        newSchedule.value.serviceTypes = [];
      }
    } else {
      // 서비스 유형이 없으면 빈 배열
      newSchedule.value.serviceTypes = [];
    }
  }
};

const resetNewSchedule = () => {
  newSchedule.value = {
    date: '',
    startTime: '',
    endTime: '',
    location: '',
    notes: '',
    beneficiaryId: null,
    beneficiaryName: '',
    serviceTypes: [],
    address: '',
    personalTypeId: null,
    title: '',
  };
  isPersonalSchedule.value = false;
  isEditMode.value = false;
  editingScheduleId.value = null;
};

const openAddModal = (payload) => {
  resetNewSchedule();
  if (payload?.date) newSchedule.value.date = payload.date;
  showAddModal.value = true;
};

const closeAddModal = () => {
  showAddModal.value = false;
  resetNewSchedule();
};

// 일정 수정 모달 열기
const openEditModal = (schedule) => {
  isEditMode.value = true;
  editingScheduleId.value = schedule.scheduleId || schedule.id;
  isPersonalSchedule.value = schedule.scheduleType === 'PERSONAL';

  if (schedule.scheduleType === 'PERSONAL') {
    // 개인 일정 수정
    newSchedule.value = {
      date: schedule.date,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      location: schedule.location || schedule.address || '',
      notes: schedule.notes || '',
      personalTypeId: schedule.personalTypeId,
      title: schedule.title || schedule.recipient,
      // 방문 일정 필드 초기화
      beneficiaryId: null,
      beneficiaryName: '',
      serviceTypes: [],
      address: '',
    };
  } else {
    // 방문 일정 수정
    newSchedule.value = {
      date: schedule.date,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      location: schedule.address || '',
      notes: schedule.notes || '',
      beneficiaryId: schedule.beneficiaryId,
      beneficiaryName: schedule.recipient,
      serviceTypes: [schedule.serviceLabel], // 단일 서비스 유형
      address: schedule.address || '',
      // 개인 일정 필드 초기화
      personalTypeId: null,
      title: '',
    };
  }

  showAddModal.value = true;
};

// 일정 삭제
const deleteSchedule = async (schedule) => {
  try {
    const scheduleId = schedule.scheduleId || schedule.id;

    if (schedule.scheduleType === 'PERSONAL') {
      // 개인 일정 삭제
      await deletePersonalSchedule(scheduleId);
      alert('개인 일정이 삭제되었습니다.');
    } else {
      // 방문 일정 삭제
      await deleteVisitSchedule(scheduleId);
      alert('방문 일정이 삭제되었습니다.');
    }

    // 상세 패널 닫기
    onCloseDetail();

    // 일정 목록 새로고침
    await loadSchedules();

    // 다른 컴포넌트에 알림
    setTimeout(() => {
      scheduleStore.notifyScheduleUpdate();
    }, 100);
  } catch (error) {
    console.error('일정 삭제 실패:', error);
    alert(`일정 삭제 실패: ${error.message || '알 수 없는 오류'}`);
  }
};

// 서비스 타입 이름을 ID로 매핑
const getServiceTypeId = (serviceTypeName) => {
  const mapping = {
    '방문요양': 1,
    '방문목욕': 2,
    '방문간호': 3,
  };
  return mapping[serviceTypeName] || null;
};

const saveSchedule = async () => {
  try {
    if (!newSchedule.value.date || !newSchedule.value.startTime || !newSchedule.value.endTime) {
      alert('날짜, 시작/종료 시간을 입력해주세요.');
      return;
    }

    // 날짜와 시간을 ISO 형식으로 변환
    const startDt = `${newSchedule.value.date}T${newSchedule.value.startTime}:00`;
    const endDt = `${newSchedule.value.date}T${newSchedule.value.endTime}:00`;

    if (!isPersonalSchedule.value) {
      // 방문 일정
      if (!newSchedule.value.beneficiaryId) {
        alert('수급자를 선택해주세요.');
        return;
      }
      if (!newSchedule.value.serviceTypes || newSchedule.value.serviceTypes.length === 0) {
        alert('서비스 유형을 최소 1개 이상 선택해주세요.');
        return;
      }

      if (isEditMode.value) {
        // 방문 일정 수정
        const serviceTypeId = getServiceTypeId(newSchedule.value.serviceTypes[0]);

        if (!serviceTypeId) {
          alert('유효하지 않은 서비스 유형입니다.');
          return;
        }

        const scheduleData = {
          beneficiaryId: newSchedule.value.beneficiaryId,
          serviceTypeId: serviceTypeId,
          startDt: startDt,
          endDt: endDt,
          visitStatus: 'SCHEDULED',
          note: newSchedule.value.notes || null,
        };

        console.log('방문 일정 수정 요청:', scheduleData);
        await updateVisitSchedule(editingScheduleId.value, scheduleData);
        alert('방문 일정이 수정되었습니다.');
      } else {
        // 방문 일정 등록 (각 서비스 타입별로 별도의 일정 생성)
        const createPromises = newSchedule.value.serviceTypes.map(async (serviceTypeName) => {
          const serviceTypeId = getServiceTypeId(serviceTypeName);

          if (!serviceTypeId) {
            console.warn(`알 수 없는 서비스 타입: ${serviceTypeName}`);
            return;
          }

          const scheduleData = {
            beneficiaryId: newSchedule.value.beneficiaryId,
            serviceTypeId: serviceTypeId,
            startDt: startDt,
            endDt: endDt,
            visitStatus: 'SCHEDULED',
            note: newSchedule.value.notes || null,
          };

          console.log('방문 일정 등록 요청:', scheduleData);
          return await createVisitSchedule(scheduleData);
        });

        await Promise.all(createPromises);

        const serviceCount = newSchedule.value.serviceTypes.length;
        alert(`${serviceCount}개의 일정이 등록되었습니다.`);
      }
    } else {
      // 개인 일정
      if (!newSchedule.value.title) {
        alert('일정 제목을 입력해주세요.');
        return;
      }
      if (!newSchedule.value.personalTypeId) {
        alert('일정 유형을 선택해주세요.');
        return;
      }

      const scheduleData = {
        personalTypeId: newSchedule.value.personalTypeId,
        title: newSchedule.value.title,
        startDt: startDt,
        endDt: endDt,
        location: newSchedule.value.location || '',
        notes: newSchedule.value.notes || '',
        scheduleStatus: 'SCHEDULED',
      };

      if (isEditMode.value) {
        // 개인 일정 수정
        console.log('개인 일정 수정 요청:', scheduleData);
        await updatePersonalSchedule(editingScheduleId.value, scheduleData);
        alert('개인 일정이 수정되었습니다.');
      } else {
        // 개인 일정 등록
        console.log('개인 일정 등록 요청:', scheduleData);
        await createPersonalSchedule(scheduleData);
        alert('개인 일정이 등록되었습니다.');
      }
    }

    closeAddModal();

    // 수정 모드였다면 상세 패널도 닫기
    if (isEditMode.value) {
      onCloseDetail();
    }

    await loadSchedules();

    // 다른 컴포넌트(홈 화면, 캘린더 등)에 일정 업데이트 알림
    setTimeout(() => {
      console.log('🔔 일정 업데이트 알림 전송 중...');
      scheduleStore.notifyScheduleUpdate();
    }, 100);
  } catch (error) {
    console.error('일정 저장 실패:', error);
    alert(`일정 저장 실패: ${error.message || '알 수 없는 오류'}`);
  }
};

// 일정 클릭 시 상세 표시
const onSelectSchedule = async (schedule) => {
  console.log('일정 클릭:', schedule);

  // 개인 일정인 경우 상세 조회 API 호출 없이 바로 표시
  if (schedule.scheduleType === 'PERSONAL') {
    console.log('개인 일정 - 상세 조회 생략, 기본 데이터 사용');
    selectedSchedule.value = schedule;
    return;
  }

  // ID 추출 (여러 가능한 필드 확인)
  const scheduleId = schedule.scheduleId || schedule.id || schedule.vsId || schedule.psId;

  if (!scheduleId) {
    console.warn('일정 ID를 찾을 수 없습니다:', schedule);
    // ID가 없어도 기본 정보는 표시
    selectedSchedule.value = schedule;
    return;
  }

  // 백엔드 연결 전 또는 에러 시 mock 데이터를 사용 중인 경우
  // scheduleId가 10 이하거나 'temp-'로 시작하면 mock/임시 데이터로 간주
  if (typeof scheduleId === 'string' && scheduleId.startsWith('temp-')) {
    console.log('임시 ID 감지 - 상세 조회 생략 (백엔드 데이터 없음)');
    selectedSchedule.value = schedule;
    return;
  }

  if (typeof scheduleId === 'number' && scheduleId <= 10) {
    console.log('Mock 데이터 감지 - 상세 조회 생략');
    selectedSchedule.value = schedule;
    return;
  }

  try {
    // 방문 일정만 상세 정보 조회
    console.log('방문 일정 상세 조회 요청 - scheduleId:', scheduleId);
    const response = await getScheduleDetail(scheduleId);
    console.log('일정 상세 응답:', response);

    // 백엔드 응답을 프론트엔드 형식으로 변환
    const detailData = response?.data || response;
    const transformedData = transformSchedule(detailData);

    console.log('변환된 상세 데이터:', transformedData);
    selectedSchedule.value = transformedData;
  } catch (error) {
    console.error('일정 상세 조회 실패:', error);
    // 실패 시 기본 정보만 표시
    selectedSchedule.value = schedule;
  }
};

// 상세 패널 닫기
const onCloseDetail = () => {
  selectedSchedule.value = null;
};

// 화면 전환 (day/week/month)
const onViewChange = (viewType) => {
  currentView.value = viewType;
  loadSchedules(); // 뷰 변경 시 일정 재로드
};

// 날짜 변경
const onDateChange = (newDate) => {
  currentDate.value = newDate;
  loadSchedules();
};

// 라우트 변경 감지 (근무일정 페이지 진입 시 오늘 날짜로 리셋)
watch(() => route.path, (newPath) => {
  if (newPath === '/workschedule') {
    console.log('📅 근무일정 페이지 진입: 오늘 날짜로 리셋');
    currentDate.value = new Date();
    componentKey.value++; // 컴포넌트 강제 리렌더링
  }
}, { immediate: true });

// 다른 곳(예: 매칭 페이지)에서 일정 변경 시 자동 새로고침
watch(() => scheduleStore.scheduleUpdateCounter, (newValue, oldValue) => {
  console.log('📅 근무일정 페이지: 일정 업데이트 감지!', { oldValue, newValue });
  console.log('📅 근무일정 페이지: 캘린더 새로고침 시작...');
  loadSchedules();
}, { immediate: false });

// 컴포넌트 마운트 시 실행
onMounted(() => {
  loadSchedules();
  loadPersonalTypes();
  loadMyBeneficiaries();
});

// 컴포넌트 활성화 시 실행 (keep-alive로 캐시된 경우)
onActivated(() => {
  console.log('📅 근무일정 페이지 활성화: 오늘 날짜로 리셋');
  currentDate.value = new Date(); // 오늘 날짜로 리셋
  componentKey.value++; // 컴포넌트 강제 리렌더링
  loadSchedules();
});
</script>

<template>
  <div class="workschedule-page">
    <div class="page-header">
      <div class="title-area">
        <h1 class="page-title">근무 일정</h1>
        <p class="page-desc">나의 근무 일정을 확인할 수 있어요</p>
      </div>
    </div>

    <div class="schedule-box">
      <ScheduleHeader />

      <div class="content-container">
        <div class="calendar-area" :class="{ 'has-detail': selectedSchedule }">
          <MonthView
            v-if="currentView === 'month'"
            :key="`month-${componentKey}`"
            :schedules="schedules"
            :current-date="currentDate"
            @select-schedule="onSelectSchedule"
            @add-schedule="openAddModal"
            @view-change="onViewChange"
            @date-change="onDateChange"
          />

          <WeekView
            v-else-if="currentView === 'week'"
            :key="`week-${componentKey}`"
            :schedules="schedules"
            :current-date="currentDate"
            @select-schedule="onSelectSchedule"
            @add-schedule="openAddModal"
            @view-change="onViewChange"
            @date-change="onDateChange"
          />

          <CalendarView
            v-else
            :key="`day-${componentKey}`"
            :schedules="schedules"
            :current-date="currentDate"
            @select-schedule="onSelectSchedule"
            @add-schedule="openAddModal"
            @view-change="onViewChange"
            @date-change="onDateChange"
          />
        </div>

        <Transition name="slide">
          <div v-if="selectedSchedule" class="detail-panel">
            <ScheduleDetail
              :schedule="selectedSchedule"
              @close="onCloseDetail"
              @edit="openEditModal"
              @delete="deleteSchedule"
            />
          </div>
        </Transition>
      </div>
    </div>

    <div v-if="showAddModal" class="modal-overlay" @click="closeAddModal">
      <div class="modal-card" @click.stop>
        <div class="modal-header">
          <h3>{{ isEditMode ? '일정 수정' : '일정 등록' }}</h3>
          <button class="close-btn" @click="closeAddModal">×</button>
        </div>
        <div class="modal-body">
          <!-- 개인일정 체크박스 (수정 모드일 때는 비활성화) -->
          <label class="checkbox-field">
            <input v-model="isPersonalSchedule" type="checkbox" @change="onPersonalScheduleChange" :disabled="isEditMode" />
            <span>개인일정</span>
          </label>

          <!-- 날짜 -->
          <label class="form-field">
            <span>날짜 <span class="required">*</span></span>
            <input v-model="newSchedule.date" type="date" />
          </label>

          <!-- 시작/종료 시간 -->
          <div class="form-row-2">
            <label class="form-field">
              <span>시작 시간 <span class="required">*</span></span>
              <input v-model="newSchedule.startTime" type="time" placeholder="--:--" />
            </label>
            <label class="form-field">
              <span>종료 시간 <span class="required">*</span></span>
              <input v-model="newSchedule.endTime" type="time" placeholder="--:--" />
            </label>
          </div>

          <!-- 방문 일정 전용 필드 -->
          <template v-if="!isPersonalSchedule">
            <label class="form-field">
              <span>수급자 <span class="required">*</span></span>
              <select
                v-model.number="newSchedule.beneficiaryId"
                @change="onBeneficiarySelect"
                class="form-select"
              >
                <option :value="null" disabled>수급자를 선택하세요</option>
                <option
                  v-for="beneficiary in myBeneficiaries"
                  :key="beneficiary.recipientId || beneficiary.beneficiaryId || beneficiary.id"
                  :value="beneficiary.recipientId || beneficiary.beneficiaryId || beneficiary.id"
                >
                  {{ beneficiary.name || beneficiary.recipientName || '이름 없음' }}
                </option>
              </select>
            </label>

            <div class="form-field">
              <span>서비스 유형 <span class="required">*</span></span>
              <div class="service-type-checkboxes">
                <label class="service-checkbox">
                  <input type="checkbox" value="방문요양" v-model="newSchedule.serviceTypes" />
                  <span>방문요양</span>
                </label>
                <label class="service-checkbox">
                  <input type="checkbox" value="방문목욕" v-model="newSchedule.serviceTypes" />
                  <span>방문목욕</span>
                </label>
                <label class="service-checkbox">
                  <input type="checkbox" value="방문간호" v-model="newSchedule.serviceTypes" />
                  <span>방문간호</span>
                </label>
              </div>
            </div>
          </template>

          <!-- 개인 일정 전용 필드 -->
          <template v-else>
            <label class="form-field">
              <span>일정 제목 <span class="required">*</span></span>
              <input
                v-model="newSchedule.title"
                type="text"
                placeholder="일정 제목을 입력하세요"
              />
            </label>

            <label class="form-field">
              <span>일정 유형 <span class="required">*</span></span>
              <select v-model.number="newSchedule.personalTypeId" class="form-select">
                <option value="" disabled>선택하세요</option>
                <option
                  v-for="type in personalTypes"
                  :key="type.personalTypeId || type.id"
                  :value="type.personalTypeId || type.id"
                >
                  {{ type.personalTypeName || type.name }}
                </option>
              </select>
            </label>
          </template>

          <!-- 공통 필드 -->
          <label class="form-field">
            <span>장소/주소</span>
            <input
              v-model="newSchedule.location"
              type="text"
              placeholder="장소나 주소를 입력하세요"
            />
          </label>

          <label class="form-field">
            <span>특이사항</span>
            <textarea
              v-model="newSchedule.notes"
              class="form-textarea"
              placeholder="특이사항을 입력하세요"
              rows="3"
            ></textarea>
          </label>
        </div>
        <div class="modal-footer">
          <button class="btn-secondary" @click="closeAddModal">취소</button>
          <button class="btn-primary" @click="saveSchedule">{{ isEditMode ? '수정' : '등록' }}</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 페이지 전체 레이아웃 (수급자 페이지와 동일한 패딩) */
.workschedule-page {
  padding: 0 24px 24px;
  background-color: transparent; /* 배경색 제거 (상위 컴포넌트 배경 따름) */
}

/* 상단 헤더 스타일 (수급자 페이지와 동일) */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28px 0 12px;
}

.title-area {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.page-title {
  font-size: 30px;
  font-weight: 600;
  color: #1a5928; /* 요청하신 초록색 타이틀 */
  margin: 0;
}

.page-desc {
  font-size: 14px;
  color: #4a5565; /* 요청하신 회색 설명 */
  margin: 0;
}

/* 추가 버튼 스타일 (수급자 등록 버튼과 동일) */
.add-button {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 18px;
  border-radius: 10px;
  border: none;
  background-color: #00c950;
  color: #fff;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s;
}

.add-button:hover {
  background-color: #00b347;
}

/* 메인 컨텐츠 박스 (수급자 페이지의 .tabs-box 스타일 적용) */
.schedule-box {
  background: #ffffff;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 4px 12px rgba(15, 23, 42, 0.05);
  padding: 20px 24px; /* 내부 패딩 */
  margin-top: 16px;
  min-height: 800px; /* 최소 높이 확보 */
}

/* 기존 캘린더 내부 레이아웃 유지 */
.content-container {
  position: relative;
  height: 800px; /* 고정 높이 혹은 min-height */
  margin-top: 1rem;
  display: flex;
  gap: 0;
  overflow: hidden; /* 슬라이드 패널 넘침 방지 */
}

.calendar-area {
  width: 100%;
  height: 100%;
  transition: width 0.3s ease-in-out;
}

.calendar-area.has-detail {
  width: calc(100% - 500px);
}

.detail-panel {
  position: absolute;
  right: 0;
  top: 0;
  width: 480px;
  height: 100%;
  background-color: white;
  box-shadow: -4px 0 12px rgba(0, 0, 0, 0.1);
  z-index: 10;
  overflow-y: auto;
  border-left: 1px solid #e2e8f0; /* 패널 구분선 추가 */
}

/* 슬라이드 애니메이션 */
.slide-enter-active,
.slide-leave-active {
  transition: transform 0.3s ease-in-out;
}

.slide-enter-from {
  transform: translateX(100%);
}

.slide-leave-to {
  transform: translateX(100%);
}

.slide-enter-to,
.slide-leave-from {
  transform: translateX(0);
}

/* --- 모달 스타일 (기존 유지) --- */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  z-index: 2000;
}

.modal-card {
  width: min(520px, 100%);
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.12);
  overflow: hidden;
  border: 1px solid #e5e7eb;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.25rem;
  border-bottom: 1px solid #e5e7eb;
  background: #f8fafc;
}

.modal-header h3 {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 700;
  color: #1f2937;
}

.close-btn {
  border: none;
  background: transparent;
  font-size: 1.25rem;
  cursor: pointer;
  color: #6b7280;
}

.modal-body {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1.5rem;
}

.checkbox-field {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  padding: 0.75rem;
  background: #f9fafb;
  border-radius: 0.5rem;
  border: 1px solid #e5e7eb;
}

.checkbox-field input[type="checkbox"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
  accent-color: #22c55e;
}

.checkbox-field span {
  font-size: 0.9375rem;
  font-weight: 600;
  color: #374151;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 0.75rem;
}

.form-row-2 {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.75rem;
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.form-field span {
  font-size: 0.875rem;
  color: #374151;
  font-weight: 600;
}

.form-field input,
.form-field select,
.form-field textarea {
  border: 1px solid #d1d5db;
  border-radius: 0.5rem;
  padding: 0.65rem 0.75rem;
  font-size: 0.9375rem;
  width: 100%;
}

.form-select {
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2322c55e'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 0.75rem center;
  background-size: 1.25rem;
  padding-right: 2.5rem;
}

.form-textarea {
  resize: vertical;
  font-family: inherit;
}

.required {
  color: #ef4444;
  font-weight: 700;
  margin-left: 0.125rem;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  padding: 1rem 1.25rem;
  border-top: 1px solid #e5e7eb;
  background: #f9fafb;
}

.btn-primary,
.btn-secondary {
  padding: 0.65rem 1.25rem;
  border-radius: 0.6rem;
  font-weight: 700;
  font-size: 0.9375rem;
  border: none;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-primary {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  color: white;
}

.btn-primary:hover {
  background: linear-gradient(135deg, #16a34a 0%, #15803d 100%);
}

.btn-secondary {
  background: white;
  color: #374151;
  border: 1px solid #d1d5db;
}

.btn-secondary:hover {
  background: #f3f4f6;
}

/* 서비스 유형 체크박스 */
.service-type-checkboxes {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.service-checkbox {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 0.75rem;
  background: #f9fafb;
  border-radius: 0.5rem;
  border: 1px solid #e5e7eb;
  cursor: pointer;
  transition: all 0.2s;
}

.service-checkbox:hover {
  background: #f3f4f6;
  border-color: #d1d5db;
}

.service-checkbox input[type="checkbox"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
  accent-color: #22c55e;
}

.service-checkbox span {
  font-size: 0.9375rem;
  font-weight: 500;
  color: #374151;
}

/* 반응형 처리 */
@media (max-width: 1024px) {
  .workschedule-page {
    padding: 16px;
  }

  .content-container {
    height: auto;
    min-height: 600px;
  }

  .calendar-area {
    width: 100% !important;
  }

  .detail-panel {
    position: fixed;
    left: 0;
    right: 0;
    top: 0;
    bottom: 0;
    width: 100%;
    height: 100vh;
    z-index: 3000; /* 모달보다 높게 */
  }

  .slide-enter-from {
    transform: translateY(100%);
  }

  .slide-leave-to {
    transform: translateY(100%);
  }

  .modal-card {
    width: 100%;
  }

  .form-row {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>