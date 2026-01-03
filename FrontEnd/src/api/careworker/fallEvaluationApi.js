import api from '@/lib/api';

/**
 * 낙상위험도 평가 API
 */

// ===== Query APIs =====

// 1. 요양보호사별 낙상위험도 평가 목록 조회
export const getFallEvaluationList = async (year = null) => {
  const params = year ? { year } : {};
  const res = await api.get('/api/fall-evaluations', { params });
  return res.data;
};

// 2. 수급자별 낙상위험도 평가 목록 조회
export const getFallEvaluationListByBeneficiary = async (beneficiaryId, year = null) => {
  if (!beneficiaryId) throw new Error('beneficiaryId is required');

  const params = year ? { year } : {};
  const res = await api.get(`/api/fall-evaluations/beneficiary/${beneficiaryId}`, { params });
  return res.data;
};

// 3. 낙상위험도 평가 상세 조회
export const getFallEvaluationDetail = async (evalId) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.get(`/api/fall-evaluations/${evalId}`);
  return res.data;
};

// ===== Command APIs =====

// 4. 낙상위험도 평가 작성
export const createFallEvaluation = async (data) => {
  const res = await api.post('/api/fall-evaluations', data);
  return res.data;
};

// 5. 낙상위험도 평가 수정
export const updateFallEvaluation = async (evalId, data) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.patch(`/api/fall-evaluations/${evalId}`, data);
  return res.data;
};

// 6. 낙상위험도 평가 삭제
export const deleteFallEvaluation = async (evalId) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.delete(`/api/fall-evaluations/${evalId}`);
  return res.data;
};
