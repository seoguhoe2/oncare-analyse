<template>
  <section class="panel">
    <header class="panel-header">
      <div class="panel-title">수급자 희망 요일/시간</div>
      <div class="panel-sub">{{ recipientName || '-' }}</div>
    </header>

    <div class="block">
      <div class="block-title">등록된 희망 시간</div>

      <div v-if="rows.length" class="list">
        <div v-for="row in rows" :key="row.key" class="row">
          <select v-model="row.day" class="select">
            <option v-for="d in dayOptions" :key="d.value" :value="d.value">
              {{ d.label }}
            </option>
          </select>

          <input v-model="row.startTime" type="time" class="time" />
          <span class="dash">-</span>
          <input v-model="row.endTime" type="time" class="time" />

          <div class="service-pill" :title="serviceTypeText(row)">
            {{ serviceTypeText(row) }}
          </div>

          <button
            type="button"
            class="icon-btn danger"
            :disabled="rows.length <= 1"
            :title="rows.length <= 1 ? '희망 시간은 최소 1개 이상 남아야 합니다.' : '삭제'"
            @click="removeRow(row.key)"
          >
            삭제
          </button>
        </div>
      </div>

      <div v-else class="empty">-</div>

      <div class="add-box">
        <button type="button" class="btn" @click="addRow">+ 희망 시간 추가</button>

        <div class="effective-box">
          <div class="effective-label">기준일</div>
          <input
            type="date"
            class="effective-date"
            v-model="effectiveDate"
            :min="todayYmd"
          />
        </div>
      </div>
    </div>

    <p v-if="localError" class="local-error">{{ localError }}</p>
  </section>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import {
  createBeneficiarySchedule,
  updateBeneficiarySchedule,
  deleteBeneficiarySchedule,
} from '@/api/schedule/beneficiaryScheduleApi.js'

const props = defineProps({
  beneficiaryId: { type: [Number, String], default: null },
  recipientName: { type: String, default: '' },
  schedules: { type: Array, default: () => [] },

  serviceTypeId: { type: [Number, String], default: null },
  serviceTypeName: { type: String, default: '' },

  serviceTypeLabelMap: { type: Object, default: () => ({}) },
})

const emit = defineEmits(['saved'])

const saving = ref(false)
const localError = ref('')

const dayOptions = [
  { value: 1, label: '월' },
  { value: 2, label: '화' },
  { value: 3, label: '수' },
  { value: 4, label: '목' },
  { value: 5, label: '금' },
  { value: 6, label: '토' },
  { value: 7, label: '일' },
]

const normalizeTime = (t) => {
  if (!t) return ''
  const s = String(t)
  return s.length >= 5 ? s.slice(0, 5) : s
}

const toSeconds = (hhmm) => {
  if (!hhmm) return ''
  const s = String(hhmm)
  if (s.length === 5) return `${s}:00`
  return s
}

const pad2 = (n) => String(n).padStart(2, '0')
const toYmd = (d) => `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`
const todayYmd = computed(() => toYmd(new Date()))

const effectiveDate = ref(todayYmd.value)

const makeKey = () => `tmp-${Math.random().toString(16).slice(2)}-${Date.now()}`
const rows = ref([])

const snapshotIds = ref(new Set())

const pickScheduleId = (s) =>
  s?.id ?? s?.beneficiaryScheduleId ?? s?.beneficiary_schedule_id ?? s?.scheduleId ?? null

const pickServiceTypeId = (s) =>
  s?.serviceTypeId ?? s?.service_type_id ?? s?.serviceTypeIdFk ?? s?.serviceType ?? null

const pickServiceTypeName = (s) =>
  s?.serviceTypeName ?? s?.service_type_name ?? s?.serviceTypeLabel ?? s?.serviceType ?? ''

const resetFromProps = () => {
  const list = Array.isArray(props.schedules) ? props.schedules : []

  rows.value = list
    .map((s) => {
      const sid = pickServiceTypeId(s) ?? props.serviceTypeId ?? null
      const sname = pickServiceTypeName(s) || props.serviceTypeName || ''
      const id = pickScheduleId(s)

      return {
        key: id != null ? `id-${id}` : makeKey(),
        id,
        day: Number(s.day ?? 1),
        startTime: normalizeTime(s.startTime),
        endTime: normalizeTime(s.endTime),
        serviceTypeId: sid,
        serviceTypeName: sname,
      }
    })
    .sort((a, b) => a.day - b.day || a.startTime.localeCompare(b.startTime))

  snapshotIds.value = new Set(list.map((s) => pickScheduleId(s)).filter((id) => id != null))

  if (rows.value.length === 0) {
    rows.value.push({
      key: makeKey(),
      id: null,
      day: 1,
      startTime: '09:00',
      endTime: '10:00',
      serviceTypeId: props.serviceTypeId ?? null,
      serviceTypeName: props.serviceTypeName || '',
    })
  }

  if (!effectiveDate.value) effectiveDate.value = todayYmd.value
}

