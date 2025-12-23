<script setup>
import { ref } from 'vue';
import CareLogForm from '@/components/careworker/activity/CareLogForm.vue';
import { careLogHistoryMock } from '@/mock/careworker/activityHistory';

// 서브 탭 상태 (작성 / 내역)
const activeTab = ref('write');

const subTabs = [
  { key: 'write', label: '작성하기', icon: '📝' },
  { key: 'history', label: '작성 내역', icon: '📋' }
];

// 임시 내역 데이터 (Mock에서 가져옴)
const careLogHistory = ref([...careLogHistoryMock]);
</script>

<template>
  <div class="daily-care-page">
    <main class="main-content">

      <div class="sub-tabs">
        <button
          v-for="tab in subTabs"
          :key="tab.key"
          class="sub-tab-btn"
          :class="{ active: activeTab === tab.key }"
          @click="activeTab = tab.key"
        >
          <span class="tab-icon">{{ tab.icon }}</span>
          <span>{{ tab.label }}</span>
        </button>
      </div>

      <div class="tab-content">
        <div v-if="activeTab === 'write'" class="write-section">
          <CareLogForm />
        </div>

        <div v-else class="history-section">
          <div class="history-header">
            <h2 class="history-title">요양일지 작성내역</h2>
            <p class="history-count">총 {{ careLogHistory.length }}건의 일지가 등록되어 있습니다</p>
          </div>

          <div class="history-list">
            <div v-for="item in careLogHistory" :key="item.id" class="care-log-card">
              <!-- 카드 헤더 -->
              <div class="card-header">
                <div class="recipient-info">
                  <div class="avatar-circle">👤</div>
                  <div class="recipient-details">
                    <h3 class="recipient-name">{{ item.recipientName }}</h3>
                    <p class="service-date">
                      {{ item.date }} ({{ item.dayOfWeek }})
                    </p>
                  </div>
                </div>
                <span class="status-badge" :class="item.status === '승인됨' ? 'approved' : 'resubmit'">
                  {{ item.status }}
                </span>
              </div>

              <!-- 시간 및 주소 -->
              <div class="card-time-location">
                <div class="info-item">
                  <span class="info-icon">🕐</span>
                  <span class="info-text">{{ item.time }}</span>
                </div>
                <div class="info-item">
                  <span class="info-icon">📍</span>
                  <span class="info-text">{{ item.address }}</span>
                </div>
              </div>

              <!-- 서비스 태그 -->
              <div class="card-services">
                <span v-for="(service, index) in item.services" :key="index" class="service-tag">
                  {{ service }}
                </span>
              </div>

              <!-- 특이사항 -->
              <div class="card-notes">
                <div class="notes-header">
                  <span class="notes-icon">⚠️</span>
                  <span class="notes-label">오전 간단한 파우 활동 진행. 집중력 양호하심. 점심 식사 후 혈압 약 확인.</span>
                </div>
                <p class="notes-content">{{ item.specialNotes }}</p>
              </div>

              <!-- 액션 버튼 -->
              <div class="card-actions">
                <button class="btn-detail">📄 상세보기</button>
                <button class="btn-edit">✏️ 수정</button>
                <button class="btn-delete">🗑️ 삭제</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<style scoped>
.daily-care-page {
  background-color: #f8fafc;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.main-content {
  flex: 1;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
  padding: 1.5rem;
  padding-bottom: 3rem;
}

/* 서브 탭 */
.sub-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  border-bottom: 2px solid #e5e7eb;
}

.sub-tab-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  border: none;
  background: transparent;
  color: #6b7280;
  font-weight: 600;
  font-size: 0.875rem;
  cursor: pointer;
  position: relative;
  transition: all 0.2s;
  border-bottom: 3px solid transparent;
}

.sub-tab-btn:hover {
  color: #16a34a;
  background: #f0fdf4;
}

.sub-tab-btn.active {
  color: #16a34a;
  border-bottom-color: #16a34a;
  background: #f0fdf4;
}

.tab-icon {
  font-size: 1.125rem;
}

/* 탭 컨텐츠 */
.tab-content {
  min-height: 400px;
}

/* 작성 내역 섹션 */
.history-section {
  padding: 0;
}

