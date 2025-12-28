// src/mock/recipient/baselineMock.js

// 🔹 기초평가 전체 Mock
// - key: 탭/평가 타입
// - label: 탭 라벨
// - rows: 테이블/문항 리스트 (id, category, options 동일 형식)
// - results: 수급자별 실제 평가 결과 더미 데이터 (recipientId 1, 2)
export const baselineMock = [
  {
    key: 'fall',
    label: '낙상위험도 (연 1회)',
    rows: [
      {
        id: 1,
        category: '연령',
        options: ['80세 이상', '70-79세', '60-69세', '해당없음', '해당없음']
      },
      {
        id: 2,
        category: '정신상태',
        options: [
          '혼란스러움/행동장애',
          '조절능력 있으나 도움 필요',
          '때때로 혼란스러움',
          '유지되는 관찰 필요',
          '해당없음'
        ]
      },
      {
        id: 3,
        category: '낙상경험',
        options: [
          '이미 세 번 이상 넘어짐',
          '두 번 넘어짐',
          '한 번 넘어짐',
          '넘어짐 없음',
          '해당없음'
        ]
      }
    ],
    // ✅ 수급자별 낙상위험도 평가 결과 더미
    results: [
      {
        recipientId: 1,
        evaluatedAt: '2024-03-15',
        totalScore: 9,
        level: '낙상위험 높음',
        memo: '최근 6개월 내 2회 낙상 경험, 보행 시 지속적 관찰 필요.'
      },
      {
        recipientId: 2,
        evaluatedAt: '2024-03-20',
        totalScore: 3,
        level: '낙상위험 낮음',
        memo: '실내 보행은 독립적으로 가능하나, 욕실 내 미끄럼 주의 필요.'
      }
    ]
  },
  {
    key: 'bedsore',
    label: '욕창위험 (연 1회)',
    rows: [
      {
        id: 1,
        category: '활동 능력',
        options: ['매우 양호', '양호', '보통', '저하', '매우 저하']
      },
      {
        id: 2,
        category: '영양 상태',
        options: ['매우 양호', '양호', '보통', '저하', '매우 저하']
      },
      {
        id: 3,
        category: '피부 상태',
        options: [
          '건조/정상',
          '약간 손상',
          '발적 있음',
          '미란·수포',
          '괴사·심한 손상'
        ]
      },
      {
        id: 4,
        category: '습도 관리',
        options: [
          '항상 건조',
          '가끔 땀/습기',
          '자주 습함',
          '항상 축축함',
          '기저귀 상시 사용'
        ]
      },
      {
        id: 5,
        category: '마찰 및 전단력',
        options: ['거의 없음', '가벼운 마찰', '가끔 미끄러짐', '자주 미끄러짐', '완전 의존']
      }
    ],
    // ✅ 수급자별 욕창위험 평가 결과 더미
    results: [
      {
        recipientId: 1,
        evaluatedAt: '2024-04-01',
        totalScore: 6,
        level: '중등도 위험',
        memo: '거동은 가능하나 침상 체위 변경이 잦지 않아 주 3회 피부 상태 확인 필요.'
      },
      {
        recipientId: 2,
        evaluatedAt: '2024-04-03',
        totalScore: 2,
        level: '위험 낮음',
        memo: '활동량이 많고 영양상태 양호하여 욕창 위험은 낮은 편.'
      }
    ]
  },
  {
    key: 'cognition',
    label: '인지기능 (연 1회)',
    rows: [
      {
        id: 1,
        category: '시간 지남력',
        options: ['정상', '경도 저하', '중등도 저하', '중증 저하', '평가 어려움']
      },
      {
        id: 2,
        category: '장소 지남력',
        options: ['정상', '가끔 혼동', '자주 혼동', '지남력 없음', '평가 어려움']
      },
      {
        id: 3,
        category: '사람 인식',
        options: [
          '가족·요양사 인지',
          '가족만 인지',
          '일부만 인지',
          '인지 불가',
          '평가 어려움'
        ]
      },
      {
        id: 4,
        category: '단기 기억력',
        options: ['정상', '가끔 망각', '자주 망각', '최근 일 기억 못함', '평가 어려움']
      },
      {
        id: 5,
        category: '판단력',
        options: ['정상', '가벼운 저하', '중등도 저하', '중증 저하', '평가 어려움']
      }
    ],
    // ✅ 수급자별 인지기능 평가 결과 더미
    results: [
      {
        recipientId: 1,
        evaluatedAt: '2024-05-10',
        totalScore: 7,
        level: '경도 인지저하',
        memo: '일상 대화는 가능하나 최근 사건에 대한 기억력 저하 관찰됨.'
      },
      {
        recipientId: 2,
        evaluatedAt: '2024-05-12',
        totalScore: 3,
        level: '정상~경도',
        memo: '시간·장소 지남력 모두 양호, 단기 기억력도 비교적 잘 유지됨.'
      }
    ]
  },
  {
    key: 'needs',
    label: '욕구사정 (연 1회)',
    rows: [
      {
        id: 1,
        category: '가족 지지',
        options: ['매우 좋음', '좋음', '보통', '부족', '전혀 없음']
      },
      {
        id: 2,
        category: '경제 상태',
        options: ['매우 여유', '여유', '보통', '다소 어려움', '매우 어려움']
      },
      {
        id: 3,
        category: '주거 환경',
        options: ['매우 적절', '적절', '보통', '부적절', '위험 요소 많음']
      },
      {
        id: 4,
        category: '돌봄 요구도',
        options: ['거의 필요 없음', '가벼운 도움', '부분 도움', '상당한 도움', '완전 의존']
      },
      {
        id: 5,
        category: '서비스 기대 수준',
        options: ['매우 높음', '높음', '보통', '낮음', '매우 낮음']
      }
    ],
    // ✅ 수급자별 욕구사정 평가 결과 더미
    results: [
      {
        recipientId: 1,
        evaluatedAt: '2024-06-01',
        level: '돌봄 요구도 高',
        memo: '가족 지지는 양호하나, 일상생활 대부분에서 타인의 도움이 필요함.'
      },
      {
        recipientId: 2,
        evaluatedAt: '2024-06-05',
        level: '돌봄 요구도 中',
        memo: '가사·외출 시 일부 도움이 필요하나 기본적인 일상생활은 독립적으로 가능.'
      }
    ]
  }
]
