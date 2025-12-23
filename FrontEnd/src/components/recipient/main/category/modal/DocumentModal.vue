<template>
  <div v-if="modelValue" class="modal-backdrop" @click.self="close">
    <div class="modal-panel">
      <!-- 헤더 -->
      <header class="modal-header">
        <div class="title-row">
          <h3>문서 상세</h3>
          <button type="button" class="close-btn" @click="close">✕</button>
        </div>
      </header>

      <!-- 본문 -->
      <section class="modal-body" v-if="doc">
        <!-- 상단 문서 카드 -->
        <div class="doc-preview-card">
          <div class="doc-icon">
            📄
          </div>
          <div class="doc-title">
            {{ doc.name }}
          </div>
          <div class="doc-sub">
            {{ fileTypeLabel }} · {{ doc.size }}
          </div>
        </div>

        <!-- 메타 정보 -->
        <div class="meta-grid">
          <div class="meta-item">
            <div class="label">업로드 날짜</div>
            <div class="value">{{ doc.date || '-' }}</div>
          </div>
          <div class="meta-item">
            <div class="label">파일 크기</div>
            <div class="value">{{ doc.size || '-' }}</div>
          </div>
          <div class="meta-item">
            <div class="label">파일 형식</div>
            <div class="value">{{ fileTypeLabel }}</div>
          </div>
        </div>
      </section>

      <!-- 푸터 버튼 -->
      <footer class="modal-footer">
        <button
          type="button"
          class="btn btn-preview"
          @click="onPreview"
        >
          👁 미리보기
        </button>
        <button
          type="button"
          class="btn btn-download"
          @click="onDownload"
        >
          ⬇ 다운로드
        </button>
        <button
          type="button"
          class="btn btn-delete"
          @click="onDelete"
        >
          🗑 삭제
        </button>
      </footer>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  document: {
    type: Object,
    default: null
  }
})

const emit = defineEmits([
  'update:modelValue',
  'preview',
  'download',
  'delete'
])

const close = () => {
  emit('update:modelValue', false)
}

const doc = computed(() => props.document)

const fileTypeLabel = computed(() => {
  if (!doc.value) return 'PDF'
  // doc.type 이 있으면 사용, 없으면 이름에서 확장자 추출
  if (doc.value.type) return doc.value.type
  const name = doc.value.name || ''
  const ext = name.includes('.') ? name.split('.').pop() : ''
  return ext ? ext.toUpperCase() : 'PDF'
})

const onPreview = () => {
  emit('preview', doc.value)
}
const onDownload = () => {
  emit('download', doc.value)
}
const onDelete = () => {
  emit('delete', doc.value)
}
</script>

<style scoped>
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 50;
}

.modal-panel {
  width: 480px;
  max-height: 90vh;
  background: #ffffff;
  border-radius: 18px;
  box-shadow: 0 20px 40px rgba(15, 23, 42, 0.25);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 헤더 */
.modal-header {
  padding: 14px 20px 10px;
  border-bottom: 1px solid #e5e7eb;
}
.title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.title-row h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #166534;
}
.close-btn {
  border: none;
  background: transparent;
  font-size: 18px;
  cursor: pointer;
  color: #6b7280;
}

/* 본문 */
.modal-body {
  padding: 16px 20px 12px;
}

/* 상단 문서 카드 */
.doc-preview-card {
  border-radius: 16px;
  border: 1px solid #e5e7eb;
  background: #f9fafb;
  padding: 20px 16px;
  text-align: center;
  margin-bottom: 16px;
}
.doc-icon {
  font-size: 40px;
  margin-bottom: 12px;
}
.doc-title {
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 4px;
}
.doc-sub {
  font-size: 12px;
  color: #6b7280;
}

/* 메타 정보 */
.meta-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px 24px;
  padding: 6px 2px 0;
}
.meta-item .label {
  font-size: 11px;
  color: #6b7280;
  margin-bottom: 2px;
}
.meta-item .value {
  font-size: 13px;
  color: #111827;
}

/* 푸터 */
.modal-footer {
  padding: 12px 20px 16px;
  display: flex;
  gap: 8px;
  justify-content: space-between;
  border-top: 1px solid #e5e7eb;
}
.btn {
  flex: 1;
  border-radius: 999px;
  padding: 9px 0;
  border: none;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
}
.btn-preview {
  background: #2563eb;
  color: #ffffff;
}
.btn-download {
  background: #16a34a;
  color: #ffffff;
}
.btn-delete {
  background: #dc2626;
  color: #ffffff;
}

@media (max-width: 540px) {
  .modal-panel {
    width: 94vw;
  }
}
</style>
