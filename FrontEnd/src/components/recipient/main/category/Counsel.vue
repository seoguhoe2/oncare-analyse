<!-- src/components/recipient/category/Counsel.vue -->
<template>
  <div class="list-column">
    <div
      v-for="item in counselingList"
      :key="item.id"
      class="list-card"
      @click="openModal(item)"
    >
      <div class="list-header-row">
        <span class="list-title">
          {{ item.date }} {{ item.title }}
        </span>
        <span class="status-pill done">완료</span>
      </div>
      <p class="list-text">
        {{ item.summary }}
      </p>
    </div>

    <!-- ✅ 상담 모달 -->
    <CounselModal
      v-model="showModal"
      :counsel="selectedCounsel"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import CounselModal from './modal/CounselModal.vue'

const showModal = ref(false)
const selectedCounsel = ref(null)

const counselingList = ref([
  {
    id: 1,
    type: '보호자상담',
    date: '2024-11-15',
    title: '보호자 상담',
    summary:
      '보호자(아들)와 전화 상담. 최근 건강 상태와 혈압 관리, 산책 활동 및 식사 패턴에 대해 안내.',
    family: '아들 (김민준)',
    careWorker: '김지은',
    beneficiary: '김영희',
    purpose: '서비스 만족도 확인 및 추가 요구사항 파악',
    mainDiscussion:
      '최근 혈압 수치 변동이 있어 오전 복약 시간 조정 필요성에 대해 논의하였고, 주 3회 산책 활동을 꾸준히 유지하기로 함.',
    agreement:
      '아들이 하루 1회 혈압 측정을 도와주고, 방문요양 시간 내 식사 기록을 정확히 남기기로 합의.',
    nextVisit: '2024-11-22 예정 (정기 방문 상담)'
  },
  {
    id: 2,
    type: '면담',
    date: '2024-10-20',
    title: '초기 상담',
    summary:
      '서비스 시작 전 가정 방문 상담. 주거 환경과 일상 패턴을 파악하고, 주 3회 방문요양 계획 수립.',
    family: '딸 (이수진)',
    careWorker: '박수진',
    beneficiary: '이순자',
    purpose: '초기 상태 파악 및 방문요양 서비스 계획 수립',
    mainDiscussion:
      '최근 낙상 경험이 있어 실내 이동 동선과 욕실 환경을 중심으로 안전 점검을 진행. 보행 보조기 사용 방법에 대해 설명.',
    agreement:
      '주 3회 방문요양(식사 보조, 청소, 산책 동행)을 3개월간 시범 운영 후 재평가하기로 함.',
    nextVisit: '2024-10-27부터 매주 월/수/금 정기 방문'
  }
])

const openModal = (item) => {
  selectedCounsel.value = item
  showModal.value = true
}
</script>

<style scoped>
.list-column {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.list-card {
  padding: 10px 12px;
  border-radius: 10px;
  background-color: #f9fafb;
  font-size: 12px;
  cursor: pointer;
}
.list-card:hover {
  background-color: #e5f2ff;
}
.list-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}
.list-title {
  font-weight: 600;
}
.list-text {
  margin: 0;
  color: #4b5563;
}
.status-pill {
  border-radius: 999px;
  padding: 2px 8px;
  font-size: 11px;
}
.status-pill.done {
  background-color: #dcfce7;
  color: #15803d;
}
</style>
