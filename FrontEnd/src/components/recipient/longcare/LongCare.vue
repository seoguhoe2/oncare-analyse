<!-- src/components/recipient/longcare/LongCare.vue -->
<template>
  <div class="card longcare-wrap">
    <header class="longcare-header">
      <h3>⚠ 장기요양등급 만료 예정</h3>

      <div class="filters">
        <button
          v-for="btn in rangeButtons"
          :key="btn.key"
          type="button"
          class="range-btn"
          :class="{ active: activeRange === btn.key }"
          @click="activeRange = btn.key"
        >
          {{ btn.label }}
        </button>
      </div>
    </header>

    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>수급자명</th>
            <th>만료일</th>
            <th>담당요양사</th>
            <th>연락시간</th>
            <th>D-Day</th>
            <th>안내여부</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="row in filteredItems"
            :key="row.id"
            :class="[
              'clickable-row',
              ddayClass(row.dday),
              row.id === selectedId ? 'is-active' : ''
            ]"
            @click="selectRow(row)"
          >
            <td>{{ row.name }}</td>
            <td>{{ row.expiryDate }}</td>
            <td>{{ row.worker }}</td>
            <td>{{ row.visitTime }}</td>
            <td>
              <span class="dday-pill">D-{{ row.dday }}</span>
            </td>
            <td>
              <span
                v-if="row.status === '완료'"
                class="status-pill complete"
              >
                완료 ({{ row.statusCount }}회)
              </span>
              <span v-else class="status-pill pending">미완료</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'

const props = defineProps({
  items: {
    type: Array,
    default: () => []
  },
  // 부모에서 v-model:selected-id 로 내려옴
  selectedId: {
    type: [Number, String, null],
    default: null
  }
})

const emit = defineEmits(['update:selectedId'])

const rangeButtons = [
  { key: 'all', label: '전체' },
  { key: '45', label: '45일 이내' },
  { key: '60', label: '60일 이내' },
  { key: '90', label: '90일 이내' }
]
const activeRange = ref('all')

const filteredItems = computed(() => {
  // 1) 등급 연장 예정이 아닌 대상은 리스트에서 제외
  let list = props.items.filter((i) => i.extendPlanned !== false)

  // 2) 일수 필터 적용
  if (activeRange.value === 'all') return list
  const limit = Number(activeRange.value)
  return list.filter((i) => i.dday <= limit)
})

const ddayClass = (dday) => {
  if (dday <= 45) return 'row-red'
  if (dday <= 60) return 'row-yellow'
  if (dday <= 90) return 'row-normal'
  return ''
}

const selectRow = (row) => {
  emit('update:selectedId', row.id)
}
</script>

<style scoped>
.longcare-wrap {
  background-color: #fff;
  border-radius: 12px;
  padding: 14px 16px;
  box-shadow: 0 0 0 1px rgba(15, 23, 42, 0.04);
}
.longcare-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}
.longcare-header h3 {
  margin: 0;
  font-size: 15px;
}
.filters {
  display: flex;
  gap: 4px;
}
.range-btn {
  border: 1px solid #e5e7eb;
  background: #f9fafb;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 11px;
  cursor: pointer;
}
.range-btn.active {
  background-color: #111827;
  color: #fff;
}

/* 테이블 */
.table-wrap {
  overflow-x: auto;
}
table {
  width: 100%;
  border-collapse: collapse;
  font-size: 12px;
}
thead th {
  text-align: left;
  padding: 8px 10px;
  background-color: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
}
tbody td {
  padding: 8px 10px;
  border-bottom: 1px solid #f3f4f6;
}

/* 행 색 */
.row-red {
  background-color: #fef2f2;
}
.row-yellow {
  background-color: #fff7ed;
}
.row-normal {
  background-color: #fefce8;
}

/* 선택 가능 행 */
.clickable-row {
  cursor: pointer;
}
.clickable-row.is-active {
  outline: 2px solid rgba(34, 197, 94, 0.6);
  outline-offset: -2px;
}

/* D-day / 상태 */
.dday-pill {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 999px;
  background-color: #fee2e2;
  color: #b91c1c;
  font-size: 10px;
}
.status-pill {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 999px;
  font-size: 10px;
}
.status-pill.complete {
  background-color: #dcfce7;
  color: #15803d;
}
.status-pill.pending {
  background-color: #f3f4f6;
  color: #6b7280;
}
</style>
