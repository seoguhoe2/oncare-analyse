<template>
  <div class="schedule-page">
    <div class="page-header">
      <div class="title-area">
        <h1 class="page-title">일정 관리</h1>
        <p class="page-desc">요양보호사와 수급자 매칭 및 일정 관리</p>
      </div>

      <button
        v-if="rightButton?.show"
        class="add-button"
        type="button"
        @click="rightButton.onClick"
      >
        <img v-if="rightButton.icon" :src="rightButton.icon" :alt="rightButton.label" />
        {{ rightButton.label }}
      </button>
    </div>

    <div class="tabs-box">
      <div class="inner-tabs">
        <RouterLink
          v-for="tab in tabs"
          :key="tab.key"
          :to="{ name: tab.routeName }"
          class="tab-item"
          :class="{ active: isActive(tab) }"
        >
          <span class="tab-icon" v-if="tab.icon">
            <img :src="isActive(tab) ? tab.activeIcon : tab.icon" :alt="tab.label" />
          </span>
          <span class="tab-label">{{ tab.label }}</span>
        </RouterLink>
      </div>

      <div class="tab-content">
        <RouterView :refresh-key="selection.refreshTick" />
      </div>
    </div>

    <MatchAssignModal
      :show="showAssignModal"
      :min="todayYmd"
      :saving="assignSaving"
      @close="onCloseAssignModal"
      @confirm="onConfirmAssign"
    />

    <MatchCompleteModal
      :show="showMatchModal"
      :message="matchModalMessage"
      @close="onCloseMatchModal"
    />

    <CreateVisitModal
      :show="showCreateVisitModal"
      @close="onCloseCreateVisitModal"
      @create="onCreateVisit"
    />
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useRoute } from 'vue-router'

import calendarIcon from '@/assets/img/common/scheduleManagement.png'
import calendarIconActive from '@/assets/img/common/greenSchedule.png'
import matchingIcon from '@/assets/img/common/employeeManagement.png'
import matchingIconActive from '@/assets/img/common/greenMatching.png'
import addScheduleIcon from '@/assets/img/schedule/addSchedule.png'

import { useMatchingSelectionStore } from '@/stores/matchingSelection'
import { assignMatchingCareWorker, createVisitSchedule } from '@/api/schedule/matching.js'

import MatchCompleteModal from '@/components/schedule/matching/MatchCompleteModal.vue'
import MatchAssignModal from '@/components/schedule/matching/MatchAssignModal.vue'
import CreateVisitModal from '@/components/schedule/calendar/CreateVisitModal.vue'

const route = useRoute()
const selection = useMatchingSelectionStore()

const showMatchModal = ref(false)
const matchModalMessage = ref('')
const showCreateVisitModal = ref(false)

const showAssignModal = ref(false)
const assignSaving = ref(false)

const pad2 = (n) => String(n).padStart(2, '0')
const toYmd = (d) => `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`
const todayYmd = computed(() => toYmd(new Date()))

const tabs = [
  {
    key: 'calendar',
    label: '캘린더',
    routeName: 'schedule-calendar',
    icon: calendarIcon,
    activeIcon: calendarIconActive,
  },
  {
    key: 'matching',
    label: '매칭',
    routeName: 'schedule-matching',
    icon: matchingIcon,
    activeIcon: matchingIconActive,
  },
]

const isActive = (tab) => route.name === tab.routeName
const isMatchingRoute = computed(() => String(route.name || '').startsWith('schedule-matching'))

const canMatch = computed(() => Boolean(selection.recipientId && selection.caregiverId))

const getRecipientName = (r) => r?.beneficiaryName ?? r?.name ?? '수급자'
const getCareWorkerName = (c) => c?.careWorkerName ?? c?.name ?? '요양보호사'

const onClickMatch = () => {
  if (!canMatch.value) return
  showAssignModal.value = true
}

const onCloseAssignModal = () => {
  showAssignModal.value = false
}

