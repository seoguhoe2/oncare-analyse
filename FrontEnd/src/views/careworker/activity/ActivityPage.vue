<template>
  <div class="activity-page">
    <div class="page-header">
      <div class="title-area">
        <h1 class="page-title">{{ currentTab.title }}</h1>
        <p class="page-desc">{{ currentTab.subtitle }}</p>
      </div>
    </div>

    <div class="tabs-box">
      <div class="inner-tabs">
        <RouterLink
          v-for="tab in tabs"
          :key="tab.key"
          :to="tab.to"
          class="tab-item"
          :class="{ active: route.name === tab.route }"
        >
          {{ tab.label }}
        </RouterLink>
      </div>

      <div class="tab-content">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute();

const tabs = [
  {
    key: 'care',
    label: '요양일지',
    route: 'activity-care',
    to: '/activity',
    title: '요양일지',
    subtitle: '방문 활동을 기록하고 관리합니다',
  },
  {
    key: 'basic',
    label: '기초평가',
    route: 'activity-basic',
    to: '/activity/basic',
    title: '기초평가',
    subtitle: '수급자의 건강 상태를 평가하고 관리합니다',
  },
  {
    key: 'counsel',
    label: '방문상담',
    route: 'activity-counsel',
    to: '/activity/counsel',
    title: '방문상담',
    subtitle: '방문 상담 내용을 기록하고 관리합니다',
  },
];

const currentTab = computed(() => {
  return tabs.find((tab) => tab.route === route.name) || tabs[0];
});
</script>

<style scoped>
/* 페이지 전체 레이아웃 */
.activity-page {
  padding: 0 24px 24px;
  background-color: transparent; /* 배경색은 상위 컨테이너를 따르거나 제거 */
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* 상단 헤더 스타일 */
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
  color: #1a5928; /* 진한 녹색 (수급자 페이지와 동일) */
  margin: 0;
}

.page-desc {
  font-size: 14px;
  color: #4a5565; /* 회색 설명 텍스트 */
  margin: 0;
}

/* 카드형 탭 박스 컨테이너 */
.tabs-box {
  background: #ffffff;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 4px 12px rgba(15, 23, 42, 0.05);
  padding: 20px 24px;
  margin-top: 16px;
  flex: 1; /* 남은 공간 채우기 */
  display: flex;
  flex-direction: column;
}

/* 내부 탭 라인 */
.inner-tabs {
  display: flex;
  gap: 24px;
  border-bottom: 1px solid #e2e8f0;
  margin-top: 8px;
  flex-shrink: 0; /* 탭 영역 높이 고정 */
}

/* 개별 탭 버튼 스타일 */
.tab-item {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 12px 0;
  font-size: 16px;
  color: #4a5565;
  text-decoration: none;
  position: relative;
  font-weight: 500;
  transition: color 0.2s;
}

.tab-item:hover {
  color: #1a5928;
}

/* 활성화된 탭 스타일 */
.tab-item.active {
  color: #00a63e; /* 밝은 녹색 포인트 */
  font-weight: 600;
}

.tab-item.active::after {
  content: '';
  position: absolute;
  left: 0;
  bottom: -1px; /* 선이 border-bottom 위에 겹치도록 */
  width: 100%;
  height: 3px;
  background-color: #00a63e;
  border-radius: 999px;
}

/* 탭 컨텐츠 영역 */
.tab-content {
  padding-top: 24px;
  flex: 1;
}

/* 반응형 조정 */
@media (max-width: 768px) {
  .activity-page {
    padding: 16px;
  }

  .page-title {
    font-size: 24px;
  }

  .inner-tabs {
    gap: 16px;
  }

  .tab-item {
    font-size: 15px;
  }
}
</style>