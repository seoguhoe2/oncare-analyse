<!-- src/components/recipient/main/category/servicerental/Service_three.vue -->
<template>
  <section>
    <div class="page-head">
      <button class="back-btn" type="button" @click="$emit('back')">←</button>
      <div class="head-text">
        <h3 class="title">방문 기록</h3>
        <p class="sub">{{ month }} · {{ serviceTypeNameLabel }}</p>
      </div>
    </div>

    <ul class="svc-card-list">
      <li v-if="!beneficiaryId" class="empty">수급자를 선택해주세요.</li>
      <li v-else-if="loading" class="empty">불러오는 중...</li>
      <li v-else-if="errorMsg" class="empty">{{ errorMsg }}</li>
      <li v-else-if="records.length === 0" class="empty">방문 기록이 없습니다.</li>

      <li v-else v-for="r in records" :key="r.recordId" class="svc-card">
        <div class="top">
          <div class="svc-left">
            <span class="pill date-pill">{{ r.workDate }}</span>
            <span class="svc-name">{{ r.startTime }} - {{ r.endTime }}</span>
            <span class="pill hour-pill">{{ formatHours(r.hours) }}</span>
          </div>

          <div class="svc-right">
            <span class="pill worker-pill">{{ r.careWorkerName ?? "담당자 없음" }}</span>
            <span class="svc-amount">{{ formatCurrency(r.amount) }}</span>
          </div>
        </div>

        <div v-if="r.note" class="note">{{ r.note }}</div>
      </li>
    </ul>
  </section>
</template>

<script setup>
import { computed, onMounted, ref, watch } from "vue";
import api from "@/lib/api";

const props = defineProps({
  beneficiaryId: { type: Number, default: null },
  month: { type: String, required: true },
  serviceTypeId: { type: Number, required: true },
});
defineEmits(["back"]);

const beneficiaryId = computed(() => props.beneficiaryId);

const loading = ref(false);
const errorMsg = ref("");
const records = ref([]);
const serviceTypeName = ref("");

/** ✅ 템플릿에서 쓰는 포맷터 (필수) */
const formatCurrency = (n) => `${(n ?? 0).toLocaleString("ko-KR")}원`;
const formatHours = (h) => `${Number(h ?? 0).toFixed(1)}시간`;

const serviceTypeNameLabel = computed(() =>
  serviceTypeName.value
    ? `${serviceTypeName.value}(#${props.serviceTypeId})`
    : `#${props.serviceTypeId}`
);

const fetchRecords = async () => {
  if (!beneficiaryId.value || !props.month || !props.serviceTypeId) {
    records.value = [];
    serviceTypeName.value = "";
    return;
  }

  loading.value = true;
  errorMsg.value = "";
  try {
    const { data } = await api.get(
      `/api/beneficiaries/${beneficiaryId.value}/services/${encodeURIComponent(
        props.month
      )}/types/${props.serviceTypeId}/records`
    );

    // ✅ 백엔드 응답: ServiceVisitRecordResponse -> serviceTypeName, records
    serviceTypeName.value = data?.serviceTypeName ?? "";
    records.value = data?.records ?? [];
  } catch (e) {
    console.error(e);
    records.value = [];
    serviceTypeName.value = "";
    errorMsg.value = "방문 기록을 불러오지 못했습니다.";
  } finally {
    loading.value = false;
  }
};

onMounted(fetchRecords);

watch(() => [beneficiaryId.value, props.month, props.serviceTypeId], fetchRecords);
</script>

<style scoped>
.page-head {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 10px;
}
.back-btn {
  border: none;
  background: transparent;
  cursor: pointer;
  font-size: 14px;
}
.head-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.title {
  margin: 0;
  font-size: 14px;
  font-weight: 800;
}
.sub {
  margin: 0;
  font-size: 11px;
  color: #6b7280;
}

.svc-card-list {
  list-style: none;
  margin: 0;
  padding: 0;
}
.svc-card {
  padding: 10px 10px;
  border-radius: 10px;
  background-color: #f9fafb;
  font-size: 12px;
  margin-bottom: 6px;
}
.top {
  display: flex;
  justify-content: space-between;
  gap: 10px;
  flex-wrap: wrap;
}
.svc-left {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}
.svc-right {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
  justify-content: flex-end;
}
.svc-name {
  font-weight: 700;
}
.svc-amount {
  font-weight: 800;
}

.note {
  margin-top: 8px;
  padding: 8px 10px;
  border-radius: 10px;
  background: #ffffff;
  color: #374151;
  font-size: 11px;
  line-height: 1.4;
}

/* pill */
.pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  padding: 2px 8px;
  font-size: 11px;
}
.date-pill {
  background-color: #eef2ff;
  color: #4f46e5;
}
.hour-pill {
  background-color: #ecfeff;
  color: #0891b2;
}
.worker-pill {
  background-color: #f0fdf4;
  color: #16a34a;
}

.empty {
  padding: 14px 10px;
  color: #6b7280;
  font-size: 12px;
}
</style>
