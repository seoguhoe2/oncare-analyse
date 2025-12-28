<template>
  <button class="icon-button" type="button" @click="$emit('toggle')">
    <img :src="iconSrc" alt="알림" />
    
    <span v-if="count > 0" class="bell-badge"></span>
  </button>
</template>

<script>
export default {
  name: 'NotificationBell',
  props: {
    // 부모로부터 받는 이미지 경로
    iconSrc: { 
      type: String, 
      default: '@/assets/img/dashboard/notification.png' // 기본값 설정 가능
    },
    // 안 읽은 개수
    count: { 
      type: Number, 
      default: 0 
    }
  }
};
</script>

<style scoped>
.icon-button {
  background: none;
  border: none;
  cursor: pointer;
  position: relative; /* 배지 위치 기준점 */
  padding: 8px;
}

.bell-badge {
  position: absolute;
  top: 5px;
  right: 5px;
  width: 8px;
  height: 8px;
  background-color: #ff4d4f; /* 빨간색 */
  border-radius: 50%;
  border: 1px solid #fff; /* 아이콘과 구분되는 흰색 테두리 */
}
</style>