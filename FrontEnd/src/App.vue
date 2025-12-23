<template>
  <div class="app-root">
    <!--  공통 헤더 -->
    <HeaderBar v-if="showHeader" />

    <!-- 각 페이지 -->
    <RouterView />

    <!-- 공통 오버레이/토스트 -->
    <LoadingOverlay />
    <ToastContainer /> 
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { RouterView, useRoute } from 'vue-router'
import api from '@/lib/api'
import { useUserStore } from '@/stores/user'
import HeaderBar from '@/components/common/HeaderBar.vue'
import LoadingOverlay from './components/common/LoadingOverlay.vue'
import ToastContainer from './components/common/ToastContainer.vue'

const userStore = useUserStore()
const route = useRoute()

// 로그인, 회원가입 같은 페이지는 공통 헤더 제외 조건
const showHeader = computed(() => {
  const noHeaderPages = ['signin', 'signup'] // 필요하면 라우트 이름 더 추가
  return !noHeaderPages.includes(route.name)
})

</script>

<style>
.app-root {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}
</style>
