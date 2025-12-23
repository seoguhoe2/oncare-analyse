<!-- src/components/recipient/category/servicerental/Service.vue -->
<template>
  <ul class="svc-card-list">
    <li
      v-for="item in serviceHistory"
      :key="item.code"
      class="svc-card"
    >
      <div class="svc-left">
        <span class="pill code-pill">{{ item.code }}</span>
        <span class="svc-name">{{ item.name }}</span>
      </div>
      <div class="svc-right">
        <span class="pill month-pill">
          {{ item.period }}
        </span>
        <span class="svc-amount">
          {{ formatCurrency(item.amount) }}
        </span>
        <span class="pill count-pill">
          {{ item.count }}회
        </span>
        <span class="svc-status">{{ item.status }}</span>
      </div>
    </li>
  </ul>
</template>

<script setup>
const props = defineProps({
  serviceHistory: {
    type: Array,
    default: () => []
  }
})

const formatCurrency = (n) =>
  (n ?? 0).toLocaleString('ko-KR') + '원'
</script>

<style scoped>
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

/* pill 공통 */
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
.count-pill {
  background-color: #ffedd5;
  color: #ea580c;
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
