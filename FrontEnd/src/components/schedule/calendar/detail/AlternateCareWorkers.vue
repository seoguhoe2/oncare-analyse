<template>
  <div class="alternate-box">
    <div class="alternate-header">
      <span class="title">{{ headerTitle }}</span>
      <span class="count">{{ alternatives.length }}명 가능</span>
    </div>

    <div class="alternate-body">
      <div v-if="loading" class="loading">불러오는 중...</div>
      <div v-else-if="error" class="error">{{ error }}</div>

      <template v-else>
        <button
          v-for="alt in alternatives"
          :key="alt.careWorkerId ?? alt.id"
          type="button"
          class="alternate-item"
          @click="openDetail(alt)"
        >
          <div class="item-left">
            <span class="name">{{ alt.name || '-' }}</span>

            <span class="gender" :class="badgeClass(alt.gender)">
              {{ displayGender(alt.gender) }}
            </span>

            <div class="tags">
              <span v-for="tag in alt.tags || []" :key="tag" class="tag">
                {{ tag }}
              </span>
              <span v-if="!alt.tags?.length" class="tag-empty">태그 없음</span>
            </div>
          </div>

          <span class="assign-chip">배정가능</span>
        </button>

        <div v-if="!alternatives.length" class="empty">
          대체 가능한 요양보호사가 없습니다.
        </div>
      </template>
    </div>

    <!-- 1) 상세 모달 -->
    <CareWorkerDetailModal
      :open="detailOpen"
      :loading="detailLoading"
      :error="detailError"
      :detail="detail"
      :confirm-loading="changeLoading"
      :mode="changeMode"
      @close="detailOpen = false"
      @confirm-change="onConfirmChange"
    />

    <!-- 2) 변경 확인 모달 -->
    <CareWorkerChangeConfirmModal
      :open="confirmOpen"
      :loading="changeLoading"
      :mode="changeMode"
      :date-text="props.scheduleDate"
      :beneficiary-name="props.beneficiaryName"
      :from-care-worker-name="props.currentCareWorkerName"
      :to-care-worker-name="pendingCareWorkerName"
      @close="confirmOpen = false"
      @confirm="onFinalConfirm"
    />
  </div>
</template>

