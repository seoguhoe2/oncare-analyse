import api from '@/lib/api'

/**
 * =========================
 * Beneficiaries
 * =========================
 */

// 수급자 목록 조회
export const getBeneficiaryList = () =>
  api.get('/matching/beneficiaries/list')

// 수급자 상세 조회
export const getBeneficiaryDetail = (beneficiaryId) =>
  api.get(`/matching/beneficiaries/${beneficiaryId}`)

/**
 * =========================
 * CareWorkers (Matching)
 * =========================
 */

// 특정 수급자 기준 후보 요양보호사 카드 조회
export const getCandidateCareWorkerCards = (beneficiaryId) =>
  api.get('/matching/careworkers/list', {
    params: { beneficiaryId },
  })

// 방문일정(confirmed) 시간 기준 배정가능 요양보호사 카드 조회
export const getVisitAvailableCareWorkerCards = ({ beneficiaryId, vsId, startDt, endDt }) =>
  api.get('/matching/careworkers/visit-available', {
    params: { beneficiaryId, vsId, startDt, endDt },
  })
  
// 요양보호사 상세 조회
export const getCareWorkerDetail = (careWorkerId) =>
  api.get(`/matching/careworkers/${careWorkerId}`)

/**
 * =========================
 * CareWorker Change
 * =========================
 */

// 매칭 요양보호사 변경
export const changeMatchingCareWorker = (matchingId, careWorkerId) =>
  api.patch(`/change/matchings/${matchingId}/care-worker`, {
    careWorkerId,
  })

// 방문일정(confirmed) 요양보호사 변경
export const changeVisitScheduleCareWorker = (vsId, careWorkerId) =>
  api.patch(`/change/visit-schedules/${vsId}/care-worker`, {
    careWorkerId,
  })

// 매칭
export const assignMatchingCareWorker = ({ beneficiaryId, careWorkerId }) =>
  api.post('/matching/assign', {
    beneficiaryId,
    careWorkerId,
  })

// 방문일정 "생성" 시간 기준 배정가능 요양보호사 카드 조회
export const getCreateVisitAvailableCareWorkerCards = ({
  beneficiaryId,
  startDt,
  endDt,
  serviceTypeId, 
}) =>
  api.get('/matching/careworkers/visit-create-available', {
    params: { beneficiaryId, startDt, endDt, serviceTypeId }, 
  })

  // 방문일정 생성
export const createVisitSchedule = ({
  beneficiaryId,
  careWorkerId,
  serviceTypeId, 
  startDt,
  endDt,
  note,          
}) =>
  api.post('/matching/visit-schedules', {
    beneficiaryId,
    careWorkerId,
    serviceTypeId,
    startDt,
    endDt,
    note,         
  })