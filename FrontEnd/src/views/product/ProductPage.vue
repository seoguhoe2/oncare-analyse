<template>
  <div class="product-page">
    <!-- 상단 헤더 -->
    <div class="page-header">
      <div class="title-area">
        <h1 class="page-title">용품 관리</h1>
        <p class="page-desc">복지용구 렌탈 및 재고 관리</p>
      </div>
    </div>

    <!-- 탭 박스 -->
    <div class="tabs-box">
      <div class="inner-tabs">
        <RouterLink
          v-for="tab in tabs"
          :key="tab.key"
          :to="{ name: tab.routeName }"
          class="tab-item"
          :class="{ active: isActive(tab) }"
        >
          <span class="tab-label">{{ tab.label }}</span>
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

const tabs = [
  {
    key: 'master',
    label: '용품 마스터',
    routeName: 'product-master',
  },
  {
    key: 'manage',
    label: '관리 용품',
    routeName: 'product-manage',
  },
  {
    key: 'rental',
    label: '렌탈 계약',
    routeName: 'product-rental-contract',
  },
  {
    key: 'inout',
    label: '입출고 예정',
    routeName: 'product-inout-plan',
  },
]

const isActive = (tab) => route.name === tab.routeName
</script>

<style scoped>
.product-page {
  padding: 0 24px 24px;
}

/* 상단 헤더 (다른 페이지랑 통일) */
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

/* 탭 박스 */
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
