// 욕창위험도 평가 데이터
export const bedsoreAssessment = {
  title: '욕창위험도 평가',
  code: 'BEDSORE',
  columns: [
    { score: 1, label: '1점' },
    { score: 2, label: '2점' },
    { score: 3, label: '3점' },
    { score: 4, label: '4점' }
  ],
  items: [
    {
      code: 'sensory',
      label: '감각인지',
      choices: [
        { score: 1, label: '완전 제한' },
        { score: 2, label: '매우 제한' },
        { score: 3, label: '약간 제한' },
        { score: 4, label: '손상 없음' }
      ]
    },
    {
      code: 'moisture',
      label: '습기',
      choices: [
        { score: 1, label: '계속 축축함' },
        { score: 2, label: '자주 축축함' },
        { score: 3, label: '가끔 축축함' },
        { score: 4, label: '거의 없음' }
      ]
    },
    {
      code: 'activity',
      label: '활동성',
      choices: [
        { score: 1, label: '침상안정' },
        { score: 2, label: '의자안정' },
        { score: 3, label: '가끔 보행' },
        { score: 4, label: '자주 보행' }
      ]
    },
    {
      code: 'mobility',
      label: '움직임',
      choices: [
        { score: 1, label: '완전 부동' },
        { score: 2, label: '매우 제한' },
        { score: 3, label: '약간 제한' },
        { score: 4, label: '제한 없음' }
      ]
    },
    {
      code: 'nutrition',
      label: '영양상태',
      choices: [
        { score: 1, label: '매우 불량' },
        { score: 2, label: '약간 불량' },
        { score: 3, label: '양호' },
        { score: 4, label: '매우 양호' }
      ]
    },
    {
      code: 'friction',
      label: '마찰력과 전단력',
      choices: [
        { score: 1, label: '문제 있음' },
        { score: 2, label: '잠재적 문제' },
        { score: 3, label: '문제 없음' }
      ]
    }
  ],
  grading: {
    ranges: [
      { min: 19, max: 23, label: '낮음(위험 없음)', color: 'green' },
      { min: 13, max: 18, label: '중간(약간~중도 위험)', color: 'yellow' },
      { min: 0, max: 12, label: '매우 높음(위험 매우 높음)', color: 'red' }
    ],
    comment_field: true
  }
};
