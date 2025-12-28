<!-- src/components/recipient/main/category/modal/DocumentModal.vue -->
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
          <div class="doc-icon">📄</div>

          <!-- ✅ 모달 제목: originalFileName -->
          <div class="doc-title">
            {{ doc.originalFileName || '-' }}
          </div>

          <!-- ✅ 파일형식 · 파일크기 -->
          <div class="doc-sub">
            {{ mimeLabel }} · {{ doc.fileSize || '-' }}
          </div>
        </div>

        <!-- 메타 정보 -->
        <div class="meta-grid">
          <div class="meta-item">
            <div class="label">업로드 날짜</div>
            <div class="value">{{ doc.createdAt || '-' }}</div>
          </div>

          <div class="meta-item">
            <div class="label">파일 크기</div>
            <div class="value">{{ doc.fileSize || '-' }}</div>
          </div>

          <div class="meta-item">
            <div class="label">파일 형식</div>
            <div class="value">{{ mimeLabel }}</div>
          </div>
        </div>

        <div v-if="errorMsg" class="error-box">
          {{ errorMsg }}
        </div>
      </section>

      <!-- 푸터 버튼 -->
      <footer class="modal-footer">
        <button type="button" class="btn btn-preview" @click="onPreview" :disabled="busy">
          👁 미리보기
        </button>
        <button type="button" class="btn btn-download" @click="onDownload" :disabled="busy">
          ⬇ 다운로드
        </button>
      </footer>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import api from '@/lib/api'

const props = defineProps({
  modelValue: { type: Boolean, default: false },

  beneficiaryId: { type: [Number, String], required: true },
  formId: { type: [Number, String], default: null },

  // ✅ 목록에서 받은 FormListItem(메타 표시용)
  document: { type: Object, default: null }
})

const emit = defineEmits(['update:modelValue'])

const errorMsg = ref('')
const busy = ref(false)

const close = () => {
  emit('update:modelValue', false)
}

const doc = computed(() => props.document)

const mimeLabel = computed(() => {
  const mime = doc.value?.mimeType || ''
  return mime ? mime : 'application/pdf'
})

// 모달 열릴 때마다 에러 초기화
watch(
  () => props.modelValue,
  (open) => {
    if (open) errorMsg.value = ''
  }
)

// ✅ 미리보기: 새 탭 열기 (inline)
//const onPreview = () => {
//  if (!props.beneficiaryId || !props.formId) return
//  // 백엔드가 Content-Disposition inline으로 내려주므로 새 탭에서 바로 보기 좋음
//  const url = `/api/beneficiaries/${props.beneficiaryId}/forms/${props.formId}/preview`
//  window.open(url, '_blank')
//}
const onPreview = async () => {
  if (!props.beneficiaryId || !props.formId) return
  busy.value = true
  errorMsg.value = ''

  try {
    // baseURL이 이미 /api면 앞의 /api 제거해서 맞춰야 함(아래 path는 상황에 맞게!)
    const path = `/api/beneficiaries/${props.beneficiaryId}/forms/${props.formId}/preview`

    const res = await api.get(path, { responseType: 'blob' })

    const blob = new Blob([res.data], { type: res.headers?.['content-type'] || 'application/pdf' })
    const objectUrl = window.URL.createObjectURL(blob)

    window.open(objectUrl, '_blank')

    // 너무 빨리 revoke하면 새탭이 못 읽을 수 있어서 약간 딜레이
    setTimeout(() => window.URL.revokeObjectURL(objectUrl), 10_000)
  } catch (e) {
    console.error('미리보기 실패:', e)
    errorMsg.value = '미리보기에 실패했습니다.'
  } finally {
    busy.value = false
  }
}



// ✅ 다운로드: blob 받아서 저장
const onDownload = async () => {
  if (!props.beneficiaryId || !props.formId) return
  busy.value = true
  errorMsg.value = ''

  try {
    const url = `/api/beneficiaries/${props.beneficiaryId}/forms/${props.formId}/download`
    const res = await api.get(url, { responseType: 'blob' })

    const blob = new Blob([res.data], { type: res.headers?.['content-type'] || 'application/octet-stream' })
    const objectUrl = window.URL.createObjectURL(blob)

    const a = document.createElement('a')
    a.href = objectUrl
    a.download = doc.value?.originalFileName || 'download'
    document.body.appendChild(a)
    a.click()
    a.remove()

    window.URL.revokeObjectURL(objectUrl)
  } catch (e) {
    console.error('다운로드 실패:', e)
    errorMsg.value = '다운로드에 실패했습니다.'
  } finally {
    busy.value = false
  }
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

.error-box {
  margin-top: 12px;
  padding: 12px;
  border-radius: 12px;
  background: #fef2f2;
  color: #991b1b;
  font-size: 12px;
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
.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
.btn-preview {
  background: #2563eb;
  color: #ffffff;
}
.btn-download {
  background: #16a34a;
  color: #ffffff;
}

@media (max-width: 540px) {
  .modal-panel {
    width: 94vw;
  }
}
</style>
