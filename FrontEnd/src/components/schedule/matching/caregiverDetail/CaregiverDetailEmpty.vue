<template>
    <section class="caregiver-empty">
      <div class="placeholder-icon">
        <img :src="caregiverIcon" alt="요양보호사 선택" />
      </div>
      <p class="placeholder-title">요양보호사를 선택하면</p>
      <p class="placeholder-desc">상세 정보가 표시됩니다</p>
    </section>
  </template>
  
  <script setup>
  import caregiverIcon from '@/assets/img/schedule/checkCareworker.png'
  </script>
  
  <style scoped>
  .caregiver-empty {
    background: #ffffff;
    border-radius: 16px;
    border: 1px solid #e5e7eb;
    padding: 24px 32px;
    min-height: 260px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    color: #9ca3af;
  }
  
  .placeholder-icon {
    width: 56px;
    height: 56px;
    margin-bottom: 8px;
  }
  
  .placeholder-icon img {
    width: 100%;
    height: 100%;
    object-fit: contain;
  }
  
  .placeholder-title {
    margin: 0;
    font-weight: 600;
  }
  
  .placeholder-desc {
    margin: 4px 0 0;
    font-size: 13px;
  }
  </style>