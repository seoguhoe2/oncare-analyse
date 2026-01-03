<template>
  <div class="detail-card">
    <!-- 헤더 -->
    <header class="detail-header">
      <div class="title">
        <h3>만료 안내 상세</h3>
        <span class="sub">{{ detail?.beneficiaryName || '-' }}님 장기요양등급 만료 안내</span>
      </div>
      <button type="button" class="close-btn" @click="onClose">✕</button>
    </header>

    <!-- 로딩/에러 -->
    <div v-if="loading" class="state">불러오는 중...</div>
    <div v-else-if="errorMsg" class="state error">{{ errorMsg }}</div>

    <template v-else>
      <div class="detail-body">
        <!-- 기본 정보 (고정) -->
        <section class="info-section">
          <div class="info-grid">
            <div class="info-item">
              <div class="label">수급자명</div>
              <div class="value">{{ detail?.beneficiaryName || '-' }}</div>
            </div>
            <div class="info-item">
              <div class="label">등급</div>
              <div class="value">{{ detail?.careLevel || '-' }}</div>
            </div>
            <div class="info-item">
              <div class="label">만료일</div>
              <div class="value">{{ detail?.endDate || '-' }}</div>
            </div>
            <div class="info-item">
              <div class="label">D-Day</div>
              <div class="value">{{ detail?.ddayLabel || '-' }}</div>
            </div>
            <div class="info-item">
              <div class="label">담당 요양보호사</div>
              <div class="value">{{ detail?.careWorkerName || '-' }}</div>
            </div>
            <div class="info-item">
              <div class="label">보호자 연락처</div>
              <div class="value">{{ detail?.guardianPhone || '-' }}</div>
            </div>
          </div>
        </section>

        <!-- 등급 연장 예정 (고정) -->
        <section class="extend-section">
          <label class="extend-checkbox">
            <input type="checkbox" v-model="extendPlanned" />
            <span class="extend-label">등급 연장 예정</span>
          </label>
          <p class="extend-help">체크 해제 시 만료 예정 리스트에서 제외됩니다</p>
        </section>

        <!-- 안내 이력 (여기만 스크롤) -->
        <section class="history-section">
          <div class="section-title-row">
            <span class="section-title">안내 이력 [{{ history.length }}회]</span>
          </div>

          <div class="history-list scroll-history">
            <div v-for="log in history" :key="log.noticeId" class="history-item">
              <div class="history-top">
                <div class="history-left">
                  <span class="history-date">{{ log.noticeDate }}</span>
                  <span class="history-staff">{{ log.empName }}</span>
                </div>
                <div class="history-right">
                  <span
                    class="history-type"
                    :class="log.type === '완료' ? 'type-complete' : 'type-missed'"
                  >
                    {{ log.type }}
                  </span>

                  <button type="button" class="icon-btn" @click="startEdit(log)">수정</button>
                  <button type="button" class="icon-btn danger" @click="removeLog(log.noticeId)">삭제</button>
                </div>
              </div>

              <div class="history-body">
                <div class="history-title">{{ log.title }}</div>
                <div class="history-memo">{{ log.memo }}</div>
              </div>
            </div>

            <div v-if="history.length === 0" class="history-empty">
              아직 등록된 안내 이력이 없습니다.
            </div>
          </div>
        </section>

        <!-- 입력 폼 (고정) -->
        <section class="form-section">
          <!-- 현재/직접입력 탭 -->
          <div class="mode-tabs">
            <button
              type="button"
              class="mode-tab"
              :class="{ active: contactMode === 'now' }"
              @click="setContactMode('now')"
            >
              현재
            </button>
            <button
              type="button"
              class="mode-tab"
              :class="{ active: contactMode === 'manual' }"
              @click="setContactMode('manual')"
            >
              직접입력
            </button>
          </div>

          <div class="form-grid single">
            <div class="form-item">
              <label class="label">연락일자</label>

              <!-- 현재 탭: 입력 막힘 + 표시용 -->
              <input
                v-if="contactMode === 'now'"
                type="text"
                :value="nowKstPretty()"
                disabled
              />

              <!-- 직접입력 탭: 과거 날짜+시간 입력 가능(미래 금지) -->
              <input
                v-else
                type="datetime-local"
                v-model="form.contactAt"
                :max="nowKstDateTimeLocal()"
              />
            </div>
          </div>

          <div class="form-item full">
            <label class="label">안내 내용</label>
            <textarea
              rows="3"
              v-model="form.memo"
              placeholder="보호자와 통화 내용, 재평가 일정 안내 등 상세 내용을 입력하세요."
            />
          </div>

          <div class="form-item full" v-if="isEditing">
            <div class="edit-hint">
              현재 이력 수정 중입니다. (noticeId: {{ editingNoticeId }})
              <button type="button" class="mini-btn" @click="cancelEdit">수정 취소</button>
            </div>
          </div>
        </section>
      </div>

      <!-- 하단 버튼 (고정) -->
      <footer class="detail-footer">
        <button
          type="button"
          class="btn-secondary"
          @click="recordAbsent"
          :disabled="actionLoading"
        >
          부재중/미완료 기록
        </button>

        <button
          v-if="!isEditing"
          type="button"
          class="btn-primary"
          @click="addComplete"
          :disabled="actionLoading"
        >
          안내 완료 처리
        </button>

        <button
          v-else
          type="button"
          class="btn-primary"
          @click="saveEdit"
          :disabled="actionLoading"
        >
          안내 이력 변경
        </button>
      </footer>
    </template>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import api from '@/lib/api'
