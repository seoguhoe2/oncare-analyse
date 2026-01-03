import api from '@/lib/api';

/**
 * 방문상담 API
 */

// ===== Query APIs =====

// 1. 요양보호사별 방문상담 목록 조회
export const getCounselingLogList = async () => {
  const res = await api.get('/api/counseling-logs');
  return res.data;
};

// 2. 수급자별 방문상담 목록 조회
export const getCounselingLogListByBeneficiary = async (beneficiaryId) => {
  if (!beneficiaryId) throw new Error('beneficiaryId is required');

  const res = await api.get(`/api/counseling-logs/beneficiary/${beneficiaryId}`);
  return res.data;
};

// 3. 방문상담 상세 조회
export const getCounselingLogDetail = async (counselingId) => {
  if (!counselingId) throw new Error('counselingId is required');

  const res = await api.get(`/api/counseling-logs/${counselingId}`);
  return res.data;
};

// ===== Command APIs =====

// 4. 방문상담 작성
export const createCounselingLog = async (data) => {
  const res = await api.post('/api/counseling-logs', data);
  return res.data;
};

// 5. 방문상담 수정
export const updateCounselingLog = async (counselingId, data) => {
  if (!counselingId) throw new Error('counselingId is required');

  const res = await api.patch(`/api/counseling-logs/${counselingId}`, data);
  return res.data;
};

// 6. 방문상담 삭제
export const deleteCounselingLog = async (counselingId) => {
  if (!counselingId) throw new Error('counselingId is required');

  const res = await api.delete(`/api/counseling-logs/${counselingId}`);
  return res.data;
};
