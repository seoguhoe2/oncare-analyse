<template>
    <div class="section">
      <div class="section-title section-title-row">
        <span>대체 가능한 요양보호사</span>
        <span class="section-sub">{{ alternatives.length }}명 가능</span>
      </div>
  
      <div class="section-card alternate-list">
        <div
          v-for="alt in alternatives"
          :key="alt.id"
          class="alternate-item"
        >
          <div class="alternate-left">
            <div
              class="avatar-circle small"
              :class="{ 'avatar-disabled': !alt.available }"
            >
              {{ String(alt.name || '').slice(0, 1) }}
            </div>
  
            <div class="alternate-info">
              <div class="name">{{ alt.name }}</div>
              <div class="distance">{{ alt.distance }}</div>
            </div>
          </div>
  
          <div class="alternate-right">
            <button
              v-if="alt.available"
              class="assign-btn"
              type="button"
              @click.stop="onAssign(alt)"
            >
              배정가능
            </button>
            <button
              v-else
              class="assign-btn disabled"
              type="button"
              disabled
            >
              배정불가
            </button>
          </div>
        </div>
  
        <div v-if="!alternatives.length" class="alternate-empty">
          대체 가능한 요양보호사가 없습니다.
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  const props = defineProps({
    alternatives: {
      type: Array,
      default: () => [],
    },
  });
  
  const emit = defineEmits(['assign']);
  
  const onAssign = (alt) => emit('assign', alt);
  </script>
  
  <style scoped>
  .section {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }
  
  .section-title {
    font-size: 14px;
    font-weight: 600;
    color: #4b5563;
  }
  
  .section-title-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .section-sub {
    font-size: 12px;
    color: #6b7280;
  }
  
  .section-card {
    background: #f9fafb;
    border-radius: 16px;
    padding: 12px 16px;
    border: 1px solid #e5e7eb;
  }
  
  .alternate-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
    background: #f0f9ff;
    border-color: #bfdbfe;
  }
  
  .alternate-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 6px 0;
  }
  
  .alternate-left {
    display: flex;
    align-items: center;
    gap: 8px;
  }
  
  .avatar-circle {
    width: 40px;
    height: 40px;
    border-radius: 999px;
    background: #22c55e;
    color: #ffffff;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .avatar-circle.small {
    width: 32px;
    height: 32px;
  }
  
  .avatar-disabled {
    background: #e5e7eb;
    color: #9ca3af;
  }
  
  .alternate-info .name {
    font-size: 14px;
    font-weight: 500;
    color: #111827;
  }
  
  .alternate-info .distance {
    font-size: 12px;
    color: #6b7280;
  }
  
  .assign-btn {
    padding: 4px 10px;
    border-radius: 999px;
    border: none;
    font-size: 12px;
    cursor: pointer;
    background: #22c55e;
    color: #ffffff;
  }
  
  .assign-btn.disabled {
    background: #e5e7eb;
    color: #9ca3af;
    cursor: not-allowed;
  }
  
  .alternate-empty {
    font-size: 13px;
    color: #6b7280;
    padding-top: 4px;
  }
  </style>