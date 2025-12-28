<template>
  <div class="memo-wrap" :class="{ 'is-saved': savedHint, 'is-error': saveError }">
    <div class="memo-head">
      <div class="memo-left">
        <img :src="memoIcon" class="memo-icon" alt="memo" />
        <div class="memo-title">{{ titleText }}</div>
      </div>

      <button
        class="accept-btn"
        type="button"
        :disabled="saving || !canSave"
        @click="onAccept"
        aria-label="메모 저장"
      >
        <img :src="memoAcceptIcon" alt="accept" />
      </button>
    </div>

    <div class="memo-box">
      <textarea
        class="memo-textarea"
        :placeholder="placeholder"
        v-model="text"
        :disabled="loading"
        @focus="clearSavedHint"
        @click="clearSavedHint"
      ></textarea>

      <div class="memo-hint">
        <span v-if="loading">불러오는 중…</span>
        <span v-else-if="saving">저장 중…</span>
        <span v-else-if="savedHint" class="hint-ok">저장 완료 ✓</span>
        <span v-else-if="saveError" class="hint-bad">저장 실패…</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue';
import memoIcon from '@/assets/img/schedule/memo.png';
import memoAcceptIcon from '@/assets/img/schedule/memoAccept.png';

import { getMemo, upsertMemo } from '@/api/schedule/memoApi.js';
import { getConfirmedMemo, upsertConfirmedMemo } from '@/api/schedule/confirmedMemoApi.js';

const props = defineProps({
  source: { type: String, default: 'NORMAL' }, // 'CONFIRMED' | 'NORMAL'
  matchingId: { type: [Number, String], default: null },
  vsId: { type: [Number, String], default: null },
  memoDate: { type: String, default: '' },
  placeholder: { type: String, default: '특이사항이나 전달사항을 입력하세요' },
  modelValue: { type: String, default: '' },
});

const emit = defineEmits(['update:modelValue', 'saved', 'loaded']);

const text = ref(props.modelValue || '');
const loading = ref(false);
const saving = ref(false);

const savedHint = ref(false);
const saveError = ref(false);

const isConfirmed = computed(() => String(props.source || '').toUpperCase() === 'CONFIRMED');
const titleText = computed(() => (isConfirmed.value ? '특이사항 메모' : '일정 메모'));

watch(
  () => props.modelValue,
  (v) => {
    if (v !== text.value) text.value = v ?? '';
  },
);

watch(
  () => text.value,
  (v) => emit('update:modelValue', v),
);

const canSave = computed(() => {
  if (isConfirmed.value) return props.vsId != null;
  return props.matchingId != null && !!props.memoDate;
});

const clearSavedHint = () => {
  // ✅ 메모창을 다시 누르면 “저장 완료” 숨김
  savedHint.value = false;
};

const resetFeedback = () => {
  saveError.value = false;
  savedHint.value = false;
};

const loadMemo = async () => {
  // ✅ 다른 일정(식별자 변경)로 이동하면 표시 초기화
  resetFeedback();

  if (!canSave.value) {
    text.value = props.modelValue || '';
    return;
  }

  loading.value = true;
  try {
    if (isConfirmed.value) {
      const res = await getConfirmedMemo({ vsId: Number(props.vsId) });
      const content = res?.note ?? '';
      text.value = content;
      emit('loaded', { content });
      return;
    }

    const res = await getMemo({ matchingId: Number(props.matchingId), date: props.memoDate });
    const content = res?.content ?? '';
    text.value = content;
    emit('loaded', { content });
  } catch (e) {
    text.value = '';
    emit('loaded', { content: '' });
  } finally {
    loading.value = false;
  }
};

const onAccept = async () => {
  if (!canSave.value) return;

  saveError.value = false;
  saving.value = true;

  try {
    if (isConfirmed.value) {
      await upsertConfirmedMemo({
        vsId: Number(props.vsId),
        note: text.value,
      });
      emit('saved', { content: text.value });
      savedHint.value = true; // ✅ 저장 완료 유지
      return;
    }

    await upsertMemo({
      matchingId: Number(props.matchingId),
      memoDate: props.memoDate,
      content: text.value,
    });
    emit('saved', { content: text.value });
    savedHint.value = true; // ✅ 저장 완료 유지
  } catch (e) {
    saveError.value = true;
    savedHint.value = false;
  } finally {
    saving.value = false;
  }
};

watch(
  () => [props.source, props.matchingId, props.vsId, props.memoDate],
  () => loadMemo(),
  { immediate: true },
);
</script>

<style scoped>
.memo-wrap {
  background: #fff7e6;
  border: 1px solid #f4c043;
  border-radius: 16px;
  padding: 16px 18px;
}

.memo-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.memo-left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.memo-icon {
  width: 22px;
  height: 22px;
}

.memo-title {
  font-size: 16px;
  font-weight: 800;
  color: #b45309;
}

.accept-btn {
  border: none;
  background: transparent;
  padding: 0;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.accept-btn:disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

.accept-btn img {
  width: 13px;
  height: 13px;
}

.memo-box {
  background: #ffffff;
  border: 1px solid #f4c043;
  border-radius: 14px;
  padding: 14px 14px 10px;
}

.memo-textarea {
  width: 100%;
  min-height: 130px;
  border: none;
  outline: none;
  resize: none;
  font-size: 14px;
  line-height: 1.6;
  color: #111827;
  background: transparent;
}

.memo-textarea:disabled {
  opacity: 0.75;
}

.memo-textarea::placeholder {
  color: #9ca3af;
}

.memo-hint {
  margin-top: 10px;
  font-size: 12px;
  color: #6b7280;
}

/* 실패만 강조 */
.memo-wrap.is-error .memo-box {
  border-color: #ef4444;
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.16);
}

.hint-ok {
  color: #16a34a;
  font-weight: 700;
}

.hint-bad {
  color: #ef4444;
  font-weight: 700;
}

.memo-wrap.is-saved .memo-box {
  border-color: #22c55e;
}
</style>