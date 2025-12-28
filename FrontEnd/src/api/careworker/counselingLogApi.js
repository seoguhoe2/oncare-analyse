import api from '@/lib/api';

/**
 * 방문상담 API
 */

// 1. 방문상담 작성
export const createCounselingLog = async (data) => {
  const res = await api.post('/api/counseling-logs', data);
  return res.data;
};

// 2. 방문상담 수정
export const updateCounselingLog = async (counselingId, data) => {
  if (!counselingId) throw new Error('counselingId is required');

  const res = await api.patch(`/api/counseling-logs/${counselingId}`, data);
  return res.data;
};

// 3. 방문상담 삭제
export const deleteCounselingLog = async (counselingId) => {
  if (!counselingId) throw new Error('counselingId is required');

  const res = await api.delete(`/api/counseling-logs/${counselingId}`);
  return res.data;
};
