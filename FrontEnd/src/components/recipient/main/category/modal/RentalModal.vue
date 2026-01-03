<!-- src/components/recipient/main/category/modal/RentalModal.vue -->
<template>
  <div v-if="modelValue" class="modal-backdrop" @click.self="close">
    <div class="modal-panel">
      <!-- Header -->
      <header class="modal-header">
        <div class="title-row">
          <h3>렌탈 용품 상세</h3>
          <button class="close-btn" type="button" @click="close">✕</button>
        </div>

        <div class="item-row">
          <div class="item-name">
            <span class="item-icon">📦</span>
            <span>{{ detail?.productName ?? summaryItem?.productName ?? "-" }}</span>
          </div>

          <span class="status-pill" :class="statusPillClass">
            {{ statusLabel }}
          </span>
        </div>
      </header>

      <!-- Body -->
      <section class="modal-body">
        <div v-if="loading" class="state-text">불러오는 중...</div>
        <div v-else-if="errorMsg" class="state-text error">{{ errorMsg }}</div>

        <template v-else-if="detail">
          <section class="section-block">
            <h4>계약 정보</h4>
            <div class="grid-2">
              <div class="field">
                <div class="label">계약 ID</div>
                <div class="value">{{ detail.rentalContractId }}</div>
              </div>
              <div class="field">
                <div class="label">용품 자산번호</div>
                <div class="value">{{ detail.productAssetId }}</div>
              </div>
              <div class="field">
                <div class="label">계약 체결일</div>
                <div class="value">{{ detail.contractDate || detail.startDate || "-" }}</div>
              </div>
              <div class="field">
                <div class="label">월 렌탈료</div>
                <div class="value">{{ formatCurrency(detail.monthlyAmount) }}</div>
              </div>
            </div>
          </section>

          <section class="section-block">
            <h4>사용 기간</h4>
            <div class="grid-2">
              <div class="field">
                <div class="label">시작일</div>
                <div class="value">{{ detail.startDate || "-" }}</div>
              </div>
              <div class="field">
                <div class="label">종료일</div>
                <div class="value">{{ detail.endDate || "진행중" }}</div>
              </div>
            </div>
          </section>

          <section class="section-block">
            <h4>비용 정보</h4>
            <div class="cost-box">
              <div class="cost-row">
                <span class="label">사용 기간</span>
                <span class="value">{{ durationLabel }}</span>
              </div>
              <div class="cost-row">
                <span class="label">월 렌탈료</span>
                <span class="value">{{ formatCurrency(detail.monthlyAmount) }}</span>
              </div>
              <div class="cost-row total">
                <span class="label">총 비용</span>
                <span class="value">{{ formatCurrency(detail.totalCost) }}</span>
              </div>
            </div>
          </section>
        </template>
      </section>

      <!-- Footer -->
      <footer class="modal-footer">
        <button
          v-if="!isEnded"
          type="button"
          class="primary-btn danger"
          :disabled="completing || loading"
          @click="onCompleteClick"
        >
          {{ completing ? "처리 중..." : "계약 완료로 변경" }}
        </button>

        <button v-else type="button" class="primary-btn" @click="close">
          닫기
        </button>
      </footer>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from "vue";
import api from "@/lib/api";

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  beneficiaryId: { type: Number, required: true },
  summaryItem: { type: Object, default: null }, // rentalContractId + productAssetId (+ contractStatusName)
});

const emit = defineEmits(["update:modelValue", "completed"]);

const loading = ref(false);
const errorMsg = ref("");
const detail = ref(null);
const completing = ref(false);

const close = () => emit("update:modelValue", false);

const statusLabel = computed(
  () => detail.value?.contractStatusName ?? props.summaryItem?.contractStatusName ?? "-"
);
const isEnded = computed(() => String(statusLabel.value).trim() === "종료");
const statusPillClass = computed(() => (isEnded.value ? "ended" : "using"));

const formatCurrency = (n) => `${(n ?? 0).toLocaleString("ko-KR")}원`;
const durationLabel = computed(() => {
  const m = detail.value?.durationMonths;
  return m ? `${m}개월` : "";
});

