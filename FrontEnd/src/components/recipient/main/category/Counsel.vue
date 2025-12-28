<!-- src/components/recipient/category/Counsel.vue -->
<template>
  <div class="list-column">
    <!-- 로딩/빈상태 -->
    <div v-if="loading" class="empty">불러오는 중...</div>
    <div v-else-if="!counselList.length" class="empty">상담 이력이 없습니다.</div>

    <!-- 목록 -->
    <div
      v-else
      v-for="item in counselList"
      :key="item.counselingId"
      class="list-card"
      @click="openModal(item.counselingId)"
    >
      <div class="list-header-row">
        <span class="list-title">
          {{ item.counselingDate }} {{ item.counselingType }}
        </span>

        <!-- satisfaction 값 있을 때만 -->
        <span v-if="item.satisfaction" class="status-pill done">
          {{ item.satisfaction }}
        </span>
      </div>

      <!-- visitPurpose(설명문) 있을 때만 -->
      <p v-if="item.visitPurpose" class="list-text">
        {{ item.visitPurpose }}
      </p>
    </div>

    <!-- ✅ 상담 모달: counselingId만 넘김 -->
    <CounselModal
      v-model="showModal"
      :beneficiary-id="beneficiaryId"
      :counseling-id="selectedCounselingId"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import api from '@/lib/api'
import CounselModal from './modal/CounselModal.vue'

const props = defineProps({
  beneficiaryId: {
    type: [Number, String],
    required: true
  },
  refreshKey: Number
})

const loading = ref(false)
const counselList = ref([])

const showModal = ref(false)
const selectedCounselingId = ref(null)

// ✅ 목록 조회만
const fetchCounselingList = async () => {
  if (!props.beneficiaryId) return
  loading.value = true

  try {
    const { data } = await api.get(`/api/beneficiaries/${props.beneficiaryId}/counselings`)
    counselList.value = data?.items ?? []
  } catch (e) {
    console.error('상담 목록 조회 실패:', e)
    counselList.value = []
  } finally {
    loading.value = false
  }
}

const openModal = (counselingId) => {
  selectedCounselingId.value = counselingId
  showModal.value = true
}

onMounted(fetchCounselingList)
watch(() => props.beneficiaryId, fetchCounselingList)

// beneficiaryId 변경 시 목록 재조회 + 모달 닫기
watch(
  () => [props.beneficiaryId, props.refreshKey],
  () => {
    counselList.value = []
    showModal.value = false
    selectedCounselingId.value = null
    fetchCounselingList()
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

.empty {
  padding: 12px;
  border-radius: 10px;
  background: #f9fafb;
  color: #6b7280;
  font-size: 12px;
}
</style>
