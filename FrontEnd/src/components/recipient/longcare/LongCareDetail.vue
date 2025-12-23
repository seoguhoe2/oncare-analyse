<!-- src/components/recipient/longcare/LongCareDetail.vue -->
<template>
  <div class="detail-card">
    <!-- 헤더 -->
    <header class="detail-header">
      <div class="title">
        <h3>만료 안내 상세</h3>
        <span class="sub">{{ item.name }}님 장기요양등급 만료 안내</span>
      </div>
      <button type="button" class="close-btn" @click="onClose">
        ✕
      </button>
    </header>

    <!-- 기본 정보 -->
    <section class="info-section">
      <div class="info-grid">
        <div class="info-item">
          <div class="label">수급자명</div>
          <div class="value">{{ item.name }}</div>
        </div>
        <div class="info-item">
          <div class="label">등급</div>
          <div class="value">{{ item.grade || '요양등급 정보' }}</div>
        </div>
        <div class="info-item">
          <div class="label">만료일</div>
          <div class="value">{{ item.expiryDate }}</div>
        </div>
        <div class="info-item">
          <div class="label">D-Day</div>
          <div class="value">D-{{ item.dday }}</div>
        </div>
        <div class="info-item">
          <div class="label">담당 요양보호사</div>
          <div class="value">{{ item.worker || '-' }}</div>
        </div>
        <div class="info-item">
          <div class="label">보호자 연락처</div>
          <div class="value">{{ item.guardianPhone || '예: 010-1234-5678' }}</div>
        </div>
      </div>
    </section>

    <!-- ✅ 등급 연장 예정 체크 -->
    <section class="extend-section">
      <label class="extend-checkbox">
        <input type="checkbox" v-model="extendPlanned" />
        <span class="extend-label">등급 연장 예정</span>
      </label>
      <p class="extend-help">
        체크 해제 시 만료 예정 리스트에서 제외됩니다
      </p>
    </section>

    <!-- 안내 이력 -->
    <section class="history-section">
      <div class="section-title-row">
        <span class="section-title">
          안내 이력 [{{ history.length }}회]
        </span>
      </div>

      <div class="history-list">
        <div
          v-for="log in history"
          :key="log.id"
          class="history-item"
        >
          <div class="history-top">
            <span class="history-date">{{ log.date }}</span>
            <span
              class="history-type"
              :class="log.type === '완료' ? 'type-complete' : 'type-missed'"
            >
              {{ log.type }}
            </span>
          </div>
          <div class="history-body">
            <div class="history-title">
              {{ log.title }}
            </div>
            <div class="history-memo">
              {{ log.memo }}
            </div>
          </div>
        </div>

        <div v-if="history.length === 0" class="history-empty">
          아직 등록된 안내 이력이 없습니다.
        </div>
      </div>
    </section>

    <!-- 최근 안내 완료 -->
    <section class="recent-section" v-if="lastComplete">
      <div class="recent-header">
        <span class="recent-icon">✅</span>
        <div>
          <div class="recent-title">최근 안내 완료</div>
          <div class="recent-sub">
            {{ lastComplete.date }} · 담당자 {{ lastComplete.staff }}
          </div>
        </div>
      </div>
      <div class="recent-body">
        <div class="recent-field">
          <div class="label">안내 내용</div>
          <div class="value">{{ lastComplete.memo }}</div>
        </div>
        <div class="recent-field" v-if="lastComplete.nextDate">
          <div class="label">다음 연락 예정일</div>
          <div class="value">{{ lastComplete.nextDate }}</div>
        </div>
      </div>
    </section>

    <!-- 입력 폼 (안내 완료 처리 전만 표시) -->
    <section class="form-section" v-if="!isCompletedMode">
      <div class="form-grid">
        <div class="form-item">
          <label class="label">연락일자</label>
          <input
            type="date"
            v-model="form.date"
          />
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

      <div class="form-item full">
        <label class="label">다음 연락 예정일</label>
        <input
          type="date"
          v-model="form.nextDate"
        />
      </div>
    </section>

    <!-- 하단 버튼 -->
    <!-- 안내 완료 처리 전: 두 개 버튼 -->
    <footer class="detail-footer" v-if="!isCompletedMode">
      <button
        type="button"
        class="btn-secondary"
        @click="addMissed"
      >
        부재중/미완료 기록
      </button>

      <button
        type="button"
        class="btn-primary"
        @click="addComplete"
      >
        안내 완료 처리
      </button>
    </footer>

    <!-- 안내 완료 처리 후: 안내 취소 버튼만 -->
    <footer class="detail-footer single" v-else>
      <button
        type="button"
        class="btn-cancel"
        @click="cancelComplete"
      >
        안내 취소
      </button>
    </footer>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  item: {
    type: Object,
    required: true,
  },
})

