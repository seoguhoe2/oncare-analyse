import api from '@/lib/api';

// API 함수들 정의
export const dashboardApi = {

  // 사용자 대시보드 설정
  getDashboardSettings: async () => {
    const response = await api.get('/api/dashboard/settings');
    return response.data;
  },

  saveDashboardSettings: async (widgetIds) => {
    await api.post('/api/dashboard/settings', { widgetIds });
  },

  // 보수 교육 알림 리스트
  getEducationAlerts: async () => {
    const response = await api.get('/api/employees/education/alerts');
    return response.data;
  },

  // 부서별 직원 수 통계
  getEmployeeJobCounts: async () => {
    const response = await api.get('/api/employees/count/by-job');
    return response.data;
  },

  // 제품별 수익 통계
  getProductStats: async () => {
    const response = await api.get('/api/statistics/products');
    return response.data;
  },

  // 장기요양등급 만료 임박 수급자 통계
  getCareLevelExpirationStats: async () => {
    const response = await api.get('/api/statistics/care-level-expiration');
    return response.data;
  },

  // 월별 잠재고객 및 계약 성사 고객 통계
  getMonthlyClientStats: async () => {
    const response = await api.get('/api/statistics/monthly-clients');
    return response.data;
  },

  // 미배정 수급자 수
  getUnassignedBeneficiariesCount: async () => {
    const response = await api.get('/api/statistics/unassigned-beneficiaries-count');
    return response.data;
  },

  // 결재 대기 건수
  getPendingApprovalsCount: async () => {
    const response = await api.get('/api/statistics/pending-approvals-count');
    return response.data;
  },

  // 월별 신규/탈퇴 수급자 통계
  getMonthlyBeneficiaryStats: async () => {
    const response = await api.get('/api/statistics/monthly-beneficiaries');
    return response.data;
  },

  // 미배정 수급자 리스트 (상세)
  getUnassignedBeneficiariesList: async () => {
    const response = await api.get('/api/statistics/unassigned-beneficiaries');
    return response.data;
  },

  // 이탈 징후 수급자 리스트
  getChurnRiskBeneficiaries: async () => {
    const response = await api.get('/api/statistics/churn-risk-beneficiaries');
    return response.data;
  },

  // 위험 등급별 수급자 현황
  getRiskLevelBeneficiariesCount: async () => {
    const response = await api.get('/api/statistics/risk-level-beneficiaries-count');
    return response.data;
  },

  // 장기요양 등급별 수급자 현황
  getCareGradeBeneficiariesCount: async () => {
    const response = await api.get('/api/statistics/care-grade-beneficiaries-count');
    return response.data;
  },

  // 연체 고객 정보 리스트
  getOverdueBeneficiaries: async () => {
    const response = await api.get('/api/statistics/overdue-beneficiaries');
    return response.data;
  }
};