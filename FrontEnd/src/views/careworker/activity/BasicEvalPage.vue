<script setup>
import { ref, computed } from "vue";
import FallRiskAssessmentForm from "@/components/careworker/activity/FallRiskAssessmentForm.vue";
import BedsoreAssessmentForm from "@/components/careworker/activity/BedsoreAssessmentForm.vue";
import CognitiveAssessmentForm from "@/components/careworker/activity/CognitiveAssessmentForm.vue";
import NeedsAssessmentForm from "@/components/careworker/activity/NeedsAssessmentForm.vue";
import { evalHistoryMock } from "@/mock/careworker/activityHistory";

// 메인 탭 상태 (작성 / 내역)
const mainTab = ref("write");
const mainTabs = [
  { key: "write", label: "작성하기", icon: "W" },
  { key: "history", label: "작성 내역", icon: "H" },
];

// 서브 탭 상태 - 기초평가 항목별
const activeTab = ref("fallRisk");
const subTabs = [
  { key: "fallRisk", label: "낙상위험도", subtitle: "(분기 1회)", icon: "🏃" },
  { key: "bedsore", label: "욕창위험도", subtitle: "(분기 1회)", icon: "🛏️" },
  { key: "cognitive", label: "인지기능", subtitle: "(분기 1회)", icon: "🧠" },
  { key: "needs", label: "욕구사정", subtitle: "(분기 1회)", icon: "📋" },
];

// 임시 작성 내역(Mock)
const evalHistory = ref([...evalHistoryMock]);

// 연도별 아코디언 상태
const openYears = ref([]);

// 연도별 아코디언 토글
const toggleYear = (year) => {
  const index = openYears.value.indexOf(year);
  if (index > -1) {
    openYears.value.splice(index, 1);
  } else {
    openYears.value.push(year);
  }
};

// 작성 내역 상세/수정 모달 상태
const showDetailModal = ref(false);
const isEditMode = ref(false);
const selectedItem = ref(null);
const editForm = ref(null);

// 활성 서브탭 기준 필터링
const filteredHistory = computed(() => evalHistory.value.filter((item) => item.type === activeTab.value));

// 연도별 그룹핑
const groupedByYear = computed(() => {
  const filtered = filteredHistory.value;
  const grouped = {};

  filtered.forEach((item) => {
    if (!grouped[item.year]) {
      grouped[item.year] = [];
    }
    grouped[item.year].push(item);
  });

  return Object.keys(grouped)
    .sort((a, b) => b.localeCompare(a))
    .map((year) => ({
      year,
      items: grouped[year].sort((a, b) => b.date.localeCompare(a.date)),
    }));
});

const statusClass = (status) => {
  const normalized = (status || "").toString().toLowerCase();
  const doneKeywords = ["완료", "승인", "제출", "완성", "approved", "done", "complete"];
  return doneKeywords.some((k) => normalized.includes(k.toLowerCase())) ? "completed" : "draft";
};

const openDetail = (item) => {
  selectedItem.value = { ...item };
  editForm.value = null;
  isEditMode.value = false;
  showDetailModal.value = true;
};

const openEdit = (item) => {
  const base = item || selectedItem.value;
  if (!base) return;
  selectedItem.value = { ...base };
  editForm.value = { ...base };
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

  const targetIndex = evalHistory.value.findIndex((h) => h.id === editForm.value.id);
  if (targetIndex === -1) {
    alert("수정할 평가 내역을 찾지 못했습니다.");
    return;
  }

  const updated = { ...evalHistory.value[targetIndex], ...editForm.value };
  evalHistory.value.splice(targetIndex, 1, updated);
  selectedItem.value = { ...updated };
  isEditMode.value = false;
  editForm.value = null;
  alert("평가 내역이 수정되었습니다.");
};

const deleteHistory = (id) => {
  const targetId = id ?? selectedItem.value?.id;
  if (!targetId) return;

  const confirmed = confirm("이 평가 내역을 삭제하시겠습니까?");
  if (!confirmed) return;
  evalHistory.value = evalHistory.value.filter((item) => item.id !== targetId);

  if (selectedItem.value?.id === targetId) {
    closeModal();
    selectedItem.value = null;
  }
  alert("삭제되었습니다.");
};

