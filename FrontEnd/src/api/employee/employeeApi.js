import api from '@/lib/api';

// 직원 목록 조회
export const getEmployeeList = async (params) => {
  const response = await api.get('/api/employees', { params });
  return response.data;
};

// 직원 상세 조회
export const getEmployeeDetail = async (id) => {
  const response = await api.get(`/api/employees/${id}`);
  return response.data;
};

// 직원 등록 (기본 정보 + 초기 자격증 리스트)
export const registerEmployee = async (employeeData) => {
  const response = await api.post('/api/employees', employeeData);
  return response.data;
};

// 직원 수정
export const updateEmployee = async (id, data) => {
  const response = await api.put(`/api/employees/${id}`, data);
  return response.data;
};

// 자격증 개별 등록 (즉시 저장용)
export const registerCertificate = async (employeeId, data) => {
  if (!employeeId) throw new Error("직원 ID가 없습니다.");

  const response = await api.post(`/api/care-workers/employees/${employeeId}/certificates`, data);
  return response.data;
};

// 보수교육 개별 등록
export const registerEducation = async (certId, data) => {
  const response = await api.post(`/api/care-workers/certificates/${certId}/educations`, data);
  return response.data;
};

// 특정 직원의 자격증 목록 조회하기
export const getCertificates = async (employeeId) => {
  const response = await api.get(`/api/care-workers/employees/${employeeId}/certificates`);

  const rawList = response.data;

  // 반려(REJECTED or 1)된 자격증은 목록에서 제외
  const filteredList = rawList.filter(c => {
    const s = c.status;
    return s !== 'REJECTED' && s !== 1 && s !== '반려';
  });

  // ID가 없으면 임시로 채워주는 로직
  return filteredList.map((cert, index) => ({
    ...cert,
    id: cert.id || (index + 1),
    name: cert.certificateName || cert.name
  }));
};

// 특정 자격증의 보수교육 목록 조회
export const getEducations = async (certId) => {
  const response = await api.get(`/api/care-workers/certificates/${certId}/educations`);
  return response.data;
};

// 승인 대기중인 자격증 목록 조회
export const getPendingCertifications = async () => {
  try {
    // [User Request] 백엔드 API 엔드포인트: /api/care-workers/certificates?status=PENDING
    const response = await api.get('/api/care-workers/certificates', {
      params: { status: 'PENDING' }
    });
    return response.data;
  } catch (error) {
    console.warn('[API Error] Failed to fetch pending certifications. Returning empty array.', error);
    return [];
  }
};

export const updateCertificateStatus = async (certId, status, reason = null) => {
  const payload = { status };
  if (reason) payload.reason = reason;

  const response = await api.patch(`/api/care-workers/certificates/${certId}/status`, payload);
  return response.data;
};

// 방문 요양 일정 조회
export const getEmployeeVisitSchedules = async (employeeId) => {
  const response = await api.get(`/api/schedules/employees/${employeeId}/visits`);
  return response.data;
};

// 물품 렌탈/회수 일정 조회
export const getEmployeeProductSchedules = async (employeeId) => {
  const response = await api.get(`/api/schedules/employees/${employeeId}/products`);
  return response.data;
};


// 특정 요양보호사의 담당 수급자 조회
export const getAssignedBeneficiaries = async (courseWorkerId) => {
  const response = await api.get(`/api/assignedBeneficiary/care-workers/${courseWorkerId}/beneficiaries`);
  return response.data;
};

// 현재 재직 중인 직원 수 조회
export const getActiveEmployeeCount = async () => {
  const response = await api.get('/api/employees/count/active');
  return response.data;
};

// 현재 휴직 중인 직원 수 조회
export const getOnLeaveEmployeeCount = async () => {
  const response = await api.get('/api/employees/count/on-leave');
  return response.data;
};

// --- 보수교육 일괄 등록용 API ---

// 1. 자격증 종류 조회
export const getCertificateTypes = async () => {
  const response = await api.get('/api/care-workers/certificates/types');
  return response.data;
};

// 2. 해당 자격증 보유자 조회
export const getCertificateHolders = async (certId) => {
  const response = await api.get(`/api/care-workers/certificates/holders/${certId}`);
  return response.data;
};

// 3. 교육 이력 일괄 등록
export const registerBulkEducation = async (payload) => {
  const response = await api.post('/api/care-workers/educations/bulk', payload);
  return response.data;
};

// 4. 보수교육 알림 조회
export const getEducationAlerts = async () => {
  const response = await api.get('/api/employees/education/alerts');
  return response.data;
};
