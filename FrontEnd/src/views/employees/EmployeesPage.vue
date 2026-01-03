<script setup>
import { ref, onMounted, watch } from 'vue';
// API 함수 import
import { 
  getEmployeeList,
  getEmployeeDetail,
  registerEmployee,
  updateEmployee,
  registerEducation,
  updateCertificateStatus,
  getPendingCertifications,
  getActiveEmployeeCount, // [추가]
  getOnLeaveEmployeeCount // [추가]
} from '@/api/employee/employeeApi';

// 컴포넌트 import
import EmployeeList from '@/components/employee/EmployeeList.vue';
import EmployeeDetail from '@/components/employee/EmployeeDetail.vue';
import EmployeeEditModal from '@/components/employee/EmployeeEditModal.vue';
import CertificationApprovalModal from '@/components/employee/CertificationApprovalModal.vue';
import BulkEducationModal from '@/components/employee/BulkEducationModal.vue';
import EmployeeRegisterModal from '@/components/employee/EmployeeRegisterModal.vue';
import EducationAlertBanner from '@/components/employee/EducationAlertBanner.vue'; // [추가]

// --- State ---
const employees = ref([]); // 서버에서 받아올 직원 목록
const selectedEmployee = ref(null);
const searchTerm = ref(''); // 검색어
const filterRole = ref(''); // 직군 필터
const activeCount = ref(0); // [추가] 활동중인 직원 수
const onLeaveCount = ref(0); // [추가] 휴직 중인 직원 수

// 모달 상태
const isRegisterModalOpen = ref(false);
const isEditModalOpen = ref(false);
const showCertApprovalModal = ref(false);
const showBulkEduModal = ref(false);

// [이동] 서비스 옵션 및 매핑 함수 (Top-Level)
const serviceOptions = [
  { id: 1, name: '방문요양' },
  { id: 2, name: '방문목욕' },
  { id: 3, name: '방문간호' }
];

const mapServiceIdsToNames = (ids) => {
  if (!Array.isArray(ids)) return [];
  return ids.map(id => {
    // 문자열 ID가 올 수도 있으므로 비교 시 주의
    const found = serviceOptions.find(opt => opt.id == id);
    return found ? found.name : null;
  }).filter(name => name);
};


// 자격증 승인 대기 목록
const pendingCertifications = ref([]);

const fetchPendingCertifications = async () => {
  try {
    const data = await getPendingCertifications();
    
    let list = [];
    if (Array.isArray(data)) {
      list = data;
    } else if (data && Array.isArray(data.content)) {
      list = data.content;
    } else if (data && Array.isArray(data.data)) {
      list = data.data;
    }

    pendingCertifications.value = list.map(item => ({
      id: item.id || item.certificateId,
      name: item.certificateName || item.name,
      number: item.licenseNo || item.number,
      status: '대기중', 
      employeeName: item.employeeName || '이름없음',
      requestDate: item.issueDate || item.createdDate || '-', 
      issueDate: item.issueDate,
      issuer: item.organization,
      fileName: item.fileName || '첨부파일'
    }));
  } catch (error) {
    console.error('승인 대기 목록 로딩 실패:', error);
    // 에러 발생 시에도 그냥 빈 배열 유지 (화면이 터지지 않게)
  }
};

