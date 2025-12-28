import api from '@/lib/api';

/**
 * 개인 일정 API
 */

// 1. 개인 일정 작성
export const createPersonalSchedule = async (data) => {
  const res = await api.post('/api/personal-schedules', data);
  return res.data;
};

// 2. 개인 일정 수정
export const updatePersonalSchedule = async (psId, data) => {
  if (!psId) throw new Error('psId is required');

  const res = await api.patch(`/api/personal-schedules/${psId}`, data);
  return res.data;
};

// 3. 개인 일정 삭제
export const deletePersonalSchedule = async (psId) => {
  if (!psId) throw new Error('psId is required');

  const res = await api.delete(`/api/personal-schedules/${psId}`);
  return res.data;
};
