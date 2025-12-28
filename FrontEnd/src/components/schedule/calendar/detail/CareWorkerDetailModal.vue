<template>
    <teleport to="body">
      <div v-if="open" class="cw-overlay" @click.self="emit('close')">
        <div class="cw-modal" role="dialog" aria-modal="true">
          <div class="cw-body">
            <div v-if="loading" class="state">불러오는 중...</div>
            <div v-else-if="error" class="state error">{{ error }}</div>
  
            <template v-else>
              <!-- Header -->
              <div class="header">
                <div class="name-row">
                  <div class="name">{{ safe(detail?.name, '-') }}</div>
                  <span class="gender" :class="genderClass(detail?.gender)">
                    {{ displayGender(detail?.gender) }}
                  </span>
                </div>
  
                <div class="address">{{ addressText }}</div>
              </div>
  
              <!-- Contact -->
              <div class="section">
                <div class="section-title">연락처</div>
                <div class="section-value">{{ safe(detail?.phone, '-') }}</div>
              </div>
  
              <!-- Working Times -->
              <div class="section">
                <div class="section-title">근무 중인 시간</div>
                <div v-if="workingTimes.length" class="time-list">
                  <div v-for="(t, idx) in workingTimes" :key="idx" class="time-item">
                    {{ formatWorkingTime(t) }}
                  </div>
                </div>
                <div v-else class="empty">등록된 근무 시간이 없습니다.</div>
              </div>
  
              <!-- Certificates -->
              <div class="section">
                <div class="section-title">자격증</div>
                <div v-if="certificates.length" class="pill-wrap">
                  <span v-for="(c, idx) in certificates" :key="idx" class="pill pill-purple">
                    {{ c }}
                  </span>
                </div>
                <div v-else class="empty">없음</div>
              </div>
  
              <!-- Services / Tags -->
              <div class="grid-2">
                <div class="section">
                  <div class="section-title">서비스</div>
                  <div v-if="services.length" class="pill-wrap">
                    <span v-for="(s, idx) in services" :key="idx" class="pill pill-green">
                      {{ s }}
                    </span>
                  </div>
                  <div v-else class="empty">없음</div>
                </div>
  
                <div class="section">
                  <div class="section-title">태그</div>
                  <div v-if="tags.length" class="pill-wrap">
                    <span v-for="(t, idx) in tags" :key="idx" class="pill pill-blue">
                      {{ t }}
                    </span>
                  </div>
                  <div v-else class="empty">없음</div>
                </div>
              </div>
  
              <!-- Footer -->
              <div class="footer">
                <button class="btn btn-ghost" type="button" @click="emit('close')">
                  닫기
                </button>
                <button
                  class="btn btn-primary"
                  type="button"
                  :disabled="confirmLoading || !selectedId"
                  @click="emit('confirm-change', selectedId)"
                >
                  <span v-if="confirmLoading">변경 중...</span>
                  <span v-else>요양보호사 변경</span>
                </button>
              </div>
            </template>
          </div>
        </div>
      </div>
    </teleport>
  </template>
  
  <script setup>
  import { computed } from 'vue'
  
  const props = defineProps({
    open: { type: Boolean, default: false },
    loading: { type: Boolean, default: false },
    error: { type: String, default: '' },
    detail: { type: Object, default: null },
    confirmLoading: { type: Boolean, default: false },
  })
  
  const emit = defineEmits(['close', 'confirm-change'])
  
  const safe = (v, fallback = '') => {
    const s = String(v ?? '').trim()
    return s ? s : fallback
  }
  
  const selectedId = computed(() => props.detail?.careWorkerId ?? props.detail?.id ?? null)
  
  const displayGender = (g) => (g === 'M' ? '남자' : g === 'F' ? '여자' : safe(g, '-'))
  
  const genderClass = (g) => ({
    male: g === '남자' || g === 'M',
    female: g === '여자' || g === 'F',
  })
  
  /* 주소 */
  const addressText = computed(() => {
    if (props.detail?.address) return safe(props.detail.address, '-')
  
    const parts = [props.detail?.sido, props.detail?.sigungu, props.detail?.dong, props.detail?.detailAddress]
      .map((x) => String(x ?? '').trim())
      .filter(Boolean)
  
    return parts.length ? parts.join(' ') : '-'
  })
  
  /* 근무 시간 */
  const workingTimes = computed(() => (Array.isArray(props.detail?.workingTimes) ? props.detail.workingTimes : []))
  
  const dayLabel = (v) => {
    const s = String(v ?? '').trim()
    if (!s) return '-'
    if (['월', '화', '수', '목', '금', '토', '일'].includes(s)) return s
  
    const n = Number(s)
    if (Number.isFinite(n)) {
      if (n >= 1 && n <= 7) return ['월', '화', '수', '목', '금', '토', '일'][n - 1]
      if (n >= 0 && n <= 6) return ['일', '월', '화', '수', '목', '금', '토'][n]
    }
    return s
  }
  
  const toHM = (v) => {
    const s = String(v ?? '').trim()
    if (!s) return ''
    const t = s.includes('T') ? s.split('T')[1] : s
    return t.slice(0, 5)
  }
  
  const formatWorkingTime = (t) => {
    const day = dayLabel(t?.day ?? t?.weekday ?? t?.dayOfWeek)
    const start = toHM(t?.start ?? t?.startTime)
    const end = toHM(t?.end ?? t?.endTime)
    const type = safe(t?.serviceTypeName ?? t?.serviceType ?? t?.serviceName, '-')
  
    if (!start || !end) return `${day} · ${type}`
    return `${day} ${start}-${end} · ${type}`
  }
  
  const toTextArray = (value) => {
    const arr = Array.isArray(value) ? value : []
    return arr
      .map((x) => {
        if (typeof x === 'string') return x.trim()
        if (x && typeof x === 'object') return String(x.name ?? x.label ?? x.title ?? x.serviceTypeName ?? '').trim()
        return ''
      })
      .filter(Boolean)
  }
  
  const pickFirstNonEmptyArray = (...candidates) => {
    for (const c of candidates) {
      const txt = toTextArray(c)
      if (txt.length) return txt
    }
    return []
  }
  
  /* 자격증 / 서비스 / 태그 */
  const certificates = computed(() =>
    pickFirstNonEmptyArray(
      props.detail?.certificates,
      props.detail?.certificateList,
      props.detail?.certificationList
    )
  )
  
  const services = computed(() =>
    pickFirstNonEmptyArray(
      props.detail?.services,          // ['방문간호'] or [{name:'방문간호'}]
      props.detail?.serviceTypes,      // ['방문요양', ...] or [{name:'방문요양'}]
      props.detail?.serviceTypeNames,  // ['방문요양', ...]
      props.detail?.serviceList        // [{name:'방문요양'}]
    )
  )
  
  const tags = computed(() => pickFirstNonEmptyArray(props.detail?.tags, props.detail?.tagList))
  </script>
  
  <style scoped>
  /* Overlay */
  .cw-overlay {
    position: fixed;
    inset: 0;
    background: rgba(15, 23, 42, 0.35);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 9999;
    padding: 16px;
  }
  
  /* Modal */
  .cw-modal {
    width: 100%;
    max-width: 560px;
    background: #ffffff;
    border-radius: 18px;
    border: 1px solid #e5e7eb;
    box-shadow: 0 18px 50px rgba(15, 23, 42, 0.12);
  }
  
  .cw-body {
    padding: 18px 22px 20px;
  }
  
  /* State */
  .state {
    padding: 26px 8px;
    font-size: 14px;
    color: #64748b;
  }
  .state.error {
    color: #b91c1c;
  }
  
  /* Header */
  .header {
    padding-bottom: 14px;
    border-bottom: 1px solid #f1f5f9;
    margin-bottom: 14px;
  }
  
  .name-row {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  
  .name {
    font-size: 22px;
    font-weight: 700;
    color: #0f172a;
    letter-spacing: -0.2px;
  }
  
  .gender {
    padding: 6px 12px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 600;
    border: 1px solid transparent;
  }
  
  .gender.female {
    background: #ffe4e6;
    color: #be185d;
    border-color: rgba(190, 24, 93, 0.18);
  }
  
  .gender.male {
    background: #dbeafe;
    color: #1d4ed8;
    border-color: rgba(29, 78, 216, 0.18);
  }
  
  .address {
    margin-top: 8px;
    font-size: 14px;
    font-weight: 500;
    color: #475569;
  }
  
  /* Sections */
  .section {
    margin-top: 14px;
  }
  
  .section-title {
    font-size: 13px;
    font-weight: 600;
    color: #64748b;
    margin-bottom: 8px;
  }
  
  .section-value {
    font-size: 18px;
    font-weight: 650;
    color: #0f172a;
    letter-spacing: -0.2px;
  }
  
  .time-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  
  .time-item {
    font-size: 14px;
    font-weight: 500;
    color: #0f172a;
  }
  
  /* Pills */
  .pill-wrap {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }
  
  .pill {
    padding: 7px 12px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 600;
    border: 1px solid transparent;
  }
  
  .pill-purple {
    background: #eef2ff;
    color: #4f46e5;
    border-color: rgba(79, 70, 229, 0.18);
  }
  
  .pill-green {
    background: #dcfce7;
    color: #15803d;
    border-color: rgba(21, 128, 61, 0.18);
  }
  
  .pill-blue {
    background: #dbeafe;
    color: #1d4ed8;
    border-color: rgba(29, 78, 216, 0.18);
  }
  
  .empty {
    font-size: 13px;
    color: #94a3b8;
    font-weight: 500;
  }
  
  /* Two column grid */
  .grid-2 {
    margin-top: 10px;
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
  }
  
  /* Footer */
  .footer {
    margin-top: 18px;
    padding-top: 14px;
    border-top: 1px solid #f1f5f9;
    display: flex;
    justify-content: flex-end;
    gap: 10px;
  }
  
  .btn {
    border-radius: 12px;
    padding: 10px 14px;
    font-weight: 650;
    cursor: pointer;
    border: none;
    font-size: 14px;
  }
  
  .btn-ghost {
    background: #ffffff;
    border: 1px solid #e5e7eb;
    color: #334155;
  }
  
  .btn-primary {
    background: #22c55e;
    color: #ffffff;
  }
  
  .btn:disabled {
    opacity: 0.55;
    cursor: not-allowed;
  }
  </style>