// --- 1. 데이터 조회 (Read) ---
const fetchEmployees = async () => {
  try {
    const params = {
      keyword: searchTerm.value,
      jobCode: filterRole.value
    };

    const data = await getEmployeeList(params);

    let list = [];
    if (Array.isArray(data)) {
      list = data;
    } else if (data && Array.isArray(data.content)) {
      list = data.content; // Spring Page
    } else if (data && Array.isArray(data.data)) {
      list = data.data; // Common wrapper
    }

    // [매핑 수정] 백엔드 DTO -> 프론트엔드 형식 변환
    employees.value = list.map(emp => ({
      id: emp.empId || emp.id,
      name: emp.empName || emp.name,
      role: emp.jobName || emp.role || '직책미정',
      phone: emp.tel || emp.phone,
      email: emp.email || '-',
      status: emp.statusField || emp.status || '활동중', // [Fix] statusField from Postman
      hireDate: emp.hireDate || '-',
      address: emp.address || '-',
      emergencyContact: emp.emergencyContact || '-',
      career: emp.career || '1년 미만',
      birth: emp.birth || '', // ★ 생년월일 초기 매핑 추가
      
      workHistory: emp.careers || [],       
      certificates: emp.certificates || (emp.certificateNames ? emp.certificateNames.split(',').map(s => s.trim()) : []), 
      
      specialties: emp.specialties || (emp.serviceTypeNames ? emp.serviceTypeNames.split(',').map(s => s.trim()) : []),
      schedules: [] 
    }));
    
  } catch (error) {
    console.error('직원 목록 로딩 실패:', error);
  }
};

// 검색어/필터 변경 시 자동 조회
watch([searchTerm, filterRole], () => {
  fetchEmployees();
});

// 대기 중인 자격증 목록 조회
const fetchPendingCerts = async () => {
  try {
    const data = await getPendingCertifications(); // Changed to getPendingCertifications()

    
    let list = [];
    if (Array.isArray(data)) {
      list = data;
    } else if (data && Array.isArray(data.content)) {
      list = data.content;
    } else if (data && Array.isArray(data.data)) {
      list = data.data;
    }
    
    // 백엔드 데이터 매핑 (Modal에서 기대하는 필드로 변환)
    pendingCertifications.value = list.map(cert => ({
      ...cert,
      id: cert.id || cert.certificateId, 
      // Modal은 name, number, employeeName 등을 기대함.
      name: cert.certificateName || cert.name,
      number: cert.licenseNo || cert.number,
      status: '대기중', // API 호출 시 PENDING만 가져오므로
      employeeName: cert.employeeName || '이름 미제공', 
      requestDate: cert.createdDate || '-', 
      issueDate: cert.issueDate,
      issuer: cert.organization,
      fileName: '-' 
    }));
  } catch (error) {
    console.error('승인 대기 목록 로딩 실패:', error);
  }
};

// [추가] 활동중인 직원 수 조회
const fetchActiveCount = async () => {
  try {
    const count = await getActiveEmployeeCount();
    activeCount.value = count;
  } catch (error) {
    console.error('활동중 직원 수 로딩 실패:', error);
  }
};

// [추가] 휴직 중인 직원 수 조회
const fetchOnLeaveCount = async () => {
  try {
    const count = await getOnLeaveEmployeeCount();
    onLeaveCount.value = count;
  } catch (error) {
    console.error('휴직중 직원 수 로딩 실패:', error);
  }
};

// 초기 로딩
onMounted(() => {
  fetchEmployees();
  fetchPendingCerts();
  fetchActiveCount(); // [추가]
  fetchOnLeaveCount(); // [추가]
});

