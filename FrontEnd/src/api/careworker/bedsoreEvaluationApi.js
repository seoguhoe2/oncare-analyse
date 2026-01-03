import api from '@/lib/api';

/**
 * 욕창위험도 평가 API
 */

// ===== Query APIs =====

// 1. 요양보호사별 욕창위험도 평가 목록 조회
export const getBedsoreEvaluationList = async (year = null) => {
  const params = year ? { year } : {};
  const res = await api.get('/api/bedsore-evaluations', { params });
  return res.data;
};

// 2. 수급자별 욕창위험도 평가 목록 조회
export const getBedsoreEvaluationListByBeneficiary = async (beneficiaryId, year = null) => {
  if (!beneficiaryId) throw new Error('beneficiaryId is required');

  const params = year ? { year } : {};
  const res = await api.get(`/api/bedsore-evaluations/beneficiary/${beneficiaryId}`, { params });
  return res.data;
};

// 3. 욕창위험도 평가 상세 조회
export const getBedsoreEvaluationDetail = async (evalId) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.get(`/api/bedsore-evaluations/${evalId}`);
  return res.data;
};

// ===== Command APIs =====

// 4. 욕창위험도 평가 작성
export const createBedsoreEvaluation = async (data) => {
  const res = await api.post('/api/bedsore-evaluations', data);
  return res.data;
};

// 5. 욕창위험도 평가 수정
export const updateBedsoreEvaluation = async (evalId, data) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.patch(`/api/bedsore-evaluations/${evalId}`, data);
  return res.data;
};

// 6. 욕창위험도 평가 삭제
export const deleteBedsoreEvaluation = async (evalId) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.delete(`/api/bedsore-evaluations/${evalId}`);
  return res.data;
};