const handleFallRiskSubmit = (data) => {
  console.log("낙상위험도 평가 제출:", data);
  alert("낙상위험도 평가가 접수되었습니다.");
};

const handleFallRiskSaveDraft = (data) => {
  console.log("낙상위험도 임시저장", data);
  alert("임시저장되었습니다.");
};

const handleBedsoreSubmit = (data) => {
  console.log("욕창위험도 평가 제출:", data);
  alert("욕창위험도 평가가 접수되었습니다.");
};

const handleBedsoreSaveDraft = (data) => {
  console.log("욕창위험도 임시저장", data);
  alert("임시저장되었습니다.");
};

const handleCognitiveSubmit = (data) => {
  console.log("인지기능 평가 제출:", data);
  alert("인지기능 평가가 접수되었습니다.");
};

const handleCognitiveSaveDraft = (data) => {
  console.log("인지기능 임시저장", data);
  alert("임시저장되었습니다.");
};

const handleNeedsSubmit = (data) => {
  console.log("욕구사정 평가 제출:", data);
  alert("욕구사정 평가가 접수되었습니다.");
};

const handleNeedsSaveDraft = (data) => {
  console.log("욕구사정 임시저장", data);
  alert("임시저장되었습니다.");
};
</script>

<template>
  <div class="basic-eval-page">
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
          <div class="tab-text">
            <span class="tab-label">{{ tab.label }}</span>
            <span class="tab-subtitle">{{ tab.subtitle }}</span>
          </div>
        </button>
      </div>

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

      <div v-if="mainTab === 'write'" class="write-section">
        <div class="tab-content">
          <div v-if="activeTab === 'fallRisk'" class="assessment-section">
            <FallRiskAssessmentForm
              @submit="handleFallRiskSubmit"
              @save-draft="handleFallRiskSaveDraft"
            />
          </div>

          <div v-else-if="activeTab === 'bedsore'" class="assessment-section">
            <BedsoreAssessmentForm
              @submit="handleBedsoreSubmit"
              @save-draft="handleBedsoreSaveDraft"
            />
          </div>

          <div v-else-if="activeTab === 'cognitive'" class="assessment-section">
            <CognitiveAssessmentForm
              @submit="handleCognitiveSubmit"
              @save-draft="handleCognitiveSaveDraft"
            />
          </div>

          <div v-else-if="activeTab === 'needs'" class="assessment-section">
            <NeedsAssessmentForm
              @submit="handleNeedsSubmit"
              @save-draft="handleNeedsSaveDraft"
            />
          </div>
        </div>
      </div>

      <div v-else class="history-section">
        <div class="history-header">
          <h2>작성 내역</h2>
          <div class="search-box">
            <input type="text" placeholder="수급자명 검색" />
            <button class="search-btn">검색</button>
          </div>
        </div>

        <div v-if="groupedByYear.length === 0" class="empty-state">
          <div class="empty-icon">i</div>
          <p class="empty-text">작성된 {{ subTabs.find(t => t.key === activeTab)?.label }} 내역이 없습니다.</p>
        </div>

        <div v-else class="year-accordion-list">
          <div v-for="yearGroup in groupedByYear" :key="yearGroup.year" class="year-accordion">
            <div
              class="year-header"
              :class="{ open: openYears.includes(yearGroup.year) }"
              @click="toggleYear(yearGroup.year)"
            >
              <div class="year-info">
                <span class="year-icon">Y</span>
                <h3 class="year-title">{{ yearGroup.year }}</h3>
                <span class="year-count">{{ yearGroup.items.length }}건</span>
              </div>
              <span class="toggle-icon">
                {{ openYears.includes(yearGroup.year) ? "▼" : "▶" }}
              </span>
            </div>

            <div v-show="openYears.includes(yearGroup.year)" class="year-content">
              <div class="history-list">
                <div v-for="item in yearGroup.items" :key="item.id" class="history-card">
                  <div class="card-info">
                    <div class="info-row">
                      <span class="label">작성일</span>
                      <span class="value">{{ item.date }}</span>
                    </div>
                    <div class="info-row">
                      <span class="label">수급자</span>
                      <span class="value">{{ item.recipientName }}</span>
                    </div>
                    <div class="info-row">
                      <span class="label">상태:</span>
                      <span class="status-badge" :class="statusClass(item.status)">
                        {{ item.status }}
                      </span>
                    </div>
                  </div>
                  <div class="card-actions">
                    <button class="btn-view" @click="openDetail(item)">상세</button>
                    <button class="btn-edit" @click="openEdit(item)">수정</button>
                    <button class="btn-delete" @click="deleteHistory(item.id)">삭제</button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div
        v-if="showDetailModal && selectedItem"
        class="eval-modal-overlay"
        @click.self="closeModal"
      >
        <div class="eval-modal-card">
          <div class="eval-modal-header">
            <div>
              <p class="eval-modal-subtitle">기초평가</p>
              <h3 class="eval-modal-title">
                {{ isEditMode ? '작성 내역 수정' : '작성 내역 상세' }}
              </h3>
            </div>
            <button class="eval-close-btn" @click="closeModal">×</button>
          </div>

          <div class="eval-modal-body">
            <template v-if="!isEditMode">
              <div class="detail-grid">
                <div class="detail-row">
                  <span class="detail-label">평가 유형</span>
                  <span class="detail-value">{{ selectedItem.typeLabel || selectedItem.type || '-' }}</span>
                </div>
                <div class="detail-row">
                  <span class="detail-label">작성일</span>
                  <span class="detail-value">{{ selectedItem.date }}</span>
                </div>
                <div class="detail-row">
                  <span class="detail-label">수급자</span>
                  <span class="detail-value">{{ selectedItem.recipientName }}</span>
                </div>
                <div class="detail-row">
                  <span class="detail-label">상태</span>
                  <span class="status-badge" :class="statusClass(selectedItem.status)">
                    {{ selectedItem.status || '미정' }}
                  </span>
                </div>
              </div>
            </template>

            <template v-else-if="editForm">
              <div class="edit-form-grid">
                <label class="edit-field">
                  <span class="edit-label">평가 유형</span>
                  <input v-model="editForm.typeLabel" type="text" />
                </label>
                <label class="edit-field">
                  <span class="edit-label">작성일</span>
                  <input v-model="editForm.date" type="date" />
                </label>
                <label class="edit-field">
                  <span class="edit-label">수급자</span>
                  <input v-model="editForm.recipientName" type="text" />
                </label>
                <label class="edit-field">
                  <span class="edit-label">상태</span>
                  <input v-model="editForm.status" type="text" placeholder="완료 / 초안 등" />
                </label>
              </div>
            </template>
          </div>

          <div class="eval-modal-footer">
            <button class="btn-secondary" @click="closeModal">닫기</button>
            <template v-if="!isEditMode">
              <button class="btn-secondary" @click="openEdit(selectedItem)">수정</button>
              <button class="btn-danger" @click="deleteHistory(selectedItem.id)">삭제</button>
            </template>
            <template v-else>
              <button class="btn-primary" @click="saveEdit">변경사항 저장</button>
            </template>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<style scoped>
