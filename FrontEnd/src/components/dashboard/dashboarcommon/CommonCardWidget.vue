<script setup>
import { computed } from 'vue';

const props = defineProps({
  title: { type: String, default: '' },
  value: { type: [String, Number], default: '' },
  change: { type: String, default: '' }, // 전일 대비 등
  subtext: { type: String, default: '' },
  icon: { type: String, default: '' },
  color: { type: String, default: 'green' }
});

const emit = defineEmits(['remove', 'toggleSize']);

// 색상 테마 매핑
const colorMap = {
  green: { bg: '#ECFDF5', text: '#059669' },
  blue:  { bg: '#EFF6FF', text: '#2563EB' },
  purple:{ bg: '#F5F3FF', text: '#7C3AED' },
  orange:{ bg: '#FFF7ED', text: '#EA580C' },
  red:   { bg: '#FEF2F2', text: '#DC2626' },
  gray:  { bg: '#F3F4F6', text: '#4B5563' }
};

const theme = computed(() => colorMap[props.color] || colorMap.green);
</script>

<template>
  <div class="common-widget">
    <div class="widget-header">
      <span class="title">{{ title }}</span>
      
      <div class="control-buttons">
        <button class="icon-btn" @click.stop="$emit('toggleSize')" title="크기 변경">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 3 21 3 21 9"></polyline><polyline points="9 21 3 21 3 15"></polyline><line x1="21" y1="3" x2="14" y2="10"></line><line x1="3" y1="21" x2="10" y2="14"></line></svg>
        </button>
        <button class="icon-btn remove" @click.stop="$emit('remove')" title="위젯 삭제">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
      </div>
    </div>
    
    <div class="widget-body">
      <div class="info-area">
        <h2 class="value">{{ value }}</h2>
        <p v-if="change" class="change-text">{{ change }}</p>
        <p v-if="subtext" class="sub-text">{{ subtext }}</p>
      </div>
      
      <div class="icon-box" :style="{ backgroundColor: theme.bg, color: theme.text }">
        {{ icon }}
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 공통 카드 스타일 (ListWidget과 통일) */
.common-widget {
  background: white;
  border-radius: 16px;
  padding: 24px;
  height: 100%;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
  display: flex; flex-direction: column; position: relative;
  transition: box-shadow 0.3s ease;
}
.common-widget:hover { box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); }

/* 헤더 */
.widget-header {
  display: flex; justify-content: space-between; align-items: flex-start;
  margin-bottom: 16px; min-height: 24px;
}
.title { font-size: 0.95rem; font-weight: 600; color: #6b7280; }

/* 버튼 그룹 */
.control-buttons {
  display: flex; gap: 4px; opacity: 0; transition: opacity 0.2s; margin-top: -4px;
}
.common-widget:hover .control-buttons { opacity: 1; }

.icon-btn { background: transparent; border: none; cursor: pointer; color: #9ca3af; padding: 4px; border-radius: 4px; display: flex; }
.icon-btn:hover { background: #f3f4f6; color: #4b5563; }
.icon-btn.remove:hover { background: #fee2e2; color: #ef4444; }

/* 본문 */
.widget-body {
  display: flex; justify-content: space-between; align-items: flex-end; flex-grow: 1;
}
.value { font-size: 1.8rem; font-weight: 700; margin: 0 0 4px 0; color: #111827; }
.change-text { font-size: 0.9rem; font-weight: 600; color: #10B981; margin: 0; }
.sub-text { font-size: 0.85rem; color: #3B82F6; margin: 0; }
.icon-box { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; }
</style>