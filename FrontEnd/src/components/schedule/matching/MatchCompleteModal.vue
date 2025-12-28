<template>
    <div v-if="show" class="modal-overlay" @click.self="$emit('close')">
      <div class="modal-card">
        <h3 class="modal-title">매칭 완료</h3>
        <p class="modal-desc">{{ message }}</p>
  
        <div class="modal-actions">
          <button type="button" class="modal-confirm" @click="$emit('close')">
            확인
          </button>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  defineProps({
    show: {
      type: Boolean,
      required: true,
    },
    message: {
      type: String,
      required: true,
    },
  })
  
  defineEmits(['close'])
  </script>
  
  <style scoped>
  .modal-overlay {
    position: fixed;
    inset: 0;
    background: rgba(15, 23, 42, 0.45);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
  }
  
  .modal-card {
    width: min(420px, calc(100vw - 32px));
    background: #fff;
    border-radius: 16px;
    padding: 18px 18px 16px;
    box-shadow: 0 16px 40px rgba(15, 23, 42, 0.25);
    border: 1px solid #e2e8f0;
  }
  
  .modal-title {
    margin: 0;
    font-size: 18px;
    font-weight: 700;
    color: #0f172a;
  }
  
  .modal-desc {
    margin: 10px 0 16px;
    font-size: 14px;
    color: #334155;
    line-height: 1.5;
  }
  
  .modal-actions {
    display: flex;
    justify-content: flex-end;
  }
  
  .modal-confirm {
    padding: 10px 14px;
    border-radius: 10px;
    border: none;
    cursor: pointer;
    background: #00a63e;
    color: #fff;
    font-weight: 600;
  }
  </style>