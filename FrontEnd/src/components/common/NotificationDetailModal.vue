<template>
  <div v-if="isOpen && notification" class="modal-overlay" @click="$emit('close')">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h3 class="modal-title">{{ notification.title }}</h3>
        <button class="modal-close-btn" @click="$emit('close')">
           <Icon icon="line-md:close" width="24" height="24" />
        </button>
      </div>
      <div class="modal-body">
        <p class="modal-message">{{ notification.content }}</p>
        <div class="modal-meta">
          <span class="modal-time">{{ timeAgo(notification.sentAt) }}</span>
          <span class="modal-status" :class="getSeverityClass(notification.severity)">
             {{ getSeverityText(notification.severity) }}
          </span>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn-confirm" @click="$emit('close')">확인</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineProps, defineEmits, onMounted, onUnmounted, watch } from 'vue';
import { Icon } from '@iconify/vue';

const props = defineProps({
  isOpen: Boolean,
  notification: Object
});

const emit = defineEmits(['close']);

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

// 중요도(1, 2, 3)에 따른 점 색상 반환 함수 (NotificationList.vue와 동일 로직)
const getSeverityClass = (level) => {
  switch (level) {
    case 1: return 'dot-red';    // 1단계: 긴급
    case 2: return 'dot-yellow'; // 2단계: 보통
    case 3: return 'dot-blue';   // 3단계: 정보
    default: return 'dot-gray';
  }
};

const getSeverityText = (level) => {
    switch (level) {
    case 1: return '긴급';
    case 2: return '알림'; 
    case 3: return '정보';
    default: return '기타';
  }
};

// 시간 포맷팅 함수
const timeAgo = (dateInput) => {
  if (!dateInput) return '';
  const diff = (new Date() - new Date(dateInput)) / 1000;
  if (diff < 60) return '방금 전';
  if (diff < 3600) return `${Math.floor(diff / 60)}분 전`;
  if (diff < 86400) return `${Math.floor(diff / 3600)}시간 전`;
  return `${Math.floor(diff / 86400)}일 전`;
};
</script>

<style scoped>
/* 모달 스타일 */
.modal-overlay {
  position: fixed; top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.5); z-index: 2000; /* Dropdown보다 높게 */
  display: flex; justify-content: center; align-items: center;
  backdrop-filter: blur(2px);
}
.modal-content {
  background: white; width: 90%; max-width: 400px;
  border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);
  overflow: hidden; animation: fadeIn 0.2s ease-out;
}
@keyframes fadeIn {
    from { opacity: 0; transform: scale(0.95); }
    to { opacity: 1; transform: scale(1); }
}
.modal-header {
  padding: 16px 20px; border-bottom: 1px solid #eee;
  display: flex; justify-content: space-between; align-items: center;
}
.modal-title { font-size: 16px; font-weight: 700; color: #111; margin: 0; }
.modal-close-btn { background: none; border: none; cursor: pointer; color: #999; }
.modal-close-btn:hover { color: #333; }

.modal-body { padding: 24px 20px; }
.modal-message { font-size: 14px; color: #333; line-height: 1.5; margin: 0 0 16px 0; }

.modal-meta { display: flex; justify-content: space-between; font-size: 12px; color: #888; align-items: center; }
.modal-status { padding: 2px 8px; border-radius: 4px; color: white; font-weight: 600; font-size: 11px; }
.modal-status.dot-red { background: #ef4444; }
.modal-status.dot-yellow { background: #eab308; }
.modal-status.dot-blue { background: #3b82f6; }
.modal-status.dot-gray { background: #d1d5db; }

.modal-footer {
  padding: 12px 20px; background: #f9fafb; border-top: 1px solid #eee;
  text-align: right;
}
.btn-confirm {
  background: #16a34a; color: white; border: none; padding: 8px 16px;
  border-radius: 6px; font-weight: 600; cursor: pointer; font-size: 13px;
}
.btn-confirm:hover { background: #15803d; }
</style>