import { useUserStore } from '@/stores/user'

const props = defineProps({
  expirationId: { type: [Number, String], required: true }
})

const emit = defineEmits(['close', 'refresh'])

const userStore = useUserStore()
const myEmpId = computed(() => userStore?.user?.userId ?? userStore?.userId ?? null)

const requireEmpId = () => {
  if (!myEmpId.value) {
    alert('로그인 정보(직원번호)가 없습니다. 다시 로그인 해주세요.')
    return false
  }
  return true
}

const loading = ref(false)
const errorMsg = ref('')
const actionLoading = ref(false)

const detail = ref(null)
const history = ref([])

const extendPlanned = ref(true)

/**
 * KST 기준 "오늘 날짜(YYYY-MM-DD)" 만들기
 */
const todayKst = () => {
  const now = new Date()
  const kst = new Date(now.getTime() + 9 * 60 * 60 * 1000)
  return kst.toISOString().slice(0, 10)
}

/**
 * KST 기준 "지금(YYYY-MM-DDTHH:mm)" (datetime-local용)
 */
const nowKstDateTimeLocal = () => {
  const now = new Date()
  const kst = new Date(now.getTime() + 9 * 60 * 60 * 1000)
  return kst.toISOString().slice(0, 16) // YYYY-MM-DDTHH:mm
}

/**
 * KST 기준 "지금(YYYY-MM-DD HH:mm)" 표시용
 */
const nowKstPretty = () => {
  return nowKstDateTimeLocal().replace('T', ' ')
}

/**
 * datetime-local -> "YYYY-MM-DD HH:mm:ss" 로 변환(백엔드 전달용)
 */
const toDbDateTimeString = (dtLocal) => {
  if (!dtLocal) return null
  // dtLocal: "YYYY-MM-DDTHH:mm"
  return `${dtLocal.replace('T', ' ')}:00`
}

const contactMode = ref('now') // 'now' | 'manual'

const form = ref({
  contactAt: nowKstDateTimeLocal(), // 직접입력 탭에서 사용
  memo: '',
})

const setContactMode = (mode) => {
  contactMode.value = mode
  if (mode === 'now') {
    // 현재 탭으로 바꾸면 "지금"으로 갱신
    form.value.contactAt = nowKstDateTimeLocal()
  }
}

const isEditing = ref(false)
const editingNoticeId = ref(null)

