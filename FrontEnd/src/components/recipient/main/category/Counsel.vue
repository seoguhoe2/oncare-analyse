<!-- src/components/recipient/category/Counsel.vue -->
<template>
  <div class="list-column scroll-wrapper">
    <!-- ✅ 상단: 총 건수만 -->
    <div class="top-bar">
      <div class="total">총 {{ totalCount }}건</div>
    </div>

    <!-- 로딩/빈상태 -->
    <div v-if="loading" class="empty">불러오는 중...</div>
    <div v-else-if="!totalCount" class="empty">상담 이력이 없습니다.</div>

    <!-- ✅ 목록(현재 페이지 10개만) -->
    <div
      v-else
      v-for="item in pagedCounselList"
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

    <!-- ✅ 하단 중앙 페이징 (페이지가 2 이상일 때만 표시) -->
    <div v-if="totalPages > 1" class="bottom-pager">
      <button
        type="button"
        class="page-btn"
        :disabled="loading || page <= 0"
        @click="page--"
      >
        이전
      </button>

      <span class="page-info">
        {{ page + 1 }} / {{ totalPages }}
      </span>

      <button
        type="button"
        class="page-btn"
        :disabled="loading || page >= totalPages - 1"
        @click="page++"
      >
        다음
      </button>
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
import { ref, onMounted, watch, computed } from 'vue'
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

/** ✅ 페이징 상태 */
const page = ref(0)
const pageSize = ref(10)

/** ✅ 총 건수/총 페이지 */
const totalCount = computed(() => counselList.value.length)
const totalPages = computed(() =>
  totalCount.value === 0 ? 0 : Math.ceil(totalCount.value / pageSize.value)
)

/** ✅ 현재 페이지에 보여줄 10개 */
const pagedCounselList = computed(() => {
  const start = page.value * pageSize.value
  return counselList.value.slice(start, start + pageSize.value)
})

// 목록 조회만
const fetchCounselingList = async () => {
  if (!props.beneficiaryId) return
  loading.value = true

  try {
    const { data } = await api.get(
      `/api/beneficiaries/${props.beneficiaryId}/counselings`
    )
    counselList.value = data?.items ?? []

    // ✅ 목록 로드 후 현재 page가 범위를 벗어나면 보정
    if (page.value > 0 && page.value >= totalPages.value) {
      page.value = Math.max(totalPages.value - 1, 0)
    }
  } catch (e) {
    console.error('상담 목록 조회 실패:', e)
    counselList.value = []
    page.value = 0
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

// beneficiaryId 변경 시 목록 재조회 + 모달 닫기 + ✅ 페이지 초기화
watch(
  () => [props.beneficiaryId, props.refreshKey],
  () => {
    counselList.value = []
    showModal.value = false
    selectedCounselingId.value = null
    page.value = 0
    fetchCounselingList()
  }
)
</script>

<style scoped>
.list-column {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

/* ✅ 상단 바(총 건수만) */
.top-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 2px 2px 6px;
}

.total {
  font-size: 12px;
  color: #6b7280;
}

/* ✅ 하단 중앙 페이징 */
.bottom-pager {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 10px;
  margin-top: 8px;
  padding: 6px 0;
}

.page-info {
  font-size: 12px;
  color: #6b7280;
}

.page-btn {
  border: none;
  background: #f3f4f6;
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 12px;
  cursor: pointer;
  white-space: nowrap;
}
.page-btn:hover {
  background: #e5e7eb;
}
.page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 스크롤바 추가 */
.scroll-wrapper {
  max-height: 360px; /* Inquiry.vue랑 동일 */
  overflow-y: auto;
  padding-right: 4px;
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
