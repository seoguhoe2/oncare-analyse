<template>
  <div class="recipient-page">
    <!-- 상단 헤더 -->
    <div class="page-header">
      <div class="title-area">
        <h1 class="page-title">수급자 관리</h1>
        <p class="page-desc">수급자 정보 및 서비스 이용 내역 관리</p>
      </div>

      <!--  여기 있던 "수급자 등록" 버튼 제거 -->
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

    <!--  여기 있던 RecipientRegist(기존명 : 수급자 등록) 모달 제거 -->
  </div>
</template>

<script setup>
import { useRoute } from 'vue-router'

const route = useRoute()

// 상단 서브 탭 정의
const tabs = [
  {
    key: 'list',
    label: '수급자 목록',
    routeName: 'recipient-list',
  },
  {
    key: 'longcare',
    label: '장기요양등급만료알림',
    routeName: 'recipient-longcare',
  },
]

const isActive = (tab) => route.name === tab.routeName
</script>

<style scoped>
.recipient-page {
  padding: 0 24px 24px;
}

/* 상단 헤더 (일정 관리와 동일 스타일) */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
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

/* 카드형 탭 박스 */
.tabs-box {
  background: #ffffff;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 4px 12px rgba(15, 23, 42, 0.05);
  padding: 20px 24px;
  margin-top: 16px;
}

/* 상단 탭 라인 */
.inner-tabs {
  display: flex;
  gap: 24px;
  border-bottom: 1px solid #e2e8f0;
  margin-top: 8px;
}

.tab-item {
  display: inline-flex;
  align-items: center;
  gap: 8px;
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