const emit = defineEmits(['close', 'change-extend'])

const history = ref([])
const lastComplete = ref(null)
const isCompletedMode = ref(false)
const extendPlanned = ref(true) // 체크박스 상태

const today = () => new Date().toISOString().slice(0, 10)

const form = ref({
  date: today(),
  staff: '',
  memo: '',
  nextDate: '',
})

watch(
  () => props.item,
  (val) => {
    if (!val) return

    // (샘플) 선택 시 기본 한 건 세팅
    history.value = [
      {
        id: 1,
        date: `${val.expiryDate}`,
        type: '완료',
        title: '사전 안내 완료',
        memo: '보호자에게 재평가 필요성 및 준비 서류 안내.',
      },
    ]
    lastComplete.value = null
    isCompletedMode.value = false

    // ✅ 등급 연장 예정 기본값: true (또는 기존 값 사용)
    if (val.extendPlanned === undefined) {
      val.extendPlanned = true
    }
    extendPlanned.value = val.extendPlanned

    form.value = {
      date: today(),
      staff: val.worker || '',
      memo: '',
      nextDate: '',
    }
  },
  { immediate: true }
)

// 체크박스 상태가 바뀌면 item 객체에 반영 + 이벤트 발행
watch(extendPlanned, (val) => {
  if (props.item) {
    props.item.extendPlanned = val
  }
  emit('change-extend', { id: props.item?.id, extendPlanned: val })
})

const nextHistoryId = () =>
  (history.value[history.value.length - 1]?.id || 0) + 1

const addMissed = () => {
  const log = {
    id: nextHistoryId(),
    date: form.value.date || today(),
    type: '부재중',
    title: '부재중 - 재연락 필요',
    memo: '연락 시도했으나 부재중. 추후 재연락 필요.',
  }
  history.value.push(log)
}

const addComplete = () => {
  if (!form.value.staff || !form.value.memo) {
    alert('담당자와 안내 내용을 입력해주세요.')
    return
  }

  const log = {
    id: nextHistoryId(),
    date: form.value.date || today(),
    type: '완료',
    title: '만료 안내 완료',
    memo: form.value.memo,
    nextDate: form.value.nextDate,
  }
  history.value.push(log)

  lastComplete.value = {
    date: log.date,
    staff: form.value.staff,
    memo: form.value.memo,
    nextDate: form.value.nextDate,
  }

  isCompletedMode.value = true

  // 안내 완료 후 메모만 비워줌
  form.value.memo = ''
}

// 이력/최근 완료는 그대로 두고, 폼/버튼 UI만 원래대로 복귀
const cancelComplete = () => {
  isCompletedMode.value = false
}

const onClose = () => {
  emit('close')
}
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
.extend-label {
  font-weight: 500;
}
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

/* 최근 안내 완료 */
.recent-section {
  border-radius: 12px;
  background: #f0fdf4;
  padding: 10px 12px;
}
.recent-header {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-bottom: 6px;
}
.recent-icon {
  font-size: 18px;
}
.recent-title {
  font-size: 13px;
  font-weight: 600;
  color: #166534;
}
.recent-sub {
  font-size: 11px;
  color: #4b5563;
}
.recent-field + .recent-field {
  margin-top: 4px;
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

/* 안내 취소 상태용 */
.detail-footer.single {
  gap: 0;
}
.btn-cancel {
  width: 100%;
  border-radius: 999px;
  border: none;
  padding: 10px 0;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  background: #e5e7eb;
  color: #374151;
}
</style>
