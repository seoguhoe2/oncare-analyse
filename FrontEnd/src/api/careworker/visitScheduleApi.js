import api from '@/lib/api';

/**
 * 방문 일정 API
 */

// 1. 방문 서비스 시작 (SCHEDULED → IN_PROGRESS)
export const startVisit = async (vsId, data) => {
  if (!vsId) throw new Error('vsId is required');

  const res = await api.post(`/api/visit-schedules/${vsId}/start`, data);
  return res.data;
};

// 2. 방문 서비스 종료 (IN_PROGRESS → DONE)
export const completeVisit = async (vsId, data) => {
  if (!vsId) throw new Error('vsId is required');

  const res = await api.post(`/api/visit-schedules/${vsId}/complete`, data);
  return res.data;
};

// 3. 방문 요양 일정 작성
export const createVisitSchedule = async (data) => {
  const res = await api.post('/api/visit-schedules', data);
  return res.data;
};

// 4. 방문 요양 일정 수정
export const updateVisitSchedule = async (vsId, data) => {
  if (!vsId) throw new Error('vsId is required');

  const res = await api.patch(`/api/visit-schedules/${vsId}`, data);
  return res.data;
};

// 5. 방문 요양 일정 삭제
export const deleteVisitSchedule = async (vsId) => {
  if (!vsId) throw new Error('vsId is required');

  const res = await api.delete(`/api/visit-schedules/${vsId}`);
  return res.data;
};
