<template>
  <section class="recipient-panel">
    <RecipientDetailEmpty
      v-if="!recipient"
      :key="emptyKey"
    />

    <RecipientDetailSelected
      v-else
      :key="recipientKey"
      :recipient="recipient"
      @unassigned="onUnassigned"
    />
  </section>
</template>

<script setup>
import { computed } from 'vue'
import RecipientDetailEmpty from './RecipientDetailEmpty.vue'
import RecipientDetailSelected from './RecipientDetailSelected.vue'
import { useMatchingSelectionStore } from '@/stores/matchingSelection'

const props = defineProps({
  recipient: { type: Object, default: null },
})

const emit = defineEmits(['unassigned'])
const store = useMatchingSelectionStore()

const getRecipientId = (r) => r?.beneficiaryId ?? r?.id ?? 'none'

const recipientKey = computed(() => {
  const id = getRecipientId(props.recipient)
  return `recipient-selected-${id}-${store.refreshTick}`
})

const emptyKey = computed(() => `recipient-empty-${store.refreshTick}`)

const onUnassigned = (payload) => {
  emit('unassigned', payload)
}
</script>

<style scoped>
.recipient-panel {
  height: 100%;
  min-height: 260px; 
}
</style>