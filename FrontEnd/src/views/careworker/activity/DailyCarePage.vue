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
const showDetailModal = ref(false);
const isEditMode = ref(false);
const selectedLog = ref(null);
const editForm = ref(null);

const openDetail = (item) => {
  selectedLog.value = { ...item };
  editForm.value = null;
  isEditMode.value = false;
  showDetailModal.value = true;
};

const openEdit = (item) => {
  const base = item || selectedLog.value;
  if (!base) return;

  selectedLog.value = { ...base };
  editForm.value = {
    ...base,
    services: Array.isArray(base.services) ? base.services.join(', ') : base.services || '',
  };
  isEditMode.value = true;
  showDetailModal.value = true;
};

const closeModal = () => {
  showDetailModal.value = false;
  isEditMode.value = false;
  editForm.value = null;
};

const saveEdit = () => {
  if (!editForm.value) return;

  const parsedServices = typeof editForm.value.services === 'string'
    ? editForm.value.services.split(',').map((s) => s.trim()).filter(Boolean)
    : Array.isArray(editForm.value.services)
      ? editForm.value.services
      : [];

  const updated = {
    ...selectedLog.value,
    ...editForm.value,
    services: parsedServices,
  };

  const targetIndex = careLogHistory.value.findIndex((log) => log.id === updated.id);
  if (targetIndex === -1) {
    alert('수정할 활동일지를 찾지 못했습니다.');
    return;
  }

  careLogHistory.value.splice(targetIndex, 1, updated);
  selectedLog.value = { ...updated };
  isEditMode.value = false;
  editForm.value = null;
  alert('활동일지가 수정되었습니다.');
};

const deleteLog = (id) => {
  const targetId = id ?? selectedLog.value?.id;
  if (!targetId) return;

  const confirmed = confirm('이 활동일지를 삭제하시겠습니까?');
  if (!confirmed) return;

  careLogHistory.value = careLogHistory.value.filter((log) => log.id !== targetId);
  if (selectedLog.value?.id === targetId) {
    closeModal();
    selectedLog.value = null;
  }
  alert('삭제되었습니다.');
};
const statusClass = (status) => {
  const normalized = (status || '').toString().toLowerCase();
  const approvedKeywords = ['approved', 'done', 'complete', 'success'];
  return approvedKeywords.some((keyword) => normalized.includes(keyword.toLowerCase()))
    ? 'approved'
    : 'resubmit';
};
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
                <span class="status-badge" :class="statusClass(item.status)">
                  {{ item.status }}
                </span>
              </div>

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

              <div class="card-services">
                <span v-for="(service, index) in item.services" :key="index" class="service-tag">
                  {{ service }}
                </span>
              </div>

               <div class="card-notes">
                <div class="notes-header">
                  <span class="notes-icon">⚠️</span>
                  <span class="notes-label">오전 간단한 파우 활동 진행. 집중력 양호하심. 점심 식사 후 혈압 약 확인.</span>
                </div>
                <p class="notes-content">{{ item.specialNotes }}</p>
              </div>

              <div class="card-actions">
                <button class="btn-detail" @click="openDetail(item)">📄 상세보기</button>
                <button class="btn-edit" @click="openEdit(item)">✏️ 수정</button>
                <button class="btn-delete" @click="deleteLog(item.id)">🗑️ 삭제</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <div
      v-if="showDetailModal && selectedLog"
      class="log-modal-overlay"
      @click.self="closeModal"
    >
      <div class="log-modal-card">
        <div class="log-modal-header">
          <div>
            <p class="log-modal-subtitle">활동일지</p>
            <h3 class="log-modal-title">
              {{ isEditMode ? '활동일지 수정' : '활동일지 상세보기' }}
            </h3>
          </div>
          <button class="log-close-btn" @click="closeModal">×</button>
        </div>

        <div class="log-modal-body">
          <template v-if="!isEditMode">
            <div class="detail-grid">
              <div class="detail-row">
                <span class="detail-label">수급자</span>
                <span class="detail-value">{{ selectedLog.recipientName }}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">일자</span>
                <span class="detail-value">
                  {{ selectedLog.date }}
                  <span v-if="selectedLog.dayOfWeek">({{ selectedLog.dayOfWeek }})</span>
                </span>
              </div>
              <div class="detail-row">
                <span class="detail-label">시간</span>
                <span class="detail-value">{{ selectedLog.time }}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">주소</span>
                <span class="detail-value">{{ selectedLog.address }}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">제공 서비스</span>
                <div class="service-chips">
                  <span
                    v-for="(service, idx) in selectedLog.services || []"
                    :key="idx"
                    class="service-chip"
                  >
                    {{ service }}
                  </span>
                  <span
                    v-if="!selectedLog.services || !selectedLog.services.length"
                    class="detail-value"
                  >
                    등록된 서비스가 없습니다.
                  </span>
                </div>
              </div>
              <div class="detail-row">
                <span class="detail-label">특이사항</span>
                <p class="detail-value multiline">{{ selectedLog.specialNotes || '기록 없음' }}</p>
              </div>
              <div class="detail-row">
                <span class="detail-label">상태</span>
                <span class="status-pill">{{ selectedLog.status || '미정' }}</span>
              </div>
            </div>
          </template>

          <template v-else-if="editForm">
            <div class="edit-form-grid">
              <label class="edit-field">
                <span class="edit-label">수급자</span>
                <input v-model="editForm.recipientName" type="text" />
              </label>
              <label class="edit-field">
                <span class="edit-label">일자</span>
                <input v-model="editForm.date" type="date" />
              </label>
              <label class="edit-field">
                <span class="edit-label">요일</span>
                <input v-model="editForm.dayOfWeek" type="text" placeholder="월/화/수 등" />
              </label>
              <label class="edit-field">
                <span class="edit-label">시간</span>
                <input v-model="editForm.time" type="text" placeholder="09:00 - 12:00" />
              </label>
              <label class="edit-field full">
                <span class="edit-label">주소</span>
                <input v-model="editForm.address" type="text" />
              </label>
              <label class="edit-field full">
                <span class="edit-label">제공 서비스</span>
                <input
                  v-model="editForm.services"
                  type="text"
                  placeholder="서비스를 쉼표(,)로 구분해 입력하세요"
                />
                <small class="input-hint">예시: 목욕, 청소, 식사보조</small>
              </label>
              <label class="edit-field full">
                <span class="edit-label">특이사항</span>
                <textarea v-model="editForm.specialNotes" rows="4"></textarea>
              </label>
              <label class="edit-field">
                <span class="edit-label">상태</span>
                <input v-model="editForm.status" type="text" />
              </label>
            </div>
          </template>
        </div>

        <div class="log-modal-footer">
          <button class="btn-secondary" @click="closeModal">닫기</button>
          <template v-if="!isEditMode">
            <button class="btn-secondary" @click="openEdit(selectedLog)">수정</button>
            <button class="btn-danger" @click="deleteLog(selectedLog.id)">삭제</button>
          </template>
          <template v-else>
            <button class="btn-primary" @click="saveEdit">변경사항 저장</button>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 페이지 전체 컨테이너: 부모 크기에 맞춤 */
