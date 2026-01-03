import api from '@/lib/api';

/**
 * 인지기능 평가 API
 */

// ===== Query APIs =====

// 1. 요양보호사별 인지기능 평가 목록 조회
export const getCognitiveEvaluationList = async (year = null) => {
  const params = year ? { year } : {};
  const res = await api.get('/api/cognitive-evaluations', { params });
  return res.data;
};

// 2. 수급자별 인지기능 평가 목록 조회
export const getCognitiveEvaluationListByBeneficiary = async (beneficiaryId, year = null) => {
  if (!beneficiaryId) throw new Error('beneficiaryId is required');

  const params = year ? { year } : {};
  const res = await api.get(`/api/cognitive-evaluations/beneficiary/${beneficiaryId}`, { params });
  return res.data;
};

// 3. 인지기능 평가 상세 조회
export const getCognitiveEvaluationDetail = async (evalId) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.get(`/api/cognitive-evaluations/${evalId}`);
  return res.data;
};

// ===== Command APIs =====

// 4. 인지기능 평가 작성
export const createCognitiveEvaluation = async (data) => {
  const res = await api.post('/api/cognitive-evaluations', data);
  return res.data;
};

// 5. 인지기능 평가 수정
export const updateCognitiveEvaluation = async (evalId, data) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.patch(`/api/cognitive-evaluations/${evalId}`, data);
  return res.data;
};

// 6. 인지기능 평가 삭제
export const deleteCognitiveEvaluation = async (evalId) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.delete(`/api/cognitive-evaluations/${evalId}`);
  return res.data;
};
