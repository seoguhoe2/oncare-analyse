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
      <!-- 기본 정보 -->
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

      <!-- ✅ 등급 연장 예정 체크 -->
      <section class="extend-section">
        <label class="extend-checkbox">
          <input type="checkbox" v-model="extendPlanned" />
          <span class="extend-label">등급 연장 예정</span>
        </label>
        <p class="extend-help">체크 해제 시 만료 예정 리스트에서 제외됩니다</p>
      </section>

      <!-- 안내 이력 -->
      <section class="history-section">
        <div class="section-title-row">
          <span class="section-title">안내 이력 [{{ history.length }}회]</span>
        </div>

        <div class="history-list">
          <div
            v-for="log in history"
            :key="log.noticeId"
            class="history-item"
          >
            <div class="history-top">
              <span class="history-date">{{ log.noticeDate }}</span>

              <div class="history-right">
                <span
                  class="history-type"
                  :class="log.type === '완료' ? 'type-complete' : 'type-missed'"
                >
                  {{ log.type }}
                </span>

                <!-- ✅ 수정/삭제 (디자인 크게 안 깨는 작은 버튼) -->
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

      <!-- 입력 폼 -->
      <section class="form-section">
        <div class="form-grid">
          <div class="form-item">
            <label class="label">연락일자</label>
            <input type="date" v-model="form.date" />
          </div>
          <div class="form-item">
            <label class="label">담당자</label>
            <input
              type="text"
              v-model="form.staff"
              placeholder="담당자 이름을 입력하세요"
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

      <!-- 하단 버튼 -->
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
const myEmpId = computed(() => {
  // ✅ empId가 없으면 null 반환
  return userStore?.user?.empId ?? userStore?.empId ?? 1    // 로그인 적용하면 empId를 확보해서 자동 주입해야 함
})

const loading = ref(false)
const errorMsg = ref('')

const actionLoading = ref(false)

const detail = ref(null)
const history = ref([])

/** 연장 예정 체크박스 */
const extendPlanned = ref(true)

/** 폼 */
const today = () => new Date().toISOString().slice(0, 10)
const form = ref({
  date: today(),
  staff: '',
  memo: '',
})

/** 수정 모드 */
const isEditing = ref(false)
const editingNoticeId = ref(null)

const autoAbsentMemo = '연락 시도했으나 부재중. 추후 재연락 필요.'

const toHistoryItem = (it) => {
  const memo = it?.memo ?? ''
  const type = memo === autoAbsentMemo ? '부재중' : '완료'
  return {
    noticeId: it.noticeId,
    noticeDate: it.noticeDate,
    memo,
    empId: it.empId,
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

    // ✅ extendsStatus: null or 'Y' => 체크 true / 'N' => false
    extendPlanned.value = (detail.value?.extendsStatus ?? 'Y') !== 'N'

    // form 기본값
    form.value.staff = detail.value?.careWorkerName || ''
    form.value.date = today()
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
    const items = data?.items ?? []
    history.value = items.map(toHistoryItem)
  } catch (e) {
    console.error(e)
    history.value = []
  }
}

const reloadAll = async () => {
  await fetchDetail()
  await fetchNotices()
}

/** ✅ 연장예정 체크 변경 -> PATCH */
watch(extendPlanned, async (val) => {
  // detail 로딩 전에는 실행하지 않게
  if (!detail.value) return

  try {
    const extendsStatus = val ? 'Y' : 'N'
    await api.patch(`/api/care-level/expirations/${props.expirationId}/extends`, {
      extendsStatus
    })

    // ✅ detail에도 반영
    detail.value.extendsStatus = extendsStatus

    // ✅ 체크 해제 시 목록에서 제외되므로 부모에게 refresh 신호
    emit('refresh')
  } catch (e) {
    console.error(e)
    // 실패 시 UI 롤백
    extendPlanned.value = !val
    alert('연장 예정 상태 변경에 실패했습니다.')
  }
})

/** ✅ 부재중 기록 */
const recordAbsent = async () => {
  actionLoading.value = true
  try {
    await api.post(`/api/care-level/expirations/${props.expirationId}/notices/absent`, null, {
      params: { empId: myEmpId.value }
    })
    await fetchNotices()
    emit('refresh') // 목록 noticeLabel 갱신 필요할 수 있음
  } catch (e) {
    console.error(e)
    alert('부재중/미완료 기록에 실패했습니다.')
  } finally {
    actionLoading.value = false
  }
}

/** ✅ 안내 완료 처리 (insertNotice + outbound Y) */
const addComplete = async () => {
  if (!form.value.memo) {
    alert('안내 내용을 입력해주세요.')
    return
  }
  actionLoading.value = true
  try {
    // 백엔드가 "yyyy-MM-dd HH:mm:ss"도 허용하지만
    // 여기서는 date input만 쓰니까 "YYYY-MM-DD"로 전달
    await api.post(`/api/care-level/expirations/${props.expirationId}/notices/complete`, {
      noticeDate: form.value.date,
      memo: form.value.memo,
      empId: myEmpId.value
    })

    form.value.memo = ''
    await fetchNotices()
    emit('refresh')
  } catch (e) {
    console.error(e)
    alert('안내 완료 처리에 실패했습니다.')
  } finally {
    actionLoading.value = false
  }
}

