// 낙상위험도 평가 데이터
export const fallRiskAssessment = {
  title: '낙상위험도 평가',
  code: 'FALL',
  columns: [
    { score: 4, label: '4점' },
    { score: 3, label: '3점' },
    { score: 2, label: '2점' },
    { score: 1, label: '1점' },
    { score: 0, label: '0점' }
  ],
  items: [
    {
      code: 'age',
      label: '연령',
      choices: [
        { score: 3, label: '80세 이상' },
        { score: 2, label: '70~79세' },
        { score: 1, label: '60~69세' },
        { score: 0, label: '60세 미만' }
      ]
    },
    {
      code: 'mental_status',
      label: '정신상태',
      choices: [
        { score: 4, label: '혼란스러움/정신장애' },
        { score: 2, label: '때때로 혼란스러움/생활환경 장애' },
        { score: 0, label: '해당없음' }
      ]
    },
    {
      code: 'stool',
      label: '배변',
      choices: [
        { score: 4, label: '소변, 대변 실금' },
        { score: 3, label: '조절능력 있지만 도움필요' },
        { score: 1, label: '유치도뇨관/인공항문' },
        { score: 0, label: '해당없음' }
      ]
    },
    {
      code: 'fall_history',
      label: '낙상경험',
      choices: [
        { score: 4, label: '이미 세 번 이상 넘어짐' },
        { score: 2, label: '이미 한 번 또는 두 번 넘어짐' },
        { score: 0, label: '해당없음' }
      ]
    },
    {
      code: 'activity',
      label: '활동',
      choices: [
        { score: 4, label: '전적으로 도움을 받음' },
        { score: 3, label: '자리에서 일어나 앉기 도움' },
        { score: 1, label: '자립/세면대,화장실이동' },
        { score: 0, label: '완전 자립' }
      ]
    },
    {
      code: 'balance',
      label: '걸음걸이 및 균형',
      choices: [
        { score: 4, label: '평균적/불안정서 있을 때와 걸을 때 균형을 거의 유지하지 못함' },
        { score: 3, label: '일어서거나, 걸을 때 기립성 반영/혈압조절 문제' },
        { score: 2, label: '보행장애/보조도구나 도움으로 걷기' },
        { score: 0, label: '해당없음' }
      ]
    },
    {
      code: 'recent',
      label: '지난 7일간 약복용이나 계획된 약물',
      choices: [
        { score: 4, label: '3개 또는 그 이상의 약 복용' },
        { score: 3, label: '두 가지 약 복용' },
        { score: 2, label: '한 가지 약 복용' },
        { score: 0, label: '해당없음' }
      ]
    }
  ],
  grading: {
    ranges: [
      { min: 0, max: 4, label: '낙상 위험 낮음', color: 'green' },
      { min: 5, max: 10, label: '낙상 위험 높음', color: 'yellow' },
      { min: 11, max: 999, label: '낙상 위험 매우 높음', color: 'red' }
    ],
    comment_field: true
  }
};
