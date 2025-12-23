export const userProfile = {
  name: '김지은',
  role: '요양보호사',
  date: '2025년 12월 10일 수요일'
};

export const alertData = {
  type: 'danger', // warning, info 등 확장 가능
  title: '📢 보수교육 기한 초과',
  desc: '다음 교육 기한:',
  highlight: '2024-11-20 (386일 초과)',
  subDesc: '요양보호사는 2년마다 1회 보수교육을 이수해야 합니다.'
};

export const summaryStats = [
  { label: '오늘 일정', value: '4건', colorClass: 'green-border' },
  { label: '담당 수급자', value: '4명', colorClass: 'blue-border' },
  { label: '주 근무시간', value: '32h', colorClass: 'purple-border' }
];

export const initialTodos = [
  { id: 1, text: '장비 회수: 김영희님 (워커)', checked: false },
  { id: 2, text: '업무일지 작성: 이순자님 (11/28)', checked: false },
  { id: 3, text: '업무일지 작성: 박철수님 (11/27)', checked: false }
];

export const scheduleItems = [
  {
    id: 1, name: '김영희', grade: '3등급', tags: ['복약 처방'],
    time: '09:00 - 10:30', service: '신체활동 지원', address: '서울시 강남구 테헤란로 123',
    status: '완료', statusColor: 'green',
    buttons: [{ text: '활동일지 보기', type: 'secondary', action: 'viewLog' }]
  },
  {
    id: 2, name: '이순자', grade: '2등급', time: '11:00 - 12:30',
    service: '일상생활 지원', address: '서울시 강남구 역삼동 456',
    status: '진행중', statusColor: 'blue',
    buttons: [{ text: '서비스 완료', type: 'primary', color: 'blue', action: 'finish' }]
  },
  {
    id: 3, name: '박철수', grade: '4등급', tags: ['병원 방문', '복약 처방'],
    time: '14:00 - 15:30', service: '신체활동 지원', address: '서울시 서초구 서초동 789',
    status: '예정', statusColor: 'gray', showAttendance: true,
    buttons: [
      { text: '서비스 시작', type: 'primary', color: 'green', action: 'start' },
      { text: '상세보기', type: 'secondary', action: 'detail' }
    ]
  },
  {
    id: 4, name: '최미숙', grade: '3등급', time: '16:00 - 17:30',
    service: '가사 및 일상생활 지원', address: '서울시 강남구 삼성동 321',
    status: '예정', statusColor: 'gray', showAttendance: true,
    buttons: [
      { text: '서비스 시작', type: 'primary', color: 'green', action: 'start' },
      { text: '상세보기', type: 'secondary', action: 'detail' }
    ]
  }
];