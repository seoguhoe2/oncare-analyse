import api from '@/lib/api';

/**
 * 평가(Assessment) API
 * - 욕창위험도 평가 (Bedsore)
 * - 인지기능 평가 (Cognitive)
 * - 낙상위험도 평가 (Fall)
 * - 욕구사정 평가 (Needs)
 */

// ==================== 욕창위험도 평가 ====================

// 1. 욕창위험도 평가 작성
export const createBedsoreEvaluation = async (data) => {
  const res = await api.post('/api/bedsore-evaluations', data);
  return res.data;
};

// 2. 욕창위험도 평가 수정
export const updateBedsoreEvaluation = async (evalId, data) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.patch(`/api/bedsore-evaluations/${evalId}`, data);
  return res.data;
};

// 3. 욕창위험도 평가 삭제
export const deleteBedsoreEvaluation = async (evalId) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.delete(`/api/bedsore-evaluations/${evalId}`);
  return res.data;
};

// ==================== 인지기능 평가 ====================

// 1. 인지기능 평가 작성
export const createCognitiveEvaluation = async (data) => {
  const res = await api.post('/api/cognitive-evaluations', data);
  return res.data;
};

// 2. 인지기능 평가 수정
export const updateCognitiveEvaluation = async (evalId, data) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.patch(`/api/cognitive-evaluations/${evalId}`, data);
  return res.data;
};

// 3. 인지기능 평가 삭제
export const deleteCognitiveEvaluation = async (evalId) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.delete(`/api/cognitive-evaluations/${evalId}`);
  return res.data;
};

// ==================== 낙상위험도 평가 ====================

// 1. 낙상위험도 평가 작성
export const createFallEvaluation = async (data) => {
  const res = await api.post('/api/fall-evaluations', data);
  return res.data;
};

// 2. 낙상위험도 평가 수정
export const updateFallEvaluation = async (evalId, data) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.patch(`/api/fall-evaluations/${evalId}`, data);
  return res.data;
};

// 3. 낙상위험도 평가 삭제
export const deleteFallEvaluation = async (evalId) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.delete(`/api/fall-evaluations/${evalId}`);
  return res.data;
};

// ==================== 욕구사정 평가 ====================

// 1. 욕구사정 평가 작성
export const createNeedsEvaluation = async (data) => {
  const res = await api.post('/api/needs-evaluations', data);
  return res.data;
};

// 2. 욕구사정 평가 수정
export const updateNeedsEvaluation = async (evalId, data) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.patch(`/api/needs-evaluations/${evalId}`, data);
  return res.data;
};

// 3. 욕구사정 평가 삭제
export const deleteNeedsEvaluation = async (evalId) => {
  if (!evalId) throw new Error('evalId is required');

  const res = await api.delete(`/api/needs-evaluations/${evalId}`);
  return res.data;
};
