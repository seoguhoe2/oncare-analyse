<script setup>
import { computed } from 'vue';
import { useUserStore } from '@/stores/user';
import { useRouter } from 'vue-router';

const userStore = useUserStore();
const router = useRouter();

// 사용자 정보를 Pinia store에서 가져옴
const userName = computed(() => userStore.name || '사용자');
const userRole = computed(() => userStore.jobName || '요양보호사');
const userEmail = computed(() => userStore.email || '');

// 현재 날짜 포맷팅
const currentDate = computed(() => {
  const today = new Date();
  const options = { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' };
  return today.toLocaleDateString('ko-KR', options);
});

// 이름의 첫 글자 (프로필 서클용)
const nameInitial = computed(() => {
  return userName.value.charAt(0);
});

// 로그아웃 처리
const handleLogout = () => {
  userStore.logOut();
  router.push({ name: 'signin' });
};
</script>

<template>
  <header class="dashboard-header">
    <div class="user-info-container">
      <div class="user-info">
        <h1 class="user-name">
          <span class="greeting-text">안녕하세요, </span>
          <span class="name-text">{{ userName }}</span>
          <span class="greeting-text"> {{ userRole }}님</span>
        </h1>
        <p class="date">{{ currentDate }}</p>
      </div>
    </div>

  </header>
</template>

<style scoped>
.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: white;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid #f3f4f6;
}

.user-info-container {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.user-avatar {
  width: 3rem;
  height: 3rem;
  background-color: #4ade80; /* 연두색 배경 */
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.avatar-icon {
  font-size: 1.5rem;
  color: white;
}

.user-info {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-size: 30px;
  font-weight: 600;
  margin: 0;
}

.greeting-text {
  color: #000000;
}

.name-text {
  color: #1a5928;
}

.date {
  font-size: 14px;
  color: #4a5565;
  margin: 0.25rem 0 0 0;
}

/* 우측 상단 영역 (알림, 프로필, 로그아웃) */
.header-actions {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.notification-badge {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  border: 1px dashed #3b82f6; /* 파란 점선 테두리 */
  padding: 0.5rem 1rem;
  border-radius: 9999px;
  background-color: #f0f9ff;
}

.bell-icon {
  font-size: 1.25rem;
  color: #1f2937;
}

.noti-text {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.noti-name {
  font-size: 0.75rem;
  font-weight: 700;
  color: #1f2937;
}

.noti-email {
  font-size: 0.65rem;
  color: #6b7280;
}

.profile-circle {
  width: 2rem;
  height: 2rem;
  background-color: #4ade80;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.875rem;
}

.logout-btn {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  background: white;
  border: 1px solid #e5e7eb;
  padding: 0.5rem 1rem;
  border-radius: 0.5rem;
  font-size: 0.875rem;
  color: #4b5563;
  cursor: pointer;
}

.logout-icon {
  font-size: 1rem;
}

@media (max-width: 768px) {
  .dashboard-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
  
  .header-actions {
    width: 100%;
    justify-content: space-between;
  }
  
  .notification-badge {
    padding: 0.25rem 0.5rem;
  }
  
  .noti-text {
    display: none; /* 모바일에서는 텍스트 숨김 */
  }
}
</style>