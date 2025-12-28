<!-- src/components/recipient/category/record/BasicTest.vue -->
<template>
  <div class="baseline-wrap">
    <!-- 기초평가 내부 탭 -->
    <div class="baseline-subtabs">
      <button
        v-for="tab in baselineTabs"
        :key="tab.key"
        type="button"
        class="baseline-subtab-btn"
        :class="{ active: activeBaseline === tab.key }"
        @click="activeBaseline = tab.key"
      >
        {{ tab.label }}
      </button>
    </div>

    <!-- 공통 패널 -->
    <section class="baseline-panel">
      <!-- 헤더 -->
      <div class="panel-header">
        <div class="header-left">
          <span class="title">{{ activeTabTitle }}</span>
          <span class="sub">최신 평가 1건 요약</span>
        </div>

        <div class="header-right">
          <span class="chip" v-if="currentData?.evalDate">
            최근 평가: {{ currentData.evalDate }}
          </span>
          <span class="chip ghost" v-else>
            평가 이력 없음
          </span>
        </div>
      </div>

      <!-- 상태(로딩/에러/빈값) -->
      <div v-if="!props.beneficiaryId" class="state-box">
        수급자를 선택하면 기초평가 결과를 조회할 수 있어요.
      </div>

      <div v-else-if="loading" class="state-box">
        최신 평가 결과를 불러오는 중입니다...
      </div>

      <div v-else-if="loadError" class="state-box error">
        불러오기에 실패했어요. ({{ loadError }})
      </div>

      <div v-else-if="!currentData" class="state-box">
        {{ emptyMessage }}
      </div>

      <!-- =========================
           1) FALL (낙상)
           ========================= -->
      <template v-else-if="activeBaseline === 'fall'">
        <div class="meta-row">
          <div class="meta-item">
            <span class="meta-label">요양사</span>
            <span class="meta-value">{{ currentData.careWorkerName || '-' }}</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">최종 점수</span>
            <span class="meta-value strong orange">{{ safeText(currentData.totalScore, '-') }}점</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">최종 등급</span>
            <span class="meta-pill">{{ safeText(currentData.grade, '-') }}</span>
          </div>
        </div>

        <div class="divider"></div>

        <ul class="qa-list">
          <li
            v-for="(a, idx) in (currentData.answers || [])"
            :key="idx"
            class="qa-item"
          >
            <div class="qa-q">
              <span class="dot"></span>
              <span class="q-text">{{ a.questionLabel }}</span>
            </div>

            <div class="qa-a">
              <span class="a-text">{{ a.selectedLabel }}</span>
              <span class="score-badge">{{ safeText(a.selectedScore, 0) }}점</span>
            </div>
          </li>
        </ul>

        <div class="hint">
          ※ 낙상위험도 기준 : 4점 이하 낮음 / 5~10점 높음 / 11점 이상 아주 높음
        </div>
      </template>

      <!-- =========================
           2) BEDSORE (욕창)
           ========================= -->
      <template v-else-if="activeBaseline === 'bedsore'">
        <div class="meta-row">
          <div class="meta-item">
            <span class="meta-label">요양사</span>
            <span class="meta-value">{{ currentData.careWorkerName || '-' }}</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">최종 점수</span>
            <span class="meta-value strong orange">{{ safeText(currentData.totalScore, '-') }}점</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">최종 등급</span>
            <span class="meta-pill">{{ safeText(currentData.grade, '-') }}</span>
          </div>
        </div>

        <div class="summary-line">
          <span class="summary-label">한줄요약</span>
          <span class="summary-text">{{ safeText(currentData.comment, '-') }}</span>
        </div>

        <div class="divider"></div>

        <ul class="qa-list">
          <li
            v-for="(a, idx) in (currentData.answers || [])"
            :key="idx"
            class="qa-item"
          >
            <div class="qa-q">
              <span class="dot"></span>
              <span class="q-text">{{ a.code }}</span>
            </div>

            <div class="qa-a">
              <span class="a-text">{{ a.label }}</span>
              <span class="score-badge">{{ safeText(a.score, 0) }}점</span>
            </div>
          </li>
        </ul>
        <div class="hint">
          ※ 욕창위험도 기준 : 19~23점 낮음(위험 없음) / 13~18점 중간(약간~중도 위험) / 12점 이하 매우 높음(위험 매우 높음)
        </div>
      </template>

      <!-- =========================
           3) COGNITIVE (인지)
           ========================= -->
      <template v-else-if="activeBaseline === 'cognitive'">
        <div class="meta-row">
          <div class="meta-item">
            <span class="meta-label">요양사</span>
            <span class="meta-value">{{ currentData.careWorkerName || '-' }}</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">최종 점수</span>
            <span class="meta-value strong orange">{{ safeText(currentData.totalScore, '-') }}점</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">최종 등급</span>
            <span class="meta-pill">{{ safeText(currentData.interpretationResult, '-') }}</span>
          </div>
        </div>

        <div class="summary-line">
          <span class="summary-label">한줄요약</span>
          <span class="summary-text">{{ safeText(currentData.interpretationComment, '-') }}</span>
        </div>

        <div class="divider"></div>

        <ul class="qa-list">
          <li class="qa-item" v-if="currentData.aTitle">
            <div class="qa-q"><span class="dot"></span><span class="q-text">{{ currentData.aTitle }}</span></div>
            <div class="qa-a"><span class="a-text">점수</span><span class="score-badge">{{ safeText(currentData.aScore, 0) }}점</span></div>
          </li>

          <li class="qa-item" v-if="currentData.cTitle">
            <div class="qa-q"><span class="dot"></span><span class="q-text">{{ currentData.cTitle }}</span></div>
            <div class="qa-a"><span class="a-text">점수</span><span class="score-badge">{{ safeText(currentData.cScore, 0) }}점</span></div>
          </li>

          <li class="qa-item" v-if="currentData.dTitle">
            <div class="qa-q"><span class="dot"></span><span class="q-text">{{ currentData.dTitle }}</span></div>
            <div class="qa-a"><span class="a-text">점수</span><span class="score-badge">{{ safeText(currentData.dScore, 0) }}점</span></div>
          </li>

          <li class="qa-item" v-if="currentData.eTitle">
            <div class="qa-q"><span class="dot"></span><span class="q-text">{{ currentData.eTitle }}</span></div>
            <div class="qa-a"><span class="a-text">점수</span><span class="score-badge">{{ safeText(currentData.eScore, 0) }}점</span></div>
          </li>

          <li class="qa-item" v-if="currentData.fTitle">
            <div class="qa-q"><span class="dot"></span><span class="q-text">{{ currentData.fTitle }}</span></div>
            <div class="qa-a">
              <span class="a-text">
                원점수 {{ safeText(currentData.fRawTotal, 0) }} / 환산 {{ safeText(currentData.fConvertedTotal, 0) }}
              </span>
              <span class="score-badge">{{ safeText(currentData.fConvertedTotal, 0) }}점</span>
            </div>
          </li>

          <li class="qa-item" v-if="currentData.gTitle">
            <div class="qa-q"><span class="dot"></span><span class="q-text">{{ currentData.gTitle }}</span></div>
            <div class="qa-a"><span class="a-text">점수</span><span class="score-badge">{{ safeText(currentData.gScore, 0) }}점</span></div>
          </li>
        </ul>

        <div class="hint" v-if="currentData.educationLabel">
          ※ 교육수준: {{ currentData.educationLabel }}
        </div>
      </template>

      <!-- =========================
           4) NEEDS (욕구)
           ========================= -->
      <template v-else>
        <div class="meta-row">
          <div class="meta-item">
            <span class="meta-label">요양사</span>
            <span class="meta-value">{{ currentData.careWorkerName || '-' }}</span>
          </div>
        </div>

        <div class="summary-line">
          <span class="summary-label">특이사항</span>
          <span class="summary-text">{{ safeText(currentData.subjectiveNeed, '-') }}</span>
        </div>

        <div class="summary-line">
          <span class="summary-label">한줄요약</span>
          <span class="summary-text">{{ safeText(currentData.summary, '-') }}</span>
        </div>
      </template>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import api from '@/lib/api'

