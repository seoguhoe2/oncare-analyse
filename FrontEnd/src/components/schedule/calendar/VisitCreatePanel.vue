<template>
  <div class="right-col">
    <div class="seg">
      <button
        class="seg-btn"
        :class="{ active: viewMode === 'form' }"
        type="button"
        @click="$emit('update:viewMode', 'form')"
      >
        입력
      </button>

      <button
        class="seg-btn"
        :class="{ active: viewMode === 'stash' }"
        type="button"
        @click="$emit('update:viewMode', 'stash')"
      >
        생성 예정
        <span class="count">{{ safeItems.length }}</span>
      </button>
    </div>

    <div class="panel" v-if="viewMode === 'form'">
      <textarea
        :value="memo"
        class="memo"
        placeholder="특이사항이나 전달사항을 입력하세요"
        @input="$emit('update:memo', $event.target.value)"
      />

      <div class="field-block">
        <div class="label">서비스 유형</div>
        <div class="select-wrap">
          <select
            :value="serviceTypeId"
            class="service-select"
            @change="$emit('update:serviceTypeId', $event.target.value)"
          >
            <option disabled value="">선택하세요</option>
            <option value="1">방문 요양</option>
            <option value="2">방문 목욕</option>
            <option value="3">방문 간호</option>
          </select>
          <span class="select-arrow">▾</span>
        </div>
      </div>

      <div class="field-list">
        <div class="field-row">
          <div class="field-label">날짜</div>
          <input
            :value="date"
            type="date"
            class="field-input"
            @input="$emit('update:date', $event.target.value)"
          />
        </div>

        <div class="field-row">
          <div class="field-label">시작</div>
          <input
            :value="startTime"
            type="time"
            class="field-input"
            @input="$emit('update:startTime', $event.target.value)"
          />
        </div>

        <div class="field-row">
          <div class="field-label">종료</div>
          <input
            :value="endTime"
            type="time"
            class="field-input"
            @input="$emit('update:endTime', $event.target.value)"
          />
        </div>
      </div>

      <div class="actions">
        <button class="btn-ghost-green" type="button" @click="$emit('stash')">
          일정 담기
        </button>
      </div>
    </div>

    <div class="panel" v-else>
      <div class="stash-head">
        <div class="stash-title">생성 예정 일정</div>

        <div class="stash-actions">
          <button
            class="mini"
            type="button"
            @click="$emit('clearAll')"
            :disabled="safeItems.length === 0"
          >
            전체 삭제
          </button>

          <button
            class="mini mini-green"
            type="button"
            @click="$emit('createAll')"
            :disabled="safeItems.length === 0"
          >
            일괄 생성
          </button>
        </div>
      </div>

      <div class="stash-list">
        <div v-if="safeItems.length === 0" class="empty">
          담긴 일정이 없습니다.
        </div>

        <div v-for="(it, idx) in safeItems" :key="it.key" class="stash-item">
          <div class="topline">
            <div class="time">
              {{ formatDot(it.date) }} · {{ it.startTime }} ~ {{ it.endTime }}
            </div>
            <button class="mini danger" type="button" @click="$emit('removeItem', idx)">
              삭제
            </button>
          </div>

          <div class="meta">
            <span class="pill">{{ serviceTypeLabel(it.serviceTypeId) }}</span>
            <span class="sep">·</span>
            <span class="name">{{ it.beneficiaryName || '수급자' }}</span>
            <span class="sep">·</span>
            <span class="name">{{ it.caregiverName || '요양보호사' }}</span>
          </div>

          <div v-if="(it.note || '').trim().length" class="note">
            {{ it.note }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  viewMode: { type: String, default: 'form' },
  items: { type: Array, default: () => [] },

  memo: { type: String, default: '' },
  serviceTypeId: { type: String, default: '' },
  date: { type: String, default: '' },
  startTime: { type: String, default: '06:00' },
  endTime: { type: String, default: '06:00' },
})

defineEmits([
  'update:viewMode',
  'update:memo',
  'update:serviceTypeId',
  'update:date',
  'update:startTime',
  'update:endTime',
  'stash',
  'createAll',
  'removeItem',
  'clearAll',
])

const safeItems = computed(() => (Array.isArray(props.items) ? props.items : []))

const formatDot = (ymd) => {
  if (!ymd) return ''
  const [y, m, d] = String(ymd).split('-')
  return `${y}. ${m}. ${d}.`
}

const serviceTypeLabel = (id) => {
  const v = Number(id)
  if (v === 1) return '방문 요양'
  if (v === 2) return '방문 목욕'
  if (v === 3) return '방문 간호'
  return '서비스'
}
</script>