/* 페이지 전체 컨테이너: 배경색과 최소 높이, 패딩을 제거하여 부모 요소에 맞춤 */
.basic-eval-page {
  width: 100%;
  height: 100%;
  background-color: transparent; /* 변경: 투명 배경 */
  display: flex;
  flex-direction: column;
}

/* 메인 컨텐츠 영역: Max-width 제거 및 여백 최소화 */
.main-content {
  flex: 1;
  width: 100%;
  max-width: none; /* 변경: 제한 해제 */
  margin: 0;      /* 변경: 마진 제거 */
  padding: 0;     /* 변경: 부모 패딩 활용을 위해 제거 */
}

/* -------------------------------------------
   아래는 기존 디자인 유지
   ------------------------------------------- */

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

.sub-tabs {
  display: flex;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
  border-bottom: 2px solid #e5e7eb;
  flex-wrap: wrap;
}

.sub-tab-btn {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 1.5rem;
  border: none;
  background: white;
  color: #6b7280;
  font-weight: 600;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s;
  border-bottom: 3px solid transparent;
  border-radius: 0.5rem 0.5rem 0 0;
  /* 부모가 흰색이면 그림자가 어색할 수 있으나 디자인 유지 요청으로 남김 */
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  border: 1px solid #f1f5f9; /* 구분감을 위해 살짝 추가 */
}

