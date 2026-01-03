<template>
  <div class="search-wrapper">
    <div class="search-input-wrap">
      <img src="@/assets/img/common/search.png" alt="search" class="search-icon" />

      <input
        type="text"
        class="search-input"
        placeholder="수급자, 요양보호사 이름 검색"
        :value="keyword"
        @input="onInput"
        @compositionstart="onCompositionStart"
        @compositionend="onCompositionEnd"
      />
    </div>

    <div class="scope-buttons">
      <button
        v-for="btn in buttons"
        :key="btn.value"
        type="button"
        class="scope-btn"
        :class="{ active: searchScope === btn.value }"
        @click="onScopeClick(btn.value)"
      >
        {{ btn.label }}
      </button>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  keyword: { type: String, default: '' },
  searchScope: { type: String, default: 'ALL' }, // ALL | BENEFICIARY | CAREWORKER
});

const emit = defineEmits(['update:keyword', 'update:searchScope']);

const buttons = [
  { label: '전체', value: 'ALL' },
  { label: '수급자', value: 'BENEFICIARY' },
  { label: '요양보호사', value: 'CAREWORKER' },
];

let composing = false;

const onCompositionStart = () => { composing = true; };
const onCompositionEnd = (e) => {
  composing = false;
  emit('update:keyword', e.target.value);
};
const onInput = (e) => {
  if (composing) return;
  emit('update:keyword', e.target.value);
};

const onScopeClick = (v) => {
  emit('update:searchScope', v);
};
</script>

<style scoped>
.search-wrapper {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 14px;
}

.search-input-wrap {
  position: relative;
  flex: 1;
  min-width: 320px;
  height: 48px;
  border: 1px solid #e2e8f0;
  border-radius: 999px;
  background: #fff;
  display: flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 16px;
  width: 18px;
  height: 18px;
  opacity: 0.8;
}

.search-input {
  width: 100%;
  height: 100%;
  padding: 0 16px 0 44px;
  border: none;
  outline: none;
  font-size: 14px;
  border-radius: 999px;
  box-sizing: border-box;
}

.search-input-wrap:has(.search-input:focus) {
  border-color: #00c950;
}

.scope-buttons {
  display: flex;
  gap: 10px;
  flex-shrink: 0;
}

.scope-btn {
  height: 48px;
  padding: 0 18px;
  border-radius: 999px;
  border: 1px solid #e2e8f0;
  background: #fff;
  font-size: 14px;
  cursor: pointer;
  white-space: nowrap;
}

.scope-btn.active {
  border-color: #22c55e;
}
</style>