<script setup>
  import { computed, ref, watch } from 'vue'
  import CareWorkerDetailModal from '@/components/schedule/calendar/detail/CareWorkerDetailModal.vue'
  import CareWorkerChangeConfirmModal from '@/components/schedule/calendar/detail/CareWorkerChangeConfirmModal.vue'
  
  import {
    getCandidateCareWorkerCards,
    getVisitAvailableCareWorkerCards,
    getCareWorkerDetail,
    changeMatchingCareWorker,
    changeVisitScheduleCareWorker,
  } from '@/api/schedule/matching.js'
  
  const props = defineProps({
    beneficiaryId: { type: [Number, String], default: null },
    source: { type: String, default: 'NORMAL' }, // 'CONFIRMED' | 'NORMAL'
  
    matchingId: { type: [Number, String], default: null }, // NORMAL 변경 시 필요
    vsId: { type: [Number, String], default: null },       // CONFIRMED 변경 시 필요
  
    beneficiaryName: { type: String, default: '' },
    currentCareWorkerName: { type: String, default: '' },
    scheduleDate: { type: String, default: '' }, // 'YYYY-MM-DD' 권장
  
    // 둘 중 하나 방식으로 들어와도 되게 처리
    startDt: { type: String, default: '' }, // 'YYYY-MM-DD HH:mm:ss' or 'YYYY-MM-DDTHH:mm:ss'
    endDt: { type: String, default: '' },
    startTime: { type: String, default: '' }, // 'HH:mm'
    endTime: { type: String, default: '' },   // 'HH:mm'
  })
  
  const emit = defineEmits(['changed'])
  
  const alternatives = ref([])
  const loading = ref(false)
  const error = ref('')
  
  const isValid = (v) => v !== null && v !== undefined && String(v).trim() !== ''
  
  const pickArray = (res) => {
    if (Array.isArray(res?.data)) return res.data
    if (Array.isArray(res?.data?.data)) return res.data.data
    return []
  }
  
  const normalizeDate = (v) => {
    const s = String(v ?? '').trim()
    if (!s) return ''
    return s.includes('T') ? s.split('T')[0] : s.slice(0, 10)
  }
  
  // '2025-12-23T09:00:00' -> '2025-12-23 09:00:00'
  const normalizeDt = (s) => {
    const v = String(s ?? '').trim()
    if (!v) return ''
    return v.includes('T') ? v.replace('T', ' ') : v
  }
  
  const buildDtFromDateAndTime = (date, hm) => {
    const d = normalizeDate(date)
    const t = String(hm ?? '').trim()
    if (!d || !t) return ''
    return `${d} ${t.slice(0, 5)}:00`
  }
  
  const resolvedStartDt = computed(() => {
    if (isValid(props.startDt)) return normalizeDt(props.startDt)
    return buildDtFromDateAndTime(props.scheduleDate, props.startTime)
  })
  
  const resolvedEndDt = computed(() => {
    if (isValid(props.endDt)) return normalizeDt(props.endDt)
    return buildDtFromDateAndTime(props.scheduleDate, props.endTime)
  })
  
  const load = async () => {
    alternatives.value = []
    error.value = ''
  
    if (!isValid(props.beneficiaryId)) return
  
    const isConfirmed = props.source === 'CONFIRMED'
  
    // ✅ CONFIRMED는 필수값 없으면 호출 자체를 안 함 (로딩도 켜지지 않게)
    if (isConfirmed) {
      if (!isValid(props.vsId)) return
      if (!isValid(resolvedStartDt.value) || !isValid(resolvedEndDt.value)) return
    }
  
    try {
      loading.value = true
  
      const res = isConfirmed
        ? await getVisitAvailableCareWorkerCards({
            beneficiaryId: props.beneficiaryId,
            vsId: props.vsId,
            startDt: resolvedStartDt.value,
            endDt: resolvedEndDt.value,
          })
        : await getCandidateCareWorkerCards(props.beneficiaryId)
  
      alternatives.value = pickArray(res)
    } catch (e) {
      error.value = '대체 요양보호사를 불러오지 못했습니다.'
    } finally {
      loading.value = false
    }
  }
  
  watch(
    () => [
      props.beneficiaryId,
      props.source,
      props.vsId,
      props.scheduleDate,
      props.startDt,
      props.endDt,
      props.startTime,
      props.endTime,
    ],
    load,
    { immediate: true }
  )
  
  const badgeClass = (g) => ({
    male: g === '남자' || g === 'M',
    female: g === '여자' || g === 'F',
  })
  
  const displayGender = (g) => (g === 'M' ? '남자' : g === 'F' ? '여자' : g || '-')
  
  const changeMode = computed(() => (props.source === 'CONFIRMED' ? 'CONFIRMED' : 'NORMAL'))
  
  const headerTitle = computed(() =>
    changeMode.value === 'CONFIRMED' ? '대체 가능한 요양보호사' : '대체 가능한 담당 요양보호사'
  )
  
  /* =========================
   * Detail Modal
   * ========================= */
  const detailOpen = ref(false)
  const detailLoading = ref(false)
  const detailError = ref('')
  const detail = ref(null)
  
  const changeLoading = ref(false)
  
  const dayLabel = (v) => {
    const s = String(v ?? '').trim()
    if (!s) return '-'
    if (s.length === 1 && /[월화수목금토일]/.test(s)) return s
  
    const n = Number(s)
    if (!Number.isFinite(n)) return s
  
    const map1to7 = ['', '월', '화', '수', '목', '금', '토', '일']
    const map0to6 = ['일', '월', '화', '수', '목', '금', '토']
  
    if (n >= 1 && n <= 7) return map1to7[n] || s
    if (n >= 0 && n <= 6) return map0to6[n] || s
    return s
  }
  
  const timeHM = (t) => {
    const s = String(t ?? '').trim()
    if (!s) return ''
    if (s.includes('T')) return (s.split('T')[1] || '').slice(0, 5)
    return s.slice(0, 5)
  }
  
  const normalizeDetailForModal = (raw) => {
    const d = raw && typeof raw === 'object' ? raw : {}
    const wt = Array.isArray(d.workingTimes) ? d.workingTimes : []
    const normalizedWorkingTimes = wt.map((x) => ({
      ...x,
      day: dayLabel(x?.day ?? x?.weekday ?? x?.dayOfWeek),
      start: timeHM(x?.start ?? x?.startTime),
      end: timeHM(x?.end ?? x?.endTime),
      serviceTypeName: x?.serviceTypeName ?? x?.serviceType ?? x?.serviceName,
    }))
  
    const normalizedServices = (() => {
      if (Array.isArray(d.services)) return d.services
      if (Array.isArray(d.serviceTypes)) return d.serviceTypes
      if (Array.isArray(d.availableServices)) return d.availableServices
      if (Array.isArray(d.serviceTypeNames)) return d.serviceTypeNames
      return []
    })()
  
    return { ...d, workingTimes: normalizedWorkingTimes, services: normalizedServices }
  }
  
  const openDetail = async (alt) => {
    const careWorkerId = alt?.careWorkerId ?? alt?.id ?? null
    if (!careWorkerId) return
  
    detailOpen.value = true
    detailLoading.value = true
    detailError.value = ''
    detail.value = null
  
    try {
      const res = await getCareWorkerDetail(careWorkerId)
      detail.value = normalizeDetailForModal(res?.data ?? null)
    } catch (e) {
      detailError.value = '요양보호사 상세 정보를 불러오지 못했습니다.'
    } finally {
      detailLoading.value = false
    }
  }
  
  /* =========================
   * Confirm Modal
   * ========================= */
  const confirmOpen = ref(false)
  const pendingCareWorkerId = ref(null)
  const pendingCareWorkerName = ref('')
  
  const onConfirmChange = async (careWorkerId) => {
    if (!careWorkerId) return
    pendingCareWorkerId.value = careWorkerId
    pendingCareWorkerName.value = String(detail.value?.name ?? '').trim() || ''
    confirmOpen.value = true
  }
  
  const onFinalConfirm = async () => {
    const careWorkerId = pendingCareWorkerId.value
    if (!careWorkerId) return
  
    try {
      changeLoading.value = true
      detailError.value = ''
  
      if (props.source === 'CONFIRMED') {
        if (!isValid(props.vsId)) throw new Error('vsId missing')
        await changeVisitScheduleCareWorker(props.vsId, careWorkerId)
      } else {
        if (!isValid(props.matchingId)) throw new Error('matchingId missing')
        await changeMatchingCareWorker(props.matchingId, careWorkerId)
      }
  
      confirmOpen.value = false
      detailOpen.value = false
      emit('changed')
    } catch (e) {
      detailError.value = '요양보호사 변경에 실패했습니다.'
      confirmOpen.value = false
    } finally {
      changeLoading.value = false
    }
  }
  </script>

