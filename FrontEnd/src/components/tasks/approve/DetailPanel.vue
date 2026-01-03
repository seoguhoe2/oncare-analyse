<template>
  <aside class="detail-sidebar">
    <div class="detail-header">
      <h2>결재 상세</h2>
      <button class="close-btn" @click="$emit('close')">✕</button>
    </div>

    <div class="detail-content">
      <div class="alert-box" v-if="['대기중', 'PENDING', 'WAITING'].includes(item.status?.toUpperCase())">
        결재 대기 중 - 내가 승인할 차례
      </div>

      <div class="detail-section">
        <h3 class="section-title">{{ item.title }}</h3>
        <span class="status-badge-sm" :class="getStatusClass(item.status)">
          {{ item.status }}
        </span>
        
        <div class="info-grid">
          <div class="info-row">
            <span class="label">요청자:</span>
            <span class="value">{{ item.drafterName }}</span>
          </div>
          <div class="info-row">
            <span class="label">요청일:</span>
            <span class="value">{{ formatDate(item.createdAt) }}</span>
          </div>
          <div class="info-row">
            <span class="label">유형:</span>
            <span class="badge category">{{ item.categoryName }}</span>
          </div>
          <div class="info-row">
            <span class="label">우선순위:</span>
            <span class="badge priority" :class="getPriorityClass(item.priority)">
              {{ item.priority }}
            </span>
          </div>
          <div class="info-row">
            <span class="label">금액:</span>
            <span class="value price">₩{{ item.amount ? item.amount.toLocaleString() : '0' }}</span>
          </div>
        </div>
      </div>

      <hr class="divider" />

      <div class="detail-section">
        <h4 class="sub-title">승인 라인:</h4>
        <div class="approval-steps">
          <template v-if="item.approverList && item.approverList.length > 0">
            <div class="step-card" v-for="(step, index) in item.approverList" :key="index">
              <div class="step-idx">{{ index + 1 }}</div>
              <div class="step-info">
                <div class="step-role">결재자</div>
                <div class="step-name">{{ step.approverName }}</div>
              </div>
              <div class="step-status">{{ step.stepStatus || '대기중' }}</div>
            </div>
          </template>
          <div v-else class="no-data">승인 라인 정보가 없습니다.</div>
        </div>
      </div>

      <hr class="divider" />

      <div class="detail-section">
        <h4 class="sub-title">결재 내용:</h4>
        <div class="content-box">
          {{ item.content }}
        </div>
      </div>
    </div>

    <div class="detail-footer">
      <button class="btn btn-approve" @click="$emit('approve', item.id)">✔ 승인</button>
      <button class="btn btn-reject" @click="$emit('reject', item.id)">✖ 반려</button>
    </div>
  </aside>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue';

// 부모로부터 받을 데이터 정의
const props = defineProps({
  item: {
    type: Object,
    required: true,
    default: () => ({})
  }
});

// 부모에게 보낼 이벤트 정의
const emit = defineEmits(['close', 'approve', 'reject']);

const formatDate = (dateString) => {
  if (!dateString) return '-';
  return dateString.split('T')[0];
};

// 키보드 이벤트 핸들러
const handleKeydown = (e) => {
  if (e.key === 'Escape') {
    emit('close');
  } else if (e.key === 'Enter') {
    // 대기중 상태일 때만 Enter로 승인 동작 수행
    // (부모에서 confirm 창을 띄우므로 바로 emit 해도 안전)
    const status = props.item.status?.toUpperCase();
    if (['대기중', 'PENDING', 'WAITING'].includes(status)) {
       emit('approve', props.item.id);
    }
  }
};

onMounted(() => {
  window.addEventListener('keydown', handleKeydown);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown);
});

// (스타일링용 유틸 함수)
const getPriorityClass = (priority) => {
  if (!priority) return '';
  const p = priority.toUpperCase();
  if (['긴급', 'HIGH', 'URGENT'].includes(p)) return 'p-high';
  if (['보통', 'MEDIUM', 'NORMAL'].includes(p)) return 'p-medium';
  if (['낮음', 'LOW'].includes(p)) return 'p-low';
  return '';
};

