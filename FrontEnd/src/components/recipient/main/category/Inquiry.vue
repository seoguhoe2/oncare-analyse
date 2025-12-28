<!-- src/components/recipient/main/category/Inquiry.vue -->
<template>
  <div class="list-column">
    <!-- 로딩/빈상태 -->
    <div v-if="loading" class="empty">불러오는 중...</div>
    <div v-else-if="!inquiryList.length" class="empty">문의 이력이 없습니다.</div>

    <!-- 목록 -->
    <div
      v-else
      v-for="item in inquiryList"
      :key="item.counselHistoryId"
      class="list-card compact"
      @click="openModal(item.counselHistoryId)"
    >
      <div class="list-header-row">
        <!-- ✅ 전화문의 등: categoryName -->
        <span class="badge-type type-phone">
          {{ item.categoryName }}
        </span>

        <!-- ✅ 날짜만 표시(시간 제거): consultDate -->
        <span class="list-date">{{ item.consultDate }}</span>
      </div>

      <!-- ✅ 내용: detail -->
      <p v-if="item.detail" class="list-text">
        {{ item.detail }}
      </p>
    </div>

    <!-- ✅ 문의 이력 모달: id만 넘김 -->
    <InquiryModal
      v-model="showModal"
      :beneficiary-id="beneficiaryId"
      :counsel-history-id="selectedCounselHistoryId"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import api from '@/lib/api'
import InquiryModal from './modal/InquiryModal.vue'

const props = defineProps({
  beneficiaryId: {
    type: [Number, String],
    required: true
  },
  refreshKey: Number
})

const loading = ref(false)
const inquiryList = ref([])

const showModal = ref(false)
const selectedCounselHistoryId = ref(null)

// ✅ 목록 조회 API만
const fetchInquiryList = async () => {
  if (!props.beneficiaryId) return
  loading.value = true

  try {
    const { data } = await api.get(
      `/api/beneficiaries/${props.beneficiaryId}/counsel-histories`
    )
    inquiryList.value = data?.items ?? []
  } catch (e) {
    console.error('문의이력 목록 조회 실패:', e)
    inquiryList.value = []
  } finally {
    loading.value = false
  }
}

const openModal = (counselHistoryId) => {
  selectedCounselHistoryId.value = counselHistoryId
  showModal.value = true
}

onMounted(fetchInquiryList)
watch(() => props.beneficiaryId, fetchInquiryList)

// beneficiaryId 변경 시 목록 재조회 + 모달 닫기
watch(
  () => [props.beneficiaryId, props.refreshKey],
  () => {
    inquiryList.value = []
    showModal.value = false
    selectedCounselHistoryId.value = null
    fetchInquiryList()
  }
  // },
  // { immediate: true }
)
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

/* ✅ 색상은 기존 phone 스타일을 재사용 */
.type-phone {
  background-color: #dcfce7;
  color: #15803d;
}

.list-date {
  color: #6b7280;
  font-size: 11px;
}

.empty {
  padding: 12px;
  border-radius: 10px;
  background: #f9fafb;
  color: #6b7280;
  font-size: 12px;
}
</style>
