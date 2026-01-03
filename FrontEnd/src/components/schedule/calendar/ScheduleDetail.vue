<template>
  <section class="detail-panel">
    <div v-if="!viewModel" class="placeholder">
      <div class="placeholder-icon">
        <img :src="scheduleManagementIcon" alt="일정 선택" class="calendar-icon-img" />
      </div>
      <p class="placeholder-main">일정을 선택하면</p>
      <p class="placeholder-sub">상세 정보가 표시됩니다</p>
    </div>

    <div v-else class="detail-content">
      <div class="detail-header">
        <div class="header-top">
          <h3 class="detail-title">일정 상세</h3>
          <button class="close-btn" type="button" @click="onClose">
            <img :src="closeIcon" alt="close" />
          </button>
        </div>

        <div class="header-bottom">
          <span class="type-pill" :class="typePillClass(viewModel.serviceTypeId)">
            {{ viewModel.serviceTypeName }}
          </span>

          <StatusToast
            v-model:show="showToast"
            :message="toastMessage"
            :type="toastType"
          />
        </div>
      </div>

      <div class="detail-body">
        <div class="top-grid">
          <div class="schedule-box">
            <div class="schedule-box-head">
              <div class="head-left">
                <img :src="detailClockIcon" alt="clock" class="schedule-icon" />
                <span class="schedule-title">일정</span>
              </div>

              <div v-if="isConfirmed" class="head-right">
                <button class="action-btn edit" type="button" @click="onClickEdit">
                  일정 수정
                </button>
                <button class="action-btn delete" type="button" @click="onClickDelete">
                  일정 삭제
                </button>
              </div>
            </div>

            <div class="schedule-rows">
              <div class="info-row">
                <span class="label">날짜:</span>
                <span class="value">{{ formatDate(viewModel.date) }}</span>
              </div>
              <div class="info-row">
                <span class="label">시작:</span>
                <span class="value">{{ formatTimeHM(viewModel.startTime) }}</span>
              </div>
              <div class="info-row">
                <span class="label">종료:</span>
                <span class="value">{{ formatTimeHM(viewModel.endTime) }}</span>
              </div>
              <div class="info-row">
                <span class="label">소요시간:</span>
                <span class="value strong">{{ formatDuration(viewModel.durationMinutes) }}</span>
              </div>
            </div>
          </div>

          <div class="person-col">
            <div class="person-card">
              <img :src="memberIcon" alt="member" class="member-icon" />
              <div class="person-text">수급자&nbsp;&nbsp;{{ viewModel.beneficiaryName }}</div>
            </div>

            <div class="person-card">
              <img :src="memberIcon" alt="member" class="member-icon" />
              <div class="person-text">요양보호사&nbsp;&nbsp;{{ viewModel.careWorkerName }}</div>
            </div>

            <div class="person-card status-card">
              <div
                v-if="viewModel.status"
                class="status-pill"
                :class="statusClass(viewModel.status)"
              >
                {{ statusLabel(viewModel.status) }}
              </div>
              <div v-else class="status-pill status-empty">-</div>
            </div>
          </div>
        </div>

        <AlternateCareWorkers
          :beneficiary-id="viewModel?.beneficiaryId ?? null"
          :source="isConfirmed ? 'CONFIRMED' : 'NORMAL'"
          :matching-id="viewModel?.matchingId ?? null"
          :vs-id="viewModel?.vsId ?? null"
          :schedule-date="formatDate(viewModel?.date) ?? ''"
          :start-time="formatTimeHM(viewModel?.startTime) ?? ''"
          :end-time="formatTimeHM(viewModel?.endTime) ?? ''"
          @changed="onCareWorkerChanged"
        />
        
        <ScheduleMemo
          :source="schedule?.source || 'NORMAL'"
          :matching-id="viewModel?.matchingId ?? null"
          :vs-id="viewModel?.vsId ?? schedule?.vsId ?? null"
          :memo-date="formatDate(viewModel?.date)"
        />
      </div>
    </div>

    <ConfirmedScheduleTimeEditModal
      :open="showEditModal"
      :vs-id="viewModel?.vsId"
      :date="formatDate(viewModel?.date)"
      :start-time="formatTimeHM(viewModel?.startTime)"
      :end-time="formatTimeHM(viewModel?.endTime)"
      :loading="editLoading"
      :server-error="editModalError"
      @close="showEditModal = false"
      @submit="onSubmitEditTime"
    />

    <ConfirmDeleteModal
      v-if="showDeleteModal"
      :loading="deleteLoading"
      title="일정 삭제"
      message="정말 삭제하시겠습니까?"
      confirm-text="예"
      cancel-text="아니오"
      @close="showDeleteModal = false"
      @confirm="onConfirmDelete"
    />
  </section>
