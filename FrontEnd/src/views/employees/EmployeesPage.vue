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
  getEmployeeSchedules
} from '@/api/employee/employeeApi';

// 컴포넌트 import
import EmployeeList from '@/components/employee/EmployeeList.vue';
import EmployeeDetail from '@/components/employee/EmployeeDetail.vue';
import EmployeeEditModal from '@/components/employee/EmployeeEditModal.vue';
import CertificationApprovalModal from '@/components/employee/CertificationApprovalModal.vue';
import BulkEducationModal from '@/components/employee/BulkEducationModal.vue';
import EmployeeRegisterModal from '@/components/employee/EmployeeRegisterModal.vue';

// --- State ---
const employees = ref([]); // 서버에서 받아올 직원 목록
const selectedEmployee = ref(null);
const searchTerm = ref(''); // 검색어
const filterRole = ref(''); // 직군 필터

// 모달 상태
const isRegisterModalOpen = ref(false);
const isEditModalOpen = ref(false);
const showCertApprovalModal = ref(false);
const showBulkEduModal = ref(false);

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
      
      // ▼▼▼ [수정] Postman 응답에는 careers/certificates가 안 보임. 없으면 빈 배열.
      workHistory: emp.careers || [],       
      certificates: emp.certificates || [], 
      
      specialties: emp.specialties || [],
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

// 초기 로딩
onMounted(() => {
  fetchEmployees();
  fetchPendingCerts(); // 추가
});

// 매핑
const handleSelect = async (emp) => {
  try {
    const detailData = await getEmployeeDetail(emp.id);

    selectedEmployee.value = {
      ...detailData,
      name: detailData.empName || detailData.name,
      role: detailData.jobName || detailData.role,
      phone: detailData.tel || detailData.phone,
      
      // 1. 자격증 및 경력
      workHistory: detailData.careers || [],
      certificates: detailData.certificates || [],
      
      // ▼▼▼ [수정] 보수교육 데이터 매핑 ▼▼▼
      educations: detailData.educations || [], 

      // ▼▼▼ [수정] 서비스 타입(객체 배열)을 전문 분야(문자열 배열)로 변환 ▼▼▼
      // 예: [{id:1, name:'방문요양'}] -> ['방문요양']
      specialties: detailData.serviceTypes 
        ? detailData.serviceTypes.map(service => service.name) 
        : (detailData.specialties || []),
        
      schedules: []
    };

    // [수정] 일정 데이터 별도 조회 및 병합 (API 분리됨)
    try {
      const scheduleData = await getEmployeeSchedules(emp.id);
      selectedEmployee.value.schedules = scheduleData;
    } catch (scheduleError) {
      console.error('일정 로딩 실패:', scheduleError);
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

  } catch (error) {
    console.error('직원 등록 실패:', error);
    alert('등록 중 오류가 발생했습니다.');
  }
};

// --- 4. 직원 수정 (Update) ---
const handleUpdateEmployee = async (updatedData) => {
  try {
    await updateEmployee(updatedData.id, updatedData);
    alert('정보가 수정되었습니다.');
    isEditModalOpen.value = false;
    
    await fetchEmployees(); // 목록 새로고침
    
    // 선택된 상세 정보도 업데이트 (API 다시 호출해서 최신화)
    await handleSelect({ id: updatedData.id });
  } catch (error) {
    console.error('수정 실패:', error);
    alert('수정 중 오류가 발생했습니다.');
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
  const reason = prompt('반려 사유를 입력하세요:');
  if (reason === null) return;
  
  try {
    await updateCertificateStatus(id, 'REJECTED', reason);
    alert('반려되었습니다.');
    await fetchPendingCerts();
    await fetchEmployees();
  } catch (e) {
    console.error(e);
    alert('오류가 발생했습니다.');
  }
};

const handleBulkEduSubmit = async ({ ids, data }) => {
  const { targetCertName, ...eduPayload } = data;
  
  if (!targetCertName) {
    alert('대상 자격증 이름을 입력해주세요.');
    return;
  }

  let successCount = 0;
  let failCount = 0;

  for (const empId of ids) {
    try {
      // 직원 찾기
      const employee = employees.value.find(e => e.id === empId);
      if (!employee) continue;

      // 자격증 찾기 (이름 부분 일치)
      const targetCert = employee.certificates.find(c => 
        (c.certificateName || c.name || '').includes(targetCertName)
      );

      if (targetCert && (targetCert.id || targetCert.certificateId)) {
        // 이미 eduName 등이 eduPayload에 포함되어 있으므로 그대로 전달
        await registerEducation(targetCert.id || targetCert.certificateId, eduPayload);
        successCount++;
      } else {
        console.warn(`[Bulk] ${employee.name}님에게 '${targetCertName}' 자격증이 없습니다.`);
        failCount++;
      }
    } catch (err) {
      console.error(err);
      failCount++;
    }
  }

  alert(`총 ${ids.length}명 중 ${successCount}명 성공, ${failCount}명 실패 (자격증 미보유 등).`);
  showBulkEduModal.value = false;
  
  // 현재 보고 있는 직원 정보 갱신
  if (selectedEmployee.value && ids.includes(selectedEmployee.value.id)) {
    refreshSelectedEmployee();
  }
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
          <p class="stat-value text-green">{{ employees.filter(e => e.status === '활동중').length }}명</p>
        </div>
        <div class="stat-icon bg-green">
          <svg class="icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><path d="m22 4-12 12-4-4"/></svg>
        </div>
      </div>
    </div>



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
      :employees="employees"
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
.stat-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; }
.bg-gray { background-color: #f1f5f9; color: #64748b; }
.bg-green { background-color: #dcfce7; color: #166534; }
.flex { display: flex; }
.items-center { align-items: center; }
.gap-2 { gap: 8px; }
.relative { position: relative; }
.badge-notification { position: absolute; top: -6px; right: -6px; width: 20px; height: 20px; border-radius: 50%; font-size: 11px; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border: 2px solid white; }
.bg-red { background-color: #ef4444; }
.bg-orange { background-color: #f97316; }
</style>
