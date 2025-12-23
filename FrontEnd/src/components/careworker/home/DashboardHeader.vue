<script setup>
import { userProfile } from '@/mock/careworker/homeData';
</script>

<template>
  <header class="dashboard-header">
    <div class="user-info-container">
      <div class="user-avatar">
        <span class="avatar-icon">👤</span>
      </div>
      <div class="user-info">
        <h1 class="user-name">안녕하세요, {{ userProfile.name }} {{ userProfile.role }}님</h1>
        <p class="date">{{ userProfile.date }}</p>
      </div>
    </div>
    
    <div class="header-actions">
      <div class="notification-badge">
        <span class="bell-icon">🔔</span>
        <div class="noti-text">
          <span class="noti-name">{{ userProfile.name }} 요양보호사</span>
          <span class="noti-email">caregiving@welfare.com</span>
        </div>
        <div class="profile-circle">김</div>
      </div>
      <button class="logout-btn">
        <span class="logout-icon">↪</span> 로그아웃
      </button>
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
  font-size: 1.25rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.date {
  font-size: 0.875rem;
  color: #6b7280;
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