/** ✅ 수정 시작 (폼에 채우기) */
const startEdit = (log) => {
  isEditing.value = true
  editingNoticeId.value = log.noticeId

  // 날짜 input은 YYYY-MM-DD만 받으니까 noticeDate에서 앞부분만
  const d = String(log.noticeDate || '').slice(0, 10)
  form.value.date = d || today()
  form.value.memo = log.memo || ''
  // staff는 화면 유지용
  form.value.staff = form.value.staff || ''
}

/** ✅ 수정 취소 */
const cancelEdit = () => {
  isEditing.value = false
  editingNoticeId.value = null
  form.value.date = today()
  form.value.memo = ''
}

/** ✅ 안내 이력 변경 PUT */
const saveEdit = async () => {
  if (!editingNoticeId.value) return
  if (!form.value.memo) {
    alert('안내 내용을 입력해주세요.')
    return
  }

  actionLoading.value = true
  try {
    await api.put(`/api/care-level/expirations/${props.expirationId}/notices/${editingNoticeId.value}`, {
      noticeDate: form.value.date,
      memo: form.value.memo,
      empId: myEmpId.value
    })

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

/** ✅ 안내 이력 삭제 DELETE */
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
  width: 100%;
  height: 100%;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  background: #ffffff;
  padding: 16px 18px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

/* 상태 */
.state {
  font-size: 12px;
  color: #6b7280;
}
.state.error {
  color: #b91c1c;
}

/* 헤더 */
.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}
.title h3 {
  margin: 0;
  font-size: 16px;
  color: #15803d;
}
.title .sub {
  font-size: 12px;
  color: #6b7280;
}
.close-btn {
  border: none;
  background: transparent;
  font-size: 18px;
  color: #9ca3af;
  cursor: pointer;
}

/* 기본 정보 */
.info-section {
  padding: 10px 12px;
  border-radius: 12px;
  background: #f9fafb;
}
.info-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px 16px;
}
.info-item .label {
  font-size: 11px;
  color: #6b7280;
}
.info-item .value {
  font-size: 13px;
  font-weight: 500;
  color: #111827;
}

/* ✅ 등급 연장 예정 체크 */
.extend-section {
  margin-top: -4px;
  padding: 8px 12px 4px;
}
.extend-checkbox {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: #111827;
}
.extend-checkbox input[type='checkbox'] {
  width: 14px;
  height: 14px;
}
.extend-label { font-weight: 500; }
.extend-help {
  margin: 2px 0 0;
  font-size: 11px;
  color: #6b7280;
}

/* 안내 이력 */
.history-section {
  border-radius: 12px;
  background: #f9fafb;
  padding: 10px 12px;
}
.section-title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}
.section-title {
  font-size: 13px;
  font-weight: 600;
}
.history-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.history-item {
  border-radius: 8px;
  background: #e0f2fe;
  padding: 8px 10px;
}
.history-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}
.history-date {
  font-size: 11px;
  color: #1e3a8a;
}

.history-right{
  display:flex;
  align-items:center;
  gap:6px;
}

.history-type {
  font-size: 11px;
  padding: 2px 8px;
  border-radius: 999px;
}
.type-complete {
  background: #dcfce7;
  color: #15803d;
}
.type-missed {
  background: #fee2e2;
  color: #b91c1c;
}

.icon-btn{
  border:none;
  background: transparent;
  font-size: 11px;
  color:#374151;
  cursor:pointer;
  padding:2px 4px;
}
.icon-btn.danger{
  color:#b91c1c;
}

.history-title {
  font-size: 12px;
  font-weight: 600;
  color: #1e3a8a;
}
.history-memo {
  font-size: 12px;
  color: #374151;
}
.history-empty {
  font-size: 12px;
  color: #9ca3af;
}

/* 폼 영역 */
.form-section {
  border-radius: 12px;
  background: #f9fafb;
  padding: 10px 12px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px 12px;
}
.form-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.form-item.full {
  grid-column: 1 / -1;
}
.label {
  font-size: 11px;
  color: #6b7280;
}
input,
textarea {
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  font-size: 12px;
  padding: 6px 8px;
  outline: none;
}
input:focus,
textarea:focus {
  border-color: #22c55e;
}

.edit-hint{
  display:flex;
  justify-content: space-between;
  align-items:center;
  font-size: 11px;
  color:#6b7280;
}
.mini-btn{
  border:none;
  background:#e5e7eb;
  color:#374151;
  border-radius: 999px;
  padding: 4px 10px;
  font-size: 11px;
  cursor:pointer;
}

/* 버튼 */
.detail-footer {
  margin-top: 4px;
  display: flex;
  gap: 10px;
}
.btn-primary,
.btn-secondary {
  flex: 1;
  border-radius: 999px;
  border: none;
  padding: 10px 0;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
}
.btn-primary {
  background: #22c55e;
  color: #ffffff;
}
.btn-secondary {
  background: #fed7aa;
  color: #92400e;
}
.btn-primary:disabled,
.btn-secondary:disabled{
  opacity:.6;
  cursor:not-allowed;
}
</style>
