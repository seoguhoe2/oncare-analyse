import api from '@/lib/api';

/**
 * 요양보호사 일정 조회 API
 */

// 1. 캘린더 일정 조회 (월간/주간/일간)
// - 일별 조회: startDate=2025-12-16&endDate=2025-12-16
// - 주별 조회: startDate=2025-12-16&endDate=2025-12-22
// - 월별 조회: startDate=2025-12-01&endDate=2025-12-31
export const getSchedules = async ({ startDate, endDate } = {}) => {
  if (!startDate || !endDate) {
    throw new Error('startDate and endDate are required');
  }

  const params = {
    startDate,
    endDate,
  };

  const res = await api.get('/api/schedules', { params });
  return res.data;
};

// 2. 일정 상세 조회
export const getScheduleDetail = async (scheduleId) => {
  if (!scheduleId) throw new Error('scheduleId is required');

  const res = await api.get(`/api/schedules/${scheduleId}`);
  return res.data;
};

// 3. 개인 일정 유형 목록 조회 (드롭다운용)
export const getPersonalTypes = async () => {
  const res = await api.get('/api/schedules/personal-types');
  return res.data;
};
