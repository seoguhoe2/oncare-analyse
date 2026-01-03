<template>
  <section class="matching-panel">
    <header class="panel-header">
      <h2 class="panel-title">수급자</h2>
      <span class="count-badge">{{ total }}명</span>
    </header>

    <div class="search-bar">
      <img :src="searchIcon" class="search-icon" />
      <input v-model="search" type="text" placeholder="수급자 검색..." />
    </div>

    <div class="table-scroll">
      <table class="list-table">
        <tbody>
          <tr
            v-for="item in pagedList"
            :key="item.beneficiaryId ?? item.id"
            class="list-row"
            :class="{ selected: selectedBeneficiaryId === (item.beneficiaryId ?? item.id) }"
            @click="handleSelect(item)"
          >
            <td class="name">{{ item.name }}</td>
            <td>
              <span :class="badgeClass(item.gender)">
                {{ item.gender }}
              </span>
            </td>
            <td><span class="grade">{{ item.riskLevel }}</span></td>
            <td>
              <span v-if="item.assigned" class="assigned-badge">배정</span>
            </td>
          </tr>

          <tr v-if="!pagedList.length && !loading">
            <td colspan="4" class="dash">표시할 수급자가 없습니다.</td>
          </tr>

          <tr v-if="loading">
            <td colspan="4" class="dash">불러오는 중...</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="pagination">
      <button @click="prevPage" :disabled="page === 1">〈</button>
      <span>{{ page }} / {{ totalPages }}</span>
      <button @click="nextPage" :disabled="page >= totalPages">〉</button>
    </div>
  </section>
</template>

<script setup>
  import { ref, computed, onMounted, watch } from 'vue'
  import searchIcon from '@/assets/img/common/search.png'
  import { getBeneficiaryList } from '@/api/schedule/matching.js'
  import { useMatchingSelectionStore } from '@/stores/matchingSelection'
  
  const props = defineProps({
    refreshKey: { type: Number, default: 0 },
  })
  
  const emit = defineEmits(['select-recipient'])
  const store = useMatchingSelectionStore()
  
  const search = ref('')
  const page = ref(1)
  const pageSize = 8
  
  const recipientsRaw = ref([])
  const selectedBeneficiaryId = ref(null)
  
  const total = ref(0)
  const loading = ref(false)
  
  const getId = (item) => item?.beneficiaryId ?? item?.id ?? null
  
  const fetchList = async () => {
    loading.value = true
    try {
      const { data } = await getBeneficiaryList({
        page: page.value - 1,
        size: pageSize,
        keyword: search.value?.trim() || null,
      })
  
      const content = Array.isArray(data?.content) ? data.content : []
      recipientsRaw.value = content
      total.value = Number.isFinite(data?.total) ? data.total : 0
  
      const storeId = store.recipientId
      if (storeId) {
        const found = content.find((r) => getId(r) === storeId)
        if (found) {
          selectedBeneficiaryId.value = storeId
          store.syncRecipient(found)
          emit('select-recipient', found)
        }
      }
    } catch (e) {
      recipientsRaw.value = []
      total.value = 0
      console.error(e)
    } finally {
      loading.value = false
    }
  }
  
  onMounted(fetchList)
  
  watch(search, async () => {
    page.value = 1
    await fetchList()
  })
  
  watch(page, async () => {
    await fetchList()
  })
  
  watch(
    () => props.refreshKey,
    async () => {
      await fetchList()
    }
  )
  
  watch(
    () => store.recipientId,
    (id) => {
      selectedBeneficiaryId.value = id
    },
    { immediate: true }
  )
  
  const pagedList = computed(() => recipientsRaw.value)
  
  const totalPages = computed(() => {
    const tp = Math.ceil((total.value || 0) / pageSize)
    return Math.max(1, tp)
  })
  
  const prevPage = () => {
    if (page.value > 1) page.value--
  }
  
  const nextPage = () => {
    if (page.value < totalPages.value) page.value++
  }
  
  const handleSelect = (item) => {
    const beneficiaryId = getId(item)
    selectedBeneficiaryId.value = beneficiaryId
    emit('select-recipient', item)
  }
  
  const badgeClass = (gender) => ({
    badge: true,
    male: gender === '남자',
    female: gender === '여자',
  })
  </script>

<style scoped>
.matching-panel {
  background: #ffffff;
  border-radius: 16px;
  padding: 16px 20px;
  border: 1px solid #e5e7eb;
  box-shadow: 0 4px 12px rgba(15, 23, 42, 0.04);
  display: flex;
  flex-direction: column;
  height: 480px;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.panel-title {
  font-size: 20px;
  font-weight: 600;
  color: #1a5928;
}

.count-badge {
  padding: 4px 10px;
  background: #f3e8ff;
  border-radius: 999px;
  font-size: 13px;
  color: #9333ea;
}

.search-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
  background: #f9fafb;
  margin-bottom: 10px;
}

.search-icon {
  width: 16px;
  height: 16px;
  opacity: 0.6;
}

.search-bar input {
  flex: 1;
  border: none;
  background: transparent;
  font-size: 14px;
  outline: none;
}

.table-scroll {
  flex: 1;
  overflow: visible;
  padding-right: 0;
  max-height: none;
}

.list-table {
  width: 100%;
  border-collapse: collapse;
}

.list-row {
  cursor: pointer;
  transition: background-color 0.15s ease;
}
.list-row:hover {
  background: #f9fafb;
}

.list-row.selected {
  background: #ecfdf5;
}
.list-row.selected:hover {
  background: #d1fae5;
}
.list-row.selected td {
  font-weight: 600;
  color: #065f46;
}

.list-table td {
  padding: 10px 6px;
  border-bottom: 1px solid #f3f4f6;
  font-size: 15px;
}

.name {
  font-weight: 500;
}

.dash {
  color: #9ca3af;
  text-align: center;
}

.badge {
  padding: 3px 8px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 500;
}

.male {
  background: #e0f2fe;
  color: #0284c7;
}

.female {
  background: #fde2e8;
  color: #ec4899;
}

.grade {
  padding: 3px 10px;
  background: #f3e8ff;
  color: #9333ea;
  border-radius: 8px;
  font-size: 12px;
}

.assigned-badge {
  background: #dcfce7;
  color: #15803d;
  padding: 3px 10px;
  border-radius: 999px;
  font-size: 12px;
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 14px;
  padding-top: 8px;
}

.pagination button {
  border: none;
  background: transparent;
  font-size: 18px;
  cursor: pointer;
}
.pagination button:disabled {
  opacity: 0.3;
  cursor: not-allowed;
}

.pagination span {
  font-size: 14px;
}
</style>