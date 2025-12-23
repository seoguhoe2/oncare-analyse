<template>
    <section class="recipient-panel">
      <!-- 선택 전 / 후 스위칭 -->
      <RecipientDetailEmpty v-if="!recipient" />
      <RecipientDetailSelected
        v-else
        :recipient="recipient"
        @remove-caregiver="$emit('remove-caregiver', $event)"
      />
    </section>
  </template>
  
  <script setup>
  import RecipientDetailEmpty from './RecipientDetailEmpty.vue'
  import RecipientDetailSelected from './RecipientDetailSelected.vue'
  
  const props = defineProps({
    recipient: {
      type: Object,
      default: null,
    },
  })
  
  defineEmits(['remove-caregiver'])
  </script>
  
  <style scoped>
  .recipient-panel {
    height: 100%;
  }
  </style>