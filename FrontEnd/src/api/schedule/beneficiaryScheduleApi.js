import api from '@/lib/api'

const toNum = (v) => {
  if (v == null || v === '') return null
  const n = Number(v)
  return Number.isFinite(n) ? n : null
}

const toTimeSeconds = (t) => {
  if (!t) return null
  const s = String(t).trim()
  if (/^\d{2}:\d{2}:\d{2}$/.test(s)) return s
  if (/^\d{2}:\d{2}$/.test(s)) return `${s}:00`
  return s
}

const toDate = (d) => {
  if (!d) return null
  return String(d)
}

const buildCreatePayload = ({
  day,
  startTime,
  endTime,
  beneficiaryId,
  serviceTypeId,
  effectiveDate,
}) => ({
  day: toNum(day),
  startTime: toTimeSeconds(startTime),
  endTime: toTimeSeconds(endTime),
  beneficiaryId: toNum(beneficiaryId),
  serviceTypeId: toNum(serviceTypeId),
  effectiveDate: toDate(effectiveDate),
})

const buildUpdatePayload = ({
  day,
  startTime,
  endTime,
  serviceTypeId,
  effectiveDate,
}) => ({
  day: toNum(day),
  startTime: toTimeSeconds(startTime),
  endTime: toTimeSeconds(endTime),
  serviceTypeId: toNum(serviceTypeId),
  effectiveDate: toDate(effectiveDate),
})

// 생성
export const createBeneficiarySchedule = async (params) => {
  const payload = buildCreatePayload(params)
  const res = await api.post('/beneficiary-schedules', payload)
  return res.data
}

// 수정
export const updateBeneficiarySchedule = async (id, params) => {
  const payload = buildUpdatePayload(params)
  const res = await api.put(`/beneficiary-schedules/${toNum(id)}`, payload)
  return res.data
}

// 삭제
export const deleteBeneficiarySchedule = async (id, effectiveDate) => {
  const res = await api.delete(`/beneficiary-schedules/${toNum(id)}`, {
    params: { effectiveDate: toDate(effectiveDate) },
  })
  return res.data
}