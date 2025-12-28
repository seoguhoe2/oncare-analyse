<!-- src/components/recipient/main/category/servicerental/Service.vue -->
<template>
  <section>
    <!-- ✅ 1번 화면 -->
    <div v-if="view === 'one'">
      <div class="page-head">
        <h3 class="title">서비스 내역</h3>
      </div>

      <ul class="svc-card-list">
        <li v-if="!beneficiaryId" class="empty">수급자를 선택해주세요.</li>
        <li v-else-if="loading" class="empty">불러오는 중...</li>
        <li v-else-if="months.length === 0" class="empty">데이터가 없습니다.</li>

        <li
          v-else
          v-for="m in months"
          :key="m.month"
          class="svc-card clickable"
          @click="openTwo(m.month)"
        >
          <div class="svc-left">
            <span class="pill month-pill">{{ m.month }}</span>
            <span class="svc-name">월 누계</span>
          </div>
          <div class="svc-right">
            <span class="svc-amount">{{ formatCurrency(m.totalAmount) }}</span>
            <span class="svc-status">자세히</span>
          </div>
        </li>
      </ul>
    </div>

    <!-- ✅ 2번 화면 -->
    <Service_two
      v-else-if="view === 'two'"
      :beneficiary-id="beneficiaryId"
      :month="selectedMonth"
      @back="goOne"
      @select-type="openThree"
    />

    <!-- ✅ 3번 화면 -->
    <Service_three
      v-else
      :beneficiary-id="beneficiaryId"
      :month="selectedMonth"
      :service-type-id="selectedServiceTypeId"
      @back="goTwo"
    />
  </section>
</template>

<script setup>
import { onMounted, ref, watch, computed } from "vue";
import api from "@/lib/api";

import Service_two from "./Service_two.vue";
import Service_three from "./Service_three.vue";

const props = defineProps({
  beneficiaryId: { type: Number, default: null },
});

const beneficiaryId = computed(() => props.beneficiaryId);

const view = ref("one");
const loading = ref(false);

const months = ref([]);

const selectedMonth = ref("");
const selectedServiceTypeId = ref(null);

// ✅ 반드시 script setup 최상단에 선언돼 있어야 템플릿에서 인식됨
const formatCurrency = (n) => `${(n ?? 0).toLocaleString("ko-KR")}원`;

const fetchMonths = async () => {
  if (!beneficiaryId.value) {
    months.value = [];
    return;
  }

  loading.value = true;
  try {
    const { data } = await api.get(
      `/api/beneficiaries/${beneficiaryId.value}/services`
    );

    // ✅ 백엔드 응답 키가 histories가 맞는지 확인 필요
    months.value = data?.histories ?? [];
  } catch (e) {
    console.error(e);
    months.value = [];
  } finally {
    loading.value = false;
  }
};

const openTwo = (month) => {
  selectedMonth.value = month;
  view.value = "two";
};

const openThree = (serviceTypeId) => {
  selectedServiceTypeId.value = serviceTypeId;
  view.value = "three";
};

const goOne = () => {
  view.value = "one";
  selectedMonth.value = "";
  selectedServiceTypeId.value = null;
};

const goTwo = () => {
  view.value = "two";
  selectedServiceTypeId.value = null;
};

onMounted(fetchMonths);

watch(
  () => beneficiaryId.value,
  async () => {
    view.value = "one";
    months.value = [];
    selectedMonth.value = "";
    selectedServiceTypeId.value = null;
    await fetchMonths();
  }
);
</script>


<style scoped>
.page-head {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}
.title {
  margin: 0;
  font-size: 14px;
  font-weight: 800;
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

.pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  padding: 2px 8px;
  font-size: 11px;
}
.month-pill {
  background-color: #eef2ff;
  color: #4f46e5;
}

.empty {
  padding: 14px 10px;
  color: #6b7280;
  font-size: 12px;
}
</style>
