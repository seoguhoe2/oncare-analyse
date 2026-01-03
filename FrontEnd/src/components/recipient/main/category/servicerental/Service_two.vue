<!-- src/components/recipient/main/category/servicerental/Service_two.vue -->
<template>
  <section>
    <div class="page-head">
      <button class="back-btn" type="button" @click="$emit('back')">←</button>
      <div class="head-text">
        <h3 class="title">서비스 유형별 누계</h3>
        <p class="sub">{{ month }}</p>
      </div>
    </div>

    <!-- ✅ 목록만 스크롤 -->
    <ul class="svc-card-list scroll-list">
      <li v-if="!beneficiaryId" class="empty">수급자를 선택해주세요.</li>
      <li v-else-if="loading" class="empty">불러오는 중...</li>
      <li v-else-if="errorMsg" class="empty">{{ errorMsg }}</li>

      <li v-else-if="types.length === 0" class="empty">
        해당 월에 RFID 완료된 기록이 없습니다.
      </li>

      <li
        v-else
        v-for="t in types"
        :key="t.serviceTypeId"
        class="svc-card clickable"
        @click="$emit('select-type', t.serviceTypeId)"
      >
        <div class="svc-left">
          <span class="pill code-pill">#{{ t.serviceTypeId }}</span>
          <span class="svc-name">{{ t.serviceTypeName }}</span>
        </div>

        <div class="svc-right">
          <span class="pill count-pill">{{ t.visitCount }}회</span>
          <span class="pill hour-pill">{{ formatHours(t.totalHours) }}</span>
          <span class="svc-amount">{{ formatCurrency(t.totalAmount) }}</span>
          <span class="svc-status">목록</span>
        </div>
      </li>
    </ul>
  </section>
</template>

<script setup>
import { onMounted, ref, watch, computed } from "vue";
import api from "@/lib/api";

const props = defineProps({
  beneficiaryId: { type: Number, default: null },
  month: { type: String, required: true },
});
defineEmits(["back", "select-type"]);

const beneficiaryId = computed(() => props.beneficiaryId);

const loading = ref(false);
const errorMsg = ref("");
const types = ref([]);

/** ✅ 템플릿에서 쓰는 포맷터 (필수) */
const formatCurrency = (n) => `${(n ?? 0).toLocaleString("ko-KR")}원`;
const formatHours = (h) => `${Number(h ?? 0).toFixed(1)}시간`;

const fetchTypes = async () => {
  if (!beneficiaryId.value || !props.month) {
    types.value = [];
    return;
  }

  loading.value = true;
  errorMsg.value = "";
  try {
    const { data } = await api.get(
      `/api/beneficiaries/${beneficiaryId.value}/services/${encodeURIComponent(
        props.month
      )}/types`
    );

    // ✅ 백엔드 응답: ServiceTypeSummaryResponse -> serviceTypes
    types.value = data?.serviceTypes ?? [];
  } catch (e) {
    console.error(e);
    types.value = [];
    errorMsg.value = "서비스 유형별 누계를 불러오지 못했습니다.";
  } finally {
    loading.value = false;
  }
};

onMounted(fetchTypes);

watch(() => [beneficiaryId.value, props.month], fetchTypes);
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

/* ✅ 스크롤바: 목록 영역에만 적용 */
.scroll-list {
  max-height: 360px;
  overflow-y: auto;
  padding-right: 4px;
}

.svc-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 10px;
  border-radius: 10px;
  background-color: #f9fafb;
  font-size: 12px;
  margin-bottom: 6px;
}
.clickable {
  cursor: pointer;
}
.clickable:hover {
  filter: brightness(0.98);
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
  flex-wrap: wrap;
  justify-content: flex-end;
}
.svc-name {
  font-weight: 600;
}
.svc-amount {
  font-weight: 800;
}
.svc-status {
  color: #6b7280;
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
.code-pill {
  background-color: #f3e8ff;
  color: #7c3aed;
}
.count-pill {
  background-color: #ffedd5;
  color: #ea580c;
}
.hour-pill {
  background-color: #ecfeff;
  color: #0891b2;
}

.empty {
  padding: 14px 10px;
  color: #6b7280;
  font-size: 12px;
}
</style>