const props = defineProps({
  beneficiaryId: { type: Number, default: null }
})

const baselineTabs = [
  { key: 'fall', label: '낙상위험도' },
  { key: 'bedsore', label: '욕창위험' },
  { key: 'cognitive', label: '인지기능' },
  { key: 'needs', label: '욕구사정' }
]

const activeBaseline = ref('fall')
const loading = ref(false)
const loadError = ref('')

const cache = ref({
  fall: null,
  bedsore: null,
  cognitive: null,
  needs: null
})

const activeTabTitle = computed(() => {
  const t = baselineTabs.find((x) => x.key === activeBaseline.value)
  return t ? `${t.label} 평가 (연 1회)` : '기초평가'
})

const emptyMessage = computed(() => {
  switch (activeBaseline.value) {
    case 'fall': return '낙상 평가 결과가 없습니다.'
    case 'bedsore': return '욕창 평가 결과가 없습니다.'
    case 'cognitive': return '인지기능 평가 결과가 없습니다.'
    case 'needs': return '욕구사정 평가 결과가 없습니다.'
    default: return '평가 결과가 없습니다.'
  }
})

const currentData = computed(() => cache.value[activeBaseline.value])

const safeText = (v, fallback = '-') => {
  if (v === null || v === undefined) return fallback
  const s = String(v).trim()
  return s.length ? s : fallback
}

