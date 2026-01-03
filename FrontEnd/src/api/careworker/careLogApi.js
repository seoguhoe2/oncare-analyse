import api from '@/lib/api';

/**
 * 요양일지 API
 */

// ===== Query APIs =====

// 1. 요양보호사별 요양일지 목록 조회
export const getCareLogList = async () => {
  const res = await api.get('/api/care-logs');

  // 백엔드에서 isDraft 필드를 반환하지 않는 경우를 대비한 임시 처리
  // TODO: 백엔드에서 isDraft 필드를 응답에 포함하도록 수정 필요
  if (res.data?.data && Array.isArray(res.data.data)) {
    res.data.data = res.data.data.map(item => ({
      ...item,
      // isDraft 필드가 없으면 false로 설정 (백엔드에서 반환하면 그대로 사용)
      isDraft: item.isDraft !== undefined ? item.isDraft : false
    }));
  }

  return res.data;
};

// 2. 수급자별 요양일지 목록 조회
export const getCareLogListByBeneficiary = async (beneficiaryId) => {
  if (!beneficiaryId) throw new Error('beneficiaryId is required');

  const res = await api.get(`/api/care-logs/beneficiary/${beneficiaryId}`);
  return res.data;
};

// 3. 요양일지 상세 조회
export const getCareLogDetail = async (logId) => {
  if (!logId) throw new Error('logId is required');

  const res = await api.get(`/api/care-logs/${logId}`);
  return res.data;
};

// ===== Command APIs =====

// 4. 요양일지 작성
export const createCareLog = async (data) => {
  const res = await api.post('/api/care-logs', data);
  return res.data;
};

// 5. 요양일지 수정
export const updateCareLog = async (logId, data) => {
  if (!logId) throw new Error('logId is required');

  const res = await api.patch(`/api/care-logs/${logId}`, data);
  return res.data;
};

// 6. 요양일지 삭제
export const deleteCareLog = async (logId) => {
  if (!logId) throw new Error('logId is required');

  const res = await api.delete(`/api/care-logs/${logId}`);
  return res.data;
};
