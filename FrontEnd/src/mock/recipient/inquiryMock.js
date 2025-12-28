export const inquiryMock = [
  {
    id: 1,
    recipientId: 1,
    type: '전화문의',
    typeClass: 'type-phone',
    typeLabel: '정기상담',
    date: '2024-12-01',
    time: '30분',
    counselor: '김상담사',
    beneficiary: '김영희',
    text: '최근 건강상태 및 서비스 만족도 조사. 혈압 관리 상태 양호하며, 요양보호사와의 관계도 원만함.',
    followUp: '혈압약 복용 시간 준수 독려'
  },
  {
    id: 2,
    recipientId: 2,
    type: '가정방문',
    typeClass: 'type-home',
    typeLabel: '추가문의',
    date: '2024-11-15',
    time: '45분',
    counselor: '박상담사',
    beneficiary: '이순자',
    text: '보호자와 함께 향후 서비스 이용 계획 점검 및 낙상 예방 교육을 진행함.',
    followUp: '욕실 미끄럼 방지 매트 설치 권장 및 야간 조명 보강 안내'
  },
  {
    id: 3,
    recipientId: 3,
    type: '문자문의',
    typeClass: 'type-sms',
    typeLabel: '사전문의',
    date: '2024-10-20',
    time: '40분',
    counselor: '최상담사',
    beneficiary: '박영수',
    text: '서비스 시작 전 기본 주의사항 안내 및 서비스 계약 관련 문의 응대.',
    followUp: '초기 방문 일정 확정 후 안내 문자 발송 예정'
  }
];