watch(
  () => props.schedules,
  () => resetFromProps(),
  { immediate: true }
)

const addRow = () => {
  localError.value = ''
  rows.value.push({
    key: makeKey(),
    id: null,
    day: 1,
    startTime: '09:00',
    endTime: '10:00',
    serviceTypeId: props.serviceTypeId ?? null,
    serviceTypeName: props.serviceTypeName || '',
  })
}

const removeRow = (key) => {
  if (rows.value.length <= 1) {
    localError.value = '희망 시간은 최소 1개 이상 남아야 합니다.'
    return
  }
  localError.value = ''
  rows.value = rows.value.filter((r) => r.key !== key)
}

const payload = computed(() =>
  rows.value.map((r) => ({
    id: r.id,
    day: r.day,
    startTime: r.startTime,
    endTime: r.endTime,
    serviceTypeId: r.serviceTypeId ?? props.serviceTypeId ?? null,
    serviceTypeName: r.serviceTypeName || props.serviceTypeName || '',
  }))
)

const validate = () => {
  localError.value = ''

  if (!props.beneficiaryId) {
    localError.value = '수급자 ID가 없어 저장할 수 없습니다.'
    return false
  }

  if (rows.value.length < 1) {
    localError.value = '희망 시간은 최소 1개 이상 등록해야 합니다.'
    return false
  }

  const finalServiceTypeId = props.serviceTypeId ?? payload.value[0]?.serviceTypeId ?? null
  if (!finalServiceTypeId) {
    localError.value = '서비스 타입이 없어 저장할 수 없습니다.'
    return false
  }

  if (!effectiveDate.value) {
    localError.value = '기준일을 선택해 주세요.'
    return false
  }

  const hasEmpty = rows.value.some((r) => !r.day || !r.startTime || !r.endTime)
  if (hasEmpty) {
    localError.value = '요일/시간을 모두 입력해 주세요.'
    return false
  }

  const hasInvalidRange = rows.value.some((r) => r.startTime >= r.endTime)
  if (hasInvalidRange) {
    localError.value = '시작 시간이 종료 시간보다 빠르도록 입력해 주세요.'
    return false
  }

  const byDay = rows.value.reduce((acc, r) => {
    const k = String(r.day)
    if (!acc[k]) acc[k] = []
    acc[k].push(r)
    return acc
  }, {})

  const hasOverlap = Object.values(byDay).some((arr) => {
    const sorted = arr.slice().sort((a, b) => a.startTime.localeCompare(b.startTime))
    return sorted.slice(0, -1).some((cur, i) => cur.endTime > sorted[i + 1].startTime)
  })

  if (hasOverlap) {
    localError.value = '같은 요일에 시간이 겹치는 구간이 있습니다.'
    return false
  }

  return true
}

const serviceTypeText = (row) => {
  const name = row?.serviceTypeName || props.serviceTypeName
  if (name) return name

  const id = row?.serviceTypeId ?? props.serviceTypeId
  if (id != null && props.serviceTypeLabelMap && props.serviceTypeLabelMap[id]) {
    return props.serviceTypeLabelMap[id]
  }

  return '서비스타입'
}

