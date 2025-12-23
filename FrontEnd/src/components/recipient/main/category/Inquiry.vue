<!-- src/components/recipient/category/Inquiry.vue -->
<template>
  <div class="list-column">
    <div
      v-for="item in inquiryList"
      :key="item.id"
      class="list-card compact"
      @click="openModal(item)"
    >
      <div class="list-header-row">
        <span class="badge-type" :class="item.typeClass">
          {{ item.type }}
        </span>
        <span class="list-date">{{ item.date }} · {{ item.time }}</span>
      </div>
      <p class="list-text">
        {{ item.text }}
      </p>
    </div>

    <!-- ✅ 문의 이력 모달 -->
    <InquiryModal
      v-model="showModal"
      :inquiry="selectedInquiry"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import InquiryModal from './modal/InquiryModal.vue'

const showModal = ref(false)
const selectedInquiry = ref(null)

const inquiryList = ref([
  {
    id: 1,
    recipient:1,
    type: '전화문의',
    typeClass: 'type-phone',
    typeLabel: '정기상담',
    date: '2024-12-01',
    time: '30분',
    counselor: '김상담사',
    beneficiary: '김영희',
    text: '최근 건강상태 및 서비스 만족도 조사. 혈압 관리 상태 양호하며, 요양보호사와의 관계도 원만함.',
    followUp: '혈압약 복용 시간 준수 독려'
  },
  {
    id: 2,
    recipient:2,
    type: '가정방문',
    typeClass: 'type-home',
    typeLabel: '추가문의',
    date: '2024-11-15',
    time: '45분',
    counselor: '박상담사',
    beneficiary: '이순자',
    text: '보호자와 함께 향후 서비스 이용 계획 점검 및 낙상 예방 교육을 진행함.',
    followUp: '욕실 미끄럼 방지 매트 설치 권장 및 야간 조명 보강 안내'
  },
  {
    id: 3,
    recipient:3,
    type: '문자문의',
    typeClass: 'type-sms',
    typeLabel: '사전문의',
    date: '2024-10-20',
    time: '40분',
    counselor: '최상담사',
    beneficiary: '박영수',
    text: '서비스 시작 전 기본 주의사항 안내 및 서비스 계약 관련 문의 응대.',
    followUp: '초기 방문 일정 확정 후 안내 문자 발송 예정'
  }
])

const openModal = (item) => {
  selectedInquiry.value = item
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
.list-card.compact {
  background-color: #f9fafb;
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
.list-text {
  margin: 0;
  color: #4b5563;
}

/* 타입 배지 */
.badge-type {
  border-radius: 999px;
  padding: 2px 8px;
  font-size: 11px;
}
.type-phone {
  background-color: #dcfce7;
  color: #15803d;
}
.type-home {
  background-color: #fee2e2;
  color: #b91c1c;
}
.type-sms {
  background-color: #e0f2fe;
  color: #1d4ed8;
}
.list-date {
  color: #6b7280;
  font-size: 11px;
}
</style>
