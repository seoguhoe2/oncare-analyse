<!-- CareWorkerChangeConfirmModal.vue -->
<template>
    <teleport to="body">
      <div v-if="open" class="ccm-overlay" @click.self="emit('close')">
        <div class="ccm-modal" role="dialog" aria-modal="true" aria-label="요양보호사 변경 확인">
          <div class="ccm-body">
            <div class="ccm-title">{{ titleText }}</div>
            <div class="ccm-message">{{ messageText }}</div>
  
            <div v-if="subMessageText" class="ccm-sub">
              {{ subMessageText }}
            </div>
  
            <div class="ccm-footer">
              <button class="ccm-btn ghost" type="button" :disabled="loading" @click="emit('close')">
                취소
              </button>
  
              <button class="ccm-btn primary" type="button" :disabled="loading" @click="emit('confirm')">
                <span v-if="loading">변경 중...</span>
                <span v-else>변경</span>
              </button>
            </div>
          </div>
  
          <button class="ccm-x" type="button" aria-label="닫기" :disabled="loading" @click="emit('close')">
            ×
          </button>
        </div>
      </div>
    </teleport>
  </template>
  
  <script setup>
  import { computed } from 'vue'
  
  const props = defineProps({
    open: { type: Boolean, default: false },
    loading: { type: Boolean, default: false },
  
    /**
     * 'CONFIRMED' : 방문일정 변경 케이스
     * 'NORMAL'    : 담당 요양보호사 변경 케이스
     */
    mode: { type: String, default: 'NORMAL' }, // 'CONFIRMED' | 'NORMAL'
  
    /** 문구에 들어갈 데이터 */
    dateText: { type: String, default: '' }, // 예: '2025년 12월 23일' 또는 '2025-12-23'
    beneficiaryName: { type: String, default: '' }, // 예: '홍길동'
    fromCareWorkerName: { type: String, default: '' }, // 기존 요양보호사명
    toCareWorkerName: { type: String, default: '' }, // 변경될 요양보호사명
  })
  
  const emit = defineEmits(['close', 'confirm'])
  
  const safe = (v, fallback = '') => {
    const s = String(v ?? '').trim()
    return s ? s : fallback
  }
  
  /* 날짜가 YYYY-MM-DD로 오면 "YYYY년 MM월 DD일"로 보여주기 */
  const formatKoreanDate = (raw) => {
    const s = String(raw ?? '').trim()
    if (!s) return ''
    // 이미 "년" 들어있으면 그대로
    if (s.includes('년')) return s
  
    // ISO 형태 대응
    const d = s.includes('T') ? s.split('T')[0] : s
    const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(d)
    if (!m) return s
  
    const yyyy = m[1]
    const mm = m[2]
    const dd = m[3]
    return `${yyyy}년 ${mm}월 ${dd}일`
  }
  
  const isConfirmed = computed(() => String(props.mode ?? '').toUpperCase() === 'CONFIRMED')
  
  const titleText = computed(() => (isConfirmed.value ? '방문일정 변경' : '담당 요양보호사 변경'))
  
  const messageText = computed(() => {
    const fromName = safe(props.fromCareWorkerName, '-')
    const toName = safe(props.toCareWorkerName, '-')
  
    if (isConfirmed.value) {
      const date = formatKoreanDate(props.dateText)
      const datePart = date ? `${date} ` : ''
      return `${datePart}요양보호사를 ${fromName}에서 ${toName}으로 변경하시겠습니까?`
    }
  
    const bName = safe(props.beneficiaryName, '-')
    return `수급자 ${bName}의 담당 요양보호사를 ${fromName}에서 ${toName}으로 변경하시겠습니까?`
  })
  
  /**
   * 필요하면 추가 안내 문구를 넣을 수 있게 해둠
   * (원치 않으면 빈 문자열이라 UI에 안 뜸)
   */
  const subMessageText = computed(() => '')
  </script>
  
  <style scoped>
  .ccm-overlay {
    position: fixed;
    inset: 0;
    background: rgba(15, 23, 42, 0.35);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 9999;
    padding: 16px;
  }
  
  .ccm-modal {
    width: 100%;
    max-width: 520px;
    background: #ffffff;
    border-radius: 18px;
    border: 1px solid #e5e7eb;
    box-shadow: 0 18px 50px rgba(15, 23, 42, 0.12);
    position: relative;
  }
  
  .ccm-x {
    position: absolute;
    top: 10px;
    right: 12px;
    width: 34px;
    height: 34px;
    border-radius: 10px;
    border: 1px solid #e5e7eb;
    background: #ffffff;
    color: #64748b;
    font-size: 20px;
    line-height: 1;
    cursor: pointer;
  }
  
  .ccm-x:disabled {
    opacity: 0.55;
    cursor: not-allowed;
  }
  
  .ccm-body {
    padding: 18px 20px 18px;
  }
  
  .ccm-title {
    font-size: 16px;
    font-weight: 700;
    color: #0f172a;
    letter-spacing: -0.2px;
    padding-right: 44px;
  }
  
  .ccm-message {
    margin-top: 10px;
    font-size: 14px;
    font-weight: 500;
    color: #334155;
    line-height: 1.55;
    word-break: keep-all;
  }
  
  .ccm-sub {
    margin-top: 8px;
    font-size: 13px;
    font-weight: 500;
    color: #64748b;
    line-height: 1.5;
    word-break: keep-all;
  }
  
  .ccm-footer {
    margin-top: 16px;
    display: flex;
    justify-content: flex-end;
    gap: 10px;
  }
  
  .ccm-btn {
    border-radius: 12px;
    padding: 10px 14px;
    font-weight: 650;
    cursor: pointer;
    border: none;
    font-size: 14px;
  }
  
  .ccm-btn.ghost {
    background: #ffffff;
    border: 1px solid #e5e7eb;
    color: #334155;
  }
  
  .ccm-btn.primary {
    background: #22c55e;
    color: #ffffff;
  }
  
  .ccm-btn:disabled {
    opacity: 0.55;
    cursor: not-allowed;
  }
  </style>