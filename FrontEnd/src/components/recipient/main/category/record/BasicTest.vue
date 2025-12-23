<!-- src/components/recipient/category/record/BasicTest.vue -->
<template>
  <div class="baseline-wrap">
    <!-- 기초평가 내부 탭 -->
    <div class="baseline-subtabs">
      <button
        v-for="tab in baselineTabs"
        :key="tab.key"
        type="button"
        class="baseline-subtab-btn"
        :class="{ active: activeBaseline === tab.key }"
        @click="activeBaseline = tab.key"
      >
        {{ tab.label }}
      </button>
    </div>

    <!-- 낙상위험도 -->
    <section v-if="activeBaseline === 'fall'" class="baseline-panel">
      <div class="panel-header">
        <span class="title">낙상위험도 평가 (연 1회)</span>
        <span class="last-date">최근 평가: 2024-03-15</span>
      </div>

      <div class="baseline-table-wrapper">
        <table class="baseline-table">
          <thead>
            <tr>
              <th>구분</th>
              <th>4점</th>
              <th>3점</th>
              <th>2점</th>
              <th>1점</th>
              <th>0점</th>
              <th>점수</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in fallRows" :key="row.id">
              <td class="cat">{{ row.category }}</td>
              <td v-for="(opt, idx) in row.options" :key="idx">
                <label class="radio-cell">
                  <input type="radio" :name="'fall-' + row.id" />
                  <span>{{ opt }}</span>
                </label>
              </td>
              <td class="score-cell">√필기필요</td>
            </tr>
          </tbody>
        </table>

        <div class="baseline-footer">
          ※ Huhn의 낙상위험도 점수: 4점 이하 - 낙상위험 낮음 / 5~10점 - 낙상위험
          높음 / 11점 이상 - 낙상위험 아주 높음
          <span class="total-score">0점</span>
        </div>
      </div>
    </section>

    <!-- 욕창위험 -->
    <section v-else-if="activeBaseline === 'bedsore'" class="baseline-panel">
      <div class="panel-header">
        <span class="title">욕창위험 평가 (연 1회)</span>
        <span class="last-date">최근 평가: 2024-03-15</span>
      </div>

      <!-- 여기부터는 나중에 실제 설문/테이블 넣으면 됨 -->
      <div class="placeholder-body">
        <ul class="item-list">
          <li>활동 능력</li>
          <li>영양 상태</li>
          <li>피부 상태</li>
          <li>습도 관리</li>
          <li>마찰 및 전단력</li>
        </ul>
        <div class="result-row">
          <span>종합 욕창 위험도</span>
          <button class="result-chip">중등도</button>
        </div>
      </div>
    </section>

    <!-- 인지기능 -->
    <section v-else-if="activeBaseline === 'cognition'" class="baseline-panel">
      <div class="panel-header">
        <span class="title">인지기능 평가 (연 1회)</span>
        <span class="last-date">최근 평가: 2024-03-15</span>
      </div>

      <div class="placeholder-body">
        <p class="placeholder-text">
          인지기능 평가 항목(시간·장소 지남력, 기억력, 판단력 등)을 여기에 구성하면 됩니다.
        </p>
      </div>
    </section>

    <!-- 욕구사정 -->
    <section v-else class="baseline-panel">
      <div class="panel-header">
        <span class="title">욕구사정 평가 (연 1회)</span>
        <span class="last-date">최근 평가: 2024-03-15</span>
      </div>

      <div class="placeholder-body">
        <p class="placeholder-text">
          욕구사정(가족 지지, 경제 상태, 돌봄 요구 등) 평가 폼을 여기에 추가하면 됩니다.
        </p>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const baselineTabs = [
  { key: 'fall',      label: '낙상위험도 (연 1회)' },
  { key: 'bedsore',   label: '욕창위험 (연 1회)' },
  { key: 'cognition', label: '인지기능 (연 1회)' },
  { key: 'needs',     label: '욕구사정 (연 1회)' }
]

const activeBaseline = ref('fall')

const fallRows = ref([
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
      '이미 세번 이상 넘어짐',
      '두번 넘어짐',
      '한번 넘어짐',
      '넘어짐 없음',
      '해당없음'
    ]
  }
])
</script>

<style scoped>
.baseline-wrap {
  margin-top: 4px;
}

/* 기초평가 내부 탭 (연 1회들) */
.baseline-subtabs {
  display: flex;
  gap: 24px;
  border-bottom: 1px solid #e5e7eb;
  margin: 0 -16px 8px;
  padding: 0 16px;
}

.baseline-subtab-btn {
  position: relative;
  border: none;
  background: transparent;
  padding: 8px 0;
  font-size: 13px;
  cursor: pointer;
  color: #6b7280;
}

.baseline-subtab-btn.active {
  color: #16a34a;
  font-weight: 600;
}

.baseline-subtab-btn.active::after {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  bottom: -1px;
  height: 2px;
  background-color: #16a34a;
  border-radius: 999px;
}

/* 공통 패널 박스 */
.baseline-panel {
  margin-top: 10px;
  padding: 10px 12px;
  border-radius: 12px;
  background-color: #faf5ff;      /* 연한 보라 톤 */
  border: 1px solid #ede9fe;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.panel-header .title {
  font-size: 13px;
  font-weight: 600;
}

.panel-header .last-date {
  font-size: 11px;
  padding: 4px 8px;
  border-radius: 999px;
  background-color: #ede9fe;
  color: #6d28d9;
}

/* 낙상위험도 테이블 */
.baseline-table-wrapper {
  margin-top: 6px;
}

.baseline-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 11px;
  background-color: #fdfcff;
}

.baseline-table th,
.baseline-table td {
  border: 1px solid #e5e7eb;
  padding: 6px 4px;
  text-align: center;
}

.baseline-table thead {
  background-color: #f9fafb;
}

.baseline-table .cat {
  text-align: left;
  padding-left: 8px;
}

.radio-cell {
  display: flex;
  align-items: center;
  gap: 3px;
}

.score-cell {
  color: #f97316;
  font-weight: 600;
}

.baseline-footer {
  margin-top: 6px;
  font-size: 11px;
  color: #ef4444;
  display: flex;
  justify-content: space-between;
}

.total-score {
  font-weight: 700;
}

/* 욕창위험 / 기타 placeholder 스타일 */
.placeholder-body {
  padding: 8px 4px 4px;
  font-size: 12px;
}

.item-list {
  list-style: none;
  margin: 0 0 10px;
  padding: 0;
  color: #4b5563;
}

.item-list li + li {
  margin-top: 4px;
}

.result-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
}

.result-chip {
  border: none;
  border-radius: 999px;
  padding: 4px 10px;
  font-size: 12px;
  background-color: #fef3c7;
  color: #92400e;
}

.placeholder-text {
  margin: 0;
  color: #4b5563;
}
</style>
