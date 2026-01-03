<template>
  <div v-if="isOpen" class="dropdown-box">
    <div class="dropdown-header">
      <span class="header-title">알림</span>
      <span class="unread-pill" v-if="unreadCount > 0">{{ unreadCount }}개 읽지 않음</span>
    </div>

    <ul class="notification-list">
      
      <li v-if="notifications.length === 0" class="empty-message">
        새로운 알림이 없습니다.
      </li>

      <li 
        v-for="alarm in notifications" 
        :key="alarm.alarmId" 
        class="notification-item" 
        :class="{ unread: alarm.status === 'SENT' }"
        @click="openModal(alarm)"
      >
        <div class="item-left">
          <div class="dot-wrapper">
            <span class="dot" :class="getSeverityClass(alarm.severity)"></span>
          </div>
          
          <div class="content-wrapper">
            <p class="message">{{ alarm.title }}</p>
            <span class="time">{{ timeAgo(alarm.sentAt) }}</span>
          </div>
        </div>

        <button class="close-btn" @click.stop="$emit('read', alarm)">
          <Icon icon="line-md:close" width="18" height="18" />
        </button>
      </li>
    </ul>

    <!-- 알림 상세 모달 -->
    <NotificationDetailModal 
      :isOpen="showModal"
      :notification="selectedNotification"
      @close="closeModal"
      @read="$emit('read', selectedNotification)"
    />

  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Icon } from '@iconify/vue';
import NotificationDetailModal from './NotificationDetailModal.vue';

const props = defineProps({
  isOpen: Boolean,
  notifications: Array
})

// 부모에게 보낼 이벤트 정의
// read: X버튼 클릭 (삭제)
// click-item: 리스트 클릭 (이동)
// view-all: 전체보기 클릭
const emit = defineEmits(['read', 'view-all', 'click-item', 'mark-read'])

// 모달 상태
const showModal = ref(false)
const selectedNotification = ref(null)

const openModal = (alarm) => {
  selectedNotification.value = alarm;
  showModal.value = true;
  if (alarm.status === 'SENT') {
    emit('mark-read', alarm); 
  }
};

const closeModal = () => {
  showModal.value = false;
  selectedNotification.value = null;
};

// 읽지 않은 알림 개수 계산 (status가 'SENT'인 것)
const unreadCount = computed(() => props.notifications.filter(n => n.status === 'SENT').length)

// ★ 중요도(1, 2, 3)에 따른 점 색상 반환 함수
const getSeverityClass = (level) => {
  // level은 DB의 severity (1, 2, 3)
  switch (level) {
    case 1: 
      return 'dot-red';    // 1단계: 긴급 (빨강)
    case 2: 
      return 'dot-yellow'; // 2단계: 보통 (노랑)
    case 3: 
      return 'dot-blue';   // 3단계: 정보 (파랑)
    default: 
      return 'dot-gray';
  }
}

// 시간 포맷팅 함수 (예: 방금 전, 10분 전)
const timeAgo = (dateInput) => {
  if (!dateInput) return ''
  const diff = (new Date() - new Date(dateInput)) / 1000
  if (diff < 60) return '방금 전'
  if (diff < 3600) return `${Math.floor(diff / 60)}분 전`
  if (diff < 86400) return `${Math.floor(diff / 3600)}시간 전`
  return `${Math.floor(diff / 86400)}일 전`
}
</script>

<style scoped>
/* 드롭다운 박스 전체 스타일 */
.dropdown-box {
  position: absolute;
  top: 100%;
  right: -10px;
  width: 340px;
  background: white;
  border: 1px solid #eaeaea;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.08);
  z-index: 1000;
  margin-top: 12px;
  overflow: hidden;
  font-family: 'Pretendard', sans-serif;
}

/* 헤더 스타일 */
.dropdown-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #f1f1f1;
  background-color: #fff;
}
.header-title {
  font-size: 16px;
  font-weight: 700;
  color: #16a34a; /* 타이틀 녹색 */
}
.unread-pill {
  background: #fee2e2;
  color: #ef4444;
  font-size: 11px;
  font-weight: 600;
  padding: 4px 8px;
  border-radius: 12px;
}

/* 리스트 스타일 */
.notification-list {
  list-style: none;
  padding: 0;
  margin: 0;
  max-height: 400px;
  overflow-y: auto;
  background-color: #ffffff; /* 기본 배경 흰색 */
}

.empty-message {
  padding: 24px;
  text-align: center;
  color: #999;
  font-size: 13px;
}

/* 개별 아이템 스타일 */
.notification-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 16px 24px; /* 좌우 패딩을 조금 더 넓게 (사진 참고) */
  border-bottom: 1px solid #f3f4f6; /* 아주 연한 회색 라인 */
  cursor: pointer;
  background-color: white;
  transition: background-color 0.2s;
}

.notification-item:hover {
  background-color: #f9fafb;
}

/* 읽지 않은 알림 배경 강조 */
/* 사진과 비슷하게 아주 은은한 푸른/회색빛 배경 (가독성 좋게) */
.notification-item.unread { 
  background-color: #f8fafc; /* Slate-50 색상 */
}

/* 왼쪽 (점 + 텍스트) 그룹 */
.item-left {
  display: flex;
  gap: 14px; /* 간격 살짝 넓힘 */
  flex: 1;
}

/* 중요도 점 스타일 */
.dot-wrapper {
  padding-top: 6px; /* 텍스트 첫 줄과 정렬 */
}
.dot {
  display: block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
}
.dot-red { background: #ef4444; }
.dot-orange { background: #f97316; }
.dot-blue { background: #3b82f6; }
.dot-yellow { background: #eab308; } /* yellow 색상 추가/수정 */
.dot-gray { background: #d1d5db; }

/* 텍스트 컨텐츠 */
.content-wrapper {
  display: flex;
  flex-direction: column;
  gap: 6px; /* 줄 간격 약간 조정 */
}
.message {
  font-size: 14px;
  font-weight: 600; /* 제목을 더 굵게 (사진 참고) */
  color: #1f2937; /* 진한 회색 (Gray-800) */
  margin: 0;
  line-height: 1.4;
}
.time {
  font-size: 12px;
  color: #6b7280; /* 중간 회색 (Gray-500) */
  font-weight: 400;
}




/* 닫기(X) 버튼 스타일 */
.close-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  color: #9ca3af; /* Gray-400 */
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  transition: all 0.2s;
  margin-left: 8px; /* 왼쪽 내용과 간격 */
}


.close-btn:hover {
  color: #4b5563; /* Gray-600 */
  background-color: #f3f4f6;
}


</style>