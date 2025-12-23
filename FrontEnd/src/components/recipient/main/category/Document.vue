<!-- src/components/recipient/category/Document.vue -->
<template>
  <div>
    <div class="files-header">
      총 {{ documents.length }}개의 문서
    </div>
    <div class="file-grid">
      <div
        v-for="doc in documents"
        :key="doc.id"
        class="file-card"
        @click="openModal(doc)"
      >
        <div class="file-icon">
          📄
          <span class="file-status-dot" :class="doc.statusClass"></span>
        </div>
        <div class="file-name">{{ doc.name }}</div>
        <div class="file-meta">
          <span>{{ doc.size }}</span>
          <span>· {{ doc.date }}</span>
        </div>
      </div>
    </div>

    <!-- ✅ 문서 상세 모달 -->
    <DocumentModal
      v-model="showModal"
      :document="selectedDocument"
      @preview="handlePreview"
      @download="handleDownload"
      @delete="handleDelete"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import DocumentModal from './modal/DocumentModal.vue'

const documents = ref([
  {
    id: 1,
    name: '방문요양 업무수행일지',
    size: '124KB',
    date: '2024-11-15',
    type: 'PDF',
    statusClass: 'status-red'
  },
  {
    id: 2,
    name: '장기요양급여 제공기록지(방문요양)',
    size: '500KB',
    date: '2024-11-10',
    type: 'PDF',
    statusClass: 'status-green'
  },
  {
    id: 3,
    name: '개인정보 수집 및 이용 동의서',
    size: '420KB',
    date: '2024-10-20',
    type: 'PDF',
    statusClass: 'status-blue'
  }
])

const showModal = ref(false)
const selectedDocument = ref(null)

const openModal = (doc) => {
  selectedDocument.value = doc
  showModal.value = true
}

const handlePreview = (doc) => {
  console.log('미리보기 클릭:', doc)
  // TODO: 파일 미리보기 로직 연결
}

const handleDownload = (doc) => {
  console.log('다운로드 클릭:', doc)
  // TODO: 파일 다운로드 로직 연결
}

const handleDelete = (doc) => {
  console.log('삭제 클릭:', doc)
  // TODO: 삭제 확인 모달 or API 연동
}
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
.file-status-dot {
  position: absolute;
  right: -2px;
  top: -2px;
  width: 10px;
  height: 10px;
  border-radius: 999px;
  border: 2px solid #f9fafb;
}
.status-red {
  background-color: #ef4444;
}
.status-green {
  background-color: #22c55e;
}
.status-blue {
  background-color: #3b82f6;
}
.file-name {
  font-weight: 500;
  margin-bottom: 2px;
}
.file-meta {
  font-size: 11px;
  color: #6b7280;
}
</style>
