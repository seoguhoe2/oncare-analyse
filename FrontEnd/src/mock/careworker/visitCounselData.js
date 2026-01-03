// 방문상담 데이터
export const visitCounselData = {
  title: '방문상담',
  description: '수급자 및 가족과의 상담 내용을 기록합니다',

  // 상담 유형 옵션
  counselTypes: [
    { code: 'initial', label: '초기 상담' },
    { code: 'regular', label: '정기 상담' },
    { code: 'emergency', label: '긴급 상담' },
    { code: 'intermediate', label: '종결 상담' },
    { code: 'guardian', label: '보호자 상담' }
  ],

  // 반응 옵션
  reactionOptions: [
    { code: 'very_good', label: '매우 만족' },
    { code: 'good', label: '만족' },
    { code: 'normal', label: '보통' },
    { code: 'bad', label: '불만족' },
    { code: 'very_bad', label: '매우 불만족' }
  ],

  // 섹션 정의
  sections: [
    {
      code: 'basic_info',
      title: '방문상담 기록',
      description: '수급자 및 가족과의 상담 내용을 자세히 기록하세요.',
      fields: [
        {
          code: 'visit_date',
          label: '상담 일시',
          type: 'datetime-local',
          required: true,
          gridColumn: 'half'
        },
        {
          code: 'recipient',
          label: '수급자',
          type: 'text',
          required: false,
          gridColumn: 'half',
          placeholder: '수급자를 선택하세요.'
        },
        {
          code: 'visit_type',
          label: '상담 유형',
          type: 'select',
          required: false,
          gridColumn: 'half',
          options: 'counselTypes',
          placeholder: '정기 상담'
        },
        {
          code: 'reaction',
          label: '반응',
          type: 'select',
          required: false,
          gridColumn: 'half',
          options: 'reactionOptions',
          placeholder: '보통'
        },
        {
          code: 'visit_detail',
          label: '방문 목적',
          type: 'textarea',
          required: true,
          placeholder: '예: 서비스 만족도 확인 및 요구사항 파악',
          rows: 3
        },
        {
          code: 'observed_condition',
          label: '참석 가족',
          type: 'textarea',
          required: false,
          placeholder: '예: 아들 (김민준)',
          rows: 1
        },
        {
          code: 'subjective_needs',
          label: '주요 논의사항',
          type: 'textarea',
          required: true,
          placeholder: '상담 중 논의한 주요 사항을 입력하세요',
          rows: 4
        },
        {
          code: 'counselor_notes',
          label: '합의 사항',
          type: 'textarea',
          required: true,
          placeholder: '합의된 사항, 향후 계획 등을 입력하세요',
          rows: 3
        },
        {
          code: 'next_action',
          label: '다음 방문 예정일',
          type: 'date',
          required: false,
          gridColumn: 'half',
          placeholder: '다음 방문 예정일을 선택하세요'
        }
      ]
    }
  ]
};