const autoAbsentMemo = '연락 시도했으나 부재중. 추후 재연락 필요.'

/** 서버에서 noticeDate를 이미 "yyyy-MM-dd HH:mm:ss" 문자열로 내려줌 */
const prettyDateTime = (s) => {
  if (!s) return '-'
  return String(s).slice(0, 16)
}

const toHistoryItem = (it) => {
  const memo = it?.memo ?? ''
  const type = memo === autoAbsentMemo ? '부재중' : '완료'
  return {
    noticeId: it.noticeId,
    noticeDate: prettyDateTime(it.noticeDate),
    memo,
    empId: it.empId,
    empName: it.empName ?? '-',
    type,
    title: type === '부재중' ? '부재중 - 재연락 필요' : '만료 안내 완료',
  }
}

const fetchDetail = async () => {
  loading.value = true
  errorMsg.value = ''
  try {
    const { data } = await api.get(`/api/care-level/expirations/${props.expirationId}`)
    detail.value = data || null
    extendPlanned.value = (detail.value?.extendsStatus ?? 'Y') !== 'N'

    // 폼 초기화
    contactMode.value = 'now'
    form.value.contactAt = nowKstDateTimeLocal()
    form.value.memo = ''
  } catch (e) {
    console.error(e)
    errorMsg.value = '상세 정보를 불러오지 못했습니다.'
    detail.value = null
  } finally {
    loading.value = false
  }
}

const fetchNotices = async () => {
  try {
    const { data } = await api.get(`/api/care-level/expirations/${props.expirationId}/notices`)
    history.value = (data?.items ?? []).map(toHistoryItem)
  } catch (e) {
    console.error(e)
    history.value = []
  }
}

const reloadAll = async () => {
  await fetchDetail()
  await fetchNotices()
}

watch(extendPlanned, async (val) => {
  if (!detail.value) return
  try {
    const extendsStatus = val ? 'Y' : 'N'
    await api.patch(`/api/care-level/expirations/${props.expirationId}/extends`, { extendsStatus })
    detail.value.extendsStatus = extendsStatus

    emit('refresh', {
      type: 'extendsStatus',
      expirationId: props.expirationId,
      extendsStatus
    })
  } catch (e) {
    console.error(e)
    extendPlanned.value = !val
    alert('연장 예정 상태 변경에 실패했습니다.')
  }
})

/**
 * 직접입력 탭일 때만 미래 금지 검사 (과거는 OK)
 */
const validateManualDateTimeOrAlert = () => {
  if (contactMode.value !== 'manual') return true
  const max = nowKstDateTimeLocal()
  if (!form.value.contactAt) {
    alert('연락일자를 입력해주세요.')
    form.value.contactAt = max
    return false
  }
  if (String(form.value.contactAt) > String(max)) {
    alert('연락일자는 미래로 입력할 수 없습니다.')
    form.value.contactAt = max
    return false
  }
  return true
}

/**
 * 부재중
 * - 현재탭: 서버 NOW()
 * - 직접입력: noticeDate를 함께 보냄(백엔드가 지원하면 해당 시간 저장)
 */
const recordAbsent = async () => {
  if (!requireEmpId()) return
  if (!validateManualDateTimeOrAlert()) return

  actionLoading.value = true
  try {
    const params = { empId: myEmpId.value }
    if (contactMode.value === 'manual') {
      params.noticeDate = toDbDateTimeString(form.value.contactAt)
    }

    await api.post(
      `/api/care-level/expirations/${props.expirationId}/notices/absent`,
      null,
      { params }
    )

    await fetchNotices()
    emit('refresh')
  } catch (e) {
    console.error(e)
    alert('부재중/미완료 기록에 실패했습니다.')
  } finally {
    actionLoading.value = false
  }
}

/**
 * 안내 완료
 * - 현재탭: 서버 NOW()
 * - 직접입력: noticeDate 함께 전송
 */
