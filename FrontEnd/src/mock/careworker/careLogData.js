// 요양일지 작성 폼 데이터
export const careLogFormData = {
  // 서비스 유형 옵션
  serviceTypes: [
    { value: '방문요양', label: '방문요양' },
    { value: '방문목욕', label: '방문목욕' },
    { value: '방문간호', label: '방문간호' }
  ],

  // 1. 신체활동 지원
  physicalSupport: {
    title: '1. 신체활동 지원',
    sections: [
      {
        code: 'meal',
        label: '식사 도움',
        type: 'checkbox',
        options: [
          { value: 'breakfast', label: '아침', field: 'isBreakfast' },
          { value: 'lunch', label: '점심', field: 'isLunch' },
          { value: 'dinner', label: '저녁', field: 'isDinner' },
          { value: 'snack', label: '간식', field: 'isSnack' }
        ]
      },
      {
        code: 'excretion',
        label: '배설 도움',
        type: 'mixed',
        options: [
          { value: 'diaper', label: '기저귀 교체', field: 'diaperCount', type: 'number', unit: '회' },
          { value: 'toilet', label: '화장실 이용', field: 'toiletCount', type: 'number', unit: '회' },
          { value: 'portable', label: '이동변기', field: 'isPortableToilet', type: 'checkbox' }
        ]
      },
      {
        code: 'excretion_status',
        label: '상태',
        type: 'checkbox',
        options: [
          { value: 'urine', label: '소변', field: 'isUrine' },
          { value: 'stool', label: '대변', field: 'isStool' }
        ]
      },
      {
        code: 'stool_type',
        label: '양상',
        type: 'checkbox',
        options: [
          { value: 'normal', label: '정상', field: 'stoolNormal' },
          { value: 'diarrhea', label: '설사', field: 'stoolDiarrhea' },
          { value: 'constipation', label: '변비', field: 'stoolConstipation' }
        ]
      },
      {
        code: 'hygiene',
        label: '개인 위생',
        type: 'checkbox',
        options: [
          { value: 'face_wash', label: '세면', field: 'isFaceWash' },
          { value: 'oral_care', label: '구강관리(양치)', field: 'isOralCare' },
          { value: 'hair_wash', label: '머리감기', field: 'isHairWash' },
          { value: 'body_wash', label: '몸 씻기(목욕)', field: 'isBodyWash' }
        ]
      },
      {
        code: 'grooming',
        label: '몸 단장',
        type: 'checkbox',
        options: [
          { value: 'change_clothes', label: '옷 갈아입기', field: 'isChangeClothes' },
          { value: 'meal_prep', label: '식사 준비 및 정리', field: 'isMealPrep' },
          { value: 'bed_care', label: '잠자리 정돈', field: 'isBedCare' }
        ]
      },
      {
        code: 'movement',
        label: '이동 도움',
        type: 'checkbox',
        options: [
          { value: 'position_change', label: '체위 변경', field: 'isPositionChange' },
          { value: 'get_up_help', label: '일어나 앉기 도움', field: 'isGetUpHelp' },
          { value: 'indoor_move', label: '실내 이동', field: 'isIndoorMove' },
          { value: 'walk_help', label: '산책/보행', field: 'isWalkHelp' }
        ]
      }
    ]
  },

  // 2. 인지 및 정서 지원
  cognitiveSupport: {
    title: '2. 인지 및 정서 지원',
    sections: [
      {
        code: 'emotional',
        label: '정서 지원',
        type: 'checkbox',
        options: [
          { value: 'emotional_talk', label: '말벗 및 위로', field: 'isEmotionalTalk' },
          { value: 'communication', label: '의사소통 도움', field: 'isCommunication' },
          { value: 'counseling', label: '생활상담', field: 'isCounseling' }
        ]
      },
      {
        code: 'cognitive',
        label: '인지 관리',
        type: 'checkbox',
        options: [
          { value: 'cognitive_care', label: '인지자극활동(퍼즐, 그림그리기 등)', field: 'isCognitiveCare' },
          { value: 'behavior_care', label: '인지행동변화 관리', field: 'isBehaviorCare' }
        ]
      }
    ]
  },

  // 3. 상태 관찰 및 특이사항
  observationStatus: {
    title: '3. 상태 관찰 및 특이사항',
    sections: [
      {
        code: 'health',
        label: '신체 상태',
        type: 'checkbox',
        options: [
          { value: 'health_good', label: '양호', field: 'isHealthGood' },
          { value: 'pain', label: '통증', field: 'isPain' },
          { value: 'edema', label: '부종', field: 'isEdema' },
          { value: 'skin_issue', label: '피부상태(발진/욕창 등)', field: 'isSkinIssue' },
          { value: 'body_etc', label: '기타', field: 'isBodyEtc' }
        ]
      },
      {
        code: 'mood',
        label: '기분 상태',
        type: 'checkbox',
        options: [
          { value: 'mood_calm', label: '평온', field: 'isMoodCalm' },
          { value: 'mood_anxious', label: '불안', field: 'isMoodAnxious' },
          { value: 'mood_depressed', label: '우울', field: 'isMoodDepressed' },
          { value: 'mood_angry', label: '흥분/화냄', field: 'isMoodAngry' },
          { value: 'mood_etc', label: '기타', field: 'isMoodEtc' }
        ]
      },
      {
        code: 'other',
        label: '배설/수면',
        type: 'checkbox',
        options: [
          { value: 'excretion_mistake', label: '배설 실수 있음', field: 'isExcretionMistake' },
          { value: 'sleep_lack', label: '수면 부족', field: 'isSleepLack' },
          { value: 'nap_excess', label: '낮잠 과다', field: 'isNapExcess' }
        ]
      }
    ]
  },

  // 특이사항 메모
  specialNotes: {
    title: '특이사항 및 인수인계 메모',
    placeholder: '오늘 서비스 시 특별히 관찰된 사항이나 전달할 내용을 기록해주세요.'
  }
};

// 낙상위험도 평가 데이터 (필요시 사용)
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
