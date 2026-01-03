import api from '@/lib/api';

/**
 * 욕구사정 평가 API
 */

// ===== Query APIs =====

// 1. 요양보호사별 욕구사정 평가 목록 조회
export const getNeedsEvaluationList = async (year = null) => {
  const params = year ? { year } : {};
  const res = await api.get('/api/needs-evaluations', { params });
  return res.data;
};

// 2. 수급자별 욕구사정 평가 목록 조회
export const getNeedsEvaluationListByBeneficiary = async (beneficiaryId, year = null) => {
  if (!beneficiaryId) throw new Error('beneficiaryId is required');

  const params = year ? { year } : {};
  const res = await api.get(`/api/needs-evaluations/beneficiary/${beneficiaryId}`, { params });
  return res.data;
};

// 3. 욕구사정 평가 상세 조회
export const getNeedsEvaluationDetail = async (evalId) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.get(`/api/needs-evaluations/${evalId}`);
  return res.data;
};

// ===== Command APIs =====

// 4. 욕구사정 평가 작성
export const createNeedsEvaluation = async (data) => {
  const res = await api.post('/api/needs-evaluations', data);
  return res.data;
};

// 5. 욕구사정 평가 수정
export const updateNeedsEvaluation = async (evalId, data) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.patch(`/api/needs-evaluations/${evalId}`, data);
  return res.data;
};

// 6. 욕구사정 평가 삭제
export const deleteNeedsEvaluation = async (evalId) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.delete(`/api/needs-evaluations/${evalId}`);
  return res.data;
};