const addComplete = async () => {
  if (!requireEmpId()) return
  if (!validateManualDateTimeOrAlert()) return

  if (!form.value.memo) {
    alert('안내 내용을 입력해주세요.')
    return
  }

  actionLoading.value = true
  try {
    const payload = {
      memo: form.value.memo,
      empId: myEmpId.value
    }
    if (contactMode.value === 'manual') {
      payload.noticeDate = toDbDateTimeString(form.value.contactAt)
    }

    await api.post(`/api/care-level/expirations/${props.expirationId}/notices/complete`, payload)

    form.value.memo = ''
    contactMode.value = 'now'
    form.value.contactAt = nowKstDateTimeLocal()

    await fetchNotices()
    emit('refresh')
  } catch (e) {
    console.error(e)
    alert('안내 완료 처리에 실패했습니다.')
  } finally {
    actionLoading.value = false
  }
}

const startEdit = (log) => {
  isEditing.value = true
  editingNoticeId.value = log.noticeId

  // 수정 시작하면: 기본은 "현재" 탭으로 두고(서버 NOW), 필요하면 직접입력으로 바꿔서 수정 가능
  contactMode.value = 'now'
  form.value.contactAt = nowKstDateTimeLocal()
  form.value.memo = log.memo || ''
}

const cancelEdit = () => {
  isEditing.value = false
  editingNoticeId.value = null

  contactMode.value = 'now'
  form.value.contactAt = nowKstDateTimeLocal()
  form.value.memo = ''
}

/**
 * 수정 저장
 * - 현재탭: 서버 NOW()로 업데이트 (00:00 문제 해결)
 * - 직접입력: noticeDate 함께 전송
 */
const saveEdit = async () => {
  if (!validateManualDateTimeOrAlert()) return
  if (!editingNoticeId.value) return

  if (!form.value.memo) {
    alert('안내 내용을 입력해주세요.')
    return
  }

  actionLoading.value = true
  try {
    const payload = {
      memo: form.value.memo,
      empId: myEmpId.value
    }
    if (contactMode.value === 'manual') {
      payload.noticeDate = toDbDateTimeString(form.value.contactAt)
    }

    await api.put(
      `/api/care-level/expirations/${props.expirationId}/notices/${editingNoticeId.value}`,
      payload
    )

    await fetchNotices()
    cancelEdit()
    emit('refresh')
  } catch (e) {
    console.error(e)
    alert('안내 이력 변경에 실패했습니다.')
  } finally {
    actionLoading.value = false
  }
}

const removeLog = async (noticeId) => {
  if (!confirm('해당 안내 이력을 삭제할까요?')) return
  actionLoading.value = true
  try {
    await api.delete(`/api/care-level/expirations/${props.expirationId}/notices/${noticeId}`)
    await fetchNotices()
    emit('refresh')
  } catch (e) {
    console.error(e)
    alert('안내 이력 삭제에 실패했습니다.')
  } finally {
    actionLoading.value = false
  }
}

const onClose = () => emit('close')

watch(
  () => props.expirationId,
  async () => {
    detail.value = null
    history.value = []
    cancelEdit()
    await reloadAll()
  },
  { immediate: true }
)
</script>

<style scoped>
.detail-card {
  box-sizing: border-box;
  max-width: 100%;
  min-width: 0;

  width: 100%;
  height: 100%;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  background: #ffffff;
  padding: 16px 18px;

  display: flex;
  flex-direction: column;
  gap: 14px;

  overflow: hidden;
}

