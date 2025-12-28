<!-- components/careworker/schedule/ScheduleDetail.vue -->

<script setup>
import { defineProps, defineEmits } from 'vue';

const props = defineProps({
  schedule: {
    type: Object,
    default: null,
  },
});

const emit = defineEmits(['close', 'edit', 'delete']);

const onClose = () => {
  emit('close');
};

// 수정 버튼
const handleEdit = () => {
  emit('edit', props.schedule);
};

// 삭제 버튼
const handleDelete = () => {
  if (confirm('정말 삭제하시겠습니까?')) {
    emit('delete', props.schedule);
  }
};

// 전화하기
const handleCall = () => {
  if (props.schedule?.phone) {
    window.location.href = `tel:${props.schedule.phone}`;
  }
};

// 길찾기
const handleNavigation = () => {
  if (props.schedule?.address) {
    // 카카오맵, 네이버지도 등으로 연동
    alert('길찾기 기능');
  }
};
</script>

<template>
  <section class="detail-panel">
    <div v-if="!schedule" class="placeholder">
      <div class="placeholder-icon">
        <div class="calendar-icon-box">📅</div>
      </div>
      <p class="placeholder-main">일정을 선택하면</p>
      <p class="placeholder-sub">상세 정보가 표시됩니다</p>
    </div>

    <div v-else class="detail-content">
      <!-- 헤더 -->
      <div class="detail-header">
        <div class="header-left">
          <h3 class="detail-title">{{ schedule.scheduleType === 'PERSONAL' ? '개인 일정' : '일정 상세' }}</h3>
        </div>
        <div class="header-right">
          <span class="status-badge">예정</span>
          <span class="date-text">{{ schedule.date }}</span>
          <button class="close-btn" type="button" @click="onClose">✕</button>
        </div>
      </div>

      <!-- 개인 일정 본문 -->
      <div v-if="schedule.scheduleType === 'PERSONAL'" class="detail-body">
        <!-- 일정 정보 카드 -->
        <div class="person-card">
          <div class="person-avatar">
            <div class="avatar-circle personal-icon">📅</div>
          </div>
          <div class="person-info">
            <div class="person-name">{{ schedule.title || schedule.recipient }}</div>
            <div class="person-detail">{{ schedule.serviceLabel || schedule.type }}</div>
            <div class="person-time">
              <span class="time-icon">🕐</span>
              {{ schedule.startTime }}-{{ schedule.endTime }}
            </div>
          </div>
        </div>

        <!-- 장소 -->
        <div class="section" v-if="schedule.location || schedule.address">
          <div class="section-header">
            <span class="section-icon">📍</span>
            <span class="section-title">장소/주소</span>
          </div>
          <div class="section-content">
            <p class="address-text">{{ schedule.location || schedule.address }}</p>
          </div>
        </div>

        <!-- 메모 -->
        <div class="section" v-if="schedule.notes">
          <div class="section-header">
            <span class="section-icon">📝</span>
            <span class="section-title">특이사항</span>
          </div>
          <div class="section-content special-content">
            <p class="special-text">{{ schedule.notes }}</p>
          </div>
        </div>

        <!-- 수정/삭제 버튼 -->
        <div class="action-buttons-bottom">
          <button class="action-btn edit-btn" type="button" @click="handleEdit">
            <span class="btn-icon">✏️</span>
            수정
          </button>
          <button class="action-btn delete-btn" type="button" @click="handleDelete">
            <span class="btn-icon">🗑️</span>
            삭제
          </button>
        </div>
      </div>

      <!-- 방문 일정 본문 -->
      <div v-else class="detail-body">
        <!-- 담당자 정보 -->
        <div class="person-card">
          <div class="person-avatar">
            <div class="avatar-circle">👤</div>
          </div>
          <div class="person-info">
            <div class="person-name">{{ schedule.recipient || '김영희' }}</div>
            <div class="person-detail">{{ schedule.serviceLabel || '신체활동지원' }}</div>
            <div class="person-time">
              <span class="time-icon">🕐</span>
              {{ schedule.startTime }}-{{ schedule.endTime }}
            </div>
          </div>
        </div>

        <!-- 전화하기 / 길찾기 버튼 -->
        <div class="action-buttons">
          <button class="action-btn call-btn" type="button" @click="handleCall">
            <span class="btn-icon">📞</span>
            전화하기
          </button>
          <button class="action-btn nav-btn" type="button" @click="handleNavigation">
            <span class="btn-icon">📍</span>
            길찾기
          </button>
        </div>

        <!-- 주소 -->
        <div class="section">
          <div class="section-header">
            <span class="section-icon">📍</span>
            <span class="section-title">주소</span>
          </div>
          <div class="section-content">
            <p class="address-text">{{ schedule.address || '서울시 강남구 테헤란로 123, 101동 502호' }}</p>
          </div>
        </div>

        <!-- 서비스 내용 -->
        <div class="section" v-if="schedule.serviceContent">
          <div class="section-header">
            <span class="section-icon">📋</span>
            <span class="section-title">서비스 내용</span>
          </div>
          <div class="section-content service-content">
            <div class="service-item">{{ schedule.serviceContent }}</div>
          </div>
        </div>

        <!-- 질환 -->
        <div class="section" v-if="schedule.disease && schedule.disease.length > 0">
          <div class="section-header">
            <span class="section-icon">❤️</span>
            <span class="section-title">질환</span>
          </div>
          <div class="section-content tag-content">
            <span class="tag tag-red" v-for="(item, index) in schedule.disease" :key="index">{{ item }}</span>
          </div>
        </div>

        <!-- 위험요소 -->
        <div class="section" v-if="schedule.riskFactors && schedule.riskFactors.length > 0">
          <div class="section-header warning-header">
            <span class="section-icon">⚠️</span>
            <span class="section-title">위험요소</span>
          </div>
          <div class="section-content tag-content">
            <span class="tag tag-warning" v-for="(item, index) in schedule.riskFactors" :key="index">{{ item }}</span>
          </div>
        </div>

        <!-- 특이사항 -->
        <div class="section" v-if="schedule.significants && schedule.significants.length > 0">
          <div class="section-header special-header">
            <span class="section-icon">⚡</span>
            <span class="section-title">특이사항</span>
          </div>
          <div class="section-content special-content">
            <p class="special-text" v-for="(item, index) in schedule.significants" :key="index">{{ item }}</p>
          </div>
        </div>

        <!-- 메모 -->
        <div class="section" v-if="schedule.notes">
          <div class="section-header">
            <span class="section-icon">📝</span>
            <span class="section-title">메모</span>
          </div>
          <div class="section-content special-content">
            <p class="special-text">{{ schedule.notes }}</p>
          </div>
        </div>

        <!-- 긴급연락처 -->
        <div class="section">
          <div class="section-header">
            <span class="section-title">긴급연락처</span>
          </div>
          <div class="section-content">
            <p class="emergency-contact">{{ schedule.emergencyContact || '010-9999-1111 (아들 김민준)' }}</p>
          </div>
        </div>

        <!-- 수정/삭제 버튼 -->
        <div class="action-buttons-bottom">
          <button class="action-btn edit-btn" type="button" @click="handleEdit">
            <span class="btn-icon">✏️</span>
            수정
          </button>
          <button class="action-btn delete-btn" type="button" @click="handleDelete">
            <span class="btn-icon">🗑️</span>
            삭제
          </button>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.detail-panel {
  box-sizing: border-box;
  width: 100%;
  height: 100%;
  background: #ffffff;
  border-radius: 24px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 4px 16px rgba(15, 23, 42, 0.04);
  padding: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.placeholder {
  height: 100%;
  min-height: 360px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #9ca3af;
}

.placeholder-icon {
  margin-bottom: 16px;
}

.calendar-icon-box {
  width: 52px;
  height: 52px;
  border-radius: 16px;
  border: 3px solid #e5e7eb;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.placeholder-main {
  font-size: 16px;
  margin: 0;
  font-weight: 600;
}

.placeholder-sub {
  font-size: 14px;
  margin: 4px 0 0;
}

.detail-content {
  display: flex;
  flex-direction: column;
  height: 100%;
}

/* 헤더 */
.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid #f1f5f9;
  flex-shrink: 0;
}