</template>

<script setup>
  import { computed, ref, watch } from 'vue'
  
  import AlternateCareWorkers from '@/components/schedule/calendar/detail/AlternateCareWorkers.vue'
  import ScheduleMemo from '@/components/schedule/calendar/detail/ScheduleMemo.vue'
  
  import ConfirmDeleteModal from '@/components/schedule/calendar/detail/ConfirmDeleteModal.vue'
  import ConfirmedScheduleTimeEditModal from '@/components/schedule/calendar/detail/ConfirmedScheduleTimeEditModal.vue'
  
  import StatusToast from '@/components/schedule/calendar/detail/ScheduleToastMessage.vue'
  
  import { getScheduleDetail } from '@/api/schedule/scheduleApi'
  import { getConfirmedScheduleDetail } from '@/api/schedule/confirmedScheduleApi'
  import {
    updateConfirmedVisitScheduleTime,
    deleteConfirmedVisitSchedule,
  } from '@/api/schedule/confirmedScheduleApi'
  
  import detailClockIcon from '@/assets/img/schedule/detailClock.png'
  import memberIcon from '@/assets/img/schedule/member.png'
  import closeIcon from '@/assets/img/common/closeButton.png'
  import scheduleManagementIcon from '@/assets/img/common/scheduleManagement.png'
  
  const props = defineProps({
    schedule: { type: Object, default: null },
  })
  
  const emit = defineEmits(['close', 'refresh'])
  
  const loading = ref(false)
  const detail = ref(null)
  
  const schedule = computed(() => props.schedule || null)
  const viewModel = computed(() => detail.value || schedule.value || null)
  
  const isConfirmed = computed(() => schedule.value?.source === 'CONFIRMED')
  
  /* -------------------- formatter -------------------- */
  const formatDate = (v) => {
    const s = String(v ?? '')
    if (!s) return ''
    return s.includes('T') ? s.split('T')[0] : s.slice(0, 10)
  }
  
  const formatTimeHM = (t) => {
    const s = String(t ?? '')
    if (!s) return ''
    if (s.includes('T')) {
      const timePart = s.split('T')[1] || ''
      return timePart.slice(0, 5)
    }
    return s.slice(0, 5)
  }
  
  const formatDuration = (minutes) => {
    const m = Number(minutes)
    if (!Number.isFinite(m) || m <= 0) return '0분'
    const h = Math.floor(m / 60)
    const r = m % 60
    if (h <= 0) return `${r}분`
    if (r === 0) return `${h}시간`
    return `${h}시간 ${r}분`
  }
  
  /* ✅ CONFIRMED startDt/endDt 안전 생성 */
  const toDate = (v) => {
    const s = String(v ?? '').trim()
    if (!s) return ''
    return s.includes('T') ? s.split('T')[0] : s.slice(0, 10)
  }
  
  const toHM = (v) => {
    const s = String(v ?? '').trim()
    if (!s) return ''
    if (s.includes('T')) return (s.split('T')[1] || '').slice(0, 5)
    return s.slice(0, 5)
  }
  
  const normalizeDtString = (v) => {
    const s = String(v ?? '').trim()
    if (!s) return ''
    // '2025-12-03T10:00:00' -> '2025-12-03 10:00:00'
    return s.replace('T', ' ')
  }
  
  const buildDt = (date, hm) => {
    const d = toDate(date)
    const t = toHM(hm)
    if (!d || !t) return ''
    return `${d} ${t}:00` // 'YYYY-MM-DD HH:mm:00'
  }
  
  const confirmedStartDt = computed(() => {
    if (schedule.value?.source !== 'CONFIRMED') return ''
  
    // 1) 서버에서 startDt 내려주는 경우 우선
    const raw = viewModel.value?.startDt || viewModel.value?.startDtRaw
    if (raw) return normalizeDtString(raw)
  
    // 2) date + startTime으로 생성
    return buildDt(viewModel.value?.date, viewModel.value?.startTime)
  })
  
  const confirmedEndDt = computed(() => {
    if (schedule.value?.source !== 'CONFIRMED') return ''
  
    const raw = viewModel.value?.endDt || viewModel.value?.endDtRaw
    if (raw) return normalizeDtString(raw)
  
    return buildDt(viewModel.value?.date, viewModel.value?.endTime)
  })
  
  /* -------------------- pill / status -------------------- */
  const typePillClass = (serviceTypeId) => {
    const n = Number(serviceTypeId)
    if (n === 1) return 'pill-care'
    if (n === 2) return 'pill-bath'
    if (n === 3) return 'pill-nurse'
    return ''
  }
  
  const statusLabel = (status) => {
    const s = String(status ?? '').toUpperCase()
    if (s === 'SCHEDULED' || s === 'PLANNED') return '방문 예정'
    if (s === 'IN_PROGRESS') return '방문 진행중'
    if (s === 'DONE') return '방문 완료'
    return ''
  }
  
  const statusClass = (status) => {
    const s = String(status ?? '').toUpperCase()
    if (s === 'SCHEDULED' || s === 'PLANNED') return 'status-planned'
    if (s === 'IN_PROGRESS') return 'status-progress'
    if (s === 'DONE') return 'status-done'
    return ''
  }
  
  /* -------------------- 토스트 -------------------- */
  const toastMessage = ref('')
  const toastType = ref('warning')
  const showToast = ref(false)
  let toastTimer = null
  
  const openToast = (message, type = 'warning') => {
    const msg = String(message ?? '').trim()
    if (!msg) return
  
    toastMessage.value = msg
    toastType.value = type
  
    if (showToast.value) showToast.value = false
  
    clearTimeout(toastTimer)
    requestAnimationFrame(() => {
      showToast.value = true
      toastTimer = setTimeout(() => (showToast.value = false), 2600)
    })
  }
  
  const pickToastType = (msg) => {
    const m = String(msg ?? '')
    if (m.includes('완료') || m.includes('성공')) return 'success'
    return 'warning'
  }
  
  /* -------------------- 에러 메시지 파싱 -------------------- */
  const normalizeApiMessage = (e, fallback) => {
    const data = e?.response?.data
    if (typeof data === 'string' && data.trim()) return data.trim()
    if (data && typeof data === 'object') {
      const m = data.message || data.error || data.msg || data.detail
      if (typeof m === 'string' && m.trim()) return m.trim()
    }
    const m2 = e?.message
    if (typeof m2 === 'string' && m2.trim()) return m2.trim()
    return fallback
  }
  
  const prettifyBusinessMessage = (raw) => {
    const msg = String(raw ?? '').trim()
    const upper = msg.toUpperCase()
  
    if (msg.includes('진행') && msg.includes('시간 변경')) return '진행 중인 일정은 수정할 수 없습니다.'
    if (msg.includes('완료') && msg.includes('시간 변경')) return '완료된 일정은 수정할 수 없습니다.'
    if (msg.includes('진행') && msg.includes('삭제')) return '진행 중인 일정은 삭제할 수 없습니다.'
    if (msg.includes('완료') && msg.includes('삭제')) return '완료된 일정은 삭제할 수 없습니다.'
  
    if (upper.includes('CAREWORKER') || upper.includes('CAREGIVER')) {
      return '해당 시간에 요양보호사가 이미 배치되어 있어 수정할 수 없습니다.'
    }
    if (upper.includes('BENEFICIARY')) {
      return '해당 시간에 수급자 일정이 이미 존재하여 수정할 수 없습니다.'
    }
  
    return msg
  }
  
  const isOverlapMessage = (msg) => {
    const m = String(msg ?? '')
    const upper = m.toUpperCase()
  
    const careWorkerOverlap =
      m.includes('요양보호사') && (m.includes('배치') || m.includes('시간') || m.includes('일정'))
    const beneficiaryOverlap =
      m.includes('수급자') && (m.includes('일정') || m.includes('존재') || m.includes('배치'))
  
    const careWorkerOverlapEN = upper.includes('CAREWORKER') || upper.includes('CAREGIVER')
    const beneficiaryOverlapEN = upper.includes('BENEFICIARY')
  
    return careWorkerOverlap || beneficiaryOverlap || careWorkerOverlapEN || beneficiaryOverlapEN
  }
  
  /* -------------------- edit/delete block -------------------- */
  const showEditBlockedToast = (status) => {
    const s = String(status ?? '').toUpperCase()
    if (s === 'IN_PROGRESS') {
      openToast('진행 중인 일정은 수정할 수 없습니다.', 'warning')
      return true
    }
    if (s === 'DONE') {
      openToast('완료된 일정은 수정할 수 없습니다.', 'success')
      return true
    }
    return false
  }
  
  const showDeleteBlockedToast = (status) => {
    const s = String(status ?? '').toUpperCase()
    if (s === 'IN_PROGRESS') {
      openToast('진행 중인 일정은 삭제할 수 없습니다.', 'warning')
      return true
    }
    if (s === 'DONE') {
      openToast('완료된 일정은 삭제할 수 없습니다.', 'success')
      return true
    }
    return false
  }
  
  /* -------------------- detail load -------------------- */
  const loadDetail = async () => {
    detail.value = null
    if (!schedule.value) return
  
    loading.value = true
    try {
      const src = schedule.value.source
  
      if (src === 'CONFIRMED') {
        const vsId = schedule.value.vsId
        if (!vsId) {
          detail.value = schedule.value
          return
        }
        detail.value = await getConfirmedScheduleDetail({ vsId })
        return
      }
  
      detail.value = await getScheduleDetail({
        matchingId: schedule.value.matchingId,
        date: formatDate(schedule.value.date),
        serviceTypeId: schedule.value.serviceTypeId,
        startTime: schedule.value.startTime,
      })
    } catch (e) {
      detail.value = schedule.value
      console.error('[ScheduleDetail] loadDetail failed:', e)
    } finally {
      loading.value = false
    }
  }
  
  watch(
    () => schedule.value,
    () => loadDetail(),
    { immediate: true }
  )
  
  const onClose = () => emit('close')
  
  /* -------------------- modals -------------------- */
  const showEditModal = ref(false)
  const showDeleteModal = ref(false)
  const editLoading = ref(false)
  const deleteLoading = ref(false)
  const editModalError = ref('')
  
  const onClickEdit = () => {
    if (!isConfirmed.value) return
    if (!viewModel.value?.vsId) return
  
    const st = viewModel.value?.status
    if (showEditBlockedToast(st)) return
  
    editModalError.value = ''
    showEditModal.value = true
  }
  
  const onClickDelete = () => {
    if (!isConfirmed.value) return
    if (!viewModel.value?.vsId) return
  
    const st = viewModel.value?.status
    if (showDeleteBlockedToast(st)) return
  
    showDeleteModal.value = true
  }
  
  /* -------------------- update time -------------------- */
  const onSubmitEditTime = async ({ startDt, endDt }) => {
    try {
      const vsId = viewModel.value?.vsId
      if (!vsId) throw new Error('vsId is missing')
  
      editLoading.value = true
      editModalError.value = ''
  
      await updateConfirmedVisitScheduleTime({ vsId, startDt, endDt })
  
      showEditModal.value = false
  
      await loadDetail()
      emit('refresh')
      openToast('시간이 수정되었습니다.', 'success')
    } catch (e) {
      const raw = normalizeApiMessage(e, '시간 변경에 실패했습니다.')
      const pretty = prettifyBusinessMessage(raw)
  
      if (isOverlapMessage(pretty)) {
        editModalError.value = pretty
        return
      }
  
      openToast(pretty, pickToastType(pretty))
      console.error('[ScheduleDetail] update time failed:', e)
    } finally {
      editLoading.value = false
    }
  }
  
  /* -------------------- delete -------------------- */
  const onConfirmDelete = async () => {
    try {
      const vsId = viewModel.value?.vsId
      if (!vsId) throw new Error('vsId is missing')
  
      deleteLoading.value = true
      await deleteConfirmedVisitSchedule({ vsId })
  
      showDeleteModal.value = false
  
      emit('refresh')
      emit('close')
      openToast('일정이 삭제되었습니다.', 'success')
    } catch (e) {
      const raw = normalizeApiMessage(e, '삭제에 실패했습니다.')
      const pretty = prettifyBusinessMessage(raw)
  
      openToast(pretty, pickToastType(pretty))
      console.error('[ScheduleDetail] delete failed:', e)
    } finally {
      deleteLoading.value = false
    }
  }
  
  const onCareWorkerChanged = async () => {
    await loadDetail()
    emit('refresh')
  }
  </script>

