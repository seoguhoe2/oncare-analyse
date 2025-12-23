<template>
    <header class="global-header">
      <!-- 왼쪽 : 로고 -->
      <div class="header-left" @click="goHome">
        <div class="logo-icon">
          <img :src="logoIcon" alt="OnCare" />
        </div>
        <div class="logo-text">
          <div class="logo-sub">{{ currentRole[1] }}</div>
        </div>
      </div>
  
      <!-- 가운데 : 메뉴 -->
      <nav class="header-center">
        <RouterLink
          v-for="item in menuList"
          :key="item.key"
          :to="{ name: item.routeName }"
          class="gnb-item"
          :class="{ active: isActive(item) }"
        >
          <span class="gnb-icon">
            <img :src="item.icon" :alt="item.label" />
          </span>
          <span class="gnb-label">{{ item.label }}</span>
        </RouterLink>
      </nav>
  
      <!-- 오른쪽 : 알림 + 로그아웃 -->
      <div class="header-right">
        <button class="icon-button" type="button">
          <img :src="notificationIcon" alt="알림" />
        </button>
  
        <div class="user-box">
          <button class="logout-button" type="button" @click="onLogout">
            <span class="logout-icon">
              <img :src="logoutIcon" alt="로그아웃" />
            </span>
            <span>로그아웃</span>
          </button>
        </div>
      </div>
    </header>
  </template>
  
  <script setup>
  import { computed } from 'vue'
  import { useRouter, useRoute, RouterLink } from 'vue-router'
  import { useUserStore } from '@/stores/user'
  
  // 공통 로고
  import logoIcon from '@/assets/img/common/oncareIcon.png'
  
  // 대시보드/메뉴 아이콘 (파일명 정확히!)
  import businessIcon from '@/assets/img/dashboard/businessManagement.png'
  import scheduleIcon from '@/assets/img/common/scheduleManagement.png'
  import employeeIcon from '@/assets/img/common/employeeManagement.png'
  import recipientIcon from '@/assets/img/dashboard/recipientManagement.png'
  import inquiryIcon from '@/assets/img/dashboard/inquiryManagement.png'
  import suppliesIcon from '@/assets/img/dashboard/suppliesManagement.png'
  import homeIcon from '@/assets/img/dashboard/home.png'
  
  // 알림 / 로그아웃
  import notificationIcon from '@/assets/img/dashboard/notification.png'
  import logoutIcon from '@/assets/img/dashboard/logout.png'
  
  const router = useRouter()
  const route = useRoute()
  const userStore = useUserStore()
  
  // 역할별 메뉴 정의
  const MENU_CONFIG = {
    ROLE_CENTER_MANAGER: [
      { key: 'schedule', label: '일정 관리', routeName: 'schedule-calendar', icon: scheduleIcon },
      { key: 'employees', label: '직원 관리', routeName: 'employees', icon: employeeIcon },
      { key: 'recipient', label: '수급자 관리', routeName: 'recipient-list', icon: recipientIcon },
      { key: 'inquiry', label: '고객 관리', routeName: 'inquiry-consult', icon: inquiryIcon },
      { key: 'product', label: '용품 관리', routeName: 'product-master', icon: suppliesIcon },
      { key: 'tasks', label: '업무 관리', routeName: 'tasks-approval', icon: businessIcon },
    ],
    ROLE_SALES_TEAM: [
      { key: 'inquiry', label: '고객 관리', routeName: 'inquiry', icon: inquiryIcon },
      { key: 'recipient', label: '수급자 관리', routeName: 'recipient-list', icon: recipientIcon },
      { key: 'tasks', label: '업무 관리', routeName: 'tasks-approval', icon: businessIcon },
    ],
    ROLE_MATERIAL_TEAM: [
      { key: 'product', label: '용품 관리', routeName: 'product', icon: suppliesIcon },
      { key: 'tasks', label: '업무 관리', routeName: 'tasks-approval', icon: businessIcon },
    ],
    ROLE_CAREGIVER: [
      { key: 'home', label: '홈', routeName: 'home', icon: homeIcon },
      { key: 'activity', label: '활동일지', routeName: 'activity-care', icon: businessIcon },
      { key: 'workschedule', label: '근무일정', routeName: 'workschedule', icon: scheduleIcon },
      { key: 'recipient', label: '수급자 관리', routeName: 'recipient-list', icon: recipientIcon },
      { key: 'tasks', label: '업무 관리', routeName: 'tasks-approval', icon: businessIcon },
    ],
  }
  
  // 현재 역할
  const currentRole = computed(() => {

    let authority = "";
    let authority_name = userStore.jobName;;
  
    if (userStore.hasSomeAuthorities(["ROLE_CENTER_MANAGER"])) {
      authority = "ROLE_CENTER_MANAGER"; // 센터 관리자 
    } else if (userStore.hasAllAuthorities(["ROLE_SALES_TEAM","ROLE_TEAM_LEAD"])) {
      authority = "ROLE_SALES_TEAM"; // or 영업팀 팀장
    }  else if (userStore.hasAllAuthorities(["ROLE_SALES_TEAM","ROLE_EMPLOYEE"])) {
      authority = "ROLE_SALES_TEAM"; // 영업사원
    } else if(userStore.hasAllAuthorities(["ROLE_CAREGIVER"])) {
      authority = "ROLE_CAREGIVER"; // 요양사
    } else if(userStore.hasAllAuthorities(["ROLE_MATERIAL_TEAM","ROLE_EMPLOYEE"])) {
      authority = "ROLE_MATERIAL_TEAM";
    }
    return [authority, authority_name];
  })
  
  // 역할별 메뉴
  const menuList = computed(() => {
    console.log("currentRole.value::", currentRole.value);
    return MENU_CONFIG[currentRole.value[0]] || MENU_CONFIG.ROLE_CENTER_MANAGER
  })
  
  // 현재 라우트 기준 활성 메뉴
  const isActive = (item) => route.name === item.routeName
  
  // const isActive = (item) => {
  //   // 수급자 관리 메뉴: 부모 recipient 가 매칭되면 활성
  //   if (item.routeName === 'recipient') {
  //     return route.matched.some((m) => m.name === 'recipient')
  //   }
  
  //   // 다른 메뉴는 기존처럼
  //   return route.matched.some((m) => m.name === item.routeName)
  // }
  
  
  const goHome = () => {
    router.push({ name: 'dashboard' })
  }
  
  const onLogout = () => {
    userStore.logOut?.()
    router.push({ name: 'signin' })
  }
  </script>
  
  <style scoped>
  .global-header {
    position: sticky;
    top: 0;
    left: 0;
    right: 0;
    z-index: 50;
    margin: 0;
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 64px;
    padding: 0 32px;
    background: #ffffff;
    border-radius: 0;
    border-bottom: 1px solid #e5e7eb;
  }
  
  .header-left {
    display: flex;
    align-items: center;
    gap: 10px;
    cursor: pointer;
  }
  
  .logo-icon {
    width: 36px;
    height: 36px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
  }
  
  .logo-icon img {
    width: 100%;
    height: 100%;
    object-fit: contain;
  }
  
  .logo-text {
    display: flex;
    flex-direction: column;
    line-height: 1.1;
  }
  
  .logo-title {
    font-weight: 700;
    font-size: 18px;
    color: #16a34a;
  }
  
  .logo-sub {
    font-size: 12px;
    color: #64748b;
  }
  
  .header-center {
    flex: 1;
    display: flex;
    justify-content: center;
    gap: 16px;
  }
  
  .gnb-item {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 8px 14px;
    border-radius: 999px;
    font-size: 14px;
    color: #64748b;
    text-decoration: none;
  }
  
  .gnb-icon {
    width: 18px;
    height: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .gnb-icon img {
    width: 100%;
    height: 100%;
    object-fit: contain;
  }
  
  .gnb-item:hover {
    background: #f1f5f9;
    color: #111827;
  }
  
  .gnb-item.active {
    background: #dcfce7;
    color: #15803d;
    font-weight: 600;
  }
  
  .header-right {
    display: flex;
    align-items: center;
    gap: 16px;
  }
  
  .icon-button {
    border: none;
    background: transparent;
    cursor: pointer;
    font-size: 0;
    padding: 0;
  }
  
  .icon-button img {
    width: 20px;
    height: 20px;
    object-fit: contain;
  }
  
  .user-box {
    display: flex;
    align-items: center;
    gap: 8px;
  }
  
  .logout-button {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    border: none;             
    background: transparent;  
    padding: 0;
    font-size: 13px;
    cursor: pointer;
    color: #64748b;
  }
  
  .logout-button:hover {
    color: #111827;
  }
  
  .logout-icon {
    width: 16px;
    height: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .logout-icon img {
    width: 100%;
    height: 100%;
  }
  </style>