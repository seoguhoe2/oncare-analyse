import api from '@/lib/api';

/**
 * 평가(Assessment) API
 * - 욕창위험도 평가 (Bedsore)
 * - 인지기능 평가 (Cognitive)
 * - 낙상위험도 평가 (Fall)
 * - 욕구사정 평가 (Needs)
 */

// ==================== 욕창위험도 평가 ====================

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
export const deleteBedsoreEvaluation = async (evalId, userId = null) => {
  if (!evalId) throw new Error('evalId is required');

  const config = userId ? { data: { careWorkerId: userId, employeeId: userId } } : {};
  const res = await api.delete(`/api/bedsore-evaluations/${evalId}`, config);
  return res.data;
};

// ==================== 인지기능 평가 ====================

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
export const deleteCognitiveEvaluation = async (evalId, userId = null) => {
  if (!evalId) throw new Error('evalId is required');

  const config = userId ? { data: { careWorkerId: userId, employeeId: userId } } : {};
  const res = await api.delete(`/api/cognitive-evaluations/${evalId}`, config);
  return res.data;
};

// ==================== 낙상위험도 평가 ====================

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
export const deleteFallEvaluation = async (evalId, userId = null) => {
  if (!evalId) throw new Error('evalId is required');

  const config = userId ? { data: { careWorkerId: userId, employeeId: userId } } : {};
  const res = await api.delete(`/api/fall-evaluations/${evalId}`, config);
  return res.data;
};

// ==================== 욕구사정 평가 ====================

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
export const deleteNeedsEvaluation = async (evalId, userId = null) => {
  if (!evalId) throw new Error('evalId is required');

  const config = userId ? { data: { careWorkerId: userId, employeeId: userId } } : {};
  const res = await api.delete(`/api/needs-evaluations/${evalId}`, config);
  return res.data;
};