// 매핑
const handleSelect = async (emp) => {
  try {
    let detailData = await getEmployeeDetail(emp.id);

    // [Safety] API 응답이 { data: { ... } } 형태로 감싸져 있을 경우 처리
    if (detailData && detailData.data && !detailData.empId && !detailData.id) {
       detailData = detailData.data;
    }

    selectedEmployee.value = {
      ...detailData,
      id: detailData.empId || detailData.id || emp.id,
      name: detailData.empName || detailData.name || emp.name,
      role: detailData.jobName || detailData.role || emp.role,
      phone: detailData.tel || detailData.phone || emp.phone,
      
      // 1. 자격증 및 경력
      workHistory: detailData.careers || [],
      certificates: detailData.certificates || [],
      
      // 보수교육 데이터 매핑
      educations: detailData.educations || [], 

      // 성별 (없으면 기본값 or 기존 emp 데이터)
      gender: detailData.gender || emp.gender,
      
      // ★ 추가 1: 생년월일, 주소 등 주요 정보 명시적 매핑
      birth: detailData.birth || emp.birth,
      address: detailData.address || emp.address,
      hireDate: detailData.hireDate || emp.hireDate,

      // 서비스 타입 매핑
      specialties: detailData.serviceTypes 
        ? detailData.serviceTypes.map(service => service.name) 
        : (detailData.serviceTypeIds 
            ? mapServiceIdsToNames(detailData.serviceTypeIds)
            : (detailData.specialties || [])),
        
      schedules: []
    };

    // [수정] 일정 데이터 별도 조회 및 병합 (API 분리됨)
    try {
      const { getEmployeeVisitSchedules, getEmployeeProductSchedules } = await import('@/api/employee/employeeApi');
      
      const [visitData, productData] = await Promise.all([
        getEmployeeVisitSchedules(emp.id).catch(() => []),
        getEmployeeProductSchedules(emp.id).catch(() => [])
      ]);
      
      const mergedSchedules = [
        // 방문 요양 일정 (Care)
        ...(Array.isArray(visitData) 
            ? visitData.map(item => ({ ...item, type: 'care' })) 
            : []),
        
        // 물품 렌탈 일정 (Rental) -> '복지용구' 등으로 serviceTypeName 식별
        ...(Array.isArray(productData) 
            ? productData.map(item => ({ ...item, type: 'rental', serviceTypeName: '복지용구' })) 
            : [])
      ];
      selectedEmployee.value.schedules = mergedSchedules;
    } catch (scheduleError) {
      console.error('일정 로딩 실패:', scheduleError);
      selectedEmployee.value.schedules = [];
    }
  } catch (error) {
    console.error('상세 정보 로딩 실패:', error);
    selectedEmployee.value = emp; 
  }
};

const refreshSelectedEmployee = async () => {
  if (!selectedEmployee.value?.id) return;
  await handleSelect({ id: selectedEmployee.value.id });
};

const handleEditClick = () => { 
  if (selectedEmployee.value) isEditModalOpen.value = true; 
};

// [추가] 알림 배너 클릭 시 해당 직원 선택 및 상세 조회
const handleAlertClick = async (employeeId) => {
  // 1. 목록에 있으면 찾아서 선택
  const target = employees.value.find(e => e.id === employeeId);
  if (target) {
    await handleSelect(target);
  } else {
    // 2. 목록에 없으면(필터링/페이지네이션 등) ID로 직접 조회 시도
    await handleSelect({ id: employeeId });
  }
};


// 직원 등록
const handleRegisterEmployee = async (payload) => {
  try {
    // 1. 데이터 정제 (Frontend 전용 필드 제거 등)
    const submitData = {
      ...payload,
      
      // careers 배열에서 계산용으로 썼던 start, end 날짜는 제거하고 보냄
      careers: payload.careers.map(c => ({
        companyName: c.companyName,
        workPeriod: c.workPeriod, // "2020.01 - 2022.12"
        task: c.task
      })),
      
      // 'career' (총 경력 텍스트)는 백엔드에서 저장 안 한다면 제외
      // career: payload.career 
    };

    // 2. API 호출
    await registerEmployee(submitData);

    // 3. 성공 처리
    alert('직원이 성공적으로 등록되었습니다.');
    isRegisterModalOpen.value = false; // 모달 닫기
    await fetchEmployees(); // 목록 새로고침
    await fetchActiveCount(); // 카운트 갱신
    await fetchOnLeaveCount();

  } catch (error) {
    console.error('직원 등록 실패:', error);
    const errorMessage = error.response?.data?.message || '등록 중 오류가 발생했습니다.';
    alert(`직원 등록 실패: ${errorMessage}`);
  }
};

