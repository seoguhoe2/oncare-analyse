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
            <span class="badge gender" :class="viewModel.gender === '여자' ? 'female' : 'male'">
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

          <!-- ✅ 위험요소 -->
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

          <!-- ✅ 태그 -->
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
            <div class="label">희망 요일</div>
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

        <article v-if="viewModel.assignedCareWorker" class="assigned-card">
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
        </article>

        <p v-else class="assigned-empty">배정된 요양보호사가 없습니다</p>
      </section>
    </template>
  </section>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import clockIcon from '@/assets/img/schedule/clock.png'
import { getBeneficiaryDetail } from '@/api/schedule/matching.js'

const props = defineProps({
  recipient: { type: Object, default: null },
})

const loading = ref(false)
const error = ref('')
const detail = ref(null)

const getBeneficiaryId = (obj) => obj?.beneficiaryId ?? obj?.id ?? null

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
    error.value = '수급자 ID가 없습니다.'
    return
  }

  try {
    loading.value = true
    error.value = ''
    const res = await getBeneficiaryDetail(beneficiaryId)
    detail.value = res?.data ?? res ?? null
  } catch (e) {
    error.value = e?.response?.data?.message || '상세 정보를 불러오지 못했습니다.'
    detail.value = null
  } finally {
    loading.value = false
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
  const preferredFromSchedules = buildPreferredFromSchedules(schedules)

  const preferredTimes =
    d.preferredTimes || preferredFromSchedules.preferredTimes || base.preferredTimes || []
  const preferredDays =
    d.preferredDays || preferredFromSchedules.preferredDays || base.preferredDays || []

  // ✅ 백엔드 응답 기준 (serviceTypes / tags / riskFactors)
  const needServices =
    d.serviceTypes ||
    d.needServices ||
    base.serviceTypes ||
    base.needServices ||
    []

  const needTags =
    d.tags ||
    d.needTags ||
    base.tags ||
    base.needTags ||
    []

  const riskFactors =
    d.riskFactors ||
    d.riskTags ||          // 혹시 예전 키명이 이런 식이면 대응
    d.risks ||
    base.riskFactors ||
    base.risks ||
    []

  const assignedCareWorker = d.assignedCareWorker || null

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
    assignedCareWorker,
  }
})
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

/* 상단 */
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

/* 중간 섹션 */
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
}

/* 기본(초록) */
.pill {
  background: #dcfce7;
  color: #15803d;
}

/* 서비스(보라/인디고) */
.pill-soft {
  background: #eef2ff;
  color: #4f46e5;
}

/* ✅ 위험요소(연한 주황/레드톤) */
.pill-risk {
  background: #ffedd5;
  color: #c2410c;
}

/* ✅ 태그(민트/그린톤 살짝 다르게) */
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

/* 하단 배정된 요양보호사 */
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
</style>