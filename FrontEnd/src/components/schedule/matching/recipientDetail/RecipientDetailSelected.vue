<template>
  <section class="recipient-detail">
    <div v-if="loading" class="loading">불러오는 중...</div>
    <div v-else-if="error" class="error">{{ error }}</div>

    <template v-else>
      <header class="header-row">
        <div class="basic-info">
          <div class="name-row">
            <span class="name">{{ viewModel.name }}</span>
            <span class="badge grade">{{ viewModel.grade }}</span>
            <span
              class="badge gender"
              :class="viewModel.gender === '여자' ? 'female' : 'male'"
            >
              {{ viewModel.gender }}
            </span>
          </div>
          <p class="address">{{ viewModel.address }}</p>
        </div>
      </header>

      <div class="info-section">
        <div class="column">
          <div class="field">
            <div class="label">연락처</div>
            <div class="value">{{ viewModel.phone || '-' }}</div>
          </div>

          <div class="field">
            <div class="label">필요 서비스</div>
            <div class="value">
              <template v-if="viewModel.needServices?.length">
                <span v-for="s in viewModel.needServices" :key="s" class="pill pill-soft">
                  {{ s }}
                </span>
              </template>
              <span v-else>-</span>
            </div>
          </div>

          <div class="field">
            <div class="label">위험요소</div>
            <div class="value">
              <template v-if="viewModel.riskFactors?.length">
                <span v-for="r in viewModel.riskFactors" :key="r" class="pill pill-risk">
                  {{ r }}
                </span>
              </template>
              <span v-else>-</span>
            </div>
          </div>

          <div class="field">
            <div class="label">태그</div>
            <div class="value">
              <template v-if="viewModel.needTags?.length">
                <span v-for="t in viewModel.needTags" :key="t" class="pill pill-tag">
                  {{ t }}
                </span>
              </template>
              <span v-else>-</span>
            </div>
          </div>

          <div class="field">
            <div class="label-row">
              <div class="label">희망 요일</div>

              <button type="button" class="edit-schedule-btn" @click="openScheduleModal">
                희망 요일/시간 변경하기
              </button>
            </div>

            <div class="value">
              <template v-if="viewModel.preferredDays?.length">
                <span v-for="d in viewModel.preferredDays" :key="d" class="day-pill">
                  {{ d }}
                </span>
              </template>
              <span v-else>-</span>
            </div>
          </div>

          <div class="field">
            <div class="label">희망 시간</div>
            <div class="time-list">
              <template v-if="viewModel.preferredTimes?.length">
                <div v-for="(t, idx) in viewModel.preferredTimes" :key="idx" class="time-row">
                  <img :src="clockIcon" alt="" class="clock-icon" />
                  <span>{{ t }}</span>
                </div>
              </template>
              <div v-else class="value">-</div>
            </div>
          </div>
        </div>
      </div>

      <section class="assigned-section">
        <h3 class="assigned-title">배정된 요양보호사</h3>

        <article
          v-if="viewModel.assignedCareWorker"
          class="assigned-card"
          role="button"
          tabindex="0"
          @click="selectAssignedCareWorker"
          @keydown.enter.prevent="selectAssignedCareWorker"
          @keydown.space.prevent="selectAssignedCareWorker"
        >
          <div class="assigned-left">
            <div class="assigned-main">
              <div class="assigned-row">
                <span class="assigned-name">{{ viewModel.assignedCareWorker.name }}</span>
                <span
                  class="badge gender small"
                  :class="viewModel.assignedCareWorker.gender === '여자' ? 'female' : 'male'"
                >
                  {{ viewModel.assignedCareWorker.gender }}
                </span>
              </div>

              <div class="assigned-meta">
                <span>배정일: {{ viewModel.assignedCareWorker.startDate || '-' }}</span>
              </div>
            </div>
          </div>

          <button type="button" class="close-btn" @click.stop="openUnassignModal">
            <img :src="closeButton" alt="배정 취소" />
          </button>
        </article>

        <p v-else class="assigned-empty">배정된 요양보호사가 없습니다</p>
      </section>

      <teleport to="body">
        <div
          v-if="showUnassignModal"
          class="modal-backdrop"
          @click.self="closeUnassignModal"
        >
          <div class="modal">
            <h3 class="modal-title">배정 취소</h3>
            <p class="modal-desc">정말 배정을 삭제할까요?</p>

            <div class="field">
              <div class="label">기준일</div>
              <input
                type="date"
                v-model="unassignEffectiveDate"
                :min="todayYmd"
                class="date-input"
              />
            </div>

            <div class="modal-actions">
              <button type="button" class="modal-btn cancel" @click="closeUnassignModal">
                취소
              </button>
              <button
                type="button"
                class="modal-btn danger"
                :disabled="!unassignEffectiveDate"
                @click="confirmUnassign"
              >
                삭제
              </button>
            </div>
          </div>
        </div>

        <div
          v-if="showScheduleModal"
          class="modal-backdrop"
          @click.self="closeScheduleModal"
        >
          <div class="modal schedule-modal">
            <div class="schedule-modal-header">
              <h3 class="modal-title">희망 요일/시간 변경</h3>
            </div>

            <div class="schedule-modal-body">
              <EditScheduleModalBody
                ref="editBodyRef"
                :beneficiaryId="viewModel.beneficiaryId"
                :recipientName="viewModel.name"
                :schedules="viewModel.schedules"
                :serviceTypeId="
                  viewModel.serviceTypeId
                  ?? viewModel.schedules?.[0]?.serviceTypeId
                  ?? viewModel.schedules?.[0]?.service_type_id
                  ?? null
                "
                :serviceTypeName="
                  viewModel.serviceTypeName
                  ?? viewModel.schedules?.[0]?.serviceTypeName
                  ?? viewModel.schedules?.[0]?.service_type_name
                  ?? ''
                "
                :assignedCareWorker="viewModel.assignedCareWorker"
                :careWorkerWorkingTimes="careWorkerWorkingTimes"
                @saved="handleScheduleSaved"
              />
            </div>

            <div class="modal-actions schedule-actions">
              <button type="button" class="modal-btn cancel" @click="closeScheduleModal">
                닫기
              </button>
              <button
                type="button"
                class="modal-btn primary"
                :disabled="editBodySaving"
                @click="handleScheduleSave"
              >
                {{ editBodySaving ? '저장 중...' : '저장' }}
              </button>
            </div>
          </div>
        </div>
      </teleport>
    </template>
  </section>
