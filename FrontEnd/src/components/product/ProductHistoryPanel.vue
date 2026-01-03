<template>
  <aside class="history-panel">
    <div class="history-header">
      <div class="header-left">
        <div class="title">제품 히스토리</div>
      </div>
      <button type="button" class="close-btn" @click="$emit('close')">
        ×
      </button>
    </div>

    <template v-if="detailRow">
      <div class="history-body">
        <section class="info-section">
          <div class="label">관리코드</div>
          <div class="value">
            <span class="badge code-badge">{{ detailRow.id }}</span>
          </div>

          <div class="label">용품명</div>
          <div class="value">
            {{ product?.name || detailRow.productName || '—' }}
          </div>
        </section>

        <section class="history-section">
          <div class="section-title">전체 이력</div>

          <div v-if="!events || events.length === 0" class="empty">
            등록된 히스토리가 없습니다.
          </div>

          <div
            v-for="event in visualItems"
            :key="event.id"
            class="history-item"
          >
            <div class="history-header-row">
              <span class="type-badge" :class="typeClass(event.status)">
                {{ event.status }}
              </span>
              <span class="history-date">{{ event.createdAt.replace('T', ' ') }}</span>
            </div>
            <div class="history-desc">
              {{ event.content }}
            </div>
            <div class="history-staff" v-if="event.staff">
              담당: {{ event.employeeName }}
            </div>
          </div>
        </section>
      </div>

      <div class="pagination-controls" v-if="totalItemCount > 0">
        <button 
          class="page-btn" 
          :disabled="visualPage === 0"
          @click="prevPage"
        >
          &lt; 이전
        </button>
        
        <span class="page-info">{{ visualPage + 1 }} 페이지</span>

        <button 
          class="page-btn" 
          :disabled="!canGoNext"
          @click="nextPage"
        >
          다음 &gt;
        </button>
      </div>
    </template>

    <div class="history-body empty-state" v-else>
      <p>좌측 목록에서 제품을 선택하면<br>상세 이력을 확인할 수 있습니다.</p>
    </div>

  </aside>
</template>
  
  <script setup>

  import { computed ,watch, ref} from 'vue'



  const props = defineProps({
    product: {
      type: Object,
      default: null,
    },
    events: {
      type: Array,
      default: () => [],
    },
    isLastBatch: { 
      type: Boolean, 
      default: true 
    }, 
    detailRow: {
      type: Object,
      default: null, 
    },
  })
  
  
  const typeClass = (s) => {
    // 보관/입고 케이스
  if (s === 'PURCHASED' || s === '보관' || s === '입고') return 'status-discard'
  // 대여 케이스
  if (s === 'RENTAL' || s === '렌탈' || s === '대여') return 'status-rent'
  // 폐기 케이스
  if (s === 'DISCARD' || s === '폐기') return 'status-discard'
  if (s === 'REPAIR' || s === '폐기') return 'status-repair'

    return ''
  }


  const emit = defineEmits(['close','needMoreData'])

  
  const visualPage = ref(0) // 현재 내가 보고 있는 화면 페이지
  const pageSize = 5      // 화면에 보여줄 개수
  const totalItemCount = computed(() => props.events?.length ?? 0) // 전체 아이템 개수


  const visualItems = computed(() => {
    if (!props.events || !Array.isArray(props.events)) return []
    
    const start = visualPage.value * pageSize
    const end = start + pageSize
    return props.events.slice(start, end)
  })

  const nextPage = async () => {
    const nextIndexStart = (visualPage.value + 1) * pageSize
    
    if (nextIndexStart >= totalItemCount.value) {
      if (props.isLastBatch) return 
      
      emit('needMoreData') 
    } else {
      visualPage.value++
    }
  }

  const canGoNext = computed(() => {
    // 메모리에 이미 다음 장 데이터가 있거나
    const hasMoreInMemory = (visualPage.value + 1) * pageSize < totalItemCount.value
    // 아니면 서버에 데이터가 더 남아있을 때 (isLastBatch가 false일 때)
    const hasMoreInServer = !props.isLastBatch
    
    return hasMoreInMemory || hasMoreInServer
  })

  const prevPage = () => {
    if (visualPage.value > 0) visualPage.value--
  }

  watch(() => props.detailRow?.id, () => {
    visualPage.value = 0
  })

  watch(() => props.events.length, (newLen, oldLen) => {
    if (newLen > oldLen && newLen > (visualPage.value + 1) * pageSize) {
      visualPage.value++
    }
  })


  
  </script>
  
  <style scoped>
  .history-panel {
    width: 390px;
    min-width: 390px;
    max-height: calc(100vh - 48px);
    border-radius: 16px;
    border: 1px solid #e5e7eb;
    background: #ffffff;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }
  
  /* 헤더 */
  .history-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: #e5f0ff;
    padding: 12px 16px;
  }
  
  .title {
    font-size: 18px;
    font-weight: 600;
    color: #166534;
  }
  
  .close-btn {
    border: none;
    background: transparent;
    font-size: 22px;
    line-height: 1;
    cursor: pointer;
    color: #4b5563;
  }
  
  /* 본문 스크롤 */
  .history-body {
    padding: 16px;
    overflow-y: auto;
  }
  
  /* 기본 정보 섹션 */
  .info-section {
    display: grid;
    grid-template-columns: 80px 1fr;
    row-gap: 6px;
    column-gap: 8px;
    margin-bottom: 20px;
  }
  
  .label {
    font-size: 13px;
    color: #6b7280;
  }
  
  .value {
    font-size: 14px;
  }
  
  /* 히스토리 섹션 */
  .history-section .section-title {
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 10px;
  }
  
  .history-item {
    border-radius: 12px;
    background: #f9fafb;
    padding: 10px 12px;
    margin-bottom: 10px;
  }
  
  .history-header-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 4px;
  }
  
  .history-date {
    font-size: 12px;
    color: #9ca3af;
  }
  
  .history-desc {
    font-size: 14px;
    margin-bottom: 2px;
  }
  
  .history-staff {
    font-size: 12px;
    color: #6b7280;
  }
  
  /* 뱃지 공통 */
  .badge,
  .type-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 4px 12px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 600;
    min-width: 60px;           /* 최소 너비 지정 시 균형 잡힘 */
  }
  
  .code-badge {
    background: #f5f3ff;
    color: #7c3aed;
  }
  
  .type-badge.status-discard {
    background: #ffedd5;
    color: #c2410c;
  }
  
  .type-badge.status-repair {
    background: #ffedd5;
    color: #c2410c;
  }
  
  .type-badge.status-storage {
    background: #e5e7eb;
    color: #374151;
  }
  
  .type-badge.status-rent {
    background: #f3e8ff; 
    color: #6b21a8;
  }
  
  .empty {
    font-size: 13px;
    color: #9ca3af;
  }

  .empty-state {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100%;
    color: #9ca3af;
    text-align: center;
    font-size: 14px;
    line-height: 1.5;
  }
  
  .pagination-controls { display: flex; justify-content: flex-end; align-items: center; gap: 12px; margin-top: 10px;  margin-bottom: 10px; padding: 0 16px; }
  .page-btn { padding: 6px 16px; border: 1px solid #e5e7eb; background-color: white; border-radius: 6px; font-size: 13px; cursor: pointer; color: #374151; transition: all 0.2s; }
  .page-btn:hover:not(:disabled) { background-color: #f3f4f6; border-color: #d1d5db; }
  .page-btn:disabled { opacity: 0.5; cursor: not-allowed; background-color: #f9fafb; }
  .page-info { font-size: 13px; color: #6b7280; }
  </style>