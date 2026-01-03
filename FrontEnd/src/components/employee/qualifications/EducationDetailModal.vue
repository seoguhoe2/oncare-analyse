<!-- 보수교육 상세 모달 -->
<script setup>
import { defineProps, defineEmits, onMounted, onUnmounted } from 'vue';

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
</script>

<template>
  <div v-if="isOpen" class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-box">
      <div class="modal-header">
        <h3>보수교육 상세 정보</h3>
        <button @click="$emit('close')" class="close-btn">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
        </button>
      </div>

      <div class="modal-body">
        <div class="banner green-banner">
          <div class="icon-circle green-circle">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><line x1="10" y1="9" x2="8" y2="9"/></svg>
          </div>
          <div>
            <h4 class="banner-title">{{ data.eduName }}</h4>
            <p class="banner-subtitle">{{ data.institution }}</p>
          </div>
        </div>

        <div class="info-grid">
          <div class="info-item">
            <span class="label">이수일</span>
            <span class="value">{{ data.eduDate }}</span>
          </div>
          <div class="info-item">
            <span class="label">다음 교육 예정일</span>
            <span class="value">{{ data.nextEduDate || '-' }}</span>
          </div>
          <div class="info-item">
            <span class="label">관련 자격증</span>
            <span class="value text-blue">{{ data.relatedCertName }}</span>
          </div>
          <div class="info-item">
             <span class="label">상태</span>
             <span v-if="data.status === 0" class="badge-green">이수 완료</span>
             <span v-else-if="data.status === 1" class="badge-red">미이수</span>
             <span v-else class="badge-gray">{{ data.status }}</span>
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
.green-banner { background-color: #f0fdf4; border-color: #dcfce7; }
.icon-circle { width: 48px; height: 48px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.green-circle { background-color: #4ade80; box-shadow: 0 4px 6px rgba(74, 222, 128, 0.2); }
.banner-title { margin: 0; font-size: 18px; font-weight: 700; color: #166534; }
.banner-subtitle { margin: 4px 0 0 0; font-size: 13px; color: #666; }

/* 그리드 */
.info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.info-item { background-color: #f9fafb; border: 1px solid #eee; border-radius: 8px; padding: 16px; }
.full-width { width: 100%; box-sizing: border-box; }
.label { display: block; font-size: 12px; color: #6b7280; margin-bottom: 4px; }
.value { display: block; font-size: 14px; color: #1f2937; font-weight: 500; }

.badge-yellow { background-color: #fef3c7; color: #b45309; padding: 4px 12px; border-radius: 6px; font-size: 13px; font-weight: 600; display: inline-block; }

/* 파일 박스 */
.file-box { background-color: #eff6ff; border: 1px solid #dbeafe; border-radius: 8px; padding: 16px; }
.file-row { display: flex; justify-content: space-between; align-items: center; }
.file-name { display: flex; align-items: center; gap: 6px; font-size: 14px; color: #1e40af; font-weight: 500; }
.file-icon { color: #3b82f6; }
.btn-download { display: flex; align-items: center; gap: 6px; background-color: #3b82f6; color: white; border: none; padding: 8px 16px; border-radius: 6px; font-size: 13px; font-weight: 500; cursor: pointer; transition: background 0.2s; }
.btn-download:hover { background-color: #2563eb; }

.modal-footer { padding: 20px; text-align: center; }
.btn-close { width: 100%; padding: 12px; background-color: #6b7280; color: white; border: none; border-radius: 8px; font-size: 15px; font-weight: 600; cursor: pointer; }
.btn-close:hover { background-color: #4b5563; }
</style>