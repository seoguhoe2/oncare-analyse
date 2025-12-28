<!-- src/components/recipient/main/category/servicerental/Rental.vue -->
<template>
  <div class="rental-wrapper">
    <!-- 현재 사용 중인 용품 -->
    <section class="rental-section current">
      <div class="rental-header">
        <h4>현재 사용 중인 용품</h4>
        <span class="rental-count">총 {{ currentItems.length }}개</span>
      </div>

      <ul class="svc-card-list">
        <li v-if="!beneficiaryId" class="empty">수급자를 선택해주세요.</li>
        <li v-else-if="loading" class="empty">불러오는 중...</li>
        <li v-else-if="errorMsg" class="empty">{{ errorMsg }}</li>
        <li v-else-if="currentItems.length === 0" class="empty">현재 렌탈 용품이 없습니다.</li>

        <li
          v-else
          v-for="item in currentItems"
          :key="itemKey(item)"
          class="svc-card rental-card current"
          @click="openModal(item, 'current')"
        >
          <div class="svc-left">
            <span class="pill code-pill">{{ item.productAssetId }}</span>
            <span class="svc-name">{{ item.productName }}</span>

            <!-- ✅ 상태에 따라 색상 변경 -->
            <span
              class="pill status-pill"
              :class="statusPillClass(item.contractStatusName)"
            >
              {{ item.contractStatusName || "계약중" }}
            </span>
          </div>

          <div class="svc-right">
            <span class="rental-meta">
              {{ item.startDate }} ~ {{ item.endDate || "진행중" }}
            </span>
            <span class="svc-amount">{{ formatCurrency(item.monthlyAmount) }}</span>
            <span class="pill month-pill">
              {{ item.durationMonths ? item.durationMonths + "개월" : "" }}
            </span>
            <span class="svc-status">상세</span>
          </div>
        </li>
      </ul>
    </section>

    <!-- 과거 렌탈 이력 -->
    <section class="rental-section past">
      <div class="rental-header">
        <h4>과거 렌탈 이력</h4>
        <span class="rental-count">총 {{ historyItems.length }}개</span>
      </div>

      <ul class="svc-card-list">
        <li v-if="!beneficiaryId" class="empty">수급자를 선택해주세요.</li>
        <li v-else-if="loading" class="empty">불러오는 중...</li>
        <li v-else-if="errorMsg" class="empty">{{ errorMsg }}</li>
        <li v-else-if="historyItems.length === 0" class="empty">과거 렌탈 이력이 없습니다.</li>

        <li
          v-else
          v-for="item in historyItems"
          :key="itemKey(item)"
          class="svc-card rental-card"
          @click="openModal(item, 'past')"
        >
          <div class="svc-left">
            <span class="pill code-pill">{{ item.productAssetId }}</span>
            <span class="svc-name">{{ item.productName }}</span>

            <!-- ✅ 과거는 기본 회색이지만, 종료면 확실히 회색으로 -->
            <span
              class="pill status-pill"
              :class="statusPillClass(item.contractStatusName)"
            >
              {{ item.contractStatusName || "종료" }}
            </span>
          </div>

          <div class="svc-right">
            <span class="rental-meta">
              {{ item.startDate }} ~ {{ item.endDate || "-" }}
            </span>
            <span class="svc-amount">{{ formatCurrency(item.monthlyAmount) }}</span>
            <span class="pill month-pill">
              {{ item.durationMonths ? item.durationMonths + "개월" : "" }}
            </span>
            <span class="svc-status">상세</span>
          </div>
        </li>
      </ul>
    </section>

    <!-- ✅ 모달 -->
    <RentalModal
      v-model="showModal"
      :beneficiary-id="beneficiaryId"
      :type="selectedType"
      :summary-item="selectedRental"
      @completed="handleCompleted"
    />
  </div>
</template>

<script setup>
import { onMounted, ref, watch } from "vue";
import api from "@/lib/api";
import RentalModal from "../modal/RentalModal.vue";

const props = defineProps({
  beneficiaryId: { type: Number, default: null },
});

const loading = ref(false);
const errorMsg = ref("");

const currentItems = ref([]);
const historyItems = ref([]);

const showModal = ref(false);
const selectedRental = ref(null);
const selectedType = ref("current");

const itemKey = (it) => `${it.rentalContractId}-${it.productAssetId}`;
const formatCurrency = (n) => `${(n ?? 0).toLocaleString("ko-KR")}원`;

/**
 * ✅ 상태 뱃지 클래스
 * - 종료면 "서비스 해지(state-off)"와 동일한 회색 계열로
 */
const statusPillClass = (statusName) => {
  const s = String(statusName || "").trim();
  if (s === "종료") return "ended"; // ✅ 서비스 해지 색과 동일
  return "using"; // 나머지는 기본 초록(사용중 느낌)
};

const fetchRentals = async () => {
  if (!props.beneficiaryId) {
    currentItems.value = [];
    historyItems.value = [];
    return;
  }

  loading.value = true;
  errorMsg.value = "";
  try {
    const { data } = await api.get(`/api/beneficiaries/${props.beneficiaryId}/rentals`);
    currentItems.value = data?.current ?? [];
    historyItems.value = data?.history ?? [];
  } catch (e) {
    console.error(e);
    currentItems.value = [];
    historyItems.value = [];
    errorMsg.value = "렌탈 정보를 불러오지 못했습니다.";
  } finally {
    loading.value = false;
  }
};

const openModal = (item, type) => {
  selectedRental.value = item;
  selectedType.value = type;
  showModal.value = true;
};

// ✅ 모달에서 완료처리 성공하면 목록 재조회
const handleCompleted = async (res) => {
  if (res?.success) await fetchRentals();
};

onMounted(fetchRentals);

watch(
  () => props.beneficiaryId,
  () => {
    showModal.value = false;
    selectedRental.value = null;
    selectedType.value = "current";
    fetchRentals();
  }
);
</script>

<style scoped>
.rental-wrapper {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.svc-card-list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.svc-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 10px;
  border-radius: 10px;
  background-color: #f9fafb;
  font-size: 12px;
  margin-bottom: 6px;
  cursor: pointer;
}
.svc-card:hover {
  background-color: #e5f2ff;
}
.svc-left {
  display: flex;
  align-items: center;
  gap: 8px;
}
.svc-right {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 11px;
}
.svc-name {
  font-weight: 500;
}
.svc-amount {
  font-weight: 600;
}
.svc-status {
  color: #6b7280;
}

.pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  padding: 2px 8px;
  font-size: 11px;
}
.code-pill {
  background-color: #f3e8ff;
  color: #7c3aed;
}
.month-pill {
  background-color: #eef2ff;
  color: #4f46e5;
}

/* ✅ 상태 뱃지 */
.status-pill.using {
  background-color: #dcfce7;
  color: #15803d;
}
/* ✅ 종료면 "서비스 해지(state-off)"와 동일 */
.status-pill.ended {
  background-color: #e5e7eb; /* state-off 배경 */
  color: #374151;           /* state-off 글자 */
}

.rental-section.current .svc-card {
  background-color: #ecfdf3;
}

.rental-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 4px 2px 6px;
}
.rental-header h4 {
  margin: 0;
  font-size: 13px;
}
.rental-count {
  font-size: 11px;
  color: #6b7280;
}
.rental-meta {
  color: #6b7280;
  font-size: 11px;
}

.empty {
  padding: 14px 10px;
  color: #6b7280;
  font-size: 12px;
}

@media (max-width: 1200px) {
  .svc-card {
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
  }
  .svc-right {
    flex-wrap: wrap;
    justify-content: flex-start;
  }
}
</style>
