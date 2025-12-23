<script setup>
import { ref } from 'vue';
import VisitCounselForm from '@/components/careworker/activity/VisitCounselForm.vue';
import { counselHistoryMock } from '@/mock/careworker/activityHistory';

// 메인 탭 상태 (작성 / 내역)
const mainTab = ref('write');

const mainTabs = [
  { key: 'write', label: '작성하기', icon: '📝' },
  { key: 'history', label: '작성 내역', icon: '📋' }
];

// 임시 내역 데이터 (Mock에서 가져옴)
const counselHistory = ref([...counselHistoryMock]);

// 전자서명 모달 상태
const showSignatureModal = ref(false);
const signatureType = ref(''); // 'recipient' or 'caregiver'
const currentItemId = ref(null);

// 방문상담 제출 처리
const handleSubmit = (data) => {
  console.log('방문상담 제출:', data);
  alert('방문상담이 저장되었습니다.');
};

// 방문상담 임시저장
const handleSaveDraft = (data) => {
  console.log('방문상담 임시저장:', data);
  alert('임시저장되었습니다.');
};

// 전자서명 모달 열기
const openSignatureModal = (itemId, type) => {
  currentItemId.value = itemId;
  signatureType.value = type;
  showSignatureModal.value = true;
};

// 전자서명 모달 닫기
const closeSignatureModal = () => {
  showSignatureModal.value = false;
  signatureType.value = '';
  currentItemId.value = null;
};

// 서명 저장
const saveSignature = () => {
  const item = counselHistory.value.find(i => i.id === currentItemId.value);
  if (item) {
    if (signatureType.value === 'recipient') {
      item.recipientSigned = true;
    } else if (signatureType.value === 'caregiver') {
      item.caregiverSigned = true;
    }
  }
  alert('서명이 저장되었습니다.');
  closeSignatureModal();
};
</script>

<template>
  <div class="visit-counsel-page">
    <main class="main-content">
      <!-- 메인 탭 (작성 / 내역) -->
      <div class="main-tabs">
        <button
          v-for="tab in mainTabs"
          :key="tab.key"
          class="main-tab-btn"
          :class="{ active: mainTab === tab.key }"
          @click="mainTab = tab.key"
        >
          <span class="tab-icon">{{ tab.icon }}</span>
          <span>{{ tab.label }}</span>
        </button>
      </div>

      <!-- 작성 탭 -->
      <div v-if="mainTab === 'write'" class="write-section">
        <VisitCounselForm
          @submit="handleSubmit"
          @save-draft="handleSaveDraft"
        />
      </div>

      <!-- 작성 내역 탭 -->
      <div v-else class="history-section">
        <div class="history-header">
          <h2 class="history-title">방문상담 작성내역</h2>
          <p class="history-count">총 {{ counselHistory.length }}건의 상담이 등록되어 있습니다</p>
        </div>

        <div class="history-list">
          <div v-for="item in counselHistory" :key="item.id" class="counsel-card">
            <!-- 카드 헤더 -->
            <div class="card-header">
              <div class="recipient-info">
                <div class="avatar-circle">👤</div>
                <div class="recipient-details">
                  <h3 class="recipient-name">{{ item.recipientName }}</h3>
                  <p class="counsel-date">{{ item.date }}</p>
                </div>
              </div>
              <span class="status-badge completed">{{ item.status }}</span>
            </div>

            <!-- 상담 정보 -->
            <div class="counsel-info-grid">
              <div class="info-field">
                <span class="field-label">상담 유형</span>
                <span class="field-value">{{ item.counselType }}</span>
              </div>
              <div class="info-field">
                <span class="field-label">만족도</span>
                <span class="field-value">{{ item.reaction }}</span>
              </div>
            </div>

            <!-- 방문 목적 -->
            <div class="section-box">
              <h4 class="section-title">방문 목적</h4>
              <p class="section-content">{{ item.visitPurpose }}</p>
            </div>

            <!-- 참석 가족 -->
            <div class="section-box">
              <h4 class="section-title">참석 가족</h4>
              <p class="section-content">{{ item.observedCondition }}</p>
            </div>

            <!-- 주요 논의사항 -->
            <div class="section-box highlight">
              <h4 class="section-title">주요 논의사항</h4>
              <p class="section-content">{{ item.subjectiveNeeds }}</p>
            </div>

            <!-- 합의 사항 -->
            <div class="section-box success">
              <h4 class="section-title">합의 사항</h4>
              <p class="section-content">{{ item.counselorNotes }}</p>
            </div>

            <!-- 다음 방문 예정 -->
            <div class="next-visit">
              <span class="calendar-icon">📅</span>
              <span class="next-visit-label">다음 방문 예정:</span>
              <span class="next-visit-date">{{ item.nextVisit }}</span>
            </div>

            <!-- 서명 및 액션 버튼 -->
            <div class="card-footer">
              <div class="signature-section">
                <button
                  class="signature-btn"
                  :class="{ signed: item.recipientSigned }"
                  @click="openSignatureModal(item.id, 'recipient')"
                >
                  <span class="signature-icon">{{ item.recipientSigned ? '✓' : '✍️' }}</span>
                  <span class="signature-label">수급자/보호자 서명</span>
                </button>
                <button
                  class="signature-btn"
                  :class="{ signed: item.caregiverSigned }"
                  @click="openSignatureModal(item.id, 'caregiver')"
                >
                  <span class="signature-icon">{{ item.caregiverSigned ? '✓' : '✍️' }}</span>
                  <span class="signature-label">요양보호사 서명</span>
                </button>
              </div>
              <div class="action-buttons">
                <button class="btn-edit">✏️ 수정</button>
                <button class="btn-delete">🗑️ 삭제</button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 전자서명 모달 -->
      <div v-if="showSignatureModal" class="modal-overlay" @click="closeSignatureModal">
        <div class="modal-content" @click.stop>
          <div class="modal-header">
            <h3>{{ signatureType === 'recipient' ? '수급자/보호자 서명' : '요양보호사 서명' }}</h3>
            <button class="modal-close-btn" @click="closeSignatureModal">✕</button>
          </div>
          <div class="modal-body">
            <div class="signature-pad">
              <p class="signature-instruction">아래 영역에 서명해주세요</p>
              <canvas class="signature-canvas" width="500" height="200"></canvas>
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn-cancel" @click="closeSignatureModal">취소</button>
            <button class="btn-save" @click="saveSignature">서명 저장</button>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<style scoped>