const endpointByKey = (id, key) => {
  if (key === 'fall') return `/api/beneficiaries/${id}/basic-evaluations/fall/latest`
  if (key === 'bedsore') return `/api/beneficiaries/${id}/basic-evaluations/bedsore/latest`
  if (key === 'cognitive') return `/api/beneficiaries/${id}/basic-evaluations/cognitive/latest`
  return `/api/beneficiaries/${id}/basic-evaluations/needs/latest`
}

const unwrapOptional = (payload) => {
  if (!payload) return null
  if (payload.data !== undefined) return payload.data
  if (payload.result !== undefined) return payload.result
  if (payload.evalId !== undefined) return payload
  return null
}

const fetchLatest = async (key) => {
  if (!props.beneficiaryId) return

  loading.value = true
  loadError.value = ''

  try {
    const url = endpointByKey(props.beneficiaryId, key)
    // ✅ 디버그: 실제 호출 확인
    console.log('[BasicTest] GET', url)

    const res = await api.get(url)
    const data = unwrapOptional(res?.data)

    // ✅ 디버그: 응답 구조 확인
    console.log('[BasicTest] RES', res?.data)

    cache.value[key] = data || null
  } catch (e) {
    cache.value[key] = null
    loadError.value = e?.response?.data?.message || e?.message || 'unknown error'
    console.error('[BasicTest] ERR', e)
  } finally {
    loading.value = false
  }
}

// ✅ beneficiaryId 바뀌면 초기화 + 현재 탭부터 로드
watch(
  () => props.beneficiaryId,
  async (newId) => {
    cache.value = { fall: null, bedsore: null, cognitive: null, needs: null }
    loadError.value = ''
    if (newId) await fetchLatest(activeBaseline.value)
  },
  { immediate: true }
)

// ✅ 탭 바뀌면 캐시 없을 때만 로드
watch(
  () => activeBaseline.value,
  async (key) => {
    if (!props.beneficiaryId) return
    if (cache.value[key]) return
    await fetchLatest(key)
  }
)
</script>

<style scoped>
.baseline-wrap { margin-top: 4px; }