<style scoped>
.alternate-box {
  background: #f0f9ff;
  border: 1px solid #bfdbfe;
  border-radius: 16px;
  overflow: hidden;
}

.alternate-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
}

.title {
  font-size: 14px;
  font-weight: 700;
  color: #2563eb;
}

.count {
  font-size: 12px;
  color: #2563eb;
  font-weight: 600;
}

.alternate-body {
  padding: 10px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.alternate-item {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #ffffff;
  border: 1px solid #bfdbfe;
  border-radius: 14px;
  padding: 12px 14px;
  gap: 12px;
  cursor: pointer;
  text-align: left;
}

.alternate-item:hover {
  background: #f8fbff;
}

.item-left {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
  flex: 1;
}

.name {
  font-size: 14px;
  font-weight: 700;
  color: #111827;
  white-space: nowrap;
}

.gender {
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
  white-space: nowrap;
}

.gender.male {
  background: #e0f2fe;
  color: #0284c7;
}

.gender.female {
  background: #fde2e8;
  color: #ec4899;
}

.tags {
  display: flex;
  gap: 6px;
  flex-wrap: nowrap;
  overflow: hidden;
}

.tag {
  background: #dcfce7;
  color: #15803d;
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
  white-space: nowrap;
}

.tag-empty {
  font-size: 12px;
  color: #9ca3af;
}

.assign-chip {
  background: #dcfce7;
  color: #15803d;
  font-size: 12px;
  font-weight: 800;
  padding: 8px 14px;
  border-radius: 999px;
  white-space: nowrap;
}

.loading,
.error,
.empty {
  font-size: 13px;
  color: #6b7280;
  padding: 6px 4px;
}

.error {
  color: #b91c1c;
}
</style>