import api from '@/lib/api';

export const getMemo = async ({ matchingId, date } = {}) => {
  const params = {
    ...(matchingId != null ? { matchingId: Number(matchingId) } : {}),
    ...(date != null && String(date).trim() !== '' ? { date: String(date).trim() } : {}),
  };

  const res = await api.get('/schedule/memo', { params });
  return res.data;
};

export const upsertMemo = async ({ matchingId, memoDate, content } = {}) => {
  const payload = {
    matchingId: matchingId != null ? Number(matchingId) : null,
    memoDate: memoDate != null ? String(memoDate).trim() : null,
    content: content ?? '',
  };

  const res = await api.put('/schedule/memo', payload);
  return res.data;
};