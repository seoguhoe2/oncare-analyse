<template>
  <section class="caregiver-panel">
    <CaregiverDetailEmpty v-if="!caregiver" :key="emptyKey" />

    <CaregiverDetailSelected
      v-else
      :key="caregiverKey"
      :caregiver="caregiver"
      @unassigned="onUnassigned"
      @matched="onMatched"
      @rematched="onRematched"
    />
  </section>
</template>

<script setup>
import { computed } from 'vue'
import CaregiverDetailEmpty from './CaregiverDetailEmpty.vue'
import CaregiverDetailSelected from './CaregiverDetailSelected.vue'
import { useMatchingSelectionStore } from '@/stores/matchingSelection'

const props = defineProps({
  caregiver: { type: Object, default: null },
})

const emit = defineEmits(['unassigned', 'matched', 'rematched'])
const store = useMatchingSelectionStore()

const getCaregiverId = (c) => c?.careWorkerId ?? c?.id ?? 'none'

const caregiverKey = computed(() => {
  const id = getCaregiverId(props.caregiver)
  return `caregiver-selected-${id}-${store.refreshTick}`
})

const emptyKey = computed(() => `caregiver-empty-${store.refreshTick}`)

const onUnassigned = (payload) => emit('unassigned', payload)
const onMatched = (payload) => emit('matched', payload)
const onRematched = (payload) => emit('rematched', payload)
</script>
<style scoped>
.caregiver-panel {
  height: 100%;
}
</style>