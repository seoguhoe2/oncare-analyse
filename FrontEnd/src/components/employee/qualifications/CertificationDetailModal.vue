<!-- 자격증 상세 모달 -->
<script setup>
import { defineProps, defineEmits, computed, onMounted, onUnmounted } from 'vue';

const props = defineProps({
  isOpen: Boolean,
  data: { type: Object, default: () => ({}) }
});

const emit = defineEmits(['close']);

// 키보드 이벤트 핸들러
const handleKeydown = (e) => {
  if (!props.isOpen) return;

  if (e.key === 'Escape' || e.key === 'Enter') {
    emit('close');
  }
};

onMounted(() => {
  window.addEventListener('keydown', handleKeydown);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown);
});

const certificateInfo = computed(() => ({
  name: props.data?.certificateName || props.data?.name || '-',
  number: props.data?.licenseNo || props.data?.number || '-',
  issueDate: props.data?.issueDate || props.data?.date || '-',
  expireDate: props.data?.expireDate || props.data?.expirationDate || '-',
  organization: props.data?.organization || props.data?.issuer || '-',
  fileName: props.data?.fileName || props.data?.file || '',
  fileUrl: props.data?.fileUrl || props.data?.filePath || ''
}));

const getStatusInfo = (status) => {
  if (status === null || status === undefined) {
    return { label: '미지정', className: 'status-gray', rawText: '정보 없음' };
  }

  const normalized = typeof status === 'string' ? status.toLowerCase() : Number(status);

  if (normalized === 0 || normalized === 'valid' || normalized === '유효' || normalized === '승인') {
    return { label: '유효', className: 'status-green', rawText: String(status) };
  }
  if (normalized === 1 || normalized === 'expired' || normalized === '만료' || normalized === '반려') {
    return { label: '만료', className: 'status-red', rawText: String(status) };
  }
  if (normalized === 2 || normalized === 'pending' || normalized === '대기중' || normalized === '예정') {
    return { label: '대기중', className: 'status-yellow', rawText: String(status) };
  }

  return { label: typeof status === 'string' ? status : `상태 코드 ${status}`, className: 'status-gray', rawText: String(status) };
};

const statusInfo = computed(() => getStatusInfo(props.data?.status));
</script>

<template>
  <div v-if="isOpen" class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-box">
      <div class="modal-header">
        <h3>자격증 상세 정보</h3>
        <button @click="$emit('close')" class="close-btn">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
        </button>
      </div>

      <div class="modal-body">
        <div class="banner purple-banner">
          <div class="icon-circle purple-circle">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2"><path d="M12 15c-4 0-7-3-7-7 0-1.5.5-3 1.5-4C8 2.5 10 2 12 2s4 .5 5.5 2c1 1 1.5 2.5 1.5 4 0 4-3 7-7 7Z"/><path d="m8.21 13.89-7 23 12-3 12 3-7-23"/></svg>
        </div>
          <div>
            <h4 class="banner-title">{{ certificateInfo.name }}</h4>
            <p class="banner-subtitle">자격증 번호: {{ certificateInfo.number }}</p>
          </div>
          <div class="status-chip" :class="statusInfo.className">
            {{ statusInfo.label }}
          </div>
        </div>

        <div class="info-grid">
          <div class="info-item">
            <span class="label">발급일</span>
            <span class="value">{{ certificateInfo.issueDate || '-' }}</span>
          </div>
          <div class="info-item">
            <span class="label">발급기관</span>
            <span class="value">{{ certificateInfo.organization }}</span>
          </div>
          <div class="info-item">
            <span class="label">만료일</span>
            <span class="value">{{ certificateInfo.expireDate || '-' }}</span>
          </div>
          <div class="info-item">
            <span class="label">상태 코드</span>
            <span class="value">{{ statusInfo.rawText }}</span>
          </div>
        </div>


      </div>

      <div class="modal-footer">
        <button @click="$emit('close')" class="btn-close">닫기</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 100; }
.modal-box { background: white; width: 500px; border-radius: 12px; overflow: hidden; box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
.modal-header { padding: 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #eee; }
.modal-header h3 { margin: 0; font-size: 18px; font-weight: 700; color: #166534; }
.close-btn { background: none; border: none; cursor: pointer; color: #666; }

.modal-body { padding: 24px; display: flex; flex-direction: column; gap: 20px; }

/* 배너 스타일 */
.banner { padding: 20px; border-radius: 12px; display: flex; align-items: center; gap: 16px; border: 1px solid transparent; }
.purple-banner { background-color: #fcfaff; border-color: #f3e8ff; }
.icon-circle { width: 48px; height: 48px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.purple-circle { background-color: #a855f7; box-shadow: 0 4px 6px rgba(168, 85, 247, 0.2); }
.banner-title { margin: 0; font-size: 18px; font-weight: 700; color: #166534; }
.banner-subtitle { margin: 4px 0 0 0; font-size: 13px; color: #666; }
.status-chip { margin-left: auto; padding: 6px 12px; border-radius: 999px; font-size: 13px; font-weight: 600; color: #fff; }
.status-green { background-color: #22c55e; }
.status-yellow { background-color: #f59e0b; }
.status-red { background-color: #ef4444; }
.status-gray { background-color: #9ca3af; }

/* 그리드 스타일 */
.info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.info-item { background-color: #f9fafb; border: 1px solid #eee; border-radius: 8px; padding: 16px; }
.label { display: block; font-size: 12px; color: #6b7280; margin-bottom: 4px; }
.value { display: block; font-size: 14px; color: #1f2937; font-weight: 500; }

/* 파일 박스 */
.file-box { background-color: #eff6ff; border: 1px solid #dbeafe; border-radius: 8px; padding: 16px; }
.file-row { display: flex; justify-content: space-between; align-items: center; }
.file-name { display: flex; align-items: center; gap: 6px; font-size: 14px; color: #1e40af; font-weight: 500; }
.file-icon { color: #3b82f6; }
.btn-download { display: flex; align-items: center; gap: 6px; background-color: #3b82f6; color: white; border: none; padding: 8px 16px; border-radius: 6px; font-size: 13px; font-weight: 500; cursor: pointer; transition: background 0.2s; }
.btn-download:hover { background-color: #2563eb; }
.empty-file { font-size: 13px; color: #6b7280; text-align: center; padding: 12px 0; border: 1px dashed #d1d5db; border-radius: 8px; background-color: #fff; }

.modal-footer { padding: 20px; text-align: center; }
.btn-close { width: 100%; padding: 12px; background-color: #6b7280; color: white; border: none; border-radius: 8px; font-size: 15px; font-weight: 600; cursor: pointer; }
.btn-close:hover { background-color: #4b5563; }
</style>