.history-header {
  margin-bottom: 1.5rem;
  padding: 1.5rem;
  background: white;
  border-radius: 0.75rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.history-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 0.5rem 0;
}

.history-count {
  font-size: 0.875rem;
  color: #6b7280;
  margin: 0;
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

/* 요양일지 카드 */
.care-log-card {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 0.75rem;
  padding: 1.5rem;
  transition: all 0.3s;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.care-log-card:hover {
  border-color: #16a34a;
  box-shadow: 0 4px 12px rgba(22, 163, 74, 0.1);
  transform: translateY(-2px);
}

/* 카드 헤더 */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #f3f4f6;
}

.recipient-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.avatar-circle {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: linear-gradient(135deg, #16a34a 0%, #22c55e 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  color: white;
  flex-shrink: 0;
}

.recipient-details {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.recipient-name {
  font-size: 1.125rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.service-date {
  font-size: 0.8125rem;
  color: #6b7280;
  margin: 0;
}

.status-badge {
  padding: 0.375rem 0.875rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 700;
  white-space: nowrap;
}

.status-badge.approved {
  background: #dcfce7;
  color: #16a34a;
}

.status-badge.resubmit {
  background: #fef3c7;
  color: #d97706;
}

/* 시간 및 위치 */
.card-time-location {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.info-icon {
  font-size: 1rem;
}

.info-text {
  font-size: 0.875rem;
  color: #4b5563;
}

/* 서비스 태그 */
.card-services {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.service-tag {
  padding: 0.375rem 0.75rem;
  background: #f0fdf4;
  color: #16a34a;
  border-radius: 0.375rem;
  font-size: 0.75rem;
  font-weight: 600;
  border: 1px solid #bbf7d0;
}

/* 특이사항 */
.card-notes {
  background: #fffbeb;
  border-left: 4px solid #f59e0b;
  padding: 1rem;
  margin-bottom: 1rem;
  border-radius: 0.375rem;
}

.notes-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.notes-icon {
  font-size: 1rem;
}

.notes-label {
  font-size: 0.8125rem;
  font-weight: 700;
  color: #92400e;
}

.notes-content {
  font-size: 0.875rem;
  color: #78350f;
  margin: 0;
  line-height: 1.5;
}

/* 액션 버튼 */
.card-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
}

.card-actions button {
  padding: 0.625rem 1.25rem;
  border-radius: 0.5rem;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  border: none;
  display: flex;
  align-items: center;
  gap: 0.375rem;
}

.btn-detail {
  background: #3b82f6;
  color: white;
}

.btn-detail:hover {
  background: #2563eb;
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(59, 130, 246, 0.3);
}

.btn-edit {
  background: white;
  color: #6b7280;
  border: 1px solid #d1d5db;
}

.btn-edit:hover {
  background: #f9fafb;
  border-color: #9ca3af;
}

.btn-delete {
  background: #ef4444;
  color: white;
}

.btn-delete:hover {
  background: #dc2626;
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(239, 68, 68, 0.3);
}

/* 반응형 */
@media (max-width: 768px) {
  .main-content {
    padding: 1rem;
  }

  .sub-tabs {
    flex-direction: column;
    border-bottom: none;
  }

  .sub-tab-btn {
    border-bottom: none;
    border-left: 3px solid transparent;
  }

  .sub-tab-btn.active {
    border-left-color: #16a34a;
    border-bottom-color: transparent;
  }

  .history-header {
    padding: 1rem;
  }

  .history-title {
    font-size: 1.125rem;
  }

  .history-count {
    font-size: 0.8125rem;
  }

  .care-log-card {
    padding: 1rem;
  }

  .card-header {
    flex-direction: column;
    gap: 0.75rem;
  }

  .status-badge {
    align-self: flex-start;
  }

  .avatar-circle {
    width: 40px;
    height: 40px;
    font-size: 1.25rem;
  }

  .recipient-name {
    font-size: 1rem;
  }

  .card-notes {
    padding: 0.75rem;
  }

  .notes-label {
    font-size: 0.75rem;
  }

  .notes-content {
    font-size: 0.8125rem;
  }

  .card-actions {
    flex-direction: column;
    width: 100%;
  }

  .card-actions button {
    width: 100%;
    justify-content: center;
  }
}
</style>