</template>

<script setup>
  import { ref, computed, watch } from 'vue'
  import clockIcon from '@/assets/img/schedule/clock.png'
  import closeButton from '@/assets/img/common/closeButton.png'
  import {
    getBeneficiaryDetail,
    unassignMatchingCareWorker,
    getCareWorkerDetail,
  } from '@/api/schedule/matching.js'
  import { useMatchingSelectionStore } from '@/stores/matchingSelection'
  import EditScheduleModalBody from '@/components/schedule/matching/editSchedule/EditScheduleModalBody.vue'
  
  const props = defineProps({
    recipient: { type: Object, default: null },
  })
  
  const store = useMatchingSelectionStore()
  const emit = defineEmits(['unassigned', 'assigned-careworker'])
  
  const careWorkerWorkingTimes = ref([])
  
  const loading = ref(false)
  const error = ref('')
  const detail = ref(null)
  
  const showUnassignModal = ref(false)
  const showScheduleModal = ref(false)
  
  const unassignEffectiveDate = ref('')
  
  const editBodyRef = ref(null)
  const editBodySaving = computed(() => !!editBodyRef.value?.isSaving?.value)
  
  const pad2 = (n) => String(n).padStart(2, '0')
  const toYmd = (d) => `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`
  const todayYmd = computed(() => toYmd(new Date()))
  
  const getBeneficiaryId = (obj) => obj?.beneficiaryId ?? obj?.id ?? null
  const getCareWorkerId = (obj) => obj?.careWorkerId ?? obj?.id ?? null
  
  const pickServiceTypeId = (obj) =>
    obj?.serviceTypeId ??
    obj?.service_type_id ??
    obj?.serviceTypeIdFk ??
    obj?.serviceType?.id ??
    obj?.serviceType ??
    null
  
  const pickServiceTypeName = (obj) =>
    obj?.serviceTypeName ??
    obj?.service_type_name ??
    obj?.serviceTypeLabel ??
    obj?.serviceType?.name ??
    (typeof obj?.serviceType === 'string' ? obj.serviceType : '') ??
    ''
  
  const dayToKor = (day) => {
    const map = { 1: '월', 2: '화', 3: '수', 4: '목', 5: '금', 6: '토', 7: '일' }
    return map[day] || ''
  }
  
  const normalizeTime = (t) => {
    if (!t) return ''
    const s = String(t)
    return s.length >= 5 ? s.slice(0, 5) : s
  }
  
  const buildPreferredFromSchedules = (schedules = []) => {
    const daySet = new Set()
    const timeLabels = schedules
      .map((s) => {
        const d = s.dayName || dayToKor(s.day)
        const st = normalizeTime(s.startTime)
        const et = normalizeTime(s.endTime)
        if (!d || !st || !et) return null
        daySet.add(d)
        return `${d}요일 ${st}-${et}`
      })
      .filter(Boolean)
  
    return {
      preferredDays: Array.from(daySet),
      preferredTimes: timeLabels,
    }
  }
  
  const loadDetail = async () => {
    const beneficiaryId = getBeneficiaryId(props.recipient)
    if (!beneficiaryId) {
      detail.value = null
      return
    }
  
    try {
      loading.value = true
      error.value = ''
      const res = await getBeneficiaryDetail(beneficiaryId)
      detail.value = res?.data ?? res ?? null
      store.syncRecipient(detail.value)
    } catch (e) {
      error.value = e?.response?.data?.message || '상세 정보를 불러오지 못했습니다.'
      detail.value = null
    } finally {
      loading.value = false
    }
  }
  
  const loadCareWorkerWorkingTimes = async (cw) => {
    const careWorkerId = getCareWorkerId(cw)
    if (!careWorkerId) {
      careWorkerWorkingTimes.value = []
      return
    }
  
    try {
      const res = await getCareWorkerDetail(careWorkerId)
      const data = res?.data ?? res ?? {}
      const raw = data.workingTimes ?? data.workTimes ?? data.careWorkerWorkingTimes ?? []
      const list = Array.isArray(raw) ? raw : []
  
      careWorkerWorkingTimes.value = list.map((w) => ({
        dayName: w.dayName ?? w.day_name ?? w.dayKor ?? w.day ?? '',
        day: w.day ?? w.dayNum ?? w.day_no ?? w.dayNumber ?? w.day,
        startTime: w.startTime ?? w.start_time ?? w.start ?? '',
        endTime: w.endTime ?? w.end_time ?? w.end ?? '',
        serviceTypeName: w.serviceTypeName ?? w.service_type_name ?? w.serviceType ?? '',
      }))
    } catch (e) {
      careWorkerWorkingTimes.value = []
    }
  }
  
  const openScheduleModal = async () => {
    const cw = viewModel.value.assignedCareWorker
    if (cw) await loadCareWorkerWorkingTimes(cw)
    showScheduleModal.value = true
  }
  
  const closeScheduleModal = () => {
    showScheduleModal.value = false
  }
  
  const handleScheduleSave = async () => {
    const ok = await editBodyRef.value?.save?.()
    if (ok) {
      await loadDetail()
      store.refresh()
      closeScheduleModal()
    }
  }
  
  const handleScheduleSaved = async () => {
    await loadDetail()
    store.refresh()
  }
  
  const openUnassignModal = () => {
    unassignEffectiveDate.value = todayYmd.value
    showUnassignModal.value = true
  }
  
  const closeUnassignModal = () => {
    showUnassignModal.value = false
  }
  
  const confirmUnassign = async () => {
    const beneficiaryId = getBeneficiaryId(props.recipient)
    if (!beneficiaryId) return
  
    if (!unassignEffectiveDate.value) {
      alert('기준일을 선택해 주세요.')
      return
    }
  
    try {
      loading.value = true
      error.value = ''
  
      await unassignMatchingCareWorker(beneficiaryId, unassignEffectiveDate.value)
  
      await loadDetail()
  
      if (typeof store.clearCaregiver === 'function') {
        store.clearCaregiver()
      } else {
        store.caregiver = null
        store.caregiverId = null
        store.refresh()
      }
  
      careWorkerWorkingTimes.value = []
      emit('unassigned', { beneficiaryId })
    } catch (e) {
      error.value = e?.response?.data?.message || '배정 취소에 실패했습니다.'
    } finally {
      loading.value = false
      showUnassignModal.value = false
    }
  }
  
  watch(
    () => getBeneficiaryId(props.recipient),
    () => loadDetail(),
    { immediate: true }
  )
  
  const viewModel = computed(() => {
    const base = props.recipient || {}
    const d = detail.value || {}
  
    const grade = d.riskLevel || d.grade || base.riskLevel || base.grade || '-'
  
    const rawGender = d.gender ?? base.gender
    const gender = rawGender === 'M' ? '남자' : rawGender === 'F' ? '여자' : rawGender || '-'
  
    const schedules = d.schedules || d.beneficiarySchedules || []
  
    const serviceTypeId =
      pickServiceTypeId(d) ?? pickServiceTypeId(base) ?? pickServiceTypeId(schedules?.[0]) ?? null
    const serviceTypeName =
      pickServiceTypeName(d) ?? pickServiceTypeName(base) ?? pickServiceTypeName(schedules?.[0]) ?? ''
  
    const preferredFromSchedules = buildPreferredFromSchedules(schedules)
  
    const preferredTimes = d.preferredTimes || preferredFromSchedules.preferredTimes || base.preferredTimes || []
    const preferredDays = d.preferredDays || preferredFromSchedules.preferredDays || base.preferredDays || []
  
    const needServices = d.serviceTypes || d.needServices || base.serviceTypes || base.needServices || []
    const needTags = d.tags || d.needTags || base.tags || base.needTags || []
    const riskFactors = d.riskFactors || d.riskTags || d.risks || base.riskFactors || base.risks || []
  
    return {
      beneficiaryId: getBeneficiaryId(base),
      name: d.name ?? base.name ?? '-',
      grade,
      gender,
      address: d.address ?? base.address ?? '-',
      phone: d.phone ?? base.phone ?? '',
      needServices,
      needTags,
      riskFactors,
      preferredDays,
      preferredTimes,
      schedules,
      serviceTypeId,
      serviceTypeName,
      assignedCareWorker: d.assignedCareWorker || null,
    }
  })
  
  const selectAssignedCareWorker = () => {
    const cw = viewModel.value.assignedCareWorker
    if (!cw) return
    store.setCaregiver(cw)
    emit('assigned-careworker', cw)
  }
  
  watch(
    () => viewModel.value.assignedCareWorker,
    async (cw) => {
      if (!cw) {
        careWorkerWorkingTimes.value = []
        return
      }
      await loadCareWorkerWorkingTimes(cw)
      emit('assigned-careworker', cw)
    },
    { immediate: true }
  )
  </script>