// --- 4. 직원 수정 (Update) ---
const handleUpdateEmployee = async (updatedData) => {
  try {
    await updateEmployee(updatedData.id, updatedData);
    alert('정보가 수정되었습니다.');
    isEditModalOpen.value = false;
    
    
    await fetchEmployees(); // 목록 새로고침
    await fetchActiveCount(); // 카운트 갱신
    await fetchOnLeaveCount();
    
    // 목록에서 방금 수정한 직원 정보(최신)를 찾아서 상세 조회에 넘김
    const freshEmployee = employees.value.find(e => e.id === updatedData.id);
    if (freshEmployee) {
      // 1. 목록에 있으면 그 최신 객체를 기반으로 상세 조회
      await handleSelect(freshEmployee);
    } else {
      // 2. 필터 등으로 목록에 안 보이면 ID로만 조회
      await handleSelect({ id: updatedData.id });
    }
    
  } catch (error) {
    console.error('수정 실패:', error);
    const errorMessage = error.response?.data?.message || '수정 중 오류가 발생했습니다.';
    alert(`직원 수정 실패: ${errorMessage}`);
  }
};

// --- 5. 기타 핸들러 ---
// --- 5. 기타 핸들러 (승인/반려 - 실제 API 연동) ---
const handleCertApprove = async (id) => {
  if (!confirm('승인하시겠습니까?')) return;
  try {
    await updateCertificateStatus(id, 'APPROVED');
    alert('승인되었습니다.');
    await fetchPendingCerts(); // 목록 갱신
    await fetchEmployees(); // 전체 직원 목록도 혹시 모르니 갱신
  } catch (e) {
    console.error(e);
    alert('오류가 발생했습니다.');
  }
};

const handleCertReject = async (id) => {
  if (!confirm('반려하시겠습니까?')) return;

  try {
    await updateCertificateStatus(id, 'REJECTED');
    alert('반려되었습니다.');
    await fetchPendingCerts();
    await fetchEmployees();
  } catch (e) {
    console.error(e);
    alert('오류가 발생했습니다.');
  }
};

const handleBulkEduSubmit = async () => {
  showBulkEduModal.value = false;
  
  // 변경 사항 반영을 위해 현재 보고 있는 직원 정보 갱신
  if (selectedEmployee.value) {
    refreshSelectedEmployee();
  }
  // 필요하다면 전체 목록도 갱신 (예: 통계 등)
  // await fetchEmployees(); 
};
</script>

<template>
  <div class="app-container">
    <header class="header">
      <div class="title-area">
        <h1 class="page-title">직원 관리</h1>
        <p class="subtitle">요양보호사 및 센터 직원 통합 관리 시스템</p>
      </div>
      
      <div class="flex items-center gap-2">
        <button class="btn btn-purple relative" @click="showCertApprovalModal = true">
          <svg class="icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="8" r="7"/><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"/></svg>
          자격증 승인
          <span v-if="pendingCertifications.filter(c => c.status === '대기중').length > 0" class="badge-notification bg-red">
            {{ pendingCertifications.filter(c => c.status === '대기중').length }}
          </span>
        </button>

        <button class="btn btn-blue" @click="showBulkEduModal = true">
          <svg class="icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
          보수교육 일괄등록
        </button>

        <button class="btn btn-primary" @click="isRegisterModalOpen = true">
          <svg class="icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 12h14"/><path d="M12 5v14"/></svg>
          직원 등록
        </button>
      </div>
    </header>

    <div class="stats-grid">
      <div class="stat-card">
        <div>
          <span class="stat-label">전체 직원</span>
          <p class="stat-value">{{ employees.length }}명</p>
        </div>
        <div class="stat-icon bg-gray">
          <svg class="icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
        </div>
      </div>
      <div class="stat-card">
        <div>
          <span class="stat-label text-green">활동중</span>
          <p class="stat-value text-green">{{ activeCount }}명</p>
        </div>
        <div class="stat-icon bg-green">
          <svg class="icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><path d="m22 4-12 12-4-4"/></svg>
        </div>
      </div>
      <div class="stat-card">
        <div>
          <span class="stat-label text-orange">휴직</span>
          <p class="stat-value text-orange">{{ onLeaveCount }}명</p>
        </div>
        <div class="stat-icon bg-orange">
          <svg class="icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        </div>
      </div>
    </div>


    <!-- 보수교육 알림 배너 추가 -->
    <EducationAlertBanner @select-employee="handleAlertClick" />

    <div class="main-grid">
      <EmployeeList 
        :employees="employees" 
        :selectedId="selectedEmployee?.id" 
        @select="handleSelect" 
      />

      <EmployeeDetail 
        :employee="selectedEmployee" 
        @edit="handleEditClick"
        @refresh="refreshSelectedEmployee"
      />
    </div>

    <EmployeeRegisterModal
      :isOpen="isRegisterModalOpen"
      @close="isRegisterModalOpen = false"
      @submit="handleRegisterEmployee"
    />

    <EmployeeEditModal
      v-if="selectedEmployee"
      :isOpen="isEditModalOpen"
      :employee="selectedEmployee"
      @close="isEditModalOpen = false"
      @submit="handleUpdateEmployee"
    />
    
    <CertificationApprovalModal 
      :isOpen="showCertApprovalModal"
      :certifications="pendingCertifications"
      @close="showCertApprovalModal = false"
      @approve="handleCertApprove"
      @reject="handleCertReject"
    />

    <BulkEducationModal 
      :isOpen="showBulkEduModal"
      @close="showBulkEduModal = false"
      @submit="handleBulkEduSubmit"
    />
  </div>
