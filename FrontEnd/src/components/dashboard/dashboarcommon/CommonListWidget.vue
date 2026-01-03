<script setup>
const props = defineProps({
  title: { type: String, default: '' },
  items: { 
    type: Array, 
    default: () => [] 
  }
});

const emit = defineEmits(['remove', 'toggleSize']);

// 상태에 따른 배경/텍스트 색상 결정
const getTypeStyle = (type) => {
  if (type === 'success') return 'bg-success'; // 초록
  if (type === 'primary') return 'bg-primary'; // 파랑
  if (type === 'warning') return 'bg-warning'; // 주황
  if (type === 'error')   return 'bg-error';   // 빨강
  return 'bg-default';                         // 회색
};
</script>

<template>
  <div class="common-widget">
    <div class="widget-header">
      <h4>{{ title }}</h4>
      
      <div class="control-buttons">
        <button class="icon-btn" @click.stop="$emit('toggleSize')" title="크기 변경">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 3 21 3 21 9"></polyline><polyline points="9 21 3 21 3 15"></polyline><line x1="21" y1="3" x2="14" y2="10"></line><line x1="3" y1="21" x2="10" y2="14"></line></svg>
        </button>
        <button class="icon-btn remove" @click.stop="$emit('remove')" title="위젯 삭제">
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
      </div>
    </div>

    <div class="widget-body">
      <div class="list-container">
        <div 
          v-for="(item, index) in items" 
          :key="index" 
          class="list-row"
          :class="getTypeStyle(item.type)"
        >
          <div class="info">
            <span class="main-text">{{ item.mainText }}</span>
            <span class="sub-text">{{ item.subText }}</span>
          </div>
          <span class="value-text" :class="item.type">{{ item.value }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 공통 카드 스타일 */
.common-widget {
  background: white;
  border-radius: 16px;
  padding: 24px;
  height: 100%;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
  display: flex;
  flex-direction: column;
  position: relative;
  transition: box-shadow 0.3s ease;
}
.common-widget:hover {
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

/* 헤더 & 버튼 */
.widget-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
  min-height: 28px;
}
.widget-header h4 { margin: 0; font-size: 1.15rem; font-weight: 700; color: #1f2937; }

.control-buttons { display: flex; gap: 6px; opacity: 0; transition: opacity 0.2s; }
.common-widget:hover .control-buttons { opacity: 1; }

.icon-btn { background: transparent; border: none; cursor: pointer; color: #9ca3af; padding: 6px; border-radius: 6px; display: flex; align-items: center; justify-content: center; }
.icon-btn:hover { background-color: #f3f4f6; color: #4b5563; }
.icon-btn.remove:hover { background-color: #fee2e2; color: #ef4444; }

/* 리스트 스타일 */
.widget-body { flex-grow: 1; overflow-y: auto; }
.list-container { display: flex; flex-direction: column; gap: 12px; }

.list-row {
  display: flex; justify-content: space-between; align-items: center;
  padding: 16px 20px; border-radius: 12px;
}

/* 색상 테마 */
.bg-success { background-color: #ECFDF5; }
.bg-primary { background-color: #EFF6FF; }
.bg-warning { background-color: #FFF7ED; }
.bg-error   { background-color: #FEF2F2; }
.bg-default { background-color: #F3F4F6; }

/* 텍스트 스타일 */
.info { display: flex; flex-direction: column; }
.main-text { font-weight: 700; font-size: 15px; color: #374151; margin-bottom: 2px; }
.sub-text { font-size: 13px; color: #6B7280; }
.value-text { font-weight: 700; font-size: 16px; }

/* 값 색상 */
.value-text.success { color: #059669; }
.value-text.primary { color: #2563EB; }
.value-text.warning { color: #EA580C; }
.value-text.error   { color: #DC2626; }
.value-text.default { color: #374151; }
</style>