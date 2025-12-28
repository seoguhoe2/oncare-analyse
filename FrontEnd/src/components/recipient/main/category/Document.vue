<!-- src/components/recipient/main/category/Document.vue -->
<template>
  <div>
    <div class="files-header">
      총 {{ documents.length }}개의 문서
    </div>

    <div v-if="loading" class="empty">불러오는 중...</div>
    <div v-else-if="!documents.length" class="empty">서류가 없습니다.</div>

    <div v-else class="file-grid">
      <div
        v-for="doc in documents"
        :key="doc.formId"
        class="file-card"
        @click="openModal(doc)"
      >
        <div class="file-icon">📄</div>
        <div class="file-name">{{ doc.categoryName }}</div>
        <div class="file-meta">
          <span>{{ doc.fileSize }}</span>
          <span>· {{ doc.createdAt }}</span>
        </div>
      </div>
    </div>

    <DocumentModal
      v-model="showModal"
      :beneficiary-id="beneficiaryId"
      :form-id="selectedFormId"
      :document="selectedDocument"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import api from '@/lib/api'
import DocumentModal from './modal/DocumentModal.vue'

const props = defineProps({
  beneficiaryId: { type: [Number, String], required: true },
  refreshKey: Number
})

const loading = ref(false)
const documents = ref([])

const showModal = ref(false)
const selectedFormId = ref(null)
const selectedDocument = ref(null)

const fetchDocuments = async () => {
  if (!props.beneficiaryId) return
  loading.value = true
  try {
    const { data } = await api.get(`/api/beneficiaries/${props.beneficiaryId}/forms`)
    documents.value = Array.isArray(data) ? data : (data?.items ?? [])
  } catch (e) {
    console.error('서류 목록 조회 실패:', e)
    documents.value = []
  } finally {
    loading.value = false
  }
}

const openModal = (doc) => {
  selectedDocument.value = doc
  selectedFormId.value = doc?.formId ?? null
  showModal.value = true
}

onMounted(fetchDocuments)
watch(() => props.beneficiaryId, fetchDocuments)
watch(
  () => [props.beneficiaryId, props.refreshKey],
  () => {
    documents.value = []
    showModal.value = false
    selectedFormId.value = null
    selectedDocument.value = null
    fetchDocuments()
  }
  // },
  // { immediate: true }
)
</script>

<style scoped>
.files-header {
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 6px;
}

.file-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  gap: 10px;
}

.file-card {
  border-radius: 12px;
  padding: 10px 8px;
  background-color: #f9fafb;
  text-align: left;
  font-size: 12px;
  cursor: pointer;
}

.file-card:hover {
  background-color: #e5f2ff;
}

.file-icon {
  font-size: 20px;
  position: relative;
  margin-bottom: 4px;
}

.file-name {
  font-weight: 500;
  margin-bottom: 2px;
}

.file-meta {
  font-size: 11px;
  color: #6b7280;
}

.empty {
  padding: 12px;
  border-radius: 10px;
  background: #f9fafb;
  color: #6b7280;
  font-size: 12px;
}
</style>
