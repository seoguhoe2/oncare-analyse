<script setup>
import { ref, computed, watch, onMounted } from 'vue';

const props = defineProps({
  isOpen: Boolean,
  allWidgets: Array // 부모로부터 받는 전체 위젯 데이터
});

const emit = defineEmits(['close', 'save']);

// 로컬 상태로 복사 (취소 시 원본 보존을 위해)
const localWidgets = ref([]);

// 데이터 초기화 함수
const initModal = () => {
  if (props.allWidgets && props.allWidgets.length > 0) {
    // 깊은 복사로 부모 데이터와 끊기
    localWidgets.value = JSON.parse(JSON.stringify(props.allWidgets));
  } else {
    localWidgets.value = [];
  }
};

// [핵심 수정] 컴포넌트가 화면에 렌더링될 때 무조건 초기화 실행
onMounted(() => {
  initModal();
});

// 혹시 모달이 닫혔다 열릴 때도 감지 (안전장치)
watch(() => props.isOpen, (newVal) => {
  if (newVal) {
    initModal();
  }
});

// 선택 토글 함수
const toggleWidget = (id) => {
  const widget = localWidgets.value.find(w => w.id === id);
  if (widget) {
    widget.selected = !widget.selected;
  }
};

// 선택된 개수 계산
const selectedCount = computed(() => localWidgets.value.filter(w => w.selected).length);

const handleSave = () => {
  emit('save', localWidgets.value);
};
</script>

<template>
  <div v-if="isOpen" class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-content">
      <div class="modal-header">
        <div>
          <h3>대시보드 위젯 선택</h3>
          <p>원하는 위젯을 선택하여 나만의 대시보드를 만드세요</p>
        </div>
        <button class="close-btn" @click="$emit('close')">×</button>
      </div>

      <div class="widget-grid">
        <div 
          v-for="widget in localWidgets" 
          :key="widget.id"
          :class="['widget-option', { active: widget.selected }]"
          @click="toggleWidget(widget.id)"
        >
          <div class="text-box">
            <h4>{{ widget.name }}</h4>
            <p>{{ widget.description }}</p>
          </div>
          <div class="check-circle">
            <span v-if="widget.selected">✔</span>
          </div>
        </div>
      </div>

      <div class="modal-footer">
        <span>{{ selectedCount }}개의 위젯이 선택됨</span>
        <button class="save-btn" @click="handleSave">완료</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay {
  position: fixed; 
  top: 0; 
  left: 0; 
  width: 100%; 
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex; 
  justify-content: center; 
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  width: 800px;
  max-width: 95%;
  border-radius: 16px;
  padding: 30px;
  box-shadow: 0 10px 25px rgba(0,0,0,0.1);
  display: flex;
  flex-direction: column;
  max-height: 90vh;
}

.modal-header {
  display: flex; justify-content: space-between; margin-bottom: 24px; flex-shrink: 0;
}
.modal-header h3 { margin: 0 0 8px 0; font-size: 1.5rem; font-weight: bold; }
.modal-header p { margin: 0; color: #666; font-size: 0.95rem; }
.close-btn { background: none; border: none; font-size: 2rem; cursor: pointer; color: #999; }

/* 그리드 레이아웃 */
.widget-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  margin-bottom: 20px;
  overflow-y: auto;
  flex-grow: 1;
  padding-right: 5px;
}

/* ★ [수정됨] 위젯 카드 스타일 */
.widget-option {
  display: flex; 
  align-items: center;
  border: 1px solid #e5e7eb; /* 기본 회색 테두리 */
  border-radius: 12px;
  padding: 16px;
  cursor: pointer;
  transition: all 0.2s ease;
  background: white; /* 기본 흰색 배경 */
  position: relative;
}

.widget-option:hover {
  border-color: #10B981; /* 호버 시 테두리만 살짝 초록색 */
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

/* ★ [수정됨] 선택된 상태 (Active) */
.widget-option.active {
  border: 2px solid #10B981; /* 진한 초록 테두리 */
  background-color: white;   /* 배경은 흰색 유지 (기존 연한 초록색 제거) */
}

/* 아이콘 박스 */
.icon-box {
  width: 48px; 
  height: 48px;
  border-radius: 10px;
  display: flex; 
  align-items: center; 
  justify-content: center;
  font-size: 1.5rem; 
  margin-right: 16px;
  background: #f3f4f6; 
  color: #6b7280;
  flex-shrink: 0;
  /* 선택 시 색상 변경 애니메이션 제거 */
}

/* 텍스트 스타일 */
.text-box h4 { 
  margin: 0 0 4px 0; 
  font-size: 1rem; 
  font-weight: 600; 
  color: #1f2937; /* 항상 진한 회색/검정 유지 */
}

/* 선택되었을 때 텍스트 색상 변경 코드 삭제됨 (기본색 유지) */

.text-box p { 
  margin: 0; 
  font-size: 0.85rem; 
  color: #6b7280; 
}

/* ★ [수정됨] 체크 아이콘 (우측 원형) */
.check-circle {
  margin-left: auto;
  width: 24px; 
  height: 24px; 
  border-radius: 50%;
  border: 2px solid #e5e7eb; /* 선택 안됐을 땐 회색 테두리 */
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  color: transparent; /* 체크 표시 숨김 */
  transition: all 0.2s;
}

/* 선택되었을 때 체크 원형 스타일 */
.widget-option.active .check-circle {
  background: #10B981;     /* 원 배경 초록색 */
  border-color: #10B981;   /* 원 테두리 초록색 */
  color: white;            /* 체크 표시 흰색 */
}

.modal-footer {
  display: flex; justify-content: space-between; align-items: center;
  border-top: 1px solid #eee; padding-top: 20px; flex-shrink: 0;
}
.save-btn {
  background: #10B981; color: white; border: none;
  padding: 10px 24px; border-radius: 8px; font-weight: bold; cursor: pointer;
}
.save-btn:hover { background: #059669; }
</style>