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
      
      <div class="notification-wrapper">
        <NotificationBell 
          :iconSrc="notificationIcon" 
          :count="unreadCount" 
          @toggle="toggleNotification" 
        />
        
        <NotificationList 
          :isOpen="isNotificationOpen" 
          :notifications="notifications" 
          @read="handleRead" 
          @click-item="handleItemClick"
          @view-all="goToAllNotifications" 
        />
      </div>
  
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
  import { computed, ref, onMounted, onUnmounted } from 'vue'
  import { useRouter, useRoute, RouterLink } from 'vue-router'
  import { useUserStore } from '@/stores/user'

  // 알림 컴포넌트 임포트
  import NotificationBell from '@/components/common/NotificationBell.vue'
  import NotificationList from '@/components/common/NotificationList.vue'
  import { getNotifications, getUnreadCount, deleteNotification, markAsRead, getSubscriptionUrl, markAllAsRead } from '@/api/alarm/alarmApi'
  
  // 공통 로고
  import logoIcon from '@/assets/img/common/oncareIcon.png'
  
  // 대시보드/메뉴 아이콘
  import businessIcon from '@/assets/img/dashboard/businessManagement.png'
  import scheduleIcon from '@/assets/img/common/scheduleManagement.png'
  import employeeIcon from '@/assets/img/common/employeeManagement.png'
  import recipientIcon from '@/assets/img/dashboard/recipientManagement.png'
  import inquiryIcon from '@/assets/img/dashboard/inquiryManagement.png'
  import suppliesIcon from '@/assets/img/dashboard/suppliesManagement.png'
  import homeIcon from '@/assets/img/dashboard/home.png'
  import api from '@/lib/api'
  
  // 알림 / 로그아웃
  import notificationIcon from '@/assets/img/dashboard/notification.png'
  import logoutIcon from '@/assets/img/dashboard/logout.png'
  
  const router = useRouter()
  const route = useRoute()
  const userStore = useUserStore()

  // --- [추가] 알림 관련 로직 ---
  const isNotificationOpen = ref(false)
  const notifications = ref([]) // 알림 데이터 목록
  const unreadCountVal = ref(0) // 읽지 않은 개수 (API 연동)
  const eventSource = ref(null) // SSE 연결 객체

  // 읽지 않은 개수 (배지용)
  const unreadCount = computed(() => unreadCountVal.value)

// 토글 함수
const toggleNotification = async () => {
  if (isNotificationOpen.value) {
      // 닫을 때: 별도의 읽음 처리 작업을 하지 않음 (클릭 시에만 읽음 처리)
      isNotificationOpen.value = false;
  } else {
      // 열 때: 알림 목록 및 개수 최신화
      await fetchNotifications();
      isNotificationOpen.value = true;
  }
}

// 1. 알림 목록 조회
const fetchNotifications = async () => {
    try {
        const response = await getNotifications(userStore.userId);
        // 전체 목록을 받아옴 (이미 읽음/안읽음 상태가 포함됨)
        notifications.value = response || [];
        
        // 읽지 않은 개수 별도 조회 (또는 목록에서 계산)
        const count = await getUnreadCount(userStore.userId);
        unreadCountVal.value = count;
        
    } catch (error) {
        console.error("알림 로딩 실패:", error);
    }
};

// 2. 알림 삭제 처리 (X 버튼 - 읽음 처리만 하고 데이터는 유지)
// 2. 알림 삭제 처리 (X 버튼 - 읽음 처리만 하고 데이터는 유지)
const handleRead = async (alarm) => {
    try {
        // 읽지 않은 상태일 때만 API 호출 및 카운트 감소
        if (alarm.status === 'SENT') {
            await markAsRead(alarm.alarmId);
            if (unreadCountVal.value > 0) unreadCountVal.value--;
        }

        // [수정] 상태와 상관없이 리스트에서 즉시 제거 (사용자 요청)
        notifications.value = notifications.value.filter(n => n.alarmId !== alarm.alarmId);
        
    } catch (e) {
        console.error("알림 삭제 처리 실패:", e);
    }
}

// 3. 알림 클릭 처리 (읽음 처리 + 이동)
const handleItemClick = async (alarm) => {
    // 1) 읽음 처리 (API 호출 및 상태 업데이트)
    if (alarm.status === 'SENT') {
        try {
            await markAsRead(alarm.alarmId);
            
            // 로컬 상태 변경 (리스트에서 삭제하지 않음)
            alarm.status = 'READ';
            if (unreadCountVal.value > 0) unreadCountVal.value--;
        } catch (e) {
            console.error("읽음 처리 실패:", e);
        }
    }

    // 2) 링크 이동
    if (alarm.linkUrl) {
        // 링크가 http로 시작하면 외부 링크, 아니면 내부 라우터
         if (alarm.linkUrl.startsWith('http')) {
            window.open(alarm.linkUrl, '_blank');
        } else {
            router.push(alarm.linkUrl);
        }
        // 알림창 닫기
        isNotificationOpen.value = false;
    }
}


// 초기 데이터 로드 및 SSE 연결
onMounted(async () => {
  if (userStore.userId) {
    try {
      // 1. 초기 데이터 병렬 조회
      const [notiData, countData] = await Promise.all([
        getNotifications(userStore.userId),
        getUnreadCount(userStore.userId)
      ])
      
      notifications.value = notiData || []
      unreadCountVal.value = countData || 0
      
      // 2. SSE 연결 (실시간 알림)
      const url = getSubscriptionUrl(userStore.userId)
      // 주의: 개발 환경 프록시가 /api 요청을 백엔드로 넘겨줘야 함
      eventSource.value = new EventSource(url)
      
      eventSource.value.addEventListener('notification', (event) => {
        try {
          const newAlarm = JSON.parse(event.data)
          console.log("새 알림 도착:", newAlarm)
          
          // 리스트 맨 앞에 추가
          notifications.value.unshift(newAlarm)
          
          // 읽지 않은 개수 증가
          unreadCountVal.value++
        } catch (e) {
          console.error('SSE parsing error:', e)
        }
      })
      
      eventSource.value.onerror = (err) => {
        console.error('SSE connection error:', err)
        eventSource.value.close()
      }
      
    } catch (err) {
      console.error('알림 초기화 실패:', err)
    }
  }
})

onUnmounted(() => {
  if (eventSource.value) {
    eventSource.value.close()
  }
})
  
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
  
  
  const goHome = async () => {
    // const response = await api.get('/health');
    // console.log(response.data);
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

.notification-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}
  </style>