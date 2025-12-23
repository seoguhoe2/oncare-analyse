<template>
  <div class="schedule-page">
    <div class="page-header">
      <div class="title-area">
        <h1 class="page-title">일정 관리</h1>
        <p class="page-desc">요양보호사와 수급자 매칭 및 일정 관리</p>
      </div>

      <button class="add-button">
        <img src="@/assets/img/schedule/addSchedule.png" alt="일정 추가" />
        일정 추가
      </button>
    </div>

    <div class="tabs-box">
      <div class="inner-tabs">
        <RouterLink
          v-for="tab in tabs"
          :key="tab.key"
          :to="{ name: tab.routeName }"
          class="tab-item"
          :class="{ active: isActive(tab) }"
        >
          <span class="tab-icon" v-if="tab.icon">
            <img
              :src="isActive(tab) ? tab.activeIcon : tab.icon"
              :alt="tab.label"
            />
          </span>
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

import calendarIcon from '@/assets/img/common/scheduleManagement.png'
import calendarIconActive from '@/assets/img/common/greenSchedule.png'
import matchingIcon from '@/assets/img/common/employeeManagement.png'
import matchingIconActive from '@/assets/img/common/greenMatching.png'

const route = useRoute()

const tabs = [
  {
    key: 'calendar',
    label: '캘린더',
    routeName: 'schedule-calendar',
    icon: calendarIcon,
    activeIcon: calendarIconActive,
  },
  {
    key: 'matching',
    label: '매칭',
    routeName: 'schedule-matching',
    icon: matchingIcon,
    activeIcon: matchingIconActive,
  },
]

const isActive = (tab) => route.name === tab.routeName
</script>

<style scoped>
.schedule-page {
  padding: 0 24px 24px;
}

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

.add-button {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 18px;
  border-radius: 10px;
  border: none;
  background-color: #00c950;
  color: #fff;
  font-size: 15px;
  cursor: pointer;
}

.add-button img {
  width: 20px;
  height: 20px;
}

.tabs-box {
  background: #ffffff;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 4px 12px rgba(15, 23, 42, 0.05);
  padding: 20px 24px;
  margin-top: 16px;
}

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

.tab-icon img {
  width: 20px;
  height: 20px;
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