.daily-care-page {
  background-color: transparent; /* 변경: 투명 */
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
}

/* 메인 컨텐츠 영역: 제한 해제 및 여백 제거 */
.main-content {
  flex: 1;
  width: 100%;
  max-width: none; /* 변경: 제한 해제 */
  margin: 0;      /* 변경: 마진 제거 */
  padding: 0;     /* 변경: 패딩 제거 (부모 패딩 사용) */
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
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(360px, 1fr));
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

.card-services {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

/* 서비스 태그 */
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

.log-modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  z-index: 2000;
}

.log-modal-card {
  width: min(960px, 100%);
  background: white;
  border-radius: 0.75rem;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.18);
  overflow: hidden;
  border: 1px solid #e5e7eb;
}

.log-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem 1.5rem;
  border-bottom: 1px solid #e5e7eb;
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
}

.log-modal-title {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 800;
  color: #166534;
}

.log-modal-subtitle {
  margin: 0;
  font-size: 0.75rem;
  color: #16a34a;
  font-weight: 700;
}

.log-close-btn {
  border: none;
  background: white;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  font-size: 1.25rem;
  color: #6b7280;
  cursor: pointer;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12);
}

.log-close-btn:hover {
  background: #fee2e2;
  color: #b91c1c;
}

.log-modal-body {
  padding: 1.5rem;
  max-height: 70vh;
  overflow-y: auto;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

.detail-row {
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 0.75rem;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.detail-label {
  font-size: 0.8125rem;
  color: #6b7280;
  font-weight: 700;
}

.detail-value {
  font-size: 0.95rem;
  color: #111827;
  font-weight: 600;
  line-height: 1.5;
}

.detail-value.multiline {
  white-space: pre-wrap;
}

.service-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.service-chip {
  background: #dcfce7;
  border: 1px solid #bbf7d0;
  color: #15803d;
  padding: 0.35rem 0.65rem;
  border-radius: 999px;
  font-size: 0.8125rem;
  font-weight: 700;
}

.status-pill {
  display: inline-flex;
  align-items: center;
  padding: 0.35rem 0.75rem;
  background: #eff6ff;
  color: #2563eb;
  border-radius: 999px;
  font-weight: 700;
  width: fit-content;
}

.edit-form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

.edit-field {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 0.75rem;
  padding: 0.9rem;
}

.edit-field.full {
  grid-column: 1 / -1;
}

.edit-label {
  font-size: 0.8125rem;
  font-weight: 700;
  color: #374151;
}

.edit-field input,
.edit-field textarea {
  border: 1px solid #d1d5db;
  border-radius: 0.5rem;
  padding: 0.65rem 0.75rem;
  font-size: 0.9375rem;
}

.edit-field textarea {
  resize: vertical;
}

.input-hint {
  color: #6b7280;
  font-size: 0.75rem;
  margin-top: 0.25rem;
}

.log-modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  padding: 1rem 1.25rem 1.25rem;
  border-top: 1px solid #e5e7eb;
  background: #f9fafb;
}

.btn-primary,
.btn-secondary,
.btn-danger {
  padding: 0.75rem 1.25rem;
  border-radius: 0.65rem;
  font-weight: 700;
  font-size: 0.9375rem;
  border: none;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-primary {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  color: white;
}

.btn-primary:hover {
  background: linear-gradient(135deg, #16a34a 0%, #15803d 100%);
}

.btn-secondary {
  background: white;
  color: #374151;
  border: 1px solid #d1d5db;
}

.btn-secondary:hover {
  background: #f3f4f6;
}

.btn-danger {
  background: #ef4444;
  color: white;
}

.btn-danger:hover {
  background: #dc2626;
}

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

  .detail-grid,
  .edit-form-grid {
    grid-template-columns: 1fr;
  }
}
</style>