<template>
  <teleport to="body">
    <div v-if="show" class="overlay" @click.self="emit('close')">
      <div class="modal" role="dialog" aria-modal="true">
        <div class="modal-header">
          <h3 class="modal-title">방문 일정 추가</h3>
        </div>

        <div class="modal-body">
          <div class="grid">
            <div class="col-scroll">
              <RecipientMatchingList @select-recipient="onSelectRecipient" />
            </div>

            <div class="col-scroll">
              <div v-if="!canFetchCaregivers" class="hint">
                <div class="hint-title">시간과 서비스 유형을 선택하면 요양보호사가 필터링 됩니다</div>
                <div class="hint-sub">오른쪽에서 서비스 유형 · 날짜 · 시작 · 종료 시간을 먼저 입력해 주세요.</div>
              </div>

              <CaregiverMatchingList
                v-else
                :recipient="selectedRecipient"
                :startDt="startDt"
                :endDt="endDt"
                :serviceTypeId="serviceTypeIdNum"
                @select-caregiver="onSelectCaregiver"
              />
            </div>

            <div class="right-wrap">
              <VisitCreatePanel
                v-model:viewMode="viewMode"
                v-model:memo="memo"
                v-model:serviceTypeId="serviceTypeId"
                v-model:date="date"
                v-model:startTime="startTime"
                v-model:endTime="endTime"
                :items="items"
                @stash="onClickStash"
                @createAll="onClickCreateAll"
                @removeItem="removeItem"
                @clearAll="clearAll"
              />
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <button class="btn" type="button" @click="emit('close')">닫기</button>
        </div>
      </div>
    </div>
  </teleport>
</template>

<script setup>
import { ref, computed, watch, nextTick, onBeforeUnmount } from 'vue'
import RecipientMatchingList from '@/components/schedule/matching/RecipientMatchingList.vue'
import CaregiverMatchingList from '@/components/schedule/matching/CaregiverMatchingList.vue'
import VisitCreatePanel from '@/components/schedule/calendar/VisitCreatePanel.vue'

const props = defineProps({
  show: { type: Boolean, default: false },
})

const emit = defineEmits(['close', 'create'])

const viewMode = ref('form')

const memo = ref('')
const serviceTypeId = ref('')

const selectedRecipient = ref(null)
const selectedCaregiver = ref(null)

const date = ref('')
const startTime = ref('06:00')
const endTime = ref('07:00')

const items = ref([])

const resetFormFields = () => {
  memo.value = ''
  serviceTypeId.value = ''
  date.value = ''
  startTime.value = '06:00'
  endTime.value = '07:00'
  selectedRecipient.value = null
  selectedCaregiver.value = null
}

const lockScroll = () => {
  const body = document.body
  const html = document.documentElement
  body.dataset.scrollY = String(window.scrollY || 0)
  body.style.position = 'fixed'
  body.style.top = `-${body.dataset.scrollY}px`
  body.style.left = '0'
  body.style.right = '0'
  body.style.width = '100%'
  html.style.overflow = 'hidden'
}

const unlockScroll = () => {
  const body = document.body
  const html = document.documentElement
  const y = Number(body.dataset.scrollY || 0)
  body.style.position = ''
  body.style.top = ''
  body.style.left = ''
  body.style.right = ''
  body.style.width = ''
  body.dataset.scrollY = ''
  html.style.overflow = ''
  window.scrollTo(0, y)
}

watch(
  () => props.show,
  async (v) => {
    if (v) {
      viewMode.value = 'form'
      startTime.value = '06:00'
      endTime.value = '07:00'
      serviceTypeId.value = ''
      memo.value = ''
      selectedRecipient.value = null
      selectedCaregiver.value = null
      date.value = ''
      items.value = []

      await nextTick()
      lockScroll()
      return
    }
    unlockScroll()
  }
)

onBeforeUnmount(() => {
  unlockScroll()
})

const toDateTimeString = (d, t) => {
  if (!d || !t) return ''
  return `${d}T${t}:00`
}

const startDt = computed(() => toDateTimeString(date.value, startTime.value))
const endDt = computed(() => toDateTimeString(date.value, endTime.value))

