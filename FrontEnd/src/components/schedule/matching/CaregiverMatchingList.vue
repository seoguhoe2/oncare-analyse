<template>
  <section class="matching-panel">
    <header class="panel-header">
      <h2 class="panel-title">요양보호사</h2>
      <span class="count-badge">{{ total }}명</span>
    </header>

    <div class="search-bar">
      <img :src="searchIcon" class="search-icon" />
      <input v-model="search" type="text" placeholder="요양보호사 검색..." />
    </div>

    <div v-if="loading" class="loading">불러오는 중...</div>
    <div v-else-if="error" class="error">{{ error }}</div>

    <div v-else class="table-scroll">
      <table class="list-table">
        <tbody>
          <tr
            v-for="item in pagedList"
            :key="item.careWorkerId ?? item.id"
            class="list-row"
            :class="{ selected: selectedCareWorkerId === (item.careWorkerId ?? item.id) }"
            @click="handleSelect(item)"
          >
            <td class="name">{{ item.name }}</td>
            <td>
              <span :class="badgeClass(item.gender)">
                {{ item.gender }}
              </span>
            </td>
            <td>
              <div class="tags">
                <span v-for="tag in item.tags" :key="tag" class="tag">
                  {{ tag }}
                </span>
              </div>
            </td>
          </tr>

          <tr v-if="!pagedList.length && !loading">
            <td colspan="3" class="dash">표시할 요양보호사가 없습니다.</td>
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
  import { ref, computed, watch } from 'vue'
  import searchIcon from '@/assets/img/common/search.png'
  import {
    getCandidateCareWorkerCards,
    getCreateVisitAvailableCareWorkerCards,
  } from '@/api/schedule/matching.js'
  import { useMatchingSelectionStore } from '@/stores/matchingSelection'
  
  const props = defineProps({
    recipient: { type: Object, default: null },
    startDt: { type: String, default: '' },
    endDt: { type: String, default: '' },
    serviceTypeId: { type: Number, default: null },
    refreshKey: { type: Number, default: 0 },
  })
  
  const emit = defineEmits(['select-caregiver'])
  const store = useMatchingSelectionStore()
  
  const search = ref('')
  const page = ref(1)
  const pageSize = 8
  
  const loading = ref(false)
  const error = ref('')
  const caregiversRaw = ref([])
  const total = ref(0)
  
  const selectedCareWorkerId = ref(null)
  const autoPickedKey = ref('')
  
  const getCareWorkerId = (obj) => obj?.careWorkerId ?? obj?.id ?? null
  const getBeneficiaryId = (obj) => obj?.beneficiaryId ?? obj?.id ?? null
  
  const beneficiaryId = computed(() => getBeneficiaryId(props.recipient))
  
  const isCreateVisitMode = computed(() => Boolean(props.startDt && props.endDt && props.serviceTypeId))
  
  const normalizeList = (list) =>
    (Array.isArray(list) ? list : []).map((c) => ({
      careWorkerId: getCareWorkerId(c),
      name: c?.name ?? '-',
      gender: c?.gender ?? '-',
      tags: Array.isArray(c?.tags) ? c.tags : [],
    }))
  
  const pickPage = (resData) => {
    if (resData && Array.isArray(resData.content)) {
      return {
        content: normalizeList(resData.content),
        total: Number.isFinite(resData.total) ? resData.total : resData.content.length,
      }
    }
    if (Array.isArray(resData)) {
      const list = normalizeList(resData)
      return { content: list, total: list.length }
    }
    if (resData && Array.isArray(resData.data)) {
      const list = normalizeList(resData.data)
      return { content: list, total: list.length }
    }
    return { content: [], total: 0 }
  }
  
  const loadCareWorkers = async () => {
    if (!beneficiaryId.value) {
      caregiversRaw.value = []
      total.value = 0
      error.value = ''
      selectedCareWorkerId.value = null
      return
    }
  
    try {
      loading.value = true
      error.value = ''
  
      const keyword = search.value?.trim() || null
  
      const res = isCreateVisitMode.value
        ? await getCreateVisitAvailableCareWorkerCards({
            beneficiaryId: beneficiaryId.value,
            startDt: props.startDt,
            endDt: props.endDt,
            serviceTypeId: props.serviceTypeId,
            page: page.value - 1,
            size: pageSize,
            keyword,
          })
        : await getCandidateCareWorkerCards({
            beneficiaryId: beneficiaryId.value,
            page: page.value - 1,
            size: pageSize,
            keyword,
          })
  
      const { content, total: t } = pickPage(res?.data)
      caregiversRaw.value = content
      total.value = t
  
      const assigned = props.recipient?.assignedCareWorker
      const assignedId = getCareWorkerId(assigned)
  
      if (assignedId) {
        selectedCareWorkerId.value = assignedId
        emit('select-caregiver', assigned)
        return
      }
  
      const storeId = store.caregiverId
      if (storeId) {
        const found = content.find((c) => c.careWorkerId === storeId)
        if (found) {
          selectedCareWorkerId.value = storeId
          emit('select-caregiver', found)
          return
        }
      }
  
      const key = `${beneficiaryId.value}-${props.startDt || ''}-${props.endDt || ''}-${props.serviceTypeId || ''}`
      if (autoPickedKey.value !== key) {
        autoPickedKey.value = key
        const first = content[0] || null
        if (first) {
          selectedCareWorkerId.value = first.careWorkerId
          emit('select-caregiver', first)
        } else {
          selectedCareWorkerId.value = null
        }
      }
    } catch (e) {
      caregiversRaw.value = []
      total.value = 0
      error.value = e?.response?.data?.message || '요양보호사 목록을 불러오지 못했습니다.'
    } finally {
      loading.value = false
    }
  }
  
  watch(
    () => [beneficiaryId.value, props.startDt, props.endDt, props.serviceTypeId],
    () => {
      page.value = 1
      search.value = ''
      autoPickedKey.value = ''
      loadCareWorkers()
    },
    { immediate: true }
  )
  
  watch(search, () => {
    page.value = 1
    loadCareWorkers()
  })
  
  watch(page, () => {
    loadCareWorkers()
  })
  
  watch(
    () => props.refreshKey,
    () => {
      autoPickedKey.value = ''
      loadCareWorkers()
    }
  )
  
  watch(
    () => store.caregiverId,
    (id) => {
      selectedCareWorkerId.value = id
    },
    { immediate: true }
  )
  
  const pagedList = computed(() => caregiversRaw.value)
  
  const totalPages = computed(() => Math.max(1, Math.ceil((total.value || 0) / pageSize)))
  
  const prevPage = () => {
    if (page.value > 1) page.value--
  }
  
  const nextPage = () => {
    if (page.value < totalPages.value) page.value++
  }
  
  const handleSelect = (item) => {
    const careWorkerId = getCareWorkerId(item)
    selectedCareWorkerId.value = careWorkerId
    emit('select-caregiver', item)
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

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.tag {
  background: #dcfce7;
  color: #15803d;
  padding: 3px 8px;
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