<script setup>
</script>

<template>
  <div class="bottom-nav">
    <div class="nav-container">
      <router-link to="/care-home" class="nav-item" active-class="active">
        <span class="nav-icon">🏠</span>
        <span class="nav-text">홈</span>
      </router-link>

      <router-link to="/care-schedule" class="nav-item" active-class="active">
        <span class="nav-icon">📅</span>
        <span class="nav-text">근무 일정</span>
      </router-link>
      
      <router-link to="/care-log" class="nav-item" active-class="active">
        <span class="nav-icon">📝</span>
        <span class="nav-text">활동일지</span>
      </router-link>

      <router-link to="/care-recipient" class="nav-item" active-class="active">
        <span class="nav-icon">👥</span>
        <span class="nav-text">수급자 관리</span>
      </router-link>
    </div>
  </div>
</template>

<style scoped>
.bottom-nav {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: white;
  border-top: 1px solid #f3f4f6;
  padding: 0.75rem 0 1.5rem 0; /* 하단 안전 영역 고려 */
  z-index: 50;
  box-shadow: 0 -1px 3px rgba(0, 0, 0, 0.05);
}

.nav-container {
  display: flex;
  justify-content: space-around;
  max-width: 600px; /* 너무 넓게 퍼지지 않도록 */
  margin: 0 auto;
}

.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-decoration: none;
  color: #9ca3af;
  gap: 0.25rem;
  cursor: pointer;
  flex: 1;
}

.nav-item.active {
  color: #16a34a; /* 활성 상태 색상 */
}

.nav-icon {
  font-size: 1.5rem;
}

.nav-text {
  font-size: 0.75rem;
  font-weight: 700;
}
</style>