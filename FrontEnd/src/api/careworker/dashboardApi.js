import api from '@/lib/api';

/**
 * 요양보호사 대시보드 API
 */

// 1. 대시보드 요약 정보 조회
export const getDashboardSummary = async () => {
  const res = await api.get('/api/dashboard/summary');
  return res.data;
};

// 2. 긴급 알림 목록 조회
export const getUrgentNotifications = async () => {
  const res = await api.get('/api/dashboard/notifications/urgent');
  return res.data;
};

// 3. 오늘의 일정 목록 조회
export const getTodaySchedules = async () => {
  const res = await api.get('/api/dashboard/schedules/today');
  return res.data;
};

// 4. 할 일 목록 조회
export const getTodos = async () => {
  const res = await api.get('/api/dashboard/todos');
  return res.data;
};

// 5. 수급자 상세 정보 조회
export const getBeneficiaryDetail = async (beneficiaryId) => {
  if (!beneficiaryId) throw new Error('beneficiaryId is required');

  const res = await api.get(`/api/dashboard/beneficiary/${beneficiaryId}`);
  return res.data;
};

// 6. 할 일 상세 정보 조회
export const getTodoDetail = async (todoId) => {
  if (!todoId) throw new Error('todoId is required');

  const res = await api.get(`/api/dashboard/todo/${todoId}`);
  return res.data;
};

// 7. 특정 일정의 요양일지 조회
export const getCareLogBySchedule = async (vsId) => {
  if (!vsId) throw new Error('vsId is required');

  const res = await api.get(`/api/dashboard/schedule/${vsId}/carelog`);
  return res.data;
};

// 8. 내 담당 수급자 목록 조회
export const getMyBeneficiaries = async () => {
  const res = await api.get('/api/dashboard/my-beneficiaries');
  return res.data;
};
