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

  // ID가 없으면 임시로 채워주는 로직
  return response.data.map((cert, index) => ({
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

// 특정 요양보호사의 일정 조회
export const getEmployeeSchedules = async (employeeId) => {
  const response = await api.get(`/api/schedules/employees/beneficiary/${employeeId}`);
  return response.data;
};

// 특정 요양보호사의 담당 수급자 조회
export const getAssignedBeneficiaries = async (courseWorkerId) => {
  const response = await api.get(`/api/assignedBeneficiary/care-workers/${courseWorkerId}/beneficiaries`);
  return response.data;
};
