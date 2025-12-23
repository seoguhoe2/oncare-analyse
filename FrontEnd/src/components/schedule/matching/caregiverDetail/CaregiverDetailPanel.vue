<!-- src/components/schedule/matching/caregiverDetail/CaregiverDetailPanel.vue -->
<template>
    <section class="caregiver-panel">
      <CaregiverDetailEmpty v-if="!caregiver" />
      <CaregiverDetailSelected v-else :caregiver="caregiver" />
    </section>
  </template>
  
  <script setup>
  import CaregiverDetailEmpty from './CaregiverDetailEmpty.vue'
  import CaregiverDetailSelected from './CaregiverDetailSelected.vue'
  
  const props = defineProps({
    caregiver: {
      type: Object,
      default: null,
    },
  })
  </script>
  
  <style scoped>
  .caregiver-panel {
    height: 100%;
  }
  </style>