.sub-tab-btn:hover {
  color: #16a34a;
  background: #f0fdf4;
  transform: translateY(-2px);
}

.sub-tab-btn.active {
  color: #16a34a;
  border-bottom-color: #16a34a;
  background: #dcfce7;
  box-shadow: 0 2px 8px rgba(22, 163, 74, 0.15);
  border-color: #16a34a;
}

.sub-tab-btn .tab-icon {
  font-size: 1.5rem;
}

.tab-text {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 0.125rem;
}

.tab-label {
  font-size: 0.9375rem;
  font-weight: 700;
}

.tab-subtitle {
  font-size: 0.75rem;
  font-weight: 500;
  opacity: 0.7;
}

.tab-content {
  min-height: 400px;
}

.assessment-section {
  animation: fadeIn 0.3s ease-in-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.history-section {
  background: white; /* 탭 박스 안이라면 중첩된 카드 느낌이 됨 */
  border-radius: 0.75rem;
  padding: 1.5rem;
  /* 부모 배경과 구분을 위해 테두리 추가 */
  border: 1px solid #e5e7eb; 
  box-shadow: none; /* 이중 그림자 방지 */
}

.history-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid #e5e7eb;
}

.history-header h2 {
  font-size: 1.25rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.search-box {
  display: flex;
  gap: 0.5rem;
}

.search-box input {
  padding: 0.5rem 1rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  width: 200px;
}

.search-btn {
  padding: 0.5rem 1rem;
  background: #16a34a;
  color: white;
  border: none;
  border-radius: 0.375rem;
  cursor: pointer;
  font-size: 1rem;
}

.search-btn:hover {
  background: #15803d;
}

.year-accordion-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.year-accordion {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 0.75rem;
  overflow: hidden;
  transition: all 0.3s;
}

.year-accordion:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.year-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  background: #f9fafb;
  cursor: pointer;
  transition: all 0.2s;
  border-bottom: 1px solid transparent;
}

