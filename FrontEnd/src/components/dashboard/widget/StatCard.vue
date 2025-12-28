<script setup>
import { computed } from 'vue';

const props = defineProps({
  data: {
    type: Object,
    required: true
  }
});

// 색상 매핑
const colorMap = {
  green: { bg: '#e8f5e9', text: '#2e7d32' },
  blue: { bg: '#e3f2fd', text: '#1565c0' },
  purple: { bg: '#f3e5f5', text: '#7b1fa2' },
  orange: { bg: '#fff3e0', text: '#ef6c00' }
};

const theme = computed(() => colorMap[props.data.color] || colorMap.green);
</script>

<template>
  <div class="stat-card">
    <div class="card-header">
      <span class="title">{{ data.title }}</span>
      <div class="controls">
        <button class="ctrl-btn">⤢</button>
        <button class="ctrl-btn">✕</button>
      </div>
    </div>
    
    <div class="card-body">
      <div class="info">
        <h2 class="value">{{ data.value }}</h2>
        <p v-if="data.change" class="change up">{{ data.change }}</p>
        <p v-if="data.subtext" class="subtext">{{ data.subtext }}</p>
      </div>
      
      <div class="icon-box" :style="{ backgroundColor: theme.bg, color: theme.text }">
        {{ data.icon }}
      </div>
    </div>
  </div>
</template>

<style scoped>
.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  border: 1px solid #eee;
  display: flex;
  flex-direction: column;
}

.card-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 12px;
}

.title {
  font-size: 14px;
  color: #666;
}

.controls {
  opacity: 0.3;
  transition: opacity 0.2s;
}
.stat-card:hover .controls {
  opacity: 1;
}

.ctrl-btn {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 12px;
  margin-left: 4px;
}

.card-body {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
}

.value {
  font-size: 24px;
  font-weight: 700;
  margin: 0 0 4px 0;
  color: #333;
}

.change {
  font-size: 12px;
  font-weight: 600;
}
.change.up { color: #4CAF50; }

.subtext {
  font-size: 13px;
  color: #1976d2; /* 파란색 텍스트 */
}

.icon-box {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
}
</style>