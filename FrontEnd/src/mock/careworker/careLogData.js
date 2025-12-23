// 요양일지 작성 폼 데이터
export const careLogFormData = {
  // 기본 정보
  basicInfo: {
    recipientName: '',
    careWorkerName: '',
    careDate: '',
    careTime: { start: '', end: '' },
    serviceType: ''
  },

  // 서비스 유형 옵션
  serviceTypes: [
    { value: 'visit', label: '방문요양' },
    { value: 'bathing', label: '방문목욕' },
    { value: 'nursing', label: '방문간호' }
  ],

  // 1. 신체활동 지원
  physicalSupport: {
    title: '1. 신체활동 지원',
    items: [
      {
        code: 'washing',
        label: '세면 도움',
        options: [
          { value: 'none', label: '미해당' },
          { value: 'partial', label: '부분 도움' },
          { value: 'full', label: '전체 도움' }
        ]
      },
      {
        code: 'body_care',
        label: '몸단장 도움',
        options: [
          { value: 'hair', label: '머리빗기' },
          { value: 'shave', label: '면도' },
          { value: 'nail', label: '손발톱 정리' }
        ]
      },
      {
        code: 'toileting',
        label: '배변 도움',
        options: [
          { value: 'toilet', label: '화장실 이용' },
          { value: 'portable', label: '이동변기' },
          { value: 'diaper', label: '기저귀 교환' }
        ]
      },
      {
        code: 'position',
        label: '체위 변경',
        options: [
          { value: 'none', label: '해당없음' },
          { value: 'sitting', label: '앉히기' },
          { value: 'turning', label: '돌려눕히기' }
        ]
      },
      {
        code: 'mobility',
        label: '이동 도움',
        options: [
          { value: 'indoor', label: '실내 이동' },
          { value: 'outdoor', label: '실외 이동' },
          { value: 'wheelchair', label: '휠체어 도움' }
        ]
      }
    ]
  },

  // 2. 인지 및 정서 지원
  cognitiveSupport: {
    title: '2. 인지 및 정서 지원',
    items: [
      {
        code: 'mental_status',
        label: '정신 상태',
        options: [
          { value: 'good', label: '명확 및 안정' },
          { value: 'sometimes_confused', label: '때때로 혼란스러움' },
          { value: 'confused', label: '혼란스러움/정신장애' }
        ]
      },
      {
        code: 'communication',
        label: '의사소통 여부',
        options: [
          { value: 'possible', label: '가능함' },
          { value: 'difficult', label: '어려움 있음' },
          { value: 'impossible', label: '불가능' }
        ]
      }
    ]
  },

  // 3. 신체 관찰 및 돌이상태
  physicalObservation: {
    title: '3. 신체 관찰 및 돌이상태',
    items: [
      {
        code: 'meal_status',
        label: '간병 상태',
        fields: [
          { code: 'breakfast', label: '아침', type: 'select', options: [
            { value: 'full', label: '완전섭취' },
            { value: 'half', label: '반 정도' },
            { value: 'few', label: '조금만' },
            { value: 'none', label: '안 먹음' }
          ]},
          { code: 'lunch', label: '점심', type: 'select', options: [
            { value: 'full', label: '완전섭취' },
            { value: 'half', label: '반 정도' },
            { value: 'few', label: '조금만' },
            { value: 'none', label: '안 먹음' }
          ]},
          { code: 'dinner', label: '저녁', type: 'select', options: [
            { value: 'full', label: '완전섭취' },
            { value: 'half', label: '반 정도' },
            { value: 'few', label: '조금만' },
            { value: 'none', label: '안 먹음' }
          ]}
        ]
      },
      {
        code: 'stool_status',
        label: '기분 상태',
        fields: [
          { code: 'morning', label: '오전', type: 'select', options: [
            { value: 'good', label: '좋음' },
            { value: 'normal', label: '보통' },
            { value: 'bad', label: '나쁨' }
          ]},
          { code: 'afternoon', label: '오후', type: 'select', options: [
            { value: 'good', label: '좋음' },
            { value: 'normal', label: '보통' },
            { value: 'bad', label: '나쁨' }
          ]}
        ]
      },
      {
        code: 'vital_signs',
        label: '생활 도움',
        fields: [
          { code: 'blood_pressure', label: '혈압', type: 'text', unit: 'mmHg' },
          { code: 'temperature', label: '체온', type: 'text', unit: '℃' },
          { code: 'pulse', label: '맥박', type: 'text', unit: '회/분' }
        ]
      }
    ]
  },

  // 특이사항 메모
  specialNotes: {
    title: '특이사항 및 건강상태 메모',
    placeholder: '오늘 서비스 시 특별히 관찰된 사항이나 전달할 내용을 기록해주세요.'
  }
};

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
