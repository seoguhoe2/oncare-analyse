import api from '@/lib/api';

// 결재 현황 요약 조회 (상단 카드 4개 카운트)
export const getPaymentDashboard = async (employeeId) => {
    const params = employeeId ? { employeeId } : {};
    const response = await api.get('/api/payments/dashboard', { params });
    return response.data;
};

// 결재 목록 조회 (검색 및 필터링)
export const getPaymentList = async (params) => {
    const response = await api.get('/api/payments', { params });
    return response.data;
};

// 결재 상세 조회 (모달 팝업용 상세 데이터)
export const getPaymentDetail = async (id) => {
    const response = await api.get(`/api/payments/${id}`);
    return response.data;
};

// 카테고리 목록 조회
export const getPaymentCategories = async () => {
    const response = await api.get('/api/payments/categories');
    return response.data;
};

// 결재 기안 작성 (생성)
export const createPayment = async (payload) => {
    const response = await api.post('/api/payments', payload);
    return response.data;
};

// 결재 승인/반려 (Action)
// 백엔드 명세: POST /api/payments/{id}/action 
// payload: { action: "APPROVE" | "REJECT", comment: "..." }
export const processPaymentAction = async (id, action, comment) => {
    const payload = { action, comment };
    const response = await api.post(`/api/payments/${id}/action`, payload);
    return response.data;
};

// (기존 승인/반려 함수 - processPaymentAction 래퍼)
export const approvePayment = async (id) => {
    return processPaymentAction(id, 'APPROVE', '승인합니다.');
};

export const rejectPayment = async (id) => {
    return processPaymentAction(id, 'REJECT', '반려합니다.');
};

// --- 승인자 검색 및 조직도 관련 API ---

// 직원 검색: 이름/직위/직책 기반 (search?keyword=...)
export const searchUsers = async (keyword) => {
    const response = await api.get('/api/payments/users/search', { params: { keyword } });
    return response.data;
};

// 최근 결재선 조회 (recent-approvers)
export const getRecentApprovers = async () => {
    const response = await api.get('/api/payments/users/recent-approvers');
    return response.data;
};

// 우리 부서원 조회 (my-department)
export const getMyDepartmentMembers = async () => {
    const response = await api.get('/api/payments/users/my-department');
    return response.data;
};

// 조직도 트리 조회 (department-tree)
export const getDepartmentTree = async () => {
    const response = await api.get('/api/payments/users/department-tree');
    return response.data;
};
