// 인지기능 평가 데이터 (CIST 기반 구조 반영)
export const cognitiveAssessment = {
  title: '인지기능 평가',
  code: 'COGNITIVE',
  max_score: 30,
  education_levels: [
    { code: 'NO_EDU_READ', label: '무학 (글자 모름)', cutoff: 14, range: '약 14~16점' },
    { code: 'NO_EDU', label: '무학 (글자 앎)', cutoff: 18, range: '약 18~20점' },
    { code: 'ELEMENTARY', label: '초등학교 졸업 (1~6년)', cutoff: 22, range: '약 22~23점' },
    { code: 'MIDDLE_HIGH', label: '중·고등학교 졸업 (7~12년)', cutoff: 24, range: '약 24~26점' },
    { code: 'COLLEGE', label: '대학 졸업 이상 (13년 이상)', cutoff: 26, range: '약 26~27점' }
  ],
  sections: [
    {
      code: 'A',
      title: 'A. 지남력 (Orientation)',
      max_score: 5,
      type: 'OX',
      items: [
        { code: 'A1', question: 'Q1. 올해는 몇 년입니까? (1점)' },
        { code: 'A2', question: 'Q2. 지금은 몇 월입니까? (1점)' },
        { code: 'A3', question: 'Q3. 오늘은 며칠입니까? (1점)' },
        { code: 'A4', question: 'Q4. 오늘은 무슨 요일입니까? (1점)' },
        { code: 'A5', question: 'Q5. 이 장소는 어디입니까? (1점)' }
      ]
    },
    {
      code: 'B',
      title: 'B. 기억력 - 기억 등록 (점수 없음)',
      max_score: 0,
      type: 'INSTRUCTION_ONLY',
      instruction: '지시: "제가 지금부터 단어 3개를 불러드릴 테니 잘 듣고 따라 해보세요. 이 단어들은 나중에 다시 여쭤볼 겁니다."',
      sub_instruction: '단어 예시: 비행기, 연필, 소나무',
      items: [
        { 
          code: 'B1', 
          question: '확인: 수급자가 3개 단어를 모두 등록(따라 말하기) 했나요?',
          choices: [{ label: '등록 완료 (다음 단계로 진행)', value: true }]
        }
      ]
    },
    {
      code: 'C',
      title: 'C. 주의력 (Attention)',
      max_score: 3,
      type: 'OX',
      items: [
        { code: 'C1', question: 'Q6. 숫자 바로 따라 말하기 (3자리) (1점)', desc: '예: 1-2-3' },
        { code: 'C2', question: 'Q7. 숫자 거꾸로 말하기 (3자리) (1점)', desc: '예: 7-8-9 → 9-8-7' },
        { code: 'C3', question: 'Q8. 숫자 거꾸로 말하기 (4자리) (1점)', desc: '예: 2-4-6-8 → 8-6-4-2' }
      ]
    },
    {
      code: 'D',
      title: 'D. 시공간 기능 (Visuospatial Function)',
      max_score: 2,
      type: 'CHOICE',
      items: [
        {
          code: 'D1',
          question: 'Q9. 도형 따라 그리기 (2점)',
          desc: '화면에 오각형 두 개가 겹친 예시 그림 제시 (캔버스 기능은 추후 추가)',
          choices: [
            { score: 2, label: '2점: 두 도형이 오각형이고, 두 개의 점(또는 면)에서 교차함' },
            { score: 1, label: '1점: 도형 형태는 맞으나 교차가 잘못됨' },
            { score: 0, label: '0점: 형태가 다름' }
          ]
        }
      ]
    },
    {
      code: 'E',
      title: 'E. 집행 기능 (Executive Function)',
      max_score: 6,
      items: [
        {
          code: 'E1',
          question: 'Q10. 유창성 검사 (동물 이름 대기 1분) (3점)',
          type: 'NUMBER_INPUT',
          unit: '개',
          grading_info: '자동 점수 계산: 0~5개: 0점 / 6~8개: 1점 / 9~11개: 2점 / 12개 이상: 3점',
          auto_score_rule: [
            { min: 0, max: 5, score: 0 },
            { min: 6, max: 8, score: 1 },
            { min: 9, max: 11, score: 2 },
            { min: 12, max: 999, score: 3 }
          ]
        },
        {
          code: 'E2',
          question: 'Q11. 선로 잇기 검사 (3점)',
          desc: '내용: "1-월-2-화-3-수..." 순서 연결하기',
          type: 'CHOICE',
          choices: [
            { score: 3, label: '3점: 실수 없이 시간 내 완료' },
            { score: 2, label: '2점: 스스로 수정하여 완료' },
            { score: 1, label: '1점: 시간 초과 또는 도움받아 완료' },
            { score: 0, label: '0점: 실패' }
          ]
        }
      ]
    },
    {
      code: 'F',
      title: 'F. 기억력 - 회상 (Memory Recall)',
      max_score: 10,
      type: 'CONVERT_SCORE', // 환산 점수 타입
      instruction: '아까 들려주었던 단어 3개를 다시 묻습니다.',
      items: [
        {
          code: 'F1',
          question: '단어 1 (비행기):',
          choices: [
            { score: 2, label: '자발회상 (2점)' },
            { score: 1, label: '힌트회상 (1점)' },
            { score: 0, label: '실패 (0점)' }
          ]
        },
        {
          code: 'F2',
          question: '단어 2 (연필):',
          choices: [
            { score: 2, label: '자발회상 (2점)' },
            { score: 1, label: '힌트회상 (1점)' },
            { score: 0, label: '실패 (0점)' }
          ]
        },
        {
          code: 'F3',
          question: '단어 3 (소나무):',
          choices: [
            { score: 2, label: '자발회상 (2점)' },
            { score: 1, label: '힌트회상 (1점)' },
            { score: 0, label: '실패 (0점)' }
          ]
        }
      ],
      convert_rule: { base_total: 6, converted_total: 10 }
    },
    {
      code: 'G',
      title: 'G. 언어 기능 (Language)',
      max_score: 4,
      type: 'CHOICE',
      items: [
        {
          code: 'G1',
          question: 'Q13. 이름 대기 및 이해',
          desc: '상황 파악 질문 (예: "눈이 오면 무엇을 신어야 합니까?")',
          choices: [
            { score: 4, label: '4점 (모두 정답)' },
            { score: 3, label: '3점' },
            { score: 2, label: '2점' },
            { score: 1, label: '1점' },
            { score: 0, label: '0점' }
          ]
        }
      ]
    }
  ],
  grading: {
    rule: 'education_cutoff',
    description: '* 현재 선택된 학력: ',
    warning: '* 해당 학력 기준 점수보다 낮으면 인지 저하 의심'
  }
};