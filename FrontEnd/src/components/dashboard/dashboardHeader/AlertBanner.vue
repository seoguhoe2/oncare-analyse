<script setup>
</script>

<template>
  <div class="alert-banner">
    <span class="icon">⚡</span>
    <p>위젯 조작: 위젯을 클릭하여 드래그하면 위치를 변경할 수 있습니다. ↙️/↗️ 버튼으로 크기를 조절하고, X 버튼으로 제거할 수 있습니다.</p>
  </div>
</template>

<style scoped>
.alert-banner {
  background-color: #e3f2fd; /* 옅은 파란색 */
  border: 1px solid #bbdefb;
  border-radius: 8px;
  padding: 12px 16px;
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 24px;
  color: #1565c0;
  font-size: 14px;
}
</style>