.baseline-subtabs {
  display: flex;
  gap: 24px;
  border-bottom: 1px solid #e5e7eb;
  margin: 0 -16px 8px;
  padding: 0 16px;
}
.baseline-subtab-btn {
  position: relative;
  border: none;
  background: transparent;
  padding: 8px 0;
  font-size: 13px;
  cursor: pointer;
  color: #6b7280;
}
.baseline-subtab-btn.active { color: #16a34a; font-weight: 600; }
.baseline-subtab-btn.active::after {
  content: '';
  position: absolute;
  left: 0; right: 0; bottom: -1px;
  height: 2px;
  background-color: #16a34a;
  border-radius: 999px;
}

.baseline-panel {
  margin-top: 10px;
  padding: 12px;
  border-radius: 12px;
  background-color: #faf5ff;
  border: 1px solid #ede9fe;
}
.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}
.header-left { display: flex; flex-direction: column; gap: 2px; }
.title { font-size: 13px; font-weight: 700; }
.sub { font-size: 11px; color: #6b7280; }
.header-right { display: flex; gap: 8px; align-items: center; }
.chip {
  font-size: 11px;
  padding: 4px 8px;
  border-radius: 999px;
  background-color: #ede9fe;
  color: #6d28d9;
  white-space: nowrap;
}
.chip.ghost { background-color: #f3f4f6; color: #6b7280; }

.state-box {
  padding: 12px 10px;
  border-radius: 10px;
  background: #fdfcff;
  border: 1px solid #e5e7eb;
  font-size: 12px;
  color: #4b5563;
}
.state-box.error {
  border-color: #fecaca;
  background: #fff1f2;
  color: #b91c1c;
}

.meta-row { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 8px; }
.meta-item {
  flex: 1;
  min-width: 140px;
  padding: 10px;
  border-radius: 10px;
  background: #fdfcff;
  border: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.meta-label { font-size: 11px; color: #6b7280; }
.meta-value { font-size: 13px; font-weight: 600; color: #111827; }
.meta-value.strong { font-weight: 800; }
.orange { color: #f97316; }

.meta-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: fit-content;
  padding: 4px 10px;
  border-radius: 999px;
  background: #fef3c7;
  color: #92400e;
  font-size: 12px;
  font-weight: 700;
}

.summary-line {
  margin-top: 10px;
  padding: 10px;
  border-radius: 10px;
  background: #fdfcff;
  border: 1px solid #e5e7eb;
  display: flex;
  gap: 10px;
  align-items: flex-start;
}
.summary-label {
  min-width: 70px;
  font-size: 11px;
  color: #6b7280;
  padding-top: 2px;
}
.summary-text { font-size: 12px; color: #374151; line-height: 1.4; white-space: pre-line; }

.divider { height: 1px; background: #e5e7eb; margin: 12px 0; }

.qa-list { list-style: none; margin: 0; padding: 0; }
.qa-item {
  padding: 10px;
  border-radius: 10px;
  background: #fdfcff;
  border: 1px solid #e5e7eb;
}
.qa-item + .qa-item { margin-top: 8px; }

.qa-q { display: flex; align-items: flex-start; gap: 8px; margin-bottom: 8px; }
.dot { width: 8px; height: 8px; border-radius: 999px; background: #a78bfa; margin-top: 4px; flex: 0 0 auto; }
.q-text { font-size: 12px; font-weight: 700; color: #111827; line-height: 1.3; }

.qa-a { display: flex; justify-content: space-between; align-items: center; gap: 10px; }
.a-text { font-size: 12px; color: #374151; line-height: 1.3; flex: 1; }

.score-badge {
  font-size: 11px;
  font-weight: 800;
  color: #6d28d9;
  background: #ede9fe;
  padding: 4px 8px;
  border-radius: 999px;
  white-space: nowrap;
}

.hint { margin-top: 10px; font-size: 11px; color: #ef4444; line-height: 1.35; }
</style>
