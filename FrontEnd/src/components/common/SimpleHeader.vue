<script setup>
defineProps({
  title: {
    type: String,
    required: true
  },
  subtitle: {
    type: String,
    default: ''
  }
});
</script>

<template>
  <header class="simple-header">
    <div class="header-content">
      <h1 class="title">{{ title }}</h1>
      <p v-if="subtitle" class="subtitle">{{ subtitle }}</p>
    </div>
  </header>
</template>

<style scoped>
.simple-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: white;
  padding: 1.5rem 2rem;
  border-bottom: 1px solid #e5e7eb;
}

.header-content {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.title {
  font-size: 1.5rem;
  font-weight: 800;
  color: #1f2937;
  margin: 0;
}

.subtitle {
  font-size: 0.875rem;
  color: #6b7280;
  margin: 0;
}

/* 우측 상단 영역 */
.header-actions {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.notification-badge {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  border: 1px dashed #3b82f6;
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
  .simple-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
    padding: 1rem;
  }

  .header-actions {
    width: 100%;
    justify-content: space-between;
  }

  .notification-badge {
    padding: 0.25rem 0.5rem;
  }

  .noti-text {
    display: none;
  }
}
</style>