.visit-counsel-page {
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

/* 메인 탭 (작성/내역) */
.main-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  border-bottom: 2px solid #e5e7eb;
}

.main-tab-btn {
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
  transition: all 0.2s;
  border-bottom: 3px solid transparent;
}

.main-tab-btn:hover {
  color: #16a34a;
  background: #f0fdf4;
}

.main-tab-btn.active {
  color: #16a34a;
  border-bottom-color: #16a34a;
  background: #f0fdf4;
}

.tab-icon {
  font-size: 1.125rem;
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
  gap: 1.5rem;
}

/* 방문상담 카드 */
.counsel-card {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 0.75rem;
  padding: 1.5rem;
  transition: all 0.3s;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.counsel-card:hover {
  border-color: #8b5cf6;
  box-shadow: 0 4px 12px rgba(139, 92, 246, 0.15);
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
  background: linear-gradient(135deg, #8b5cf6 0%, #a78bfa 100%);
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

.counsel-date {
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

.status-badge.completed {
  background: #dcfce7;
  color: #16a34a;
}

/* 상담 정보 그리드 */
.counsel-info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
  margin-bottom: 1rem;
}

.info-field {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.field-label {
  font-size: 0.75rem;
  color: #6b7280;
  font-weight: 600;
}

.field-value {
  font-size: 0.875rem;
  color: #1f2937;
  font-weight: 500;
}

/* 섹션 박스 */
.section-box {
  background: #f9fafb;
  border-radius: 0.5rem;
  padding: 1rem;
  margin-bottom: 0.75rem;
}

.section-box.highlight {
  background: #eff6ff;
  border-left: 4px solid #3b82f6;
}

.section-box.success {
  background: #f0fdf4;
  border-left: 4px solid #16a34a;
}

.section-title {
  font-size: 0.8125rem;
  font-weight: 700;
  color: #374151;
  margin: 0 0 0.5rem 0;
}

.section-content {
  font-size: 0.875rem;
  color: #4b5563;
  margin: 0;
  line-height: 1.6;
}

/* 다음 방문 예정 */
.next-visit {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  background: #fef3c7;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
}

.calendar-icon {
  font-size: 1.125rem;
}

.next-visit-label {
  font-size: 0.875rem;
  color: #92400e;
  font-weight: 600;
}

.next-visit-date {
  font-size: 0.875rem;
  color: #92400e;
  font-weight: 700;
}

/* 카드 푸터 */
.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #f3f4f6;
}

.signature-section {
  display: flex;
  gap: 0.75rem;
  flex: 1;
}

.signature-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  border: 2px dashed #d1d5db;
  background: white;
  border-radius: 0.5rem;
  font-size: 0.8125rem;
  font-weight: 600;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.2s;
}

.signature-btn:hover {
  border-color: #8b5cf6;
  background: #faf5ff;
  color: #8b5cf6;
}

.signature-btn.signed {
  border-color: #16a34a;
  border-style: solid;
  background: #dcfce7;
  color: #16a34a;
}

.signature-icon {
  font-size: 1.125rem;
}

.signature-label {
  font-size: 0.8125rem;
}

.action-buttons {
  display: flex;
  gap: 0.5rem;
}

.action-buttons button {
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

/* 전자서명 모달 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 1rem;
}

.modal-content {
  background: white;
  border-radius: 0.75rem;
  max-width: 600px;
  width: 100%;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #e5e7eb;
}

.modal-header h3 {
  font-size: 1.125rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.modal-close-btn {
  border: none;
  background: transparent;
  font-size: 1.5rem;
  color: #9ca3af;
  cursor: pointer;
  padding: 0;
  line-height: 1;
}

.modal-close-btn:hover {
  color: #6b7280;
}

.modal-body {
  padding: 1.5rem;
}

.signature-pad {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.signature-instruction {
  font-size: 0.875rem;
  color: #6b7280;
  margin: 0;
  text-align: center;
}

.signature-canvas {
  width: 100%;
  border: 2px dashed #d1d5db;
  border-radius: 0.5rem;
  background: #f9fafb;
  cursor: crosshair;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  padding: 1.5rem;
  border-top: 1px solid #e5e7eb;
}

.btn-cancel {
  padding: 0.625rem 1.5rem;
  border-radius: 0.5rem;
  font-size: 0.875rem;
  font-weight: 600;
  border: 1px solid #d1d5db;
  background: white;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-cancel:hover {
  background: #f9fafb;
}

.btn-save {
  padding: 0.625rem 1.5rem;
  border-radius: 0.5rem;
  font-size: 0.875rem;
  font-weight: 600;
  border: none;
  background: #8b5cf6;
  color: white;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-save:hover {
  background: #7c3aed;
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(139, 92, 246, 0.3);
}

/* 반응형 */
@media (max-width: 768px) {
  .main-content {
    padding: 1rem;
  }

  .main-tabs {
    flex-direction: column;
    border-bottom: none;
  }

  .main-tab-btn {
    border-bottom: none;
    border-left: 3px solid transparent;
  }

  .main-tab-btn.active {
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

  .counsel-card {
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

  .counsel-info-grid {
    grid-template-columns: 1fr;
    gap: 0.75rem;
  }

  .section-box {
    padding: 0.75rem;
  }

  .section-title {
    font-size: 0.75rem;
  }

  .section-content {
    font-size: 0.8125rem;
  }

  .next-visit {
    flex-wrap: wrap;
    padding: 0.625rem 0.875rem;
  }

  .card-footer {
    flex-direction: column;
    gap: 1rem;
  }

  .signature-section {
    flex-direction: column;
    width: 100%;
  }

  .signature-btn {
    width: 100%;
  }

  .action-buttons {
    width: 100%;
  }

  .action-buttons button {
    flex: 1;
  }

  .modal-content {
    max-width: 100%;
    margin: 1rem;
  }

  .signature-canvas {
    width: 100%;
    height: 150px;
  }

  .modal-footer {
    flex-direction: column-reverse;
  }

  .btn-cancel,
  .btn-save {
    width: 100%;
  }
}
</style>
