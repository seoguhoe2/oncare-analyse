// 인지기능 평가 데이터
export const cognitiveAssessment = {
  title: '인지기능 평가',
  code: 'COGNITIVE',
  max_score: 30,
  education_levels: [
    { code: 'NO_EDU_READ', label: '무학(글자 모름)', cutoff: 14 },
    { code: 'NO_EDU', label: '무학(글자 앎)', cutoff: 18 },
    { code: 'ELEMENTARY', label: '초등학교 졸업', cutoff: 22 },
    { code: 'MIDDLE_HIGH', label: '중·고등학교 졸업', cutoff: 24 },
    { code: 'COLLEGE', label: '대학교 졸업 이상', cutoff: 26 }
  ],
  sections: [
    {
      code: 'A',
      title: '지남력 (Orientation)',
      max_score: 5,
      items: [
        { code: 'A1', question: '올해는 몇 년입니까?', score: 1 },
        { code: 'A2', question: '지금은 몇 월입니까?', score: 1 },
        { code: 'A3', question: '오늘은 며칠입니까?', score: 1 },
        { code: 'A4', question: '오늘은 무슨 요일입니까?', score: 1 },
        { code: 'A5', question: '여기는 어디입니까?', score: 1 }
      ]
    },
    {
      code: 'B',
      title: '기억력 - 등록',
      max_score: 0,
      items: [
        {
          code: 'B1',
          instruction: '비행기, 연필, 소나무를 따라 말하게 한다',
          note: '점수 없음'
        }
      ]
    },
    {
      code: 'C',
      title: '주의력 (Attention)',
      max_score: 3,
      items: [
        { code: 'C1', question: '숫자 바로 따라 말하기 (3자리)', score: 1 },
        { code: 'C2', question: '숫자 거꾸로 말하기 (3자리)', score: 1 },
        { code: 'C3', question: '숫자 거꾸로 말하기 (4자리)', score: 1 }
      ]
    },
    {
      code: 'D',
      title: '시공간 기능 (Visuospatial)',
      max_score: 2,
      items: [
        {
          code: 'D1',
          question: '도형 따라 그리기',
          choices: [
            { score: 2, label: '두 도형 정확, 교차 정확' },
            { score: 1, label: '형태 맞으나 교차 오류' },
            { score: 0, label: '형태 다름' }
          ]
        }
      ]
    },
    {
      code: 'E',
      title: '집행 기능 (Executive Function)',
      max_score: 6,
      items: [
        {
          code: 'E1',
          question: '동물 이름 말하기 (1분)',
          input_type: 'number',
          auto_score_rule: [
            { min: 0, max: 5, score: 0 },
            { min: 6, max: 8, score: 1 },
            { min: 9, max: 11, score: 2 },
            { min: 12, max: 99, score: 3 }
          ]
        },
        {
          code: 'E2',
          question: '선로 잇기 검사',
          choices: [
            { score: 3, label: '실수 없이 시간 내 완료' },
            { score: 2, label: '스스로 수정하여 완료' },
            { score: 1, label: '시간 초과/도움 필요' },
            { score: 0, label: '실패' }
          ]
        }
      ]
    },
    {
      code: 'F',
      title: '기억력 - 회상 (Memory Recall)',
      max_score: 10,
      base_total: 6,
      converted_total: 10,
      items: [
        {
          code: 'F1',
          word: '비행기',
          choices: [
            { score: 2, label: '자발 회상' },
            { score: 1, label: '힌트 회상' },
            { score: 0, label: '실패' }
          ]
        },
        {
          code: 'F2',
          word: '연필',
          choices: [
            { score: 2, label: '자발 회상' },
            { score: 1, label: '힌트 회상' },
            { score: 0, label: '실패' }
          ]
        },
        {
          code: 'F3',
          word: '소나무',
          choices: [
            { score: 2, label: '자발 회상' },
            { score: 1, label: '힌트 회상' },
            { score: 0, label: '실패' }
          ]
        }
      ]
    },
    {
      code: 'G',
      title: '언어 기능 (Language)',
      max_score: 4,
      items: [
        {
          code: 'G1',
          question: '상황 파악 질문',
          choices: [
            { score: 4, label: '모두 정답' },
            { score: 3, label: '부분 정답' },
            { score: 2, label: '약간 이해' },
            { score: 1, label: '이해 어려움' },
            { score: 0, label: '전혀 이해 못함' }
          ]
        }
      ]
    }
  ],
  grading: {
    rule: 'education_cutoff',
    description: '선택된 학력 기준 점수 미만일 경우 인지저하 의심'
  }
};