<style scoped>
.detail-panel {
  box-sizing: border-box;
  width: 100%;
  height: 100%;
  background: #ffffff;
  border-radius: 24px;
  border: 1px solid #d7f3dd;
  box-shadow: 0 4px 16px rgba(15, 23, 42, 0.05);
  overflow: hidden;
}

.placeholder {
  height: 100%;
  min-height: 360px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #9ca3af;
  padding: 24px;
}

.placeholder-icon {
  margin-bottom: 16px;
}

.calendar-icon-img {
  width: 33px;
  height: 33px;
}

.placeholder-main {
  font-size: 16px;
  margin: 0;
}

.placeholder-sub {
  font-size: 14px;
  margin: 4px 0 0;
}

.detail-content {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.detail-header {
  background: #ecfdf1;
  padding: 18px 20px 14px;
  border-bottom: 1px solid #e5e7eb;
}

.header-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.detail-title {
  font-size: 20px;
  font-weight: 600;
  color: #388e3c;
  margin: 0;
}

.close-btn {
  border: none;
  background: transparent;
  padding: 0;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.close-btn img {
  width: 22px;
  height: 40px;
}

.header-bottom {
  margin-top: 10px;
  position: relative;
  min-height: 44px;
  display: flex;
  align-items: center;
}

.type-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
  border: 1px solid rgba(34, 197, 94, 0.35);
  background: #dfffe9;
  color: #166534;
}

.pill-care {
  background: #dbeafe;
  color: #1d4ed8;
  border-color: rgba(29, 78, 216, 0.25);
}

.pill-bath {
  background: #ffe4ef;
  color: #be185d;
  border-color: rgba(190, 24, 93, 0.25);
}

.pill-nurse {
  background: #dcfce7;
  color: #15803d;
  border-color: rgba(21, 128, 61, 0.25);
}

.detail-body {
  padding: 14px 18px 18px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.top-grid {
  display: grid;
  grid-template-columns: 1.4fr 1fr;
  gap: 16px;
  align-items: stretch;
}

.schedule-box {
  background: #f9fafb;
  border-radius: 14px;
  border: 2px solid #e5e7eb;
  padding: 14px 16px;
  display: flex;
  flex-direction: column;
}

.schedule-box-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 10px;
  margin-bottom: 8px;
}

.head-left {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.schedule-icon {
  width: 18px;
  height: 18px;
}

.schedule-title {
  font-size: 14px;
  font-weight: 600;
  color: #4a5565;
}

.head-right {
  display: inline-flex;
  align-items: center;
  gap: 10px;
}

.action-btn {
  height: 34px;
  padding: 0 12px;
  border-radius: 999px;
  border: 1px solid #e2e8f0;
  background: #ffffff;
  cursor: pointer;
  font-size: 13px;
  font-weight: 800;
  line-height: 1;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.action-btn.edit {
  border-color: rgba(34, 197, 94, 0.55);
  background: #f0fdf4;
  color: #166534;
}


.action-btn.delete {
  border-color: rgba(239, 68, 68, 0.5);
  background: #fff1f2;
  color: #b91c1c;
}

.head-divider {
  opacity: 0.7;
}

.schedule-rows {
  display: flex;
  flex-direction: column;
  gap: 12px;
  flex: 1;
}

.info-row {
  display: grid;
  grid-template-columns: auto 1fr;
  align-items: center;
  font-size: 14px;
}

.label {
  color: #4a5565;
  font-weight: 600;
}

.value {
  color: #4a5565;
  font-weight: 600;
  text-align: right;
}

.value.strong {
  font-weight: 900;
}

.person-col {
  display: flex;
  flex-direction: column;
  gap: 12px;
  height: 100%;
}

.person-card {
  background: #f9fafb;
  border-radius: 14px;
  border: 2px solid #e5e7eb;
  padding: 12px 14px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.member-icon {
  width: 18px;
  height: 18px;
}

.person-text {
  font-size: 14px;
  font-weight: 500;
  color: #101828;
}

.person-card.status-card {
  border: none;
  background: transparent;
  padding: 0;
  justify-content: center;
  align-items: center;
}

.status-pill {
  width: 100%;
  height: 50px;
  border-radius: 999px;
  border: 4px solid #e5e7eb;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
  font-weight: 400;
  line-height: 1;
}

.status-empty {
  color: #9ca3af;
  border-color: #e5e7eb;
}

.status-planned {
  color: #2563eb;
  border-color: rgba(37, 99, 235, 0.25);
}

.status-progress {
  color: #d97706;
  border-color: rgba(217, 119, 6, 0.25);
}

.status-done {
  color: #16a34a;
  border-color: rgba(22, 163, 74, 0.25);
}
</style>