.detail-body {
  flex: 1;
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.state { font-size: 12px; color: #6b7280; }
.state.error { color: #b91c1c; }

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}
.title h3 { margin: 0; font-size: 16px; color: #15803d; }
.title .sub { font-size: 12px; color: #6b7280; }
.close-btn {
  border: none;
  background: transparent;
  font-size: 18px;
  color: #9ca3af;
  cursor: pointer;
}

.info-section { padding: 10px 12px; border-radius: 12px; background: #f9fafb; }
.info-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px 16px;
}
.info-item .label { font-size: 11px; color: #6b7280; }
.info-item .value { font-size: 13px; font-weight: 500; color: #111827; }

.extend-section { margin-top: -4px; padding: 8px 12px 4px; }
.extend-checkbox {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: #111827;
}
.extend-checkbox input[type='checkbox'] { width: 14px; height: 14px; }
.extend-label { font-weight: 500; }
.extend-help { margin: 2px 0 0; font-size: 11px; color: #6b7280; }

.history-section {
  border-radius: 12px;
  background: #f9fafb;
  padding: 10px 12px;
  min-height: 0;
}
.scroll-history {
  max-height: 240px;
  overflow-y: auto;
  padding-right: 4px;
}
.scroll-history::-webkit-scrollbar { width: 6px; }
.scroll-history::-webkit-scrollbar-thumb { background-color: #d1d5db; border-radius: 4px; }
.scroll-history::-webkit-scrollbar-track { background-color: transparent; }

.section-title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}
.section-title { font-size: 13px; font-weight: 600; }

.history-list { display: flex; flex-direction: column; gap: 6px; }
.history-item { border-radius: 8px; background: #e0f2fe; padding: 8px 10px; }
.history-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px; }
.history-date { font-size: 11px; color: #1e3a8a; }
.history-right { display:flex; align-items:center; gap:6px; }
.history-type { font-size: 11px; padding: 2px 8px; border-radius: 999px; }
.type-complete { background: #dcfce7; color: #15803d; }
.type-missed { background: #fee2e2; color: #b91c1c; }
.icon-btn { border:none; background: transparent; font-size: 11px; color:#374151; cursor:pointer; padding:2px 4px; }
.icon-btn.danger { color:#b91c1c; }
.history-title { font-size: 12px; font-weight: 600; color: #1e3a8a; }
.history-memo { font-size: 12px; color: #374151; }
.history-empty { font-size: 12px; color: #9ca3af; }

.form-section {
  border-radius: 12px;
  background: #f9fafb;
  padding: 10px 12px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

/* 현재/직접입력 탭 */
.mode-tabs {
  display: flex;
  gap: 6px;
}
.mode-tab {
  border: 1px solid #e5e7eb;
  background: #ffffff;
  color: #374151;
  font-size: 12px;
  padding: 6px 10px;
  border-radius: 999px;
  cursor: pointer;
}
.mode-tab.active {
  border-color: #22c55e;
  color: #15803d;
  font-weight: 700;
  background: #ecfdf5;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px 12px;
}
.form-grid.single { grid-template-columns: 1fr; }

.form-item { display: flex; flex-direction: column; gap: 4px; }
.form-item.full { grid-column: 1 / -1; }
.label { font-size: 11px; color: #6b7280; }

input, textarea {
  box-sizing: border-box;
  width: 100%;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  font-size: 12px;
  padding: 6px 8px;
  outline: none;
}
input:focus, textarea:focus { border-color: #22c55e; }

.edit-hint {
  display:flex;
  justify-content: space-between;
  align-items:center;
  font-size: 11px;
  color:#6b7280;
}
.mini-btn {
  border:none;
  background:#e5e7eb;
  color:#374151;
  border-radius: 999px;
  padding: 4px 10px;
  font-size: 11px;
  cursor:pointer;
}

.detail-footer { margin-top: 4px; display: flex; gap: 10px; }
.btn-primary, .btn-secondary {
  flex: 1;
  border-radius: 999px;
  border: none;
  padding: 10px 0;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
}
.btn-primary { background: #22c55e; color: #ffffff; }
.btn-secondary { background: #fed7aa; color: #92400e; }
.btn-primary:disabled, .btn-secondary:disabled { opacity:.6; cursor:not-allowed; }

.history-left {
  display: flex;
  align-items: center;
  gap: 8px;
}
.history-staff {
  font-size: 11px;
  color: #374151;
  font-weight: 600;
}
</style>