const getStatusClass = (status) => {
  if (!status) return '';
  const s = status.toUpperCase();
  if (['승인', 'APPROVED'].includes(s)) return 's-approved';
  if (['반려', 'REJECTED'].includes(s)) return 's-rejected';
  if (['대기중', 'PENDING', 'WAITING'].includes(s)) return 's-waiting';
  return '';
};
</script>

<style scoped>
/* 사이드바 레이아웃 */
.detail-sidebar {
  position: fixed;
  top: 0;
  right: 0;
  width: 480px;
  height: 100vh;
  background: white;
  box-shadow: -5px 0 15px rgba(0,0,0,0.1);
  z-index: 100;
  display: flex;
  flex-direction: column;
  border-left: 1px solid #eee;
}

/* 헤더 */
.detail-header {
  padding: 20px;
  border-bottom: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.detail-header h2 { margin: 0; font-size: 1.2rem; }
.close-btn { background: none; border: none; font-size: 1.5rem; cursor: pointer; color: #999; }

/* 본문 스크롤 영역 */
.detail-content {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
}

/* 스타일 요소들 */
.alert-box {
  background-color: #fffbeb;
  border: 1px solid #fcd34d;
  color: #b45309;
  padding: 12px;
  border-radius: 8px;
  margin-bottom: 20px;
  font-size: 0.9rem;
  font-weight: 500;
}
.section-title { font-size: 1.1rem; margin-bottom: 5px; color: #111; display: block; }
.status-badge-sm { font-size: 0.8rem; padding: 2px 8px; border-radius: 4px; display: inline-block; margin-bottom: 15px; }

/* 상태별 색상 (리스트와 동일하게 유지) */
.s-waiting { background-color: #fef9c3; color: #d97706; }
.s-approved { background-color: #dcfce7; color: #16a34a; }
.s-rejected { background-color: #fee2e2; color: #dc2626; }

/* 그리드 정보 */
.info-grid { display: flex; flex-direction: column; gap: 12px; }
.info-row { display: flex; align-items: center; }
.info-row .label { width: 80px; color: #888; font-size: 0.9rem; }
.info-row .value { font-weight: 500; color: #333; }
.info-row .price { font-size: 1.1rem; font-weight: bold; }

/* 뱃지 */
.badge { padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; font-weight: 500; }
.category { background-color: #eef2ff; color: #6366f1; }
.p-high { background-color: #fee2e2; color: #ef4444; }
.p-medium { background-color: #ffedd5; color: #f97316; }
.p-low { background-color: #f3f4f6; color: #6b7280; }

.divider { border: 0; border-top: 1px solid #eee; margin: 20px 0; }
.sub-title { margin: 0 0 10px 0; color: #555; font-size: 0.95rem; }

/* 승인 라인 */
.approval-steps { display: flex; flex-direction: column; gap: 10px; }
.step-card {
  display: flex; align-items: center;
  background: #f8f9fa; border: 1px solid #eee;
  padding: 10px; border-radius: 8px;
}
.step-idx { 
  width: 24px; height: 24px; background: #ddd; color: #fff; 
  border-radius: 50%; text-align: center; line-height: 24px; 
  font-size: 0.8rem; margin-right: 10px;
}
.step-info { flex: 1; }
.step-role { font-size: 0.8rem; color: #666; }
.step-name { font-weight: 600; font-size: 0.95rem; }
.step-status { font-size: 0.8rem; color: #888; }
.no-data {
    color: #999;
    font-size: 0.9rem;
    font-style: italic;
}

.content-box {
  background: #fdfdfd; padding: 15px; border-radius: 8px;
  border: 1px solid #eee; font-size: 0.95rem; line-height: 1.6; color: #444;
  white-space: pre-line;
}

/* 푸터 */
.detail-footer {
  padding: 20px;
  border-top: 1px solid #eee;
  display: flex;
  gap: 10px;
  background: white;
}
.btn { flex: 1; padding: 12px; border: none; border-radius: 8px; font-weight: bold; cursor: pointer; color: white; font-size: 1rem; }
.btn-approve { background-color: #4ade80; }
.btn-approve:hover { background-color: #22c55e; }
.btn-reject { background-color: #f87171; }
.btn-reject:hover { background-color: #ef4444; }

/* 모바일 반응형 */
@media (max-width: 768px) {
  .detail-sidebar { width: 100%; }
}
</style>