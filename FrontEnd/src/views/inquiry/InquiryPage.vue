<template>
  <div class="inquiry-page">

    <!-- 상단 헤더 -->
    <div class="page-header">
      <div class="title-area">
        <h1 class="page-title">고객 관리</h1>
        <p class="page-desc">상담 이력 및 고객 정보를 관리합니다</p>
      </div>
    </div>

    <!-- 탭 박스 -->
    <div class="tabs-box">
      <div class="inner-tabs">
        <RouterLink
          :to="{ name: 'inquiry-consult' }"
          class="tab-item"
          :class="{ active: isActive('inquiry-consult') }"
        >
          상담 관리
        </RouterLink>

        <RouterLink
          :to="{ name: 'inquiry-customer' }"
          class="tab-item"
          :class="{ active: isActive('inquiry-customer') }"
        >
          고객 관리
        </RouterLink>
      </div>

      <div class="tab-content">
        <RouterView />
      </div>
    </div>

  </div>
</template>

<script setup>
import { useRoute } from 'vue-router'

const route = useRoute()

// 활성 탭 체크
const isActive = (name) => route.name === name
</script>

<style scoped>
.inquiry-page {
  padding: 0 24px 24px;
}

/* 상단 헤더 */
.page-header {
  padding: 28px 0 12px;
}

.title-area {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.page-title {
  font-size: 30px;
  font-weight: 600;
  color: #1a5928;
  margin: 0;
}

.page-desc {
  font-size: 14px;
  color: #4a5565;
  margin: 0;
}

/* 탭 박스 (일정/수급자/직원과 동일한 스타일) */
.tabs-box {
  background: #ffffff;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 4px 12px rgba(15, 23, 42, 0.05);
  padding: 20px 24px;
  margin-top: 16px;
}

/* 탭 라인 */
.inner-tabs {
  display: flex;
  gap: 24px;
  border-bottom: 1px solid #e2e8f0;
  margin-top: 8px;
}

.tab-item {
  padding: 12px 0;
  font-size: 16px;
  color: #4a5565;
  text-decoration: none;
  position: relative;
  font-weight: 500;
}

.tab-item.active {
  color: #00a63e;
  font-weight: 600;
}

.tab-item.active::after {
  content: '';
  position: absolute;
  left: 0;
  bottom: -1px;
  width: 100%;
  height: 3px;
  background-color: #00a63e;
  border-radius: 999px;
}

.tab-content {
  padding-top: 16px;
}
</style>
