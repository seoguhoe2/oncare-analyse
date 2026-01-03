<template>
    <div class="edit-schedule-grid">
        <RecipientPreferredEditor
            ref="preferredRef"
            :beneficiaryId="beneficiaryId"
            :recipientName="recipientName"
            :schedules="schedules"
            :serviceTypeId="
                props.serviceTypeId
                ?? schedules?.[0]?.serviceTypeId
                ?? schedules?.[0]?.service_type_id
                ?? null
            "
            :serviceTypeName="
                props.serviceTypeName
                ?? schedules?.[0]?.serviceTypeName
                ?? schedules?.[0]?.service_type_name
                ?? ''
            "
            @saved="$emit('saved', $event)"
        />
  
      <CareWorkerWorkingViewer
        v-if="assignedCareWorker"
        :careWorker="assignedCareWorker"
        :workingTimes="safeWorkingTimes"
      />
  
      <div v-else class="right-empty">
        <div class="empty-title">요양보호사 근무 시간</div>
        <div class="empty-desc">아직 매칭된 요양보호사가 없어 표시할 수 없습니다.</div>
      </div>
    </div>
  </template>
  
  <script setup>
  import { computed, ref } from 'vue'
  import RecipientPreferredEditor from './RecipientPreferredEditor.vue'
  import CareWorkerWorkingViewer from './CareWorkerWorkingViewer.vue'
  
  defineEmits(['saved'])
  
  const props = defineProps({
    beneficiaryId: { type: [Number, String], default: null },
    recipientName: { type: String, default: '' },
    schedules: { type: Array, default: () => [] },
    assignedCareWorker: { type: Object, default: null },
    careWorkerWorkingTimes: { type: [Array, Object], default: () => [] },
    serviceTypeId: { type: [Number, String], default: null },
    serviceTypeName: { type: String, default: '' },
  })
  
  const preferredRef = ref(null)
  
  const safeWorkingTimes = computed(() => {
    const v = props.careWorkerWorkingTimes
    if (v && typeof v === 'object' && 'value' in v) return Array.isArray(v.value) ? v.value : []
    return Array.isArray(v) ? v : []
  })
  
  const save = async () => {
    const fn = preferredRef.value?.handleSave
    if (typeof fn !== 'function') return false
    return await fn()
  }
  
  const isSaving = computed(() => !!preferredRef.value?.saving?.value)
  
  defineExpose({
    save,
    isSaving,
  })
  </script>
  
  <style scoped>
  .edit-schedule-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
    min-height: 200px;
  }
  
  .right-empty {
    border: 1px solid #e5e7eb;
    border-radius: 16px;
    background: #f9fafb;
    padding: 14px;
  }
  
  .empty-title {
    font-size: 13px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 6px;
  }
  
  .empty-desc {
    font-size: 12px;
    color: #6b7280;
  }
  </style>