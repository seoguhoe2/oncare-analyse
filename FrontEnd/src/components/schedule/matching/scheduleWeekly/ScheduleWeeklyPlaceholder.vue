<template>
  <div class="placeholder">
    <img :src="scheduleIcon" alt="주간 일정 아이콘" class="icon" />
    <p class="title">수급자 또는 요양보호사를 선택하면</p>
    <p class="desc">일정이 표시됩니다</p>
  </div>
</template>

<script setup>
import scheduleIcon from '@/assets/img/common/scheduleManagement.png'
</script>

<style scoped>
.placeholder {
  width: 100%;
  height: 100%;
  min-height: 200px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #9ca3af;
  text-align: center;
}

.icon {
  width: 64px;
  height: 64px;
  margin-bottom: 10px;
  opacity: 0.8;
}

.title {
  margin: 0;
  font-weight: 600;
}

.desc {
  margin-top: 4px;
  font-size: 14px;
}
</style>