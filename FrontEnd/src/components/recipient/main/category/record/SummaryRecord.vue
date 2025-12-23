<!-- src/components/recipient/category/record/SummaryRecord.vue -->
<template>
  <div class="record-summary">
    <!-- 월별 보기 -->
    <div v-if="recordViewMode === 'monthly'" class="record-monthly">
      <div
        v-for="item in monthlySummaries"
        :key="item.month"
        class="summary-card"
        @click="openDailyList(item.month)"
      >
        <div class="summary-icon">
          📅
        </div>
        <div class="summary-main">
          <div class="summary-header">
            <span class="summary-month">{{ item.month }}</span>
            <button type="button" class="ai-btn">AI 요약</button>
          </div>
          <p class="summary-text">
            {{ item.text }}
          </p>
        </div>
      </div>
    </div>

    <!-- 일지 리스트 보기 -->
    <div v-else-if="recordViewMode === 'dailyList'">
      <button
        type="button"
        class="link-btn mb-8"
        @click="recordViewMode = 'monthly'"
      >
        ← 월별 보기로 돌아가기
      </button>

      <h4 class="section-title">{{ selectedMonth }} 일지</h4>
      <ul class="daily-list">
        <li
          v-for="log in dailyLogs"
          :key="log.date"
          class="daily-row"
          @click="recordViewMode = 'detail'"
        >
          <div class="daily-left">
            <span class="daily-icon">📄</span>
            <span class="daily-date">{{ log.date }}</span>
            <span class="daily-worker">{{ log.worker }}</span>
          </div>
          <span class="daily-satisfaction" :class="log.satisfactionClass">
            {{ log.satisfaction }}
          </span>
        </li>
      </ul>
    </div>

    <!-- 상세 기록지 -->
    <div v-else-if="recordViewMode === 'detail'" class="record-detail">
      <button
        type="button"
        class="link-btn mb-8"
        @click="recordViewMode = 'dailyList'"
      >
        ← 일지 리스트로 돌아가기
      </button>

      <div class="detail-header-row">
        <div>
          <div class="detail-line">
            <span class="detail-label">기록일자</span>
            <span>2024-12-05</span>
          </div>
          <div class="detail-line">
            <span class="detail-label">서비스 구분</span>
            <span>방문요양</span>
          </div>
        </div>
        <div>
          <div class="detail-line">
            <span class="detail-label">방문 시간</span>
            <span>09:00 ~ 13:00</span>
          </div>
          <div class="detail-line">
            <span class="detail-label">방문 요양보호사</span>
            <span>박민수</span>
          </div>
        </div>
      </div>

      <div class="detail-section blue">
        <h5>1. 신체활동 지원</h5>
        <div class="chip-row">
          <span class="chip">식사 도움</span>
          <span class="chip">세면 도움</span>
          <span class="chip">체위 변경</span>
        </div>
      </div>

      <div class="detail-section purple">
        <h5>2. 인지 및 정서 지원</h5>
        <div class="chip-row">
          <span class="chip">정서 지원</span>
          <span class="chip">말벗</span>
        </div>
      </div>

      <div class="detail-section green">
        <h5>3. 상태 관찰 및 특이사항</h5>
        <p class="detail-note">
          오늘 방문 중 혈압이 약간 높게 측정되어 보호자에게 공유하였으며,
          식이 조절 및 활동량 유지에 대해 안내 드렸습니다.
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const recordViewMode = ref('monthly') // 'monthly' | 'dailyList' | 'detail'
const selectedMonth = ref('2024-12')

const monthlySummaries = ref([
  {
    month: '2024-12',
    text: '12월 한 달간 방문요양 서비스를 제공하며 전반적인 건강 상태를 안정적으로 유지하고 있습니다. 활발한 실외활동과 균형 잡힌 식단으로 컨디션이 양호합니다.'
  },
  {
    month: '2024-11',
    text: '11월 한 달간 주 3회 방문요양 서비스를 통해 일상생활 지원 및 인지활동 프로그램을 진행하였습니다. 전반적으로 건강 상태가 호전되는 양상을 보입니다.'
  }
])

const dailyLogs = ref([
  {
    date: '2024-12-05',
    worker: '박민수',
    satisfaction: '만족',
    satisfactionClass: 'satis-normal'
  },
  {
    date: '2024-12-03',
    worker: '박민수',
    satisfaction: '매우만족',
    satisfactionClass: 'satis-high'
  },
  {
    date: '2024-12-01',
    worker: '박민수',
    satisfaction: '만족',
    satisfactionClass: 'satis-normal'
  }
])

const openDailyList = (month) => {
  selectedMonth.value = month
  recordViewMode.value = 'dailyList'
}
</script>

<style scoped>
.link-btn {
  border: none;
  background: transparent;
  font-size: 12px;
  color: #4b5563;
  cursor: pointer;
}
.mb-8 {
  margin-bottom: 8px;
}

/* 월별 카드 */
.record-monthly {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.summary-card {
  display: flex;
  gap: 10px;
  padding: 10px 12px;
  border-radius: 10px;
  background-color: #f9fafb;
  cursor: pointer;
}
.summary-icon {
  font-size: 18px;
}
.summary-main {
  flex: 1;
}
.summary-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}
.summary-month {
  font-weight: 600;
  font-size: 13px;
}
.ai-btn {
  border-radius: 999px;
  border: none;
  padding: 4px 8px;
  font-size: 11px;
  background-color: #eef2ff;
  color: #4f46e5;
  cursor: pointer;
}
.summary-text {
  margin: 0;
  font-size: 12px;
  color: #4b5563;
}

/* 일지 리스트 */
.section-title {
  margin: 0 0 6px;
  font-size: 14px;
  font-weight: 600;
}
.daily-list {
  list-style: none;
  margin: 0;
  padding: 0;
}
.daily-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 10px;
  border-radius: 8px;
  background-color: #f9fafb;
  font-size: 12px;
  margin-bottom: 4px;
  cursor: pointer;
}
.daily-left {
  display: flex;
  align-items: center;
  gap: 8px;
}
.daily-icon {
  font-size: 14px;
}
.daily-date {
  font-weight: 500;
}
.daily-worker {
  color: #6b7280;
}
.daily-satisfaction {
  border-radius: 999px;
  padding: 2px 8px;
  font-size: 11px;
}
.satis-normal {
  background-color: #eef2ff;
  color: #4f46e5;
}
.satis-high {
  background-color: #dcfce7;
  color: #15803d;
}

/* 상세 기록지 */
.record-detail {
  font-size: 12px;
}
.detail-header-row {
  display: flex;
  justify-content: space-between;
  gap: 20px;
  margin-bottom: 10px;
}
.detail-line {
  margin-bottom: 2px;
}
.detail-label {
  display: inline-block;
  width: 80px;
  color: #6b7280;
}
.detail-section {
  border-radius: 10px;
  padding: 8px 10px;
  margin-bottom: 8px;
}
.detail-section.blue {
  background-color: #eef2ff;
}
.detail-section.purple {
  background-color: #f5f3ff;
}
.detail-section.green {
  background-color: #ecfdf3;
}
.detail-section h5 {
  margin: 0 0 4px;
  font-size: 12px;
}
.detail-note {
  margin: 0;
  font-size: 12px;
  color: #4b5563;
}
.chip-row {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}
.chip {
  border-radius: 999px;
  padding: 2px 8px;
  font-size: 11px;
  background-color: #e5e7eb;
  color: #374151;
}
</style>
