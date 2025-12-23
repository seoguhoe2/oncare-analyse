import api from '@/lib/api';

export const getScheduleRangeCounts = async ({
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

  const res = await api.get('/schedule/range-counts', { params });
  return res.data;
};

export const getScheduleDayList = async ({
  date,
  beneficiaryId,
  careWorkerId,
  serviceTypeId,
  keyword,
  searchField,
} = {}) => {
  const params = {
    date,
    ...(beneficiaryId != null ? { beneficiaryId } : {}),
    ...(careWorkerId != null ? { careWorkerId } : {}),
    ...(serviceTypeId != null ? { serviceTypeId } : {}),
    ...(keyword != null && String(keyword).trim() !== '' ? { keyword: String(keyword).trim() } : {}),
    ...(searchField != null && String(searchField).trim() !== '' ? { searchField: String(searchField).trim() } : {}),
  };

  const res = await api.get('/schedule/day', { params });
  return res.data;
};

export const getScheduleDetail = async ({
  matchingId,
  date,
  serviceTypeId,
  startTime,
} = {}) => {
  const params = {
    matchingId,
    date,
    ...(serviceTypeId != null ? { serviceTypeId } : {}),
    ...(startTime != null && String(startTime).trim() !== '' ? { startTime: String(startTime).trim() } : {}),
  };

  const res = await api.get('/schedule/detail', { params });
  return res.data;
};