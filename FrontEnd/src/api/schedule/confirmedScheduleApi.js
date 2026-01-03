import api from '@/lib/api';

export const getConfirmedScheduleRangeCounts = async ({
  start,
  end,
  beneficiaryId,
  careWorkerId,
  serviceTypeId,
  keyword,
  searchField,
} = {}) => {
  const params = {
    start,
    end,
    ...(beneficiaryId != null ? { beneficiaryId } : {}),
    ...(careWorkerId != null ? { careWorkerId } : {}),
    ...(serviceTypeId != null ? { serviceTypeId } : {}),
    ...(keyword != null && String(keyword).trim() !== '' ? { keyword: String(keyword).trim() } : {}),
    ...(searchField != null && String(searchField).trim() !== '' ? { searchField: String(searchField).trim() } : {}),
  };

  const res = await api.get('/confirmed-calendar/range-counts', { params });
  return res.data;
};

export const getConfirmedScheduleDayList = async ({
  date,
  page = 0,
  size = 5,
  beneficiaryId,
  careWorkerId,
  serviceTypeId,
  keyword,
  searchField,
} = {}) => {
  const params = {
    date,
    page,
    size,
    ...(beneficiaryId != null ? { beneficiaryId } : {}),
    ...(careWorkerId != null ? { careWorkerId } : {}),
    ...(serviceTypeId != null ? { serviceTypeId } : {}),
    ...(keyword != null && String(keyword).trim() !== '' ? { keyword: String(keyword).trim() } : {}),
    ...(searchField != null && String(searchField).trim() !== '' ? { searchField: String(searchField).trim() } : {}),
  };

  const res = await api.get('/confirmed-calendar/day-list', { params });
  return res.data;
};

export const getConfirmedScheduleDetail = async ({ vsId } = {}) => {
    if (!vsId) throw new Error('vsId is required');
  
    const res = await api.get('/confirmed-calendar/detail', {
      params: { vsId },
    });
  
    return res.data;
};

// 일정 시간 수정
export const updateConfirmedVisitScheduleTime = async ({ vsId, startDt, endDt }) => {
  if (!vsId) throw new Error('vsId is required');

  const res = await api.put(
    `/confirmed-calendar/visit-schedules/${vsId}/time`,
    { startDt, endDt }
  );

  return res.data;
};

// 일정 삭제
export const deleteConfirmedVisitSchedule = async ({ vsId }) => {
  if (!vsId) throw new Error('vsId is required');

  await api.delete(`/confirmed-calendar/visit-schedules/${vsId}`);
};