<style scoped>
.recipient-detail {
  background: #faf5ff;
  border-radius: 16px;
  border: 1px solid #f3e8ff;
  padding: 24px 32px;
  min-height: 260px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.loading {
  padding: 16px;
  color: #6b7280;
}

.error {
  padding: 16px;
  color: #b91c1c;
  background: #fee2e2;
  border-radius: 12px;
  border: 1px solid #fecaca;
}

.header-row {
  display: flex;
  gap: 16px;
  align-items: center;
}

.basic-info {
  flex: 1;
}

.name-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

.name {
  font-size: 20px;
  font-weight: 700;
  color: #166534;
}

.badge {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 12px;
}

.badge.grade {
  background: #f3e8ff;
  color: #6d28d9;
}

.badge.gender {
  background: #dbeafe;
  color: #1d4ed8;
}

.badge.gender.female {
  background: #fee2e2;
  color: #be123c;
}

.badge.small {
  font-size: 11px;
  padding: 2px 8px;
}

.address {
  margin: 0;
  font-size: 14px;
  color: #4b5563;
}

.info-section {
  display: flex;
  gap: 40px;
  margin-top: 12px;
}

.column {
  flex: 1;
}

.field {
  margin-bottom: 14px;
}

.label {
  font-size: 13px;
  color: #6b7280;
  margin-bottom: 4px;
}

.value {
  font-size: 14px;
  color: #111827;
}

.pill {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 12px;
  margin-right: 6px;
  margin-bottom: 6px;
  background: #dcfce7;
  color: #15803d;
}

.pill-soft {
  background: #eef2ff;
  color: #4f46e5;
}

.pill-risk {
  background: #ffedd5;
  color: #c2410c;
}

.pill-tag {
  background: #ecfeff;
  color: #0f766e;
}

.day-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 8px;
  background: #eef2ff;
  color: #4f46e5;
  font-size: 13px;
  margin-right: 6px;
}

