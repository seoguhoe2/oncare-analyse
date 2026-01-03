<!-- src/components/recipient/main/category/Inquiry.vue -->
<template>
  <div class="list-column scroll-wrapper">
    <!-- ✅ 상단: 총 건수만 -->
    <div class="top-bar">
      <div class="total">총 {{ totalCount }}건</div>
    </div>

    <!-- 로딩/빈상태 -->
    <div v-if="loading" class="empty">불러오는 중...</div>
    <div v-else-if="!totalCount" class="empty">문의 이력이 없습니다.</div>

    <!-- ✅ 목록(현재 페이지 10개만) -->
    <div
      v-else
      v-for="item in pagedInquiryList"
      :key="item.counselHistoryId"
      class="list-card compact"
      @click="openModal(item.counselHistoryId)"
    >
      <div class="list-header-row">
        <span class="badge-type type-phone">
          {{ item.categoryName }}
        </span>

        <span class="list-date">{{ item.consultDate }}</span>
      </div>

      <p v-if="item.detail" class="list-text">
        {{ item.detail }}
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

    <!-- 문의 이력 모달: id만 넘김 -->
    <InquiryModal
      v-model="showModal"
      :beneficiary-id="beneficiaryId"
      :counsel-history-id="selectedCounselHistoryId"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, watch, computed } from 'vue'
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

/** ✅ 페이징 상태 */
const page = ref(0)
const pageSize = ref(10)

/** ✅ 총 건수/총 페이지 */
const totalCount = computed(() => inquiryList.value.length)
const totalPages = computed(() =>
  totalCount.value === 0 ? 0 : Math.ceil(totalCount.value / pageSize.value)
)

/** ✅ 현재 페이지에 보여줄 10개 */
const pagedInquiryList = computed(() => {
  const start = page.value * pageSize.value
  return inquiryList.value.slice(start, start + pageSize.value)
})

// 목록 조회 API
const fetchInquiryList = async () => {
  if (!props.beneficiaryId) return
  loading.value = true

  try {
    const { data } = await api.get(
      `/api/beneficiaries/${props.beneficiaryId}/counsel-histories`
    )
    inquiryList.value = data?.items ?? []

    // ✅ 목록 로드 후 현재 page가 범위를 벗어나면 보정
    if (page.value > 0 && page.value >= totalPages.value) {
      page.value = Math.max(totalPages.value - 1, 0)
    }
  } catch (e) {
    console.error('문의이력 목록 조회 실패:', e)
    inquiryList.value = []
    page.value = 0
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

// beneficiaryId/refreshKey 변경 시 목록 재조회 + 모달 닫기 + ✅ 페이지 초기화
watch(
  () => [props.beneficiaryId, props.refreshKey],
  () => {
    inquiryList.value = []
    showModal.value = false
    selectedCounselHistoryId.value = null
    page.value = 0
    fetchInquiryList()
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

/* 스크롤바 추가 (목록이 길어지면 이 영역 안에서만 스크롤) */
.scroll-wrapper {
  max-height: 360px;
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
