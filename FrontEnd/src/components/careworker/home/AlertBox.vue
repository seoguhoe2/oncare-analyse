<script setup>
import { ref, onMounted } from 'vue';
import { getUrgentNotifications } from '@/api/careworker';

const notifications = ref([]);
const loading = ref(true);

onMounted(async () => {
  try {
    const response = await getUrgentNotifications();
    notifications.value = response.data || [];
  } catch (error) {
    console.error('긴급 알림 로드 실패:', error);
  } finally {
    loading.value = false;
  }
});
</script>

<template>
  <section class="alert-section">
    <h2 class="section-title">🔔 알림</h2>
    <div v-if="loading" class="alert-content">
      <p class="alert-desc">알림을 불러오는 중...</p>
    </div>
    <div v-else-if="notifications.length === 0" class="alert-content info">
      <p class="alert-desc">현재 긴급 알림이 없습니다.</p>
    </div>
    <div v-else>
      <div v-for="notification in notifications" :key="notification.id" class="alert-content">
        <div>
          <p class="alert-title">{{ notification.title }}</p>
          <p class="alert-desc">
            {{ notification.message }}
            <span v-if="notification.dueDate" class="highlight">
              기한: {{ notification.dueDate }}
            </span>
          </p>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.alert-section {
  background-color: white;
  padding: 1.5rem;
  border-radius: 0.75rem; /* 둥글게 */
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1); /* 그림자 강화 */
  margin-top: 1.5rem;
  border: 1px solid #ffe4e6; /* 연한 붉은 테두리 */
}

.section-title {
  font-size: 1.125rem;
  font-weight: 800;
  color: #991b1b; /* 짙은 붉은색 타이틀 */
  margin-bottom: 1rem;
}

.alert-content {
  background-color: #fef2f2;
  border-left: 4px solid #ef4444;
  padding: 1rem;
  border-radius: 0.25rem;
}

.alert-title { 
  font-size: 0.95rem; 
  font-weight: 700; 
  color: #b91c1c; 
  margin-bottom: 0.5rem; 
}

.alert-desc { 
  font-size: 0.875rem; 
  color: #dc2626; 
  line-height: 1.5; 
}

.highlight { 
  font-weight: 800; 
  text-decoration: underline; 
}
</style>