.time-list {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.time-row {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #111827;
}

.clock-icon {
  width: 16px;
  height: 16px;
  object-fit: contain;
}

.assigned-section {
  margin-top: 12px;
}

.assigned-title {
  margin: 0 0 8px;
  font-size: 15px;
  font-weight: 600;
  color: #111827;
}

.assigned-empty {
  margin: 12px 0 0;
  font-size: 14px;
  color: #9ca3af;
  text-align: center;
  padding: 20px 0;
  background: #f9fafb;
  border-radius: 12px;
}

.assigned-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #ffffff;
  border-radius: 14px;
  padding: 14px 18px;
  border: 1px solid #e5e7eb;
  position: relative;
  cursor: pointer;
}

.assigned-card:focus {
  outline: none;
}

.assigned-left {
  display: flex;
  gap: 12px;
  align-items: center;
}

.assigned-main {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.assigned-row {
  display: flex;
  align-items: center;
  gap: 6px;
}

.assigned-name {
  font-size: 15px;
  font-weight: 600;
  color: #111827;
}

.assigned-meta {
  font-size: 13px;
  color: #6b7280;
}

.close-btn {
  position: absolute;
  top: 7px;
  right: 7px;
  width: 24px;
  height: 24px;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.close-btn img {
  width: 16px;
  height: 14px;
}

.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(17, 24, 39, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.modal {
  width: 360px;
  max-width: calc(100vw - 32px);
  background: #fff;
  border-radius: 16px;
  padding: 18px 18px 14px;
  border: 1px solid #e5e7eb;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
  box-sizing: border-box;
}

.modal-title {
  margin: 0 0 6px;
  font-size: 16px;
  font-weight: 700;
  color: #111827;
}

.modal-desc {
  margin: 0 0 14px;
  font-size: 14px;
  color: #4b5563;
}

.modal .field {
  margin: 10px 0 14px;
}

.modal .field .label {
  margin-bottom: 6px;
}

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

.modal-btn {
  height: 38px;
  padding: 0 14px;
  border-radius: 12px;
  font-size: 14px;
  border: 1px solid transparent;
  cursor: pointer;
}

.modal-btn.cancel {
  background: #f3f4f6;
  color: #111827;
  border-color: #e5e7eb;
}

.modal-btn.danger {
  background: #ef4444;
  color: #fff;
}

.modal-btn.primary {
  background: #4f46e5;
  color: #fff;
  border-color: #4f46e5;
}

.modal-btn.primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.modal-btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.date-input {
  display: block;
  width: 100%;
  height: 38px;
  padding: 0 12px;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
  background: #fff;
  font-size: 14px;
  color: #111827;
  box-sizing: border-box;
}

.label-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  margin-bottom: 4px;
}

.edit-schedule-btn {
  height: 30px;
  padding: 0 10px;
  border-radius: 10px;
  border: 1px solid #e5e7eb;
  background: #ffffff;
  font-size: 12px;
  color: #4f46e5;
  cursor: pointer;
  white-space: nowrap;
}

.edit-schedule-btn:hover {
  background: #f3f4f6;
}

.schedule-modal {
  width: 980px;
  max-width: calc(100vw - 32px);
  border-radius: 18px;
  padding: 18px;
}

.schedule-modal-header {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  padding-bottom: 12px;
  border-bottom: 1px solid #f3f4f6;
  margin-bottom: 12px;
}

.schedule-modal-body {
  max-height: calc(100vh - 230px);
  overflow: auto;
}

.schedule-actions {
  padding-top: 14px;
  margin-top: 14px;
  border-top: 1px solid #f3f4f6;
}
</style>