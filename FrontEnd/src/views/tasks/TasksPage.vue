<script setup>
import { ref } from 'vue'
import { useRoute } from 'vue-router'
// (1) 컴포넌트 import (경로는 실제 파일 위치에 맞게 수정해주세요)
import RequestModal from '@/components/tasks/tasksheader/RequestModal.vue'
import TaskSummary from '@/components/tasks/tasksheader/TaskSummary.vue' 

const route = useRoute()
const isActive = (name) => route.name === name

// 모달 상태 관리
const isModalOpen = ref(false)

const handleCreate = () => {
  isModalOpen.value = true
}
</script>

<template>
  <div class="tasks-page">

    <div class="page-header">
      <div class="title-area">
        <h1 class="page-title">업무 관리</h1>
        <p class="page-desc">전자 결재 및 시설관리 업무</p>
      </div>
      
      <button class="btn-create" @click="handleCreate">
        <span class="plus-icon">+</span> 결재 요청
      </button>
    </div>

    <TaskSummary />

    <div class="tabs-box">
      <div class="inner-tabs">
        <RouterLink 
          :to="{ name: 'tasks-approval' }" 
          class="tab-item" 
          :class="{ active: isActive('tasks-approval') }"
        >
          전자 결재
        </RouterLink>
      </div>
      <div class="tab-content">
        <RouterView />
      </div>
    </div>

    <Transition name="fade">
      <RequestModal 
        v-if="isModalOpen" 
        @close="isModalOpen = false" 
      />
    </Transition>

  </div>
</template>

<style scoped>
.tasks-page {
  padding: 0 24px 24px;
}

/* 상단 헤더 */
.page-header {
  padding: 28px 0 12px;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
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

/* 결재 요청 버튼 스타일 */
.btn-create {
  background-color: #4ade80;
  color: white;
  border: none;
  border-radius: 8px;
  padding: 10px 20px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: background-color 0.2s;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.btn-create:hover {
  background-color: #22c55e;
}

.plus-icon {
  font-size: 18px;
  line-height: 1;
  font-weight: 400;
}

/* 모달 애니메이션 */
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

/* 카드형 탭 박스 */
.tabs-box {
  background: #ffffff;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 4px 12px rgba(15, 23, 42, 0.05);
  padding: 20px 24px;
  /* margin-top은 요약 카드가 들어왔으므로 약간 줄이거나 조정해도 됩니다. */
  margin-top: 16px; 
  min-height: 600px;
}

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
  cursor: pointer;
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