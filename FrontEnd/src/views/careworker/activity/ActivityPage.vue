<template>
  <div class="activity-page">
    <SimpleHeader
      :title="currentTab.title"
      :subtitle="currentTab.subtitle"
    />

    <nav class="top-tabs">
      <RouterLink
        v-for="tab in tabs"
        :key="tab.key"
        :to="tab.to"
        class="tab-btn"
        :class="{ active: route.name === tab.route }"
      >
        {{ tab.label }}
      </RouterLink>
    </nav>

    <div class="tab-content">
      <router-view />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import SimpleHeader from '@/components/common/SimpleHeader.vue'

const route = useRoute()

const tabs = [
  {
    key: 'care',
    label: '요양일지',
    route: 'activity-care',
    to: '/activity',
    title: '활동일지',
    subtitle: '방문 활동을 기록하고 관리합니다'
  },
  {
    key: 'basic',
    label: '기초평가',
    route: 'activity-basic',
    to: '/activity/basic',
    title: '기초평가',
    subtitle: '수급자의 건강 상태를 평가하고 관리합니다'
  },
  {
    key: 'counsel',
    label: '방문상담',
    route: 'activity-counsel',
    to: '/activity/counsel',
    title: '방문상담',
    subtitle: '방문 상담 내용을 기록하고 관리합니다'
  },
]

const currentTab = computed(() => {
  return tabs.find(tab => tab.route === route.name) || tabs[0]
})
</script>

<style scoped>
.activity-page {
  background-color: #f8fafc;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.top-tabs {
  display: flex;
  gap: 0.5rem;
  padding: 0 1.5rem;
  background: white;
  border-bottom: 2px solid #e5e7eb;
  max-width: 1400px;
  margin: 0 auto;
  width: 100%;
}

.tab-btn {
  padding: 1rem 1.5rem;
  text-decoration: none;
  color: #6b7280;
  font-weight: 600;
  font-size: 0.875rem;
  border-bottom: 3px solid transparent;
  transition: all 0.2s;
  position: relative;
}

.tab-btn:hover {
  color: #16a34a;
  background: #f0fdf4;
}

.tab-btn.active {
  color: #16a34a;
  background: #f0fdf4;
  border-bottom-color: #16a34a;
}

.tab-content {
  flex: 1;
}

/* 반응형 */
@media (max-width: 768px) {
  .top-tabs {
    padding: 0 1rem;
  }

  .tab-btn {
    padding: 0.75rem 1rem;
    font-size: 0.8125rem;
  }
}
</style>