const beneficiaryId = computed(
  () => selectedRecipient.value?.beneficiaryId ?? selectedRecipient.value?.id ?? null
)

const careWorkerId = computed(
  () => selectedCaregiver.value?.careWorkerId ?? selectedCaregiver.value?.id ?? null
)

const serviceTypeIdNum = computed(() => {
  const v = String(serviceTypeId.value).trim()
  return v ? Number(v) : null
})

const canFetchCaregivers = computed(() => {
  return !!beneficiaryId.value && !!serviceTypeIdNum.value && !!startDt.value && !!endDt.value
})

watch(
  () => [beneficiaryId.value, serviceTypeIdNum.value, startDt.value, endDt.value],
  () => {
    selectedCaregiver.value = null
  }
)

const onSelectRecipient = (item) => {
  selectedRecipient.value = item
  selectedCaregiver.value = null
}

const onSelectCaregiver = (item) => {
  selectedCaregiver.value = item
}

const overlaps = (aStart, aEnd, bStart, bEnd) => {
  return aStart < bEnd && bStart < aEnd
}

const validateForm = () => {
  if (!beneficiaryId.value) return { ok: false, message: '수급자를 선택해 주세요.' }
  if (!serviceTypeIdNum.value) return { ok: false, message: '서비스 유형을 선택해 주세요.' }
  if (!date.value) return { ok: false, message: '날짜를 선택해 주세요.' }
  if (!startTime.value) return { ok: false, message: '시작 시간을 선택해 주세요.' }
  if (!endTime.value) return { ok: false, message: '종료 시간을 선택해 주세요.' }
  if (!careWorkerId.value) return { ok: false, message: '요양보호사를 선택해 주세요.' }
  if (!startDt.value || !endDt.value) return { ok: false, message: '날짜/시간 값이 올바르지 않습니다.' }

  if (startDt.value === endDt.value) {
    return { ok: false, message: '시작 시간과 종료 시간이 같습니다. 종료 시간을 더 늦게 설정해 주세요.' }
  }
  if (startDt.value > endDt.value) {
    return { ok: false, message: '종료 시간이 시작 시간보다 빠릅니다. 종료 시간을 더 늦게 설정해 주세요.' }
  }

  return { ok: true, message: '' }
}

const currentKey = () => {
  return [
    beneficiaryId.value,
    careWorkerId.value,
    serviceTypeIdNum.value,
    date.value,
    startTime.value,
    endTime.value,
  ].join('|')
}

const checkConflictsInStash = (s, e, nextBeneficiaryId, nextCareWorkerId) => {
  const caregiverConflict = items.value.some((x) => {
    if (x.careWorkerId !== nextCareWorkerId) return false
    return overlaps(s, e, x.startDt, x.endDt)
  })

  if (caregiverConflict) {
    return {
      ok: false,
      message: '같은 요양보호사 일정 시간이 겹칩니다. 다른 시간으로 진행해 주세요.',
    }
  }

  const beneficiaryConflict = items.value.some((x) => {
    if (x.beneficiaryId !== nextBeneficiaryId) return false
    return overlaps(s, e, x.startDt, x.endDt)
  })

  if (beneficiaryConflict) {
    return {
      ok: false,
      message: '같은 수급자 일정 시간이 겹칩니다. 같은 시간대에는 하나의 일정만 가능합니다.',
    }
  }

  return { ok: true, message: '' }
}

const onClickStash = () => {
  const v = validateForm()
  if (!v.ok) {
    alert(v.message)
    return
  }

  const key = currentKey()
  if (items.value.some((x) => x.key === key)) {
    alert('이미 담긴 일정입니다.')
    return
  }

  const s = startDt.value
  const e = endDt.value

  const c = checkConflictsInStash(s, e, beneficiaryId.value, careWorkerId.value)
  if (!c.ok) {
    alert(c.message)
    return
  }

  items.value.push({
    key,
    beneficiaryId: beneficiaryId.value,
    careWorkerId: careWorkerId.value,
    serviceTypeId: serviceTypeIdNum.value,
    date: date.value,
    startTime: startTime.value,
    endTime: endTime.value,
    startDt: s,
    endDt: e,
    note: memo.value,
    beneficiaryName: selectedRecipient.value?.beneficiaryName ?? selectedRecipient.value?.name ?? '',
    caregiverName: selectedCaregiver.value?.careWorkerName ?? selectedCaregiver.value?.name ?? '',
  })

  resetFormFields()
  viewMode.value = 'stash'
}

