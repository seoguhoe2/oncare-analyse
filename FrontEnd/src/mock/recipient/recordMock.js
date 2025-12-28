// src/mock/recipient/recordMock.js

// 🔹 월별 요약 (recipientId 기준으로도 나눌 수 있게)
export const recordMonthlySummaryMock = [
  {
    id: 1,
    recipientId: 1,
    month: '2025-12',
    text: '12월 한 달간 방문요양 서비스를 제공하며 전반적인 건강 상태를 안정적으로 유지하고 있습니다. 활발한 실외활동과 균형 잡힌 식단으로 컨디션이 양호합니다.'
  },
  {
    id: 2,
    recipientId: 1,
    month: '2024-11',
    text: '11월 한 달간 주 3회 방문요양 서비스를 통해 일상생활 지원 및 인지활동 프로그램을 진행하였습니다. 전반적으로 건강 상태가 호전되는 양상을 보입니다.'
  },
  // 필요하면 다른 수급자 것도 추가
  {
    id: 3,
    recipientId: 2,
    month: '2025-12',
    text: '12월 한 달간 컨디션이 다소 불안정하여 체력 보강 중심의 방문요양을 진행하였습니다.'
  }
]

// 🔹 일별 요양일지
export const recordDailyLogMock = [
  {
    id: 1,
    recipientId: 1,
    date: '2024-12-05',
    worker: '박민수',
    satisfaction: '만족',
    satisfactionClass: 'satis-normal'
  },
  {
    id: 2,
    recipientId: 1,
    date: '2024-12-03',
    worker: '박민수',
    satisfaction: '매우만족',
    satisfactionClass: 'satis-high'
  },
  {
    id: 3,
    recipientId: 1,
    date: '2024-12-01',
    worker: '박민수',
    satisfaction: '만족',
    satisfactionClass: 'satis-normal'
  },
  {
    id: 4,
    recipientId: 2,
    date: '2024-12-02',
    worker: '김지은',
    satisfaction: '보통',
    satisfactionClass: 'satis-normal'
  }
]