.header-left {
  display: flex;
  align-items: center;
}

.detail-title {
  font-size: 18px;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.status-badge {
  padding: 4px 12px;
  border-radius: 999px;
  font-size: 13px;
  font-weight: 600;
  background: #dbeafe;
  color: #1d4ed8;
}

.date-text {
  font-size: 14px;
  color: #64748b;
  font-weight: 500;
}

.close-btn {
  border: none;
  background: transparent;
  font-size: 20px;
  cursor: pointer;
  color: #94a3b8;
  padding: 4px;
  line-height: 1;
}

.close-btn:hover {
  color: #64748b;
}

/* 본문 스크롤 영역 */
.detail-body {
  flex: 1;
  overflow-y: auto;
  padding: 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* 담당자 카드 */
.person-card {
  background: #f0fdf4;
  border-radius: 16px;
  padding: 16px;
  display: flex;
  gap: 12px;
  align-items: flex-start;
}

.person-avatar .avatar-circle {
  width: 48px;
  height: 48px;
  border-radius: 999px;
  background: #22c55e;
  color: #ffffff;
  font-size: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.person-avatar .avatar-circle.personal-icon {
  background: #a78bfa;
}

.person-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.person-name {
  font-size: 16px;
  font-weight: 700;
  color: #1e293b;
}

.person-detail {
  font-size: 14px;
  color: #64748b;
}

.person-time {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 14px;
  color: #475569;
  margin-top: 4px;
}

.time-icon {
  font-size: 16px;
}

/* 액션 버튼 */
.action-buttons {
  display: flex;
  gap: 12px;
}

.action-btn {
  flex: 1;
  height: 48px;
  border-radius: 12px;
  border: none;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  transition: all 0.2s;
}

.call-btn {
  background: #dbeafe;
  color: #1e40af;
}

.call-btn:hover {
  background: #bfdbfe;
}

.nav-btn {
  background: #f3e8ff;
  color: #7c3aed;
}

.nav-btn:hover {
  background: #e9d5ff;
}

.btn-icon {
  font-size: 18px;
}

/* 섹션 */
.section {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 6px;
}

.section-icon {
  font-size: 16px;
}

.section-title {
  font-size: 14px;
  font-weight: 700;
  color: #334155;
}

.section-content {
  padding-left: 22px;
}

/* 주소 */
.address-text {
  margin: 0;
  font-size: 14px;
  color: #475569;
  line-height: 1.6;
}

/* 서비스 내용 */
.service-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.service-item {
  position: relative;
  padding-left: 20px;
  font-size: 14px;
  color: #475569;
}

.service-item::before {
  content: '✓';
  position: absolute;
  left: 0;
  color: #22c55e;
  font-weight: 700;
}

/* 태그 컨텐츠 */
.tag-content {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag {
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
  display: inline-block;
}

.tag-red {
  background: #fee2e2;
  color: #dc2626;
}

.tag-purple {
  background: #f3e8ff;
  color: #7c3aed;
}

.tag-warning {
  background: #fef3c7;
  color: #d97706;
}

/* 위험요소 헤더 */
.warning-header {
  color: #dc2626;
}

.warning-header .section-title {
  color: #dc2626;
}

/* 특이사항 */
.special-header {
  color: #d97706;
}

.special-header .section-title {
  color: #d97706;
}

.special-content {
  background: #fffbeb;
  border-radius: 12px;
  padding: 12px;
  margin-left: 0;
  padding-left: 12px;
}

.special-text {
  margin: 0;
  font-size: 14px;
  color: #92400e;
  line-height: 1.6;
}

/* 긴급연락처 */
.emergency-contact {
  margin: 0;
  font-size: 14px;
  color: #475569;
  font-weight: 500;
}

/* 하단 액션 버튼 */
.action-buttons-bottom {
  display: flex;
  gap: 12px;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #f1f5f9;
}

.edit-btn {
  background: #f0f9ff;
  color: #0369a1;
  border: 1px solid #bae6fd;
}

.edit-btn:hover {
  background: #e0f2fe;
  border-color: #7dd3fc;
}

.delete-btn {
  background: #fef2f2;
  color: #dc2626;
  border: 1px solid #fecaca;
}

.delete-btn:hover {
  background: #fee2e2;
  border-color: #fca5a5;
}

/* 스크롤바 스타일 */
.detail-body::-webkit-scrollbar {
  width: 6px;
}

.detail-body::-webkit-scrollbar-track {
  background: transparent;
}

.detail-body::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

.detail-body::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}
</style>