const handleSave = async () => {
  if (!validate()) return false

  try {
    saving.value = true
    localError.value = ''

    const prevList = Array.isArray(props.schedules) ? props.schedules : []

    const existingMap = new Map(
      prevList
        .map((s) => {
          const id = pickScheduleId(s)
          if (id == null) return null
          const sid = pickServiceTypeId(s) ?? props.serviceTypeId ?? null
          return [
            id,
            {
              id,
              day: Number(s.day ?? 1),
              startTime: normalizeTime(s.startTime),
              endTime: normalizeTime(s.endTime),
              serviceTypeId: sid,
            },
          ]
        })
        .filter(Boolean)
    )

    const current = payload.value

    const toCreate = current.filter((r) => r.id == null)

    const toUpdate = current
      .filter((r) => r.id != null)
      .filter((r) => {
        const prev = existingMap.get(r.id)
        if (!prev) return true
        return (
          Number(prev.day) !== Number(r.day) ||
          prev.startTime !== r.startTime ||
          prev.endTime !== r.endTime ||
          String(prev.serviceTypeId ?? '') !== String(r.serviceTypeId ?? '')
        )
      })

    const currentIds = new Set(current.map((r) => r.id).filter((id) => id != null))
    const toDelete = Array.from(snapshotIds.value).filter((id) => !currentIds.has(id))

    for (const id of toDelete) {
      await deleteBeneficiarySchedule(id, effectiveDate.value)
    }

    for (const r of toUpdate) {
      const sid = r.serviceTypeId ?? props.serviceTypeId ?? null
      await updateBeneficiarySchedule(r.id, {
        day: r.day,
        startTime: toSeconds(r.startTime),
        endTime: toSeconds(r.endTime),
        serviceTypeId: sid,
        effectiveDate: effectiveDate.value,
      })
    }

    for (const r of toCreate) {
      const sid = r.serviceTypeId ?? props.serviceTypeId ?? null
      await createBeneficiarySchedule({
        day: r.day,
        startTime: toSeconds(r.startTime),
        endTime: toSeconds(r.endTime),
        beneficiaryId: props.beneficiaryId,
        serviceTypeId: sid,
        effectiveDate: effectiveDate.value,
      })
    }

    emit('saved', current)
    return true
  } catch (e) {
    const data = e?.response?.data
    localError.value =
      (typeof data === 'string' ? data : data?.message) || e?.message || '저장에 실패했습니다.'
    return false
  } finally {
    saving.value = false
  }
}

defineExpose({
  handleSave,
  saving,
})
</script>

<style scoped>
.panel {
  border: 1px solid #e5e7eb;
  border-radius: 16px;
  background: #ffffff;
  padding: 14px;
}

.panel-header {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 12px;
  padding-bottom: 10px;
  border-bottom: 1px solid #f3f4f6;
  margin-bottom: 10px;
}

.panel-title {
  font-size: 14px;
  font-weight: 800;
  color: #111827;
}

.panel-sub {
  font-size: 12px;
  color: #6b7280;
  max-width: 220px;
  text-align: right;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.block {
  margin-top: 8px;
}

.block-title {
  font-size: 12px;
  font-weight: 700;
  color: #374151;
  margin-bottom: 8px;
}

.list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.row {
  display: grid;
  grid-template-columns: 76px minmax(140px, 1fr) 14px minmax(140px, 1fr) 120px 64px;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border: 1px solid #eef2f7;
  border-radius: 16px;
  background: #fbfbfd;
}

.select,
.time {
  width: 100%;
  height: 34px;
  padding: 0 10px;
  border-radius: 14px;
  border: 1px solid #e5e7eb;
  background: #fff;
  font-size: 13px;
  color: #111827;
  box-sizing: border-box;
}

.select:focus,
.time:focus {
  outline: none;
  border-color: #a5b4fc;
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
}

.dash {
  text-align: center;
  color: #9ca3af;
  font-size: 12px;
}

.service-pill {
  height: 34px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0 12px;
  border-radius: 999px;
  border: 1px solid #e0e7ff;
  background: #eef2ff;
  color: #3730a3;
  font-size: 12px;
  font-weight: 700;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.icon-btn {
  height: 34px;
  padding: 0 10px;
  border-radius: 14px;
  border: 1px solid #e5e7eb;
  background: #fff;
  font-size: 12px;
  cursor: pointer;
  white-space: nowrap;
}

.icon-btn.danger {
  border-color: #fecaca;
  color: #b91c1c;
  background: #fff;
}

.icon-btn.danger:hover {
  background: #fff5f5;
  border-color: #fca5a5;
}

.icon-btn:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}
.icon-btn.danger:disabled:hover {
  background: #fff;
  border-color: #fecaca;
}

.add-box {
  margin-top: 10px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.btn {
  height: 34px;
  padding: 0 14px;
  border-radius: 14px;
  font-size: 13px;
  border: 1px solid #e5e7eb;
  background: #ffffff;
  cursor: pointer;
}

.btn:hover {
  background: #f9fafb;
}

.effective-box {
  display: flex;
  align-items: center;
  gap: 10px;
}

.effective-label {
  font-size: 12px;
  color: #6b7280;
  font-weight: 700;
  white-space: nowrap;
}

.effective-date {
  height: 34px;
  padding: 0 10px;
  border-radius: 14px;
  border: 1px solid #e5e7eb;
  background: #fff;
  font-size: 13px;
  color: #111827;
  box-sizing: border-box;
}

.empty {
  font-size: 13px;
  color: #9ca3af;
  padding: 8px 0;
}

.local-error {
  margin-top: 10px;
  padding: 10px 12px;
  border-radius: 12px;
  background: #fee2e2;
  border: 1px solid #fecaca;
  color: #b91c1c;
  font-size: 12px;
}
</style>