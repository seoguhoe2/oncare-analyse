<!-- src/views/recipient/LongCarePage.vue -->
<template>
  <div class="page-body-longcare">
    <!-- 왼쪽 : 장기요양등급 만료 테이블 -->
    <section class="left-panel">
      <LongCare
        :key="refreshKey"
        v-model:selected-id="selectedId"
      />
    </section>

    <!-- 오른쪽 : 상세 안내 컴포넌트 -->
    <section class="right-panel">
      <!-- 아직 선택 안 된 상태 -->
      <div v-if="!selectedId" class="placeholder-card">
        <div class="placeholder-icon">⚠</div>
        <p class="placeholder-text">
          수급자를 선택하면<br />
          안내 상세 정보를 확인할 수 있습니다
        </p>
      </div>

      <!-- ✅ 선택된 상태: expirationId만 넘기면 됨 -->
      <LongCareDetail
        v-else
        :expiration-id="selectedId"
        @close="selectedId = null"
        @refresh="refreshKey++"
      />
    </section>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import LongCare from '@/components/recipient/longcare/LongCare.vue'
import LongCareDetail from '@/components/recipient/longcare/LongCareDetail.vue'

/** ✅ 선택된 expirationId */
const selectedId = ref(null)

/**
 * ✅ 상세에서 완료/수정/삭제/연장예정체크 등으로 인해
 * 목록이 갱신되어야 하면 refresh 이벤트를 올리고
 * 왼쪽 목록을 리로드하고 싶을 때 사용 가능
 *
 * - 가장 간단: LongCare에 :key를 걸어서 재마운트 → 목록 재조회
 */
const refreshKey = ref(0)
</script>

<style scoped>
.page-body-longcare {
  margin-top: 12px;
  display: grid;
  grid-template-columns: minmax(0, 2.2fr) minmax(320px, 1fr);
  gap: 16px;
}

/* 왼/오 패널 공통 */
.left-panel,
.right-panel {
  display: flex;
  flex-direction: column;
}

/* 선택 전 안내 카드 */
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

/* 반응형 */
@media (max-width: 960px) {
  .page-body-longcare {
    grid-template-columns: 1fr;
  }

  .placeholder-card {
    margin-top: 8px;
  }
}
</style>
