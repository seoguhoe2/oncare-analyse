// mock/careworker/scheduleData.js

export const scheduleStats = {
  todayCount: 2,
  weeklyDays: 5,
  weeklyHours: 21.0
};

export const scheduleList = [
  {
    id: 1,
    recipient: '박순자',
    service: 'VISIT_CARE',
    serviceLabel: '방문요양',
    startTime: '10:00',
    endTime: '12:00',
    duration: '2시간',
    date: '2025-12-11',
    status: '진행중',
    statusColor: 'green',
    caregiver: '김지은',
    address: '서울시 송파구 올림픽로 456, 201동 1203호',
    serviceContent: '청소, 세탁, 식사 준비, 장보기 동행',
    disease: ['골다공증', '관절염'],
    riskFactors: ['낙상 주의', '관절 통증 관리'],
    notes: '관절염으로 거동 불편',
    emergencyContact: '010-8888-2222 (딸 박지영)',
    colorClass: 'bg-yellow'
  },
  {
    id: 2,
    recipient: '한상민',
    service: 'VISIT_BATH',
    serviceLabel: '방문목욕',
    startTime: '14:30',
    endTime: '16:30',
    duration: '2시간',
    date: '2025-12-11',
    status: '예정',
    statusColor: 'gray',
    caregiver: '김지은',
    address: '서울시 용산구 한강대로 100',
    serviceContent: '식사 도움, 이동 보조, 산책',
    disease: ['파킨슨병'],
    riskFactors: ['낙상 주의'],
    notes: '오후 약 복용 확인 필요',
    emergencyContact: '010-1234-5678 (아들 한철수)',
    colorClass: 'bg-yellow'
  }
];

export const alternateCaregivers = [
  { id: 101, scheduleId: 1, name: '이영희', distance: '500m', available: true },
  { id: 102, scheduleId: 1, name: '박철수', distance: '1.2km', available: false },
  { id: 103, scheduleId: 2, name: '정민수', distance: '800m', available: true }
];