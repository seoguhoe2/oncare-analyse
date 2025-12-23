<!-- 수급자 목록(필터링 컴포 포함) -->
 <!-- src/components/recipient/RecipientList.vue -->
<template>
  <div class="filter-card">
    <!-- 검색 -->
    <div class="search-box">
      <input
        v-model="searchText"
        type="text"
        placeholder="이름, 연락처, 주소 검색..."
      />
    </div>

    <!-- 1차 필터 -->
    <div class="filter-group">
      <button class="filter-header" type="button" @click="toggle('first')">
        <span>1차 필터</span>
        <span class="arrow" :class="{ open: open.first }">⌃</span>
      </button>
      <div v-if="open.first" class="filter-body">
        <select v-model="firstFilter">
          <option value="">제한 없음</option>
          <option value="서비스 중">서비스 중</option>
          <option value="서비스 중지">서비스 중지</option>
        </select>
      </div>
    </div>

    <!-- 2차 필터 -->
    <div class="filter-group">
      <button class="filter-header" type="button" @click="toggle('second')">
        <span>2차 필터</span>
        <span class="arrow" :class="{ open: open.second }">⌃</span>
      </button>
      <div v-if="open.second" class="filter-body">
        <select v-model="riskFilter">
          <option value="">위험등급 - 전체</option>
          <option value="고위험">고위험</option>
          <option value="중위험">중위험</option>
          <option value="저위험">저위험</option>
        </select>
        <select v-model="careLevelFilter">
          <option value="">장기요양등급 - 전체</option>
          <option v-for="n in 5" :key="n" :value="n">{{ n }}등급</option>
          <option value="인지지원등급">인지지원등급</option>
        </select>
      </div>
    </div>

    <!-- 정렬 기준 -->
    <div class="filter-group">
      <div class="filter-header no-btn">
        <span>정렬 기준</span>
      </div>
      <div class="filter-body">
        <select v-model="sortKey">
          <option value="name">이름순</option>
          <option value="risk">위험도순</option>
          <option value="careLevel">장기요양등급순</option>
        </select>
      </div>
    </div>

    <div class="list-count">
      총 {{ filteredList.length }}명
    </div>

    <!-- 목록 -->
    <div class="list-card">
      <div class="list-scroll">
        <button
          v-for="r in pagedList"
          :key="r.id"
          type="button"
          class="recipient-item"
          :class="{ active: r.id === selectedId }"
          @click="$emit('update:selectedId', r.id)"
        >
          <div class="row-top">
            <span class="name">{{ r.name }}</span>
            <span class="badge status" :class="riskClass(r.risk)">
              {{ r.risk }}
            </span>
          </div>
          <div class="row-middle">
            <span class="meta">{{ r.careLevel }}등급 · 담당: {{ r.careWorker }}</span>
          </div>
          <div class="row-bottom">
            <span class="tag tag-level">장기요양 {{ r.careLevel }}등급</span>
            <span class="tag tag-service">{{ r.serviceType }}</span>
          </div>
        </button>
      </div>

      <!-- 간단 페이지 사이즈 -->
      <div class="pagination">
        <div class="page-info">
          1 / 1
        </div>
        <div class="page-size">
          <button
            v-for="size in [10, 15, 20, 30]"
            :key="size"
            type="button"
            class="page-size-btn"
            :class="{ active: pageSize === size }"
            @click="pageSize = size"
          >
            {{ size }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'

const props = defineProps({
  recipients: {
    type: Array,
    required: true
  },
  selectedId: {
    type: Number,
    default: null
  }
})
defineEmits(['update:selectedId'])

const searchText = ref('')
const firstFilter = ref('')
const riskFilter = ref('')
const careLevelFilter = ref('')
const sortKey = ref('name')
const pageSize = ref(10)

const open = ref({ first: true, second: true })
const toggle = (key) => (open.value[key] = !open.value[key])

const filteredList = computed(() => {
  let list = props.recipients

  const q = searchText.value.trim().toLowerCase()
  if (q) {
    list = list.filter((r) =>
      [r.name, r.phone, r.address].some((field) =>
        String(field || '')
          .toLowerCase()
          .includes(q)
      )
    )
  }

  const risk = firstFilter.value || riskFilter.value
  if (risk) {
    list = list.filter((r) => r.risk === risk)
  }
  if (careLevelFilter.value) {
    list = list.filter((r) => String(r.careLevel) === String(careLevelFilter.value))
  }

  // 정렬
  const sorted = [...list]
  if (sortKey.value === 'name') {
    sorted.sort((a, b) => a.name.localeCompare(b.name, 'ko'))
  } else if (sortKey.value === 'careLevel') {
    sorted.sort((a, b) => a.careLevel - b.careLevel)
  } else if (sortKey.value === 'risk') {
    const order = { 고위험: 1, 중위험: 2, 저위험: 3 }
    sorted.sort((a, b) => (order[a.risk] || 99) - (order[b.risk] || 99))
  }

  return sorted
})

const pagedList = computed(() => filteredList.value.slice(0, pageSize.value))

const riskClass = (risk) => ({
  'risk-high': risk === '고위험',
  'risk-mid': risk === '중위험',
  'risk-low': risk === '저위험'
})
</script>

<style scoped>
.filter-card {
  background-color: #fff;
  border-radius: 12px;
  padding: 14px;
  box-shadow: 0 0 0 1px rgba(15, 23, 42, 0.04);
}

/* 검색창 */
.search-box {
  margin-bottom: 6px;
}
.search-box input {
  width: 100%;
  padding: 4px 8px;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  font-size: 12px;
  box-sizing: border-box;
}

/* 필터 */
.filter-group {
  margin-top: 8px;
}
.filter-header {
  width: 100%;
  border: none;
  background: transparent;
  padding: 4px 2px;
  font-size: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
  color: #6b7280;
}
.filter-header.no-btn {
  cursor: default;
}
.filter-body {
  margin-top: 4px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.filter-body select {
  width: 100%;
  padding: 4px 8px;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  font-size: 12px;
}
.arrow {
  font-size: 10px;
  transition: transform 0.15s;
}
.arrow.open {
  transform: rotate(180deg);
}

.list-count {
  margin-top: 10px;
  font-size: 11px;
  color: #9ca3af;
}

/* 리스트 카드 */
.list-card {
  margin-top: 8px;
  background-color: #fff;
  border-radius: 12px;
  padding: 10px 10px 8px;
  box-shadow: 0 0 0 1px rgba(15, 23, 42, 0.04);
}
.list-scroll {
  max-height: 360px;
  overflow-y: auto;
  padding-right: 4px;
}
.recipient-item {
  width: 100%;
  border: none;
  background: #fff;
  border-radius: 10px;
  padding: 8px 10px;
  margin-bottom: 6px;
  text-align: left;
  cursor: pointer;
  transition: background-color 0.15s, box-shadow 0.15s;
}
.recipient-item:hover {
  background-color: #f3f4f6;
}
.recipient-item.active {
  background-color: #e9f8f0;
  box-shadow: 0 0 0 1px #22c55e33;
}
.row-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.name {
  font-size: 14px;
  font-weight: 600;
}
.row-middle {
  margin-top: 2px;
}
.meta {
  font-size: 11px;
  color: #9ca3af;
}
.row-bottom {
  margin-top: 4px;
  display: flex;
  gap: 4px;
  flex-wrap: wrap;
}
.tag {
  padding: 2px 8px;
  border-radius: 999px;
  font-size: 10px;
}
.tag-level {
  background-color: #ecfdf3;
  color: #15803d;
}
.tag-service {
  background-color: #e0f2fe;
  color: #1d4ed8;
}

/* 위험도 배지 */
.badge {
  padding: 2px 8px;
  border-radius: 999px;
  font-size: 10px;
}
.status.risk-high {
  background-color: #fee2e2;
  color: #b91c1c;
}
.status.risk-mid {
  background-color: #fef3c7;
  color: #92400e;
}
.status.risk-low {
  background-color: #e0f2fe;
  color: #1d4ed8;
}

/* 페이지네이션 */
.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 6px;
  font-size: 11px;
}
.page-size {
  display: flex;
  gap: 4px;
}
.page-size-btn {
  border: none;
  background: #f3f4f6;
  padding: 2px 6px;
  border-radius: 6px;
  font-size: 11px;
  cursor: pointer;
}
.page-size-btn.active {
  background-color: #22c55e;
  color: #fff;
}
</style>
