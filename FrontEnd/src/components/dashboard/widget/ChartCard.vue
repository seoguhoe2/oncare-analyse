<script setup>
defineProps(['title']);
</script>

<template>
  <div class="chart-card">
    <div class="chart-header">
      <h3>{{ title }}</h3>
      <div class="controls">
        <button>⤢</button>
        <button>✕</button>
      </div>
    </div>
    <div class="chart-content">
      <slot></slot>
    </div>
  </div>
</template>

<style scoped>
.chart-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  border: 1px solid #eee;
  height: 100%;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.chart-header h3 {
  font-size: 18px;
  font-weight: 600;
  color: #2c3e50;
  margin: 0;
}

.controls button {
  background: none;
  border: none;
  color: #999;
  cursor: pointer;
  font-size: 14px;
  margin-left: 8px;
}
</style>