const fetchDetail = async () => {
  if (!props.modelValue) return;

  if (!props.beneficiaryId || !props.summaryItem?.rentalContractId || !props.summaryItem?.productAssetId) {
    detail.value = null;
    errorMsg.value = "상세 조회 정보가 부족합니다.";
    return;
  }

  loading.value = true;
  errorMsg.value = "";
  detail.value = null;

  try {
    const { data } = await api.get(
      `/api/beneficiaries/${props.beneficiaryId}/rentals/${props.summaryItem.rentalContractId}/products/${encodeURIComponent(
        props.summaryItem.productAssetId
      )}`
    );
    detail.value = data ?? null;
  } catch (e) {
    console.error(e);
    errorMsg.value = "렌탈 상세 정보를 불러오지 못했습니다.";
  } finally {
    loading.value = false;
  }
};

watch(
  () => [props.modelValue, props.summaryItem?.rentalContractId, props.summaryItem?.productAssetId],
  fetchDetail,
  { immediate: true }
);

const onCompleteClick = async () => {
  if (completing.value) return;
  completing.value = true;
  errorMsg.value = "";

  try {
    const { data } = await api.patch(
      `/api/beneficiaries/${props.beneficiaryId}/rentals/${props.summaryItem.rentalContractId}/complete`
    );

    if (!data?.success) {
      errorMsg.value = data?.message || "계약 완료 처리 실패";
      return;
    }

    emit("completed", data);
    emit("update:modelValue", false);
  } catch (e) {
    console.error(e);
    errorMsg.value = "계약 완료 처리 실패";
  } finally {
    completing.value = false;
  }
};
</script>

<style scoped>
/* ✅ 모달이 아래로 내려가는 문제는 대부분 여기(position: fixed)가 적용 안 된 케이스 */
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.modal-panel {
  width: 520px;
  max-height: 90vh;
  background: #ffffff;
  border-radius: 18px;
  box-shadow: 0 20px 40px rgba(15, 23, 42, 0.25);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.modal-header {
  padding: 16px 20px 14px;
  border-bottom: 1px solid #e5e7eb;
  background: #f9fafb;
}

.title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}
.title-row h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
}
.close-btn {
  border: none;
  background: transparent;
  font-size: 18px;
  cursor: pointer;
  color: #6b7280;
}

.item-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.item-name {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-weight: 500;
}
.item-icon {
  width: 28px;
  height: 28px;
  border-radius: 999px;
  background: #ffffff;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.status-pill {
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 500;
}
.status-pill.using {
  background-color: #dcfce7;
  color: #15803d;
}
.status-pill.ended {
  background-color: #e5e7eb;
  color: #374151;
}

.modal-body {
  padding: 18px 20px 12px;
  flex: 1;
  overflow-y: auto;
}

.state-text {
  padding: 10px 0;
  font-size: 12px;
  color: #6b7280;
}
.state-text.error {
  color: #b91c1c;
}

.section-block + .section-block {
  margin-top: 16px;
}
.section-block h4 {
  margin: 0 0 8px;
  font-size: 13px;
  font-weight: 600;
  color: #111827;
}

.grid-2 {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px 16px;
}
.field .label {
  font-size: 11px;
  color: #6b7280;
  margin-bottom: 2px;
}
.field .value {
  font-size: 13px;
  color: #111827;
}

.cost-box {
  border-radius: 12px;
  background: #f9fafb;
  padding: 10px 12px;
  font-size: 12px;
}
.cost-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}
.cost-row:last-child {
  margin-bottom: 0;
}
.cost-row .label {
  color: #6b7280;
}
.cost-row .value {
  font-weight: 500;
}
.cost-row.total .label {
  font-weight: 600;
}
.cost-row.total .value {
  font-weight: 700;
}

.modal-footer {
  padding: 12px 20px 16px;
  border-top: 1px solid #e5e7eb;
}
.primary-btn {
  width: 100%;
  border-radius: 999px;
  padding: 10px 0;
  border: none;
  font-size: 14px;
  font-weight: 600;
  background: #2563eb;
  color: #ffffff;
  cursor: pointer;
}
.primary-btn.danger {
  background: #dc2626;
}
.primary-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

@media (max-width: 540px) {
  .modal-panel {
    width: 94vw;
  }
}
</style>
