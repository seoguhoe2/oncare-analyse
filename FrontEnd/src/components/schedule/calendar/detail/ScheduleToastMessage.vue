<template>
    <transition name="fade">
      <div v-if="visible" class="status-toast" :class="type">
        {{ message }}
      </div>
    </transition>
  </template>
  
  <script setup>
  import { ref, watch } from 'vue';
  
  const props = defineProps({
    message: { type: String, default: '' },
    type: { type: String, default: 'warning' }, // warning | success
    show: { type: Boolean, default: false },
    duration: { type: Number, default: 2500 },
  });
  
  const emit = defineEmits(['update:show']);
  
  const visible = ref(false);
  let timer = null;
  
  watch(
    () => props.show,
    (v) => {
      clearTimeout(timer);
      visible.value = v;
  
      if (v) {
        timer = setTimeout(() => {
          visible.value = false;
          emit('update:show', false);
        }, props.duration);
      }
    }
  );
  </script>
  
  <style scoped>
  .status-toast {
    position: absolute;
    top: 10px;
    right: 20px; 
    padding: 10px 16px;
    border-radius: 12px;
    font-size: 14px;
    font-weight: 700;
    background: #ffffff;
    border: 2px solid;
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
    z-index: 20;
  }
  
  .status-toast.warning {
    color: #d97706;
    border-color: #d97706;
  }
  
  .status-toast.success {
    color: #16a34a;
    border-color: #16a34a;
  }
  
  .fade-enter-active,
  .fade-leave-active {
    transition: opacity 0.2s ease, transform 0.2s ease;
  }
  
  .fade-enter-from,
  .fade-leave-to {
    opacity: 0;
    transform: translateY(-4px);
  }
  </style>