<template>
  <section class="caregiver-detail">
    <div v-if="loading" class="loading">불러오는 중...</div>
    <div v-else-if="error" class="error">{{ error }}</div>

    <template v-else>
      <header class="header-row">
        <div class="basic-info">
          <div class="name-row">
            <span class="name">{{ viewModel.name }}</span>
            <span class="badge gender" :class="viewModel.gender === '여자' ? 'female' : 'male'">
              {{ viewModel.gender }}
            </span>
          </div>

          <p class="address">{{ viewModel.address }}</p>

          <div class="phone-row">
            <div class="label">연락처</div>
            <div class="value">{{ viewModel.phone || '-' }}</div>
          </div>
        </div>
      </header>

      <div class="field">
        <div class="label">근무 중인 시간</div>
        <div class="time-list">
          <template v-if="viewModel.workingTimes?.length">
            <div v-for="(t, idx) in viewModel.workingTimes" :key="idx" class="time-row">
              <img :src="clockIcon" alt="" class="clock-icon" />
              <span>{{ t }}</span>
            </div>
          </template>
          <div v-else class="value">-</div>
        </div>
      </div>

      <div class="field">
        <div class="label">자격증</div>
        <div class="value">
          <template v-if="viewModel.certificates?.length">
            <span v-for="c in viewModel.certificates" :key="c" class="badge-cert">
              {{ c }}
            </span>
          </template>
          <span v-else>-</span>
        </div>
      </div>

      <div class="info-section two-col">
        <div class="column">
          <div class="field">
            <div class="label">서비스</div>
            <div class="value">
              <template v-if="viewModel.serviceTypes?.length">
                <span v-for="s in viewModel.serviceTypes" :key="s" class="pill">
                  {{ s }}
                </span>
              </template>
              <span v-else>-</span>
            </div>
          </div>
        </div>

        <div class="column">
          <div class="field">
            <div class="label">태그</div>
            <div class="value">
              <template v-if="viewModel.tags?.length">
                <span v-for="t in viewModel.tags" :key="t" class="pill soft">
                  {{ t }}
                </span>
              </template>
              <span v-else>-</span>
            </div>
          </div>
        </div>
      </div>

      <div class="tag-description">
        요양보호사는 수급자의 태그 매칭을 바탕으로
        거리가 가까운 요양보호사를 추천합니다.
      </div>
    </template>
  </section>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import clockIcon from '@/assets/img/schedule/clock.png'
import { getCareWorkerDetail } from '@/api/schedule/matching.js'
import { useMatchingSelectionStore } from '@/stores/matchingSelection'

const props = defineProps({
  caregiver: { type: Object, default: null },
  refreshKey: { type: Number, default: 0 },
})

const store = useMatchingSelectionStore()

const loading = ref(false)
const error = ref('')
const detail = ref(null)

const getCareWorkerId = (obj) => obj?.careWorkerId ?? obj?.id ?? null

const normalizeTime = (t) => {
  if (!t) return ''
  const s = String(t)
  return s.length >= 5 ? s.slice(0, 5) : s
}

const loadDetail = async () => {
  const careWorkerId = getCareWorkerId(props.caregiver)
  if (!careWorkerId) {
    detail.value = null
    error.value = ''
    return
  }

  try {
    loading.value = true
    error.value = ''
    const res = await getCareWorkerDetail(careWorkerId)
    detail.value = res?.data ?? res ?? null
    store.syncCaregiver(detail.value)
  } catch (e) {
    error.value = e?.response?.data?.message || '상세 정보를 불러오지 못했습니다.'
    detail.value = null
  } finally {
    loading.value = false
  }
}

watch(
  () => getCareWorkerId(props.caregiver),
  () => loadDetail(),
  { immediate: true }
)

watch(
  () => props.refreshKey,
  () => loadDetail()
)

const viewModel = computed(() => {
  const base = props.caregiver || store.caregiver || {}
  const d = detail.value || {}

  const rawGender = d.gender ?? base.gender
  const gender =
    rawGender === 'M' ? '남자' :
    rawGender === 'F' ? '여자' :
    rawGender || '-'

  const workingTimes = (d.workingTimes ?? [])
    .map((w) => {
      const dayName = w.dayName || ''
      const st = normalizeTime(w.startTime)
      const et = normalizeTime(w.endTime)
      const svc = w.serviceTypeName ? ` · ${w.serviceTypeName}` : ''
      if (!dayName || !st || !et) return null
      return `${dayName} ${st}-${et}${svc}`
    })
    .filter(Boolean)

  return {
    careWorkerId: d.careWorkerId ?? getCareWorkerId(base),
    name: d.name ?? base.name ?? '-',
    gender,
    address: d.address ?? base.address ?? '-',
    phone: d.phone ?? base.phone ?? '',
    serviceTypes: d.serviceTypes ?? [],
    tags: d.tags ?? [],
    certificates: d.certificates ?? [],
    workingTimes,
  }
})
</script>

<style scoped>
/* ===== 전체 카드 ===== */
.caregiver-detail {
  background: #f0fdf4;
  border-radius: 16px;
  border: 1px solid #bbf7d0;
  padding: 24px 32px;
  min-height: 260px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* ===== 상태 ===== */
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

/* ===== 상단 헤더 ===== */
.header-row {
  display: flex;
  align-items: flex-start;
}

.basic-info {
  flex: 1;
}

/* 이름 + 성별 */
.name-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 6px;
}

.name {
  font-size: 20px;
  font-weight: 700;
  color: #166534;
}

/* 성별 뱃지 */
.badge {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 12px;
}

.badge.gender {
  background: #dbeafe;
  color: #1d4ed8;
}

.badge.gender.female {
  background: #fee2e2;
  color: #be123c;
}

/* 주소 */
.address {
  margin: 0;
  font-size: 14px;
  color: #4b5563;
}

/* 연락처 (주소 밑) */
.phone-row {
  margin-top: 14px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

/* ===== 공통 필드 ===== */
.field {
  margin-top: 16px;
}

.label {
  font-size: 13px;
  color: #6b7280;
  margin-bottom: 6px;
}

.value {
  font-size: 14px;
  color: #111827;
}

/* ===== 근무 시간 ===== */
.time-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
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

/* ===== 자격증 ===== */
.badge-cert {
  display: inline-flex;
  align-items: center;
  padding: 4px 12px;
  border-radius: 999px;
  background: #f5f3ff;
  color: #6d28d9;
  font-size: 12px;
  margin-right: 6px;
  margin-bottom: 6px;
}

/* ===== 하단 2열 영역 (서비스 / 태그) ===== */
.info-section.two-col {
  display: flex;
  gap: 40px;
  margin-top: 12px;
}

.column {
  flex: 1;
}

/* 서비스 pill */
.pill {
  display: inline-flex;
  align-items: center;
  padding: 4px 12px;
  border-radius: 999px;
  background: #dcfce7;
  color: #15803d;
  font-size: 12px;
  margin-right: 6px;
  margin-bottom: 6px;
}

/* 태그 pill */
.pill.soft {
  background: #e0f2fe;
  color: #0369a1;
}
.tag-description {
  margin-top: 20px;          /* 서비스/태그 줄과 간격 */
  max-width: 220px;         
  font-size: 13px;
  line-height: 1.6;
  color: #6b7280;
  word-break: keep-all;
}
</style>