.year-header:hover { background: #f0fdf4; }

.year-header.open {
  background: #f0fdf4;
  border-bottom-color: #e5e7eb;
}

.year-info { display: flex; align-items: center; gap: 0.75rem; }
.year-icon { font-size: 1.25rem; }
.year-title { font-size: 1.125rem; font-weight: 700; color: #1f2937; margin: 0; }
.year-count { padding: 0.25rem 0.75rem; background: #16a34a; color: white; border-radius: 9999px; font-size: 0.75rem; font-weight: 700; }
.toggle-icon { font-size: 0.875rem; color: #6b7280; transition: transform 0.2s; }

.year-content {
  padding: 1rem;
  animation: slideDown 0.3s ease-out;
}

@keyframes slideDown {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

.history-list { display: flex; flex-direction: column; gap: 0.75rem; }

.history-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.25rem;
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
  background: white;
  transition: all 0.2s;
}

.history-card:hover {
  border-color: #16a34a;
  box-shadow: 0 2px 8px rgba(22, 163, 74, 0.1);
  transform: translateX(4px);
}

.card-info { display: flex; gap: 2rem; }
.info-row { display: flex; align-items: center; gap: 0.5rem; }
.label { font-size: 0.875rem; color: #6b7280; font-weight: 600; }
.value { font-size: 0.875rem; color: #1f2937; font-weight: 500; }

.status-badge { padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 700; }
.status-badge.completed { background: #dcfce7; color: #16a34a; }
.status-badge.draft { background: #fef3c7; color: #d97706; }

.card-actions { display: flex; gap: 0.5rem; }
.card-actions button { padding: 0.5rem 1rem; border-radius: 0.375rem; font-size: 0.875rem; font-weight: 600; cursor: pointer; transition: all 0.2s; border: none; }
.btn-view { background: #3b82f6; color: white; }
.btn-view:hover { background: #2563eb; }
.btn-edit { background: white; color: #6b7280; border: 1px solid #d1d5db; }
.btn-edit:hover { background: #f9fafb; }
.btn-delete { background: #ef4444; color: white; }
.btn-delete:hover { background: #dc2626; }

.eval-modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  z-index: 2000;
}

.eval-modal-card {
  width: min(720px, 100%);
  background: white;
  border-radius: 0.75rem;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.16);
  overflow: hidden;
  border: 1px solid #e5e7eb;
}

.eval-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem 1.5rem;
  border-bottom: 1px solid #e5e7eb;
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
}

.eval-modal-title { margin: 0; font-size: 1.2rem; font-weight: 800; color: #166534; }
.eval-modal-subtitle { margin: 0; font-size: 0.8rem; color: #16a34a; font-weight: 700; }

.eval-close-btn {
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

.eval-close-btn:hover { background: #fee2e2; color: #b91c1c; }

.eval-modal-body {
  padding: 1.5rem;
  max-height: 70vh;
  overflow-y: auto;
}

.detail-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem; }
.detail-row { background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 0.75rem; padding: 1rem; display: flex; flex-direction: column; gap: 0.35rem; }
.detail-label { font-size: 0.8125rem; color: #6b7280; font-weight: 700; }
.detail-value { font-size: 0.95rem; color: #111827; font-weight: 600; }

.edit-form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem; }
.edit-field { display: flex; flex-direction: column; gap: 0.4rem; background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 0.75rem; padding: 0.9rem; }
.edit-label { font-size: 0.8125rem; font-weight: 700; color: #374151; }
.edit-field input { border: 1px solid #d1d5db; border-radius: 0.5rem; padding: 0.65rem 0.75rem; font-size: 0.9375rem; }

.eval-modal-footer { display: flex; justify-content: flex-end; gap: 0.5rem; padding: 1rem 1.25rem 1.25rem; border-top: 1px solid #e5e7eb; background: #f9fafb; }

.btn-primary, .btn-secondary, .btn-danger { padding: 0.7rem 1.2rem; border-radius: 0.6rem; font-weight: 700; font-size: 0.9375rem; border: none; cursor: pointer; transition: all 0.2s; }
.btn-primary { background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%); color: white; }
.btn-primary:hover { background: linear-gradient(135deg, #16a34a 0%, #15803d 100%); }
.btn-secondary { background: white; color: #374151; border: 1px solid #d1d5db; }
.btn-secondary:hover { background: #f3f4f6; }
.btn-danger { background: #ef4444; color: white; }
.btn-danger:hover { background: #dc2626; }

.empty-state { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 4rem 2rem; color: #9ca3af; }
.empty-icon { font-size: 3rem; margin-bottom: 1rem; opacity: 0.5; }
.empty-text { font-size: 1rem; font-weight: 500; margin: 0; }

@media (max-width: 1024px) {
  .main-content { max-width: 100%; }
}

@media (max-width: 768px) {
  .main-content { padding: 0; }
  .main-tabs { flex-direction: column; border-bottom: none; }
  .main-tab-btn { border-bottom: none; border-left: 3px solid transparent; }
  .main-tab-btn.active { border-left-color: #16a34a; border-bottom-color: transparent; }
  .sub-tabs { gap: 0.5rem; }
  .sub-tab-btn { padding: 0.75rem 1rem; flex: 1; min-width: calc(50% - 0.25rem); }
  .sub-tab-btn .tab-icon { font-size: 1.25rem; }
  .tab-label { font-size: 0.8125rem; }
  .tab-subtitle { font-size: 0.6875rem; }
  .history-header { flex-direction: column; align-items: flex-start; gap: 1rem; }
  .search-box input { width: 100%; }
  .history-card { flex-direction: column; align-items: flex-start; gap: 1rem; }
  .card-info { flex-direction: column; gap: 0.5rem; width: 100%; }
  .card-actions { width: 100%; }
  .card-actions button { flex: 1; }
  .year-header { padding: 0.875rem 1rem; }
  .year-title { font-size: 1rem; }
  .year-count { font-size: 0.6875rem; padding: 0.2rem 0.6rem; }
  .year-content { padding: 0.75rem; }
  .detail-grid, .edit-form-grid { grid-template-columns: 1fr; }
}
</style>