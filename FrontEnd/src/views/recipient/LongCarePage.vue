<!-- src/views/recipient/LongCarePage.vue -->
<template>
  <div class="page-body-longcare">
    <!-- 왼쪽 : 장기요양등급 만료 테이블 -->
    <section class="left-panel">
      <LongCare
        v-model:selected-id="selectedId"
        :refresh-key="refreshKey"
        :last-change="lastChange"
      />
    </section>

    <!-- 오른쪽 : 상세 안내 컴포넌트 -->
    <section class="right-panel">
      <div v-if="!selectedId" class="placeholder-card">
        <div class="placeholder-icon">⚠</div>
        <p class="placeholder-text">
          수급자를 선택하면<br />
          안내 상세 정보를 확인할 수 있습니다
        </p>
      </div>

      <LongCareDetail
        v-else
        :expiration-id="selectedId"
        @close="selectedId = null"
        @refresh="onRefresh"
      />
    </section>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import LongCare from '@/components/recipient/longcare/LongCare.vue'
import LongCareDetail from '@/components/recipient/longcare/LongCareDetail.vue'

const selectedId = ref(null)
const refreshKey = ref(0)

/**
 * ✅ 상세에서 올라온 변경 이벤트 전달용(즉시 UI 반영)
 * 예) { type:'extendsStatus', expirationId: 3, extendsStatus:'N' }
 */
const lastChange = ref(null)

const onRefresh = (payload) => {
  // ✅ extendsStatus 토글은 "즉시 제거/이동"이 목적 → 재조회 말고 이벤트만 전달
  if (payload && payload.type === 'extendsStatus') {
    // 같은 payload 연속 emit이어도 watcher가 확실히 돌도록 객체 새로 생성
    lastChange.value = { ...payload, ts: Date.now() }
    return
  }

  // ✅ 그 외(완료/삭제/수정 등)는 기존대로 재조회
  refreshKey.value++
}
</script>

<style scoped>
.page-body-longcare {
  margin-top: 12px;
  display: grid;
  grid-template-columns: minmax(0, 2.2fr) minmax(320px, 1fr);
  gap: 16px;
}

.left-panel,
.right-panel {
  display: flex;
  flex-direction: column;
}

.placeholder-card {
  width: 100%;
  height: 100%;
  min-height: 260px;
  border-radius: 16px;
  border: 1px solid #fde68a;
  background: #fffbeb;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.placeholder-icon {
  font-size: 32px;
  margin-bottom: 8px;
  color: #f97316;
}

.placeholder-text {
  margin: 0;
  font-size: 14px;
  color: #92400e;
  text-align: center;
  line-height: 1.5;
}

@media (max-width: 960px) {
  .page-body-longcare {
    grid-template-columns: 1fr;
  }

  .placeholder-card {
    margin-top: 8px;
  }
}
</style>