</template>

<style scoped>
.app-container { padding: 0 24px 24px; background-color: #fcfcfc; min-height: 100vh; color: #333; }
.header { display: flex; justify-content: space-between; align-items: center; padding: 28px 0 12px; }
.title-area { display: flex; flex-direction: column; gap: 4px; }
.page-title { font-size: 30px; font-weight: 600; color: #1a5928; margin: 0; }
.subtitle { font-size: 14px; color: #4a5565; margin: 0; }

/* 메인 그리드 높이 설정 (스크롤 적용을 위해 중요) */
.main-grid { 
  display: grid; 
  grid-template-columns: 340px minmax(0, 1fr); 
  gap: 24px; 
  height: calc(100vh - 220px); 
  width: 100%; 
}

@media (max-width: 768px) { .main-grid { grid-template-columns: 1fr; height: auto; } }

.btn { display: flex; align-items: center; gap: 6px; padding: 10px 18px; border-radius: 10px; border: none; font-size: 15px; cursor: pointer; transition: opacity 0.2s; color: white; font-weight: 500; }
.btn:hover { opacity: 0.9; }
.btn-primary { background-color: #00c950; }
.btn-purple { background-color: #a855f7; }
.btn-blue { background-color: #3b82f6; }
.icon { width: 20px; height: 20px; }
.stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px; }
.stat-card { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; background: white; border-radius: 16px; border: 1px solid #e2e8f0; box-shadow: 0 4px 12px rgba(15, 23, 42, 0.05); }
.stat-label { font-size: 14px; color: #64748b; font-weight: 500; }
.stat-value { font-size: 24px; font-weight: 700; margin-top: 4px; color: #1e293b; }
.text-green { color: #00a63e; }
.text-orange { color: #d97706; } /* [추가] */
.stat-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; }
.bg-gray { background-color: #f1f5f9; color: #64748b; }
.bg-green { background-color: #dcfce7; color: #166534; }
.bg-orange { background-color: #ffedd5; color: #9a3412; } /* [추가] */
.flex { display: flex; }
.items-center { align-items: center; }
.gap-2 { gap: 8px; }
.relative { position: relative; }
.badge-notification { position: absolute; top: -6px; right: -6px; width: 20px; height: 20px; border-radius: 50%; font-size: 11px; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border: 2px solid white; }
.bg-red { background-color: #ef4444; }
.bg-orange { background-color: #f97316; }
</style>