<style scoped>
.right-col {
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  background: #fff;
}

.seg {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  padding: 0 0 12px;
  border-bottom: 1px solid #eef2f7;
}

.seg-btn {
  height: 46px;
  border-radius: 14px;
  border: 1px solid #e7edf6;
  background: #fff;
  cursor: pointer;
  font-weight: 900;
  color: #334155;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.seg-btn.active {
  border-color: rgba(0, 201, 80, 0.55);
  color: #0f172a;
}

.count {
  min-width: 24px;
  height: 24px;
  padding: 0 9px;
  border-radius: 999px;
  background: #eef2f7;
  font-weight: 900;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: #0f172a;
}

.panel {
  flex: 1;
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 12px 0 0;
}

.memo {
  width: 100%;
  height: 210px;
  resize: none;
  border: 1px solid #e7edf6;
  border-radius: 16px;
  padding: 14px;
  font-size: 14px;
  outline: none;
  background: #fff;
  color: #0f172a;
  box-sizing: border-box;
}

.memo::placeholder {
  color: #94a3b8;
  font-weight: 700;
}

.memo:focus {
  border-color: rgba(0, 201, 80, 0.55);
}

.field-block .label {
  font-size: 13px;
  font-weight: 900;
  color: #64748b;
  margin-bottom: 6px;
}

.select-wrap {
  position: relative;
}

.service-select {
  width: 100%;
  height: 44px;
  border-radius: 14px;
  border: 1px solid #e7edf6;
  padding: 0 40px 0 14px;
  font-size: 14px;
  background: #fff;
  color: #0f172a;
  outline: none;
  appearance: none;
  font-weight: 900;
}

.service-select:focus {
  border-color: rgba(0, 201, 80, 0.55);
}

.select-arrow {
  position: absolute;
  right: 14px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 14px;
  color: #64748b;
  pointer-events: none;
}

.field-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.field-row {
  display: grid;
  grid-template-columns: 52px 1fr;
  align-items: center;
  gap: 10px;
}

.field-label {
  font-size: 14px;
  font-weight: 900;
  color: #64748b;
}

.field-input {
  width: 100%;
  border: none;
  outline: none;
  background: transparent;
  font-size: 15px;
  color: #0f172a;
  padding: 6px 0;
  border-bottom: 1px solid #e7edf6;
  font-weight: 900;
  box-sizing: border-box;
}

.actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 6px;
}

.btn-ghost-green {
  height: 40px;
  padding: 0 14px;
  border-radius: 12px;
  border: 1px solid rgba(0, 201, 80, 0.55);
  background: #fff;
  color: #0b7a33;
  font-size: 14px;
  font-weight: 900;
  cursor: pointer;
  box-shadow: none;
}

.btn-ghost-green:hover {
  background: rgba(0, 201, 80, 0.06);
}

.btn-ghost-green:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

.stash-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  padding-bottom: 4px;
}

.stash-title {
  font-size: 16px;
  font-weight: 900;
  color: #0f172a;
}

.stash-actions {
  display: flex;
  gap: 10px;
  align-items: center;
}

.mini {
  height: 40px;
  padding: 0 14px;
  border: 1px solid #e7edf6;
  background: #fff;
  border-radius: 999px;
  font-weight: 900;
  cursor: pointer;
  color: #475569;
}

.mini-green {
  border-color: rgba(0, 201, 80, 0.55);
  color: #0b7a33;
}

.mini-green:hover {
  background: rgba(0, 201, 80, 0.06);
}

.mini:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

.mini.danger {
  border-color: rgba(239, 68, 68, 0.25);
  color: #ef4444;
}

.stash-list {
  flex: 1;
  min-height: 0;
  overflow: auto;
  padding-right: 2px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.empty {
  padding: 14px 2px;
  color: #94a3b8;
  font-weight: 900;
}

.stash-item {
  border: 1px solid #e7edf6;
  border-radius: 16px;
  padding: 14px;
  background: #fff;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.topline {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 10px;
}

.time {
  font-weight: 900;
  color: #0f172a;
}

.meta {
  font-weight: 900;
  color: #475569;
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}

.pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  height: 24px;
  padding: 0 10px;
  border-radius: 999px;
  background: rgba(0, 201, 80, 0.1);
  color: #0b7a33;
  font-weight: 900;
}

.sep {
  color: #cbd5e1;
  font-weight: 900;
}

.name {
  color: #0f172a;
}

.note {
  white-space: pre-wrap;
  color: #64748b;
  font-weight: 900;
  line-height: 1.5;
}
</style>