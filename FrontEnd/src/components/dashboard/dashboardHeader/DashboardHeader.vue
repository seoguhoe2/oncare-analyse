<script setup>
</script>

<template>
  <header class="header">
    <div class="header-left">
      <h1>대시보드</h1>
      <p>복지용구 렌탈서비스 & 방문요양 현황</p>
    </div>
    <button class="custom-btn">
      ⚙️ 대시보드 커스터마이징
    </button>
  </header>
</template>

<style scoped>
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  background-color: #fff;
  border-bottom: 1px solid #e0e0e0;
}

.header-left h1 {
  font-size: 24px;
  font-weight: 700;
  margin: 0 0 4px 0;
  color: #2c3e50;
}

.header-left p {
  font-size: 14px;
  color: #666;
  margin: 0;
}

.custom-btn {
  background-color: #4CAF50; /* 이미지의 초록색 */
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: background 0.3s;
}

.custom-btn:hover {
  background-color: #43a047;
}
</style>