const removeItem = (idx) => {
  items.value.splice(idx, 1)
}

const clearAll = () => {
  items.value = []
}

const onClickCreateAll = () => {
  if (!Array.isArray(items.value) || items.value.length === 0) return

  const invalid = items.value.some(
    (x) => !x.beneficiaryId || !x.careWorkerId || !x.serviceTypeId || !x.startDt || !x.endDt
  )
  if (invalid) {
    alert('담긴 일정 중 필수 값이 누락된 항목이 있습니다.')
    return
  }

  const local = [...items.value]
  const errors = []

  local.forEach((x, i) => {
    const key = x.key ?? `row-${i}`
    const s = x.startDt
    const e = x.endDt

    if (!s || !e) {
      errors.push('날짜/시간 값이 올바르지 않은 일정이 있습니다.')
      return
    }
    if (s === e) {
      errors.push('시작 시간과 종료 시간이 같은 일정이 있습니다.')
      return
    }
    if (s > e) {
      errors.push('종료 시간이 시작 시간보다 빠른 일정이 있습니다.')
      return
    }

    const c1 = local.some((y, j) => {
      if (i === j) return false
      if (y.careWorkerId !== x.careWorkerId) return false
      return overlaps(s, e, y.startDt, y.endDt)
    })
    if (c1) errors.push('담긴 일정 중 같은 요양보호사 시간대가 겹치는 항목이 있습니다.')

    const c2 = local.some((y, j) => {
      if (i === j) return false
      if (y.beneficiaryId !== x.beneficiaryId) return false
      return overlaps(s, e, y.startDt, y.endDt)
    })
    if (c2) errors.push('담긴 일정 중 같은 수급자 시간대가 겹치는 항목이 있습니다.')

    if (!x.key) x.key = key
  })

  if (errors.length) {
    alert([...new Set(errors)].join('\n'))
    return
  }

  const payload = local.map((x) => ({
    beneficiaryId: x.beneficiaryId,
    careWorkerId: x.careWorkerId,
    serviceTypeId: x.serviceTypeId,
    startDt: x.startDt,
    endDt: x.endDt,
    note: x.note ?? '',
  }))

  emit('create', payload)
}
</script>
<style scoped>
.overlay {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.modal {
  width: 1200px;
  max-width: calc(100vw - 40px);
  height: calc(100vh - 80px);
  background: #fff;
  border-radius: 18px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 18px 48px rgba(15, 23, 42, 0.18);
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.modal-header {
  padding: 16px 18px;
  border-bottom: 1px solid #eef2f7;
  flex: 0 0 auto;
}

.modal-title {
  margin: 0;
  font-size: 16px;
  font-weight: 900;
  color: #0f172a;
}

.modal-body {
  padding: 14px 18px;
  flex: 1;
  min-height: 0;
  overflow: hidden;
}

.grid {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 16px;
  height: 100%;
  min-height: 0;
}

.col-scroll {
  min-height: 0;
  overflow: auto;
  border: 1px solid #e7edf6;
  border-radius: 16px;
  background: #fff;
}

.right-wrap {
  min-height: 0;
  overflow: hidden;
  border: 1px solid #e7edf6;
  border-radius: 16px;
  background: #fff;
  padding: 16px;
  display: flex;
  flex-direction: column;
}

.hint {
  height: 100%;
  min-height: 0;
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 22px;
  gap: 10px;
  color: #0f172a;
}

.hint-title {
  font-size: 16px;
  font-weight: 900;
}

.hint-sub {
  font-size: 13px;
  color: #64748b;
  font-weight: 800;
  line-height: 1.6;
}

.modal-footer {
  padding: 12px 18px;
  border-top: 1px solid #eef2f7;
  display: flex;
  justify-content: flex-end;
  flex: 0 0 auto;
}

.btn {
  border: 1px solid #e7edf6;
  background: #fff;
  border-radius: 12px;
  padding: 10px 16px;
  cursor: pointer;
  font-weight: 900;
}
</style>