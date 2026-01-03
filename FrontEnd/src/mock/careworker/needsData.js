export const needsAssessment = {
  title: '욕구사정 평가',
  code: 'NEEDS',
  sections: [
    {
      code: '1',
      title: '일반 상태',
      items: [
        { code: 'weight', label: '체중', type: 'number', unit: 'kg' },
        { code: 'height', label: '키', type: 'number', unit: 'cm' },
        { code: 'nutrition_status', label: '영양상태', type: 'radio', choices: ['양호', '적당', '부족', '매우 나쁨'] },
        { code: 'diet_type', label: '식사형태', type: 'checkbox', choices: ['일반식', '다진식', '죽식', '미음', '유동식', '연하식', '기타'], hasTextWhen: ['기타'] },
        { code: 'therapeutic_diet', label: '치료식이', type: 'checkbox', choices: ['당뇨식', '저염식', '고단백식', '체중조절식'] },
        { code: 'eating_problem', label: '식사 시 문제점', type: 'checkbox', choices: ['양호', '저작곤란', '소화불량', '오심·구토', '연하곤란', '기타'], hasTextWhen: ['기타'] },
        { code: 'oral_status', label: '구강상태', type: 'radio', choices: ['양호', '청결불량', '치아 약함', '틀니', '전존 치아 없음', '기타'], hasTextWhen: ['기타'] },
        { code: 'urination_status', label: '배설 양상 - 소변상태', type: 'checkbox', choices: ['양호', '요실금', '배뇨곤란', '기타'], hasTextWhen: ['기타'] },
        { code: 'defecation_status', label: '대변상태', type: 'checkbox', choices: ['양호', '지속적인 설사', '변비', '기타'], hasTextWhen: ['기타'] },
        { code: 'diaper_use', label: '기저귀 사용 여부', type: 'radio', choices: ['사용', '미사용'] }
      ]
    },
    {
      code: '2',
      title: '주요 질병상태',
      items: [
        { code: 'past_history', label: '과거 병력', type: 'text' },
        { code: 'current_diagnosis', label: '현 진단명', type: 'text' },
        { code: 'chronic_disease', label: '만성질환', type: 'checkbox', choices: ['당뇨', '고혈압', '만성호흡기질환', '암', '기타'], hasTextWhen: ['기타'] },
        { code: 'circulatory', label: '순환기계', type: 'checkbox', choices: ['뇌경색', '뇌출혈', '협심증', '심근경색증', '기타'], hasTextWhen: ['기타'] },
        { code: 'neurologic', label: '신경계', type: 'checkbox', choices: ['치매', '파킨슨병', '간질', '기타'], hasTextWhen: ['기타'] },
        { code: 'musculoskeletal', label: '근골격계', type: 'checkbox', choices: ['관절염', '요통, 좌골통', '골절 등 후유증', '기타'], hasTextWhen: ['기타'] },
        { code: 'mental_behavior', label: '정신·행동장애', type: 'checkbox', choices: ['중풍', '우울증', '수면장애', '정신질환', '기타'], hasTextWhen: ['기타'] },
        { code: 'respiratory', label: '호흡기계', type: 'checkbox', choices: ['호흡곤란', '결핵', '기타'], hasTextWhen: ['기타'] },
        { code: 'renal', label: '만성 신장질환', type: 'checkbox', choices: ['만성신부전증', '보막투석', '혈액투석', '기타'], hasTextWhen: ['기타'] },
        {
          code: 'other_disease',
          label: '기타 질환',
          type: 'checkbox',
          choices: ['알레르기', '기타'],
          hasTextWhen: ['기타', '알레르기'],
          textLabel: { '알레르기': '식품 등', '기타': '내용' }
        }
      ]
    },
    {
      code: '3',
      title: '신체 상태 (일상생활동작 수행능력)',
      items: [
        {
          code: 'adl',
          label: 'ADL',
          type: 'table_radio',
          rows: ['옷 벗고 입기', '세수하기', '양치질하기', '식사하기', '목욕하기', '체위변경', '일어나 앉기', '옮겨 앉기', '화장실 사용하기', '몸단장하기'],
          columns: ['완전자립', '부분도움', '완전도움']
        }
      ]
    },
    {
      code: '4',
      title: '인지 상태',
      items: [
        {
          code: 'behavior',
          label: '행동 증상',
          type: 'checkbox',
          choices: ['망상 (남을 의심하거나, 위험을 느낌)', '환각 (헛것을 보거나 환청을 듣는다.)', '배회 (의미 없이 걷는다.)', '반복적인 행동 (의미 없는 행동을 한다.)', '부적절한 행동 (불결행위 및 숨기는 행동을 한다.)', '폭력적 행동 (주변인에게 폭력적인 행동을 보인다.)', '우울 (슬프거나 처져있고 때로는 운다.)', '불안 (서성이거나, 안절부절 못한다.)']
        }
      ]
    },
    {
      code: '5',
      title: '의사소통',
      items: [
        { code: 'hearing', label: '청력상태', type: 'radio', choices: ['정상(보청기 포함)', '가까운 곳 대화 가능', '큰소리만 들음', '소리에 거의 반응 없음', '들리는지 판단 불능'] },
        { code: 'communication', label: '의사소통', type: 'radio', choices: ['모두 이해·표현 가능', '대부분 이해하고 의사표현 가능', '가끔 이해하고 의사표현 가능', '거의 이해하지 못하고 의사전달 불가능'] },
        { code: 'speech', label: '발음능력', type: 'radio', choices: ['정확함', '옹얼거림', '간혹 왜곡', '전혀 안 됨'] }
      ]
    },
    {
      code: '6',
      title: '가족 및 환경상태',
      items: [
        { code: 'living_with', label: '동거인', type: 'checkbox', choices: ['독거', '배우자', '부모', '자녀', '자부/사위', '손자녀', '친척', '친구/이웃', '기타'], hasTextWhen: ['기타'] },
        {
          code: 'children',
          label: '자녀수',
          type: 'compound',
          fields: [
            { code: 'has_children', label: '유무', type: 'radio', choices: ['무', '유'] },
            { code: 'son_count', label: '아들 수', type: 'number', showWhen: { has_children: '유' } },
            { code: 'daughter_count', label: '딸 수', type: 'number', showWhen: { has_children: '유' } }
          ]
        },
        { code: 'main_supporter', label: '주수발자', type: 'radio', choices: ['무', '유'] },
        {
          code: 'supporter_relation',
          label: '관계',
          type: 'radio',
          choices: ['배우자', '자녀', '자부', '사위', '형제자매', '친척', '기타'],
          hasTextWhen: ['기타'],
          showWhen: { main_supporter: '유' }
        },
        { code: 'economic', label: '경제 상태', type: 'radio', choices: ['안정', '불안정', '연금생활', '기초생활수급', '의료급여'] },
        { code: 'care_burden', label: '수발 부담', type: 'radio', choices: ['전혀 부담되지 않음', '아주 가끔 부담됨', '가끔 부담됨', '자주 부담됨', '항상 부담됨'] },
        { code: 'housing', label: '거주 환경', type: 'radio', choices: ['아파트', '단독주택', '연립주택', '다세대주택', '기타'], hasTextWhen: ['기타'] }
      ]
    },
    {
      code: '7',
      title: '자원 이용',
      items: [
        {
          code: 'medical_institution',
          label: '진료 병원',
          type: 'compound',
          fields: [
            { code: 'hospital_name', label: '병원명(진료과)', type: 'text' },
            { code: 'regular_visit', label: '정기진료', type: 'radio', choices: ['무', '유'] },
            { code: 'hospital_phone', label: '전화번호', type: 'text', showWhen: { regular_visit: '유' } }
          ]
        },
        { code: 'religion', label: '종교활동', type: 'radio', choices: ['없음', '천주교', '기독교', '불교', '기타'], hasTextWhen: ['기타'], isOptional: true },
        { code: 'community_service', label: '지역사회 자원', type: 'checkbox', choices: ['노인맞춤돌봄서비스', '노인돌봄기본서비스', '노인돌봄종합서비스', '단기가사서비스', '독거노인사회관계활성화', '초기독거노인자립지원', '가사간병', '재가복지', '급식및도시락배달', '보건소사업', '개인간병인', '산업재해간병인', '치매안심센터', '복지관(다음희망)', '노인정', '이동서비스', '종교단체', '이미용', '주거개선사업', '기타'], hasTextWhen: ['기타'], isOptional: true }
      ]
    },
    {
      code: '8',
      title: '주관적 욕구',
      items: [{ code: 'subjective_need', label: '수급자 또는 보호자가 희망하는 개별 욕구', type: 'textarea', isOptional: true }]
    },
    {
      code: '9',
      title: '총평',
      items: [{ code: 'summary', label: '종합 소견', type: 'textarea', isOptional: true }]
    },
    {
      code: '10',
      title: '간호평가',
      items: [
        { code: 'respiration', label: '호흡', type: 'checkbox', choices: ['기관지 절개관 간호', '흡인', '산소요법', '기타'], hasTextWhen: ['기타'] },
        { code: 'nutrition_nursing', label: '영양', type: 'checkbox', choices: ['경관영양', '기타'], hasTextWhen: ['기타'] },
        { code: 'elimination_nursing', label: '배설', type: 'checkbox', choices: ['투석간호', '유치도뇨관', '단순 도뇨', '방광루', '요루', '장루간호'] },
        {
          code: 'wound',
          label: '상처',
          type: 'checkbox',
          choices: ['상처간호', '당뇨발간호', '기타'],
          hasTextWhen: ['상처간호', '기타'],
          textLabel: { '상처간호': '부위', '기타': '내용' }
        },
        { code: 'bedsore_stage', label: '욕창 단계', type: 'radio', choices: ['없음', '1단계', '2단계', '3단계', '4단계'] },
        { code: 'bedsore_site', label: '욕창 부위', type: 'checkbox', choices: ['머리', '등', '어깨', '팔꿈치', '엉덩이', '뒤꿈치', '기타'], hasTextWhen: ['기타'] },
        { code: 'bedsore_prevention', label: '욕창 방지 도구', type: 'text', isOptional: true },
        { code: 'pain_cancer_site', label: '통증 - 암 발생 부위', type: 'checkbox', choices: ['없음', '폐', '위', '대장', '간', '전립선', '유방', '담낭 및 기타담도', '기타'], hasTextWhen: ['기타'] },
        { code: 'pain_general_site', label: '일반 통증 부위', type: 'checkbox', choices: ['없음', '머리', '상지', '하지', '허리', '등', '복부', '기타'], hasTextWhen: ['기타'] }
      ]
    }
  ]
};