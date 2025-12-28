<template>
  <div class="login-page">
    <div class="login-card">
      <div class="logo-area">
        <img src="@/assets/img/common/oncareIcon.png" alt="OnCare Logo" class="logo-image" />
      </div>

      <!-- 이메일 -->
      <div class="input-group">
        <img src="@/assets/img/sign/email.png" class="input-icon" />
        <input type="text" placeholder="이메일을 입력하세요" v-model="email" />
      </div>

      <!-- 비밀번호 -->
      <div class="input-group">
        <img src="@/assets/img/sign/password.png" class="input-icon" />
        <input type="password" placeholder="비밀번호를 입력하세요" v-model="pwd"/>
      </div>

      <button class="login-button" @click="handleLogin">
        로그인
      </button>
    </div>

    <p class="copyright">
      © 2025 OnCare. All rights reserved.
    </p>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { ref } from 'vue'
import { useUserStore } from '@/stores/user'
import api from '@/lib/api'
import {jwtDecode} from 'jwt-decode'
const router = useRouter();
const userStore = useUserStore();

/**
 * 권한별 아이디
 * id : admin1@example.com            관리자
 * id : material.staff1@example.com   자재팀 사원
 * id : cg1@example.com               요양보호사 (김요양1)
 * id : cg2@example.com               요양보호사 (이요양2)
 * id : sales.lead1@example.com       영업팀장
 * pwd : pwd123    (공통)
 */

const email = ref('cg1@example.com');
const pwd = ref('pwd123');

const handleLogin = async() => {
  const response =
    await api.post('/auth/login',
      {
        useremail: email.value,
        password: pwd.value
      },
      {
          headers: {
            'Content-Type': 'application/json',
            }
      });

    const { accessToken, tokenType } = response.data;

    // JWT 디코딩 (핵심)
    // 토큰의 Payload(Claim) 부분을 JSON 객체로 변환해줍니다.
    const decoded = jwtDecode(accessToken);

    userStore.setToken(accessToken , tokenType);
    userStore.logIn(decoded);

  // 요양보호사(jobname === '요양보호사')면 홈페이지로, 아니면 대시보드로 이동
  if (decoded.jobname === '요양보호사') {
    router.push({ name: 'home' })
  } else {
    router.push({ name: 'dashboard' })
  }
}
</script>

<style scoped>
/* 전체 레이아웃 */
.login-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #f6fbf8;
  font-family: 'Noto Sans KR', sans-serif;
}

/* 카드 */
.login-card {
  width: 420px;
  max-width: 92vw;
  background: #ffffff;
  border-radius: 20px;
  padding: 40px 48px 36px;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.06);
}

/* 로고 */
.logo-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 28px;
}

.logo-image {
  width: 60px;
  height: 60px;
  margin-bottom: 8px;
}

/* 입력창 */
.input-group {
  position: relative;
  display: flex;
  align-items: center;
  margin-bottom: 14px;
  background: #fafafa;
  border-radius: 10px;
  border: 1px solid #e4e4e4;
  padding: 12px 14px;
}

.input-icon {
  width: 20px;
  margin-right: 10px;
  opacity: 0.75;
}

.input-group input {
  flex: 1;
  border: none;
  font-size: 14px;
  background: transparent;
  outline: none;
}

/* 로그인 버튼 */
.login-button {
  width: 100%;
  padding: 12px 0;
  border-radius: 30px;
  border: none;
  background: linear-gradient(90deg, #36b46b, #1a8b4c);
  color: #fff;
  font-size: 16px;
  font-weight: 600;
  margin-top: 18px;
  cursor: pointer;
  transition: 0.2s;
}

.login-button:hover {
  opacity: 0.9;
}

.login-button:active {
  transform: scale(0.98);
}

copyright {
  margin-top: 16px;
  font-size: 12px;
  color: #999;
}
</style>