const onConfirmAssign = async (effectiveDate) => {
  const beneficiaryId = selection.recipientId
  const careWorkerId = selection.caregiverId
  if (!beneficiaryId || !careWorkerId) return

  try {
    assignSaving.value = true

    await assignMatchingCareWorker({
      beneficiaryId,
      careWorkerId,
      effectiveDate,
    })

    selection.refresh()

    matchModalMessage.value =
      `${getRecipientName(selection.recipient)}와 ` +
      `${getCareWorkerName(selection.caregiver)}의 매칭이 완료되었습니다.`

    showAssignModal.value = false
    showMatchModal.value = true
  } catch (e) {
    console.error('[매칭 실패]', e)
    alert(e?.response?.data?.message || '매칭에 실패했습니다.')
  } finally {
    assignSaving.value = false
  }
}

const onCloseMatchModal = () => {
  showMatchModal.value = false
}

const onClickAddSchedule = () => {
  showCreateVisitModal.value = true
}

const onCloseCreateVisitModal = () => {
  showCreateVisitModal.value = false
}

const onCreateVisit = async (payload) => {
  const list = Array.isArray(payload) ? payload : [payload]
  const tasks = list
    .filter(Boolean)
    .map((p) => ({
      beneficiaryId: p.beneficiaryId,
      careWorkerId: p.careWorkerId,
      serviceTypeId: p.serviceTypeId,
      startDt: p.startDt,
      endDt: p.endDt,
      note: p.note ?? '',
    }))

  if (tasks.length === 0) return

  const invalid = tasks.some(
    (p) => !p.beneficiaryId || !p.careWorkerId || !p.serviceTypeId || !p.startDt || !p.endDt
  )
  if (invalid) {
    window.alert('수급자/요양보호사/서비스유형/날짜/시간을 모두 선택해 주세요.')
    return
  }

  let success = 0
  const failed = []

  for (const t of tasks) {
    try {
      await createVisitSchedule(t)
      success += 1
    } catch (e) {
      failed.push(e?.response?.data?.message || '일정 생성에 실패했습니다.')
    }
  }

  selection.refresh()

  if (failed.length === 0) {
    window.alert(`${success}건 일정이 생성되었습니다.`)
    showCreateVisitModal.value = false
    return
  }

  const preview = failed.slice(0, 3).map((m) => `- ${m}`).join('\n')
  window.alert(`성공 ${success}건 / 실패 ${failed.length}건\n${preview}${failed.length > 3 ? '\n...' : ''}`)
}

const rightButton = computed(() => {
  if (isMatchingRoute.value) {
    return {
      show: canMatch.value,
      label: '매칭하기',
      icon: null,
      onClick: onClickMatch,
    }
  }

  return {
    show: true,
    label: '일정 추가',
    icon: addScheduleIcon,
    onClick: onClickAddSchedule,
  }
})
</script>

<style scoped>
.schedule-page {
  padding: 0 24px 24px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28px 0 12px;
}

.title-area {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.page-title {
  font-size: 30px;
  font-weight: 600;
  color: #1a5928;
  margin: 0;
}

.page-desc {
  font-size: 14px;
  color: #4a5565;
  margin: 0;
}

.add-button {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 18px;
  border-radius: 10px;
  border: none;
  background-color: #00c950;
  color: #fff;
  font-size: 15px;
  cursor: pointer;
}

.add-button img {
  width: 20px;
  height: 20px;
}

.tabs-box {
  background: #ffffff;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 4px 12px rgba(15, 23, 42, 0.05);
  padding: 20px 24px;
  margin-top: 16px;
}

.inner-tabs {
  display: flex;
  gap: 24px;
  border-bottom: 1px solid #e2e8f0;
  margin-top: 8px;
}

.tab-item {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 12px 0;
  font-size: 16px;
  color: #4a5565;
  text-decoration: none;
  position: relative;
}

.tab-icon img {
  width: 20px;
  height: 20px;
}

.tab-item.active {
  color: #00a63e;
  font-weight: 600;
}

.tab-item.active::after {
  content: '';
  position: absolute;
  left: 0;
  bottom: -1px;
  width: 100%;
  height: 3px;
  background-color: #00a63e;
  border-radius: 999px;
}

.tab-content {
  padding-top: 16px;
}
</style>