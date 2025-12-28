<template>
    <div class="modal-backdrop" @click.self="$emit('close')">
      <div class="modal-card" role="dialog" aria-modal="true">
        <h3 class="modal-title">정말 삭제하시겠습니까?</h3>
        <p class="modal-desc">삭제한 일정은 복구할 수 없습니다.</p>
  
        <div class="modal-actions">
          <button class="btn" type="button" @click="$emit('close')">취소</button>
          <button class="btn danger" type="button" :disabled="loading" @click="$emit('confirm')">
            {{ loading ? '삭제 중...' : '예' }}
          </button>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  defineProps({
    loading: { type: Boolean, default: false },
  });
  defineEmits(['close', 'confirm']);
  </script>
  
  <style scoped>
  .modal-backdrop {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.35);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
  }
  
  .modal-card {
    width: 360px;
    background: #fff;
    border-radius: 16px;
    padding: 18px;
    border: 1px solid #e5e7eb;
  }
  
  .modal-title { margin: 0 0 8px; font-size: 16px; }
  .modal-desc { margin: 0 0 14px; font-size: 13px; color: #6b7280; }
  
  .modal-actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
  }
  
  .btn {
    border: 1px solid #e5e7eb;
    background: #fff;
    border-radius: 10px;
    padding: 8px 12px;
    cursor: pointer;
  }
  
  .btn.danger {
    border-color: #ef4444;
    color: #ef4444;
  }
  </style>