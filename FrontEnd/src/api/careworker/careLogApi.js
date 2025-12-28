import api from '@/lib/api';

/**
 * 요양일지 API
 */

// 1. 요양일지 작성
export const createCareLog = async (data) => {
  const res = await api.post('/api/care-logs', data);
  return res.data;
};

// 2. 요양일지 수정
export const updateCareLog = async (logId, data) => {
  if (!logId) throw new Error('logId is required');

  const res = await api.patch(`/api/care-logs/${logId}`, data);
  return res.data;
};

// 3. 요양일지 삭제 (논리삭제)
export const deleteCareLog = async (logId) => {
  if (!logId) throw new Error('logId is required');

  const res = await api.delete(`/api/care-logs/${logId}`);
  return res.data;
};
