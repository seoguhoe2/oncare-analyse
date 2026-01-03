<script setup>
import { ref, computed, watch, onMounted } from "vue";
import { useUserStore } from '@/stores/user';

// 1. 각 평가 폼 컴포넌트 임포트
import FallRiskAssessmentForm from "@/components/careworker/activity/FallRiskAssessmentForm.vue";
import BedsoreAssessmentForm from "@/components/careworker/activity/BedsoreAssessmentForm.vue";
import CognitiveAssessmentForm from "@/components/careworker/activity/CognitiveAssessmentForm.vue";
import NeedsAssessmentForm from "@/components/careworker/activity/NeedsAssessmentForm.vue";

// 2. API 임포트
import {
  getFallEvaluationList,
  getFallEvaluationDetail,
  getBedsoreEvaluationList,
  getBedsoreEvaluationDetail,
  getCognitiveEvaluationList,
  getCognitiveEvaluationDetail,
  getNeedsEvaluationList,
  getNeedsEvaluationDetail,
  createFallEvaluation,
  updateFallEvaluation,
  createBedsoreEvaluation,
  updateBedsoreEvaluation,
  createCognitiveEvaluation,
  updateCognitiveEvaluation,
  createNeedsEvaluation,
  updateNeedsEvaluation,
  deleteFallEvaluation,
  deleteBedsoreEvaluation,
  deleteCognitiveEvaluation,
  deleteNeedsEvaluation,
} from '@/api/careworker';

const userStore = useUserStore();

// 메인 탭 (평가 종류)
const activeCategory = ref("fallRisk");
// 서브 탭 (작성하기 / 내역)
const activeView = ref("write");

const evalHistory = ref([]);
const loading = ref(false);
const selectedYear = ref(new Date().getFullYear());
const yearStats = ref({});

// 평가 카테고리 정의
const categories = [
  { key: "fallRisk", label: "낙상위험도", icon: "⚠️", component: FallRiskAssessmentForm },
  { key: "bedsore", label: "욕창위험도", icon: "🩹", component: BedsoreAssessmentForm },
  { key: "cognitive", label: "인지기능", icon: "🧠", component: CognitiveAssessmentForm },
  { key: "needs", label: "욕구사정", icon: "📋", component: NeedsAssessmentForm || null },
];

// 보기 모드 탭 정의
const viewTabs = [
  { key: "write", label: "작성하기", icon: "✏️" },
  { key: "history", label: "작성 내역", icon: "📑" },
];

const apiMap = {
  fallRisk: getFallEvaluationList,
  bedsore: getBedsoreEvaluationList,
  cognitive: getCognitiveEvaluationList,
  needs: getNeedsEvaluationList,
};

const detailApiMap = {
  fallRisk: getFallEvaluationDetail,
  bedsore: getBedsoreEvaluationDetail,
  cognitive: getCognitiveEvaluationDetail,
  needs: getNeedsEvaluationDetail,
};

const createApiMap = {
  fallRisk: createFallEvaluation,
  bedsore: createBedsoreEvaluation,
  cognitive: createCognitiveEvaluation,
  needs: createNeedsEvaluation,
};

const updateApiMap = {
  fallRisk: updateFallEvaluation,
  bedsore: updateBedsoreEvaluation,
  cognitive: updateCognitiveEvaluation,
  needs: updateNeedsEvaluation,
};

// 현재 탭 컴포넌트
const currentTabComponent = computed(() => {
  const tab = categories.find(t => t.key === activeCategory.value);
  return tab ? tab.component : null;
});

// 평가 등급 판정
const getGradeLabel = (resultGrade) => {
  if (!resultGrade) return '-';
  if (resultGrade.includes('낮음') || resultGrade.includes('정상') || resultGrade.includes('없음')) return '낮음';
  if (resultGrade.includes('중간') || resultGrade.includes('보통')) return '중간';
  if (resultGrade.includes('높음')) return '높음';
  return '-';
};

// 등급별 CSS 클래스 매핑
const getGradeClass = (gradeLabel) => {
  switch (gradeLabel) {
    case '낮음': return 'grade-low';
    case '중간': return 'grade-mid';
    case '높음': return 'grade-high';
    default: return '';
  }
};

// 연도별 통계 계산
const calculateYearStats = (data) => {
  const stats = {};
  data.forEach(item => {
    const itemDate = new Date(item.evalDate || item.assessmentDate || item.evaluationDate);
    const year = itemDate.getFullYear();

    if (!stats[year]) {
      stats[year] = { count: 0, items: [] };
    }
    stats[year].count++;
    stats[year].items.push(item);
  });
  return stats;
};

const loadEvaluationHistory = async () => {
  loading.value = true;
  evalHistory.value = [];
  yearStats.value = {};

  try {
    const currentApi = apiMap[activeCategory.value];
    if (!currentApi) return;

    const response = await currentApi();
    const data = response?.data ?? response;

    const formattedData = (data || []).map(item => {
      let totalScore = item.totalScore ?? 0;
      let resultGrade = item.resultGrade || '-';

      // evalData 파싱 로직
      let parsedIsDraft = false;
      if (item.evalData) {
        try {
          const parsedData = typeof item.evalData === 'string' ? JSON.parse(item.evalData) : item.evalData;
          
          if (parsedData.isDraft) parsedIsDraft = true; // JSON 내부 플래그 확인

          if (parsedData.result) {
            totalScore = parsedData.result.total_score ?? totalScore;
            resultGrade = parsedData.result.grade || resultGrade;
          }
        } catch (error) { /* Ignore */ }
      }

      // isDraft 필드값 확인 + 파싱된 값 확인
      const isDraft = item.isDraft === true || item.isDraft === 'true' || item.isDraft === 1 ||
                      item.is_draft === true || item.is_draft === 'true' || item.is_draft === 1 ||
                      parsedIsDraft;

      return {
        id: item.evalId || item.id,
        evalDate: item.evalDate || item.assessmentDate || item.evaluationDate,
        beneficiaryId: item.beneficiaryId,
        beneficiaryName: item.beneficiaryName || item.recipientName || '-',
        careLevel: item.careLevel || '-',
        resultGrade: resultGrade,
        gradeLabel: getGradeLabel(resultGrade),
        totalScore: totalScore,
        status: isDraft ? '임시저장' : '제출됨',
        evaluatorName: item.employeeName || item.evaluatorName || userStore.name || '-',
        comment: item.specialNote || item.comment || '',
        scoreDetails: item.scoreDetails || ''
      };
    });

    // 날짜 최신순 정렬
    formattedData.sort((a, b) => new Date(b.evalDate) - new Date(a.evalDate));

    evalHistory.value = formattedData;
    yearStats.value = calculateYearStats(formattedData);
    
    const years = Object.keys(yearStats.value).sort((a, b) => b - a);
    if (years.length > 0 && !yearStats.value[selectedYear.value]) {
      selectedYear.value = parseInt(years[0]);
    }

  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const searchQuery = ref('');

const filteredByYear = computed(() => {
  if (!selectedYear.value || !yearStats.value[selectedYear.value]) return [];
  let items = yearStats.value[selectedYear.value].items || [];

  if (searchQuery.value) {
    const query = searchQuery.value.trim().toLowerCase();
    items = items.filter(item => item.beneficiaryName.toLowerCase().includes(query));
  }
  
  return items;
});

const availableYears = computed(() => {
  return Object.keys(yearStats.value).sort((a, b) => b - a);
});


// --- Actions ---
const createPayload = (data, isDraft = false) => {
  const commonEvalData = {
    isDraft: isDraft,
    items: {}, // 아래에서 할당
    result: {
      total_score: data.totalScore,
      grade: data.grade
    },
    comment: data.comment
  };

  // 각 카테고리별 데이터 매핑
  if (activeCategory.value === 'fallRisk' && data.fallRisk) {
    commonEvalData.items = data.fallRisk;
  } else if (activeCategory.value === 'bedsore' && data.bedsoreRisk) {
    commonEvalData.items = data.bedsoreRisk;
  } else if (activeCategory.value === 'cognitive') {
    commonEvalData.items = data.responses || data.cognitiveItems || {};
    commonEvalData.educationLevel = data.educationLevel; // 학력 정보 추가 저장
  } else if (activeCategory.value === 'needs') {
     commonEvalData.items = data.responses || {};
     commonEvalData.textResponses = data.textResponses || {};
  }

  const payload = {
    beneficiaryId: data.beneficiaryId,
    assessmentDate: data.assessmentDate,
    evaluationDate: data.assessmentDate,
    evalDate: data.assessmentDate,
    careWorkerName: data.careWorkerName,
    careWorkerId: userStore.userId, 
    employeeId: userStore.userId,    
    totalScore: data.totalScore,
    resultGrade: data.grade, 
    comment: data.comment,
    isDraft: isDraft, 
    evalData: JSON.stringify(commonEvalData)
  };
  
  return payload;
};

const handleSubmit = async (data) => {
  try {
    const createApi = createApiMap[activeCategory.value];
    if (!createApi) {
      alert('저장 기능이 준비되지 않았습니다.');
      return;
    }

    const payload = createPayload(data, false); 
    await createApi(payload);
    alert('평가가 저장되었습니다.'); 
    activeView.value = 'history';
    await loadEvaluationHistory();
  } catch (error) {
    console.error('평가 저장 실패:', error);
    alert(`평가 저장 실패: ${error.message}`);
  }
};

const handleSaveDraft = async (data) => {
  try {
    const createApi = createApiMap[activeCategory.value];
    if (!createApi) {
      alert('저장 기능이 준비되지 않았습니다.');
      return;
    }

    if (!data.beneficiaryId) {
      alert('수급자를 선택해주세요.');
      return;
    }

    const payload = createPayload(data, true); 
    await createApi(payload);
    alert('임시저장 되었습니다.');
    activeView.value = 'history';
    await loadEvaluationHistory();
  } catch (error) {
    console.error('임시저장 실패:', error);
    alert(`임시저장 실패: ${error.message}`);
  }
};

const showDetailModal = ref(false);
const detailItem = ref(null);
const showEditModal = ref(false);
const editItem = ref(null);

// 상세/수정 데이터 파싱 유틸 함수
const parseDetailData = (item) => {
  let parsed = { ...item };
  
  // 수급자명 매핑 (List는 beneficiaryName, Form은 recipientName 사용)
  parsed.recipientName = item.beneficiaryName || item.recipientName;

  if (item.evalData) {
    try {
      const evalJson = typeof item.evalData === 'string' ? JSON.parse(item.evalData) : item.evalData;
      
      // 카테고리별로 items를 올바른 키로 매핑
      if (activeCategory.value === 'fallRisk') {
        parsed.fallRisk = evalJson.items || {};
      } else if (activeCategory.value === 'bedsore') {
        parsed.bedsoreRisk = evalJson.items || {};
      } else if (activeCategory.value === 'cognitive') {
        parsed.responses = evalJson.items || {};
        parsed.educationLevel = evalJson.educationLevel || 'MIDDLE_HIGH';
      } else if (activeCategory.value === 'needs') {
        parsed.responses = evalJson.items || {};
        parsed.textResponses = evalJson.textResponses || {};
      }
      
      // 공통 필드 복원 (코멘트 등)
      if (evalJson.comment) parsed.comment = evalJson.comment;
      
    } catch (e) {
      console.error('evalData 파싱 실패:', e);
    }
  }
  return parsed;
};

const openDetailModal = async (item) => {
  try {
    const detailApi = detailApiMap[activeCategory.value];
    let data = { ...item };

    if (detailApi) {
      if (!item.id) throw new Error('evalId is required');
      const response = await detailApi(item.id);
      data = response?.data ?? response;
    }

    // ID 보존 (API 응답에 ID가 없는 경우 대비)
    data.id = data.id || data.evalId || item.id;

    // 데이터 파싱 및 매핑
    detailItem.value = parseDetailData(data);
    showDetailModal.value = true;
  } catch (error) {
    console.error('평가 상세 조회 실패:', error);
    alert('평가 정보를 불러오는데 실패했습니다.');
  }
};

const closeDetailModal = () => {
  showDetailModal.value = false;
  detailItem.value = null;
};

const openEditModal = async (item) => {
  try {
    const detailApi = detailApiMap[activeCategory.value];
    let data = { ...item };

    if (detailApi) {
      const targetId = item.id || (item.value && item.value.id); // detailItem.value에서 호출될 때 대비
      if (!targetId) throw new Error('evalId is required');
      
      const response = await detailApi(targetId);
      data = response?.data ?? response;
    }

    // ID 보존
    data.id = data.id || data.evalId || item.id;

    // 데이터 파싱 및 매핑
    editItem.value = parseDetailData(data);
    showEditModal.value = true;
  } catch (error) {
    console.error('평가 상세 조회 실패:', error);
    alert('평가 정보를 불러오는데 실패했습니다.');
  }
};

const closeEditModal = () => {
  showEditModal.value = false;
  editItem.value = null;
};

const handleEditSubmit = async (formData) => {
  try {
    const updateApi = updateApiMap[activeCategory.value];
    if (!updateApi) {
      alert('수정 기능이 준비되지 않았습니다.');
      return;
    }
    
    // id가 없는 경우 대비
    const evalId = formData.id || (editItem.value && (editItem.value.id || editItem.value.evalId));
    
    if (!evalId) {
      console.error('ID 없음. formData:', formData, 'editItem:', editItem.value);
      throw new Error('평가 ID를 찾을 수 없습니다.');
    }

    const payload = createPayload(formData, false); // isDraft = false (제출)
    await updateApi(evalId, payload);
    alert('수정되었습니다.');
    closeEditModal();
    closeDetailModal(); // 상세 모달도 닫기
    await loadEvaluationHistory();
  } catch (error) {
    console.error('평가 수정 실패:', error);
    alert('평가 수정 실패');
  }
};

const handleEditDraft = async (formData) => {
  try {
    const updateApi = updateApiMap[activeCategory.value];
    if (!updateApi) {
      alert('수정 기능이 준비되지 않았습니다.');
      return;
    }
    
    const evalId = formData.id || (editItem.value && (editItem.value.id || editItem.value.evalId));
    
    if (!evalId) {
      throw new Error('평가 ID를 찾을 수 없습니다.');
    }

    const payload = createPayload(formData, true); // isDraft = true (임시저장)
    await updateApi(evalId, payload);
    alert('임시저장 되었습니다.');
    closeEditModal();
    closeDetailModal(); // 상세 모달도 닫기
    await loadEvaluationHistory();
  } catch (error) {
    console.error('평가 임시저장 수정 실패:', error);
    alert('평가 임시저장 수정 실패');
  }
};

const handleDelete = async (item) => {
  if (!confirm(`${item.beneficiaryName}님의 평가를 삭제하시겠습니까?`)) return;
  try {
     const deleteApis = {
      fallRisk: deleteFallEvaluation,
      bedsore: deleteBedsoreEvaluation,
      cognitive: deleteCognitiveEvaluation,
      needs: deleteNeedsEvaluation
    };
    const deleteApi = deleteApis[activeCategory.value];
    if (deleteApi) await deleteApi(item.id, userStore.userId);
    
    alert('삭제되었습니다.');
    await loadEvaluationHistory();
    closeDetailModal(); 
  } catch (error) {
    alert('삭제 실패');
  }
};

watch([activeCategory, activeView], ([newCategory, newView]) => {
  if (newView === 'history') loadEvaluationHistory();
});

onMounted(() => {
  if (activeView.value === 'history') loadEvaluationHistory();
});
</script>

<template>
  <div class="basic-eval-page">
    <main class="main-content">
      
      <div class="category-tabs">
        <button
          v-for="cat in categories"
          :key="cat.key"
          class="category-btn"
          :class="{ active: activeCategory === cat.key }"
          @click="activeCategory = cat.key"
        >
          <span class="tab-icon">{{ cat.icon }}</span>
          <span>{{ cat.label }}</span>
        </button>
      </div>

      <div class="view-tabs">
        <button
          v-for="tab in viewTabs"
          :key="tab.key"
          class="view-tab-btn"
          :class="{ active: activeView === tab.key }"
          @click="activeView = tab.key"
        >
          <span class="view-icon">{{ tab.icon }}</span>
          <span>{{ tab.label }}</span>
        </button>
      </div>

      <div class="content-area">
        <div v-if="activeView === 'write'" class="write-mode">
          <div class="form-container">
             <component 
              v-if="currentTabComponent"
              :is="currentTabComponent"
              :key="activeCategory"
              @submit="handleSubmit"
              @save-draft="handleSaveDraft"
            />
            <div v-else class="empty-state">준비 중입니다.</div>
          </div>
        </div>

        <div v-else class="history-mode">
          <div class="history-header">
            <div class="header-left">
              <h2 class="history-title">{{ categories.find(c => c.key === activeCategory)?.label }} 평가 내역</h2>
              <p class="history-count">총 {{ filteredByYear.length }}건</p>
            </div>
            
            <div class="header-controls">
              <div class="search-wrap">
                <input 
                  type="text" 
                  :value="searchQuery" 
                  @input="searchQuery = $event.target.value"
                  placeholder="수급자 검색" 
                  class="search-input"
                />
              </div>
              <div class="year-filter" v-if="availableYears.length > 0">
                <select v-model="selectedYear" class="year-select">
                  <option v-for="year in availableYears" :key="year" :value="parseInt(year)">
                    {{ year }}년
                  </option>
                </select>
              </div>
            </div>
          </div>

          <div v-if="loading" class="loading-state">데이터를 불러오는 중...</div>

          <div v-else-if="filteredByYear.length > 0" class="history-list">
            <div
              v-for="item in filteredByYear"
              :key="item.id"
              class="eval-row"
              @click="openDetailModal(item)"
            >
              <div class="row-col basic-info">
                <div class="info-stack">
                  <span class="recipient-name">{{ item.beneficiaryName }}</span>
                  
                  <div class="badge-row">
                    <span 
                      class="status-badge"
                      :class="item.status === '임시저장' ? 'draft' : 'submitted'"
                    >
                      {{ item.status }}
                    </span>
                    
                    <span 
                      class="grade-badge" 
                      :class="getGradeClass(item.gradeLabel)"
                    >
                      {{ item.resultGrade }}
                    </span>
                  </div>
                </div>
              </div>

              <div class="row-col date-info">
                <span class="row-date">{{ item.evalDate?.split('T')[0] }}</span>
                <span class="row-evaluator">평가자: {{ item.evaluatorName }}</span>
              </div>

              <div class="row-col score-info">
                 <div v-if="activeCategory !== 'needs'" class="score-wrapper">
                    <span class="score-label">총점</span>
                    <span class="score-value">{{ item.totalScore }}점</span>
                 </div>
                 <div v-if="item.comment" class="comment-preview">
                    <span class="comment-icon">💬</span>
                    <span class="comment-text">{{ item.comment }}</span>
                 </div>
              </div>

              <div class="row-col action-col">
                 <span class="chevron">›</span>
              </div>
            </div>
          </div>

          <div v-else class="empty-state">
            <p>등록된 평가 내역이 없습니다.</p>
          </div>
        </div>
      </div>

    </main>

    <div v-if="showDetailModal" class="modal-overlay" @click="closeDetailModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>평가 상세 정보</h3>
          <button class="modal-close-btn" @click="closeDetailModal">×</button>
        </div>
        <div class="modal-body">
           <component
            v-if="currentTabComponent && detailItem"
            :is="currentTabComponent"
            :initialData="detailItem"
            :readOnly="true"
          />
        </div>
        <div class="modal-footer">
          <button class="btn-secondary" @click="closeDetailModal">닫기</button>
          <button class="btn-secondary" @click="openEditModal(detailItem)">수정</button>
          <button class="btn-danger" @click="handleDelete(detailItem)">삭제</button>
        </div>
      </div>
    </div>

    <div v-if="showEditModal" class="modal-overlay" @click="closeEditModal">
      <div class="modal-content edit-modal" @click.stop>
        <div class="modal-header">
          <h3>평가 수정</h3>
          <button class="modal-close-btn" @click="closeEditModal">×</button>
        </div>
        <div class="modal-body">
           <component
            v-if="currentTabComponent && editItem"
            :is="currentTabComponent"
            :initialData="editItem"
            @submit="handleEditSubmit"
            @save-draft="handleEditDraft"
          />
        </div>
      </div>
    </div>

  </div>
</template>

<style scoped>
/* 페이지 레이아웃 */
.basic-eval-page {
  background-color: transparent;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.main-content {
  flex: 1;
  width: 100%;
  padding-bottom: 3rem;
}

/* 탭 스타일 */
.category-tabs {
  display: flex; gap: 0.5rem; margin-bottom: 1rem; overflow-x: auto; padding-bottom: 0.5rem;
}
.category-btn {
  display: flex; align-items: center; gap: 0.5rem; padding: 0.75rem 1.25rem;
  border: 1px solid #e5e7eb; background: white; color: #6b7280; border-radius: 0.75rem;
  font-weight: 600; font-size: 0.9rem; cursor: pointer; transition: all 0.2s;
}
.category-btn.active {
  background: #16a34a; color: white; border-color: #16a34a;
  box-shadow: 0 4px 6px rgba(22, 163, 74, 0.2);
}

.view-tabs {
  display: flex; gap: 0.5rem; margin-bottom: 1.5rem; border-bottom: 2px solid #e5e7eb;
}
.view-tab-btn {
  display: flex; align-items: center; gap: 0.5rem; padding: 0.75rem 1.5rem;
  border: none; background: transparent; color: #6b7280; font-weight: 600;
  font-size: 0.875rem; cursor: pointer; transition: all 0.2s; border-bottom: 3px solid transparent;
}
.view-tab-btn.active {
  color: #16a34a; border-bottom-color: #16a34a; background: #f0fdf4;
}

.form-container { background: white; border-radius: 0.75rem; }

/* 내역 헤더 */
.history-header {
  margin-bottom: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
  background: white;
  padding: 16px 20px;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.header-left { display: flex; flex-direction: column; gap: 4px; }
.header-controls { display: flex; align-items: center; gap: 12px; }

.history-title {
  font-size: 1.1rem;
  font-weight: 700;
  color: #111827;
  margin: 0;
}

.history-count {
  font-size: 0.85rem;
  color: #6b7280;
  margin: 0;
}

.search-input {
  padding: 8px 12px;
  font-size: 0.9rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  width: 180px;
}
.search-input:focus {
  outline: none;
  border-color: #10b981;
  box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.1);
}

.year-select {
  padding: 6px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.9rem;
  background-color: white;
  cursor: pointer;
  color: #374151;
  outline: none;
}

/* 리스트 스타일 (Row Layout) */
.history-list {
  display: flex; flex-direction: column; gap: 12px;
}

.eval-row {
  background: white; border: 1px solid #e5e7eb; border-radius: 12px;
  padding: 16px 24px; display: grid;
  /* 그리드 정의: 이름/등급 | 날짜/평가자 | 점수/총평 | 화살표 */
  grid-template-columns: 1.2fr 1.2fr 2fr 40px;
  align-items: center; gap: 16px; transition: all 0.2s; cursor: pointer;
}

.eval-row:hover {
  border-color: #16a34a; box-shadow: 0 4px 12px rgba(22, 163, 74, 0.1); transform: translateX(4px);
}

/* 1. 기본 정보 (이름, 배지 스택) - 수정됨 */
.row-col.basic-info .info-stack {
  display: flex; 
  flex-direction: column; 
  gap: 8px; /* 요소 사이 간격 (사진과 유사하게) */
  align-items: flex-start;
}
.recipient-name { font-size: 1.1rem; font-weight: 800; color: #1f2937; margin-bottom: 2px; }

.badge-row {
  display: flex;
  gap: 6px;
  align-items: center;
}

/* 등급 배지 스타일 */
.grade-badge {
  display: inline-block; padding: 4px 8px; border-radius: 6px;
  font-size: 0.8rem; font-weight: 600; width: fit-content;
}
.grade-badge.grade-low { background: #dcfce7; color: #16a34a; }
.grade-badge.grade-mid { background: #fef3c7; color: #d97706; }
.grade-badge.grade-high { background: #fee2e2; color: #dc2626; }

/* 상태 배지 스타일 - 수정됨 */
.status-badge {
  display: inline-block; padding: 4px 8px; border-radius: 6px;
  font-size: 0.8rem; font-weight: 600; width: fit-content;
}

/* 임시저장: 노란색 테마 (CareLog form DailyCarePage) */
.status-badge.draft { 
  background: #fef3c7; 
  color: #d97706;      
  border: none;
}

/* 제출됨: 파란색 테마 */
.status-badge.submitted { 
  background: #E0F2FE; 
  color: #0369A1;      
  border: 1px solid #BAE6FD; 
}

/* 2. 날짜 정보 */
.row-col.date-info {
  display: flex; flex-direction: column; gap: 2px;
}
.row-date { font-size: 0.9rem; color: #374151; font-weight: 600; }
.row-evaluator { font-size: 0.8rem; color: #6b7280; }

/* 3. 점수 및 총평 */
.row-col.score-info {
  display: flex; flex-direction: column; gap: 4px;
}
.score-wrapper { display: flex; align-items: center; gap: 6px; }
.score-label { font-size: 0.75rem; color: #6b7280; }
.score-value { font-size: 0.9rem; font-weight: 700; color: #16a34a; }

.comment-preview {
  display: flex; align-items: center; gap: 6px; background: #fffbeb;
  padding: 4px 8px; border-radius: 4px; border-left: 3px solid #f59e0b;
  overflow: hidden; max-width: 100%;
}
.comment-icon { font-size: 0.8rem; }
.comment-text {
  font-size: 0.8rem; color: #92400e; white-space: nowrap;
  overflow: hidden; text-overflow: ellipsis;
}

/* 4. 액션 */
.row-col.action-col {
  text-align: right; color: #d1d5db; font-size: 1.5rem; font-weight: 300;
}

/* 모달 스타일 */
.modal-overlay {
  position: fixed; inset: 0; background: rgba(0, 0, 0, 0.45);
  display: flex; align-items: center; justify-content: center;
  padding: 1rem; z-index: 2000;
}
.modal-content {
  width: min(1000px, 95%); background: white; border-radius: 0.75rem;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.18); overflow: hidden;
  display: flex; flex-direction: column; max-height: 90vh;
}
.modal-header {
  display: flex; justify-content: space-between; align-items: center;
  padding: 1.25rem 1.5rem; border-bottom: 1px solid #e5e7eb;
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
}
.modal-header h3 { margin: 0; font-size: 1.25rem; font-weight: 800; color: #166534; }
.modal-close-btn {
  background: transparent; border: none; font-size: 1.5rem; cursor: pointer; color: #6b7280;
}
.modal-body { padding: 1.5rem; overflow-y: auto; }
.modal-footer {
  padding: 1rem 1.5rem; border-top: 1px solid #e5e7eb; background: #f9fafb;
  display: flex; justify-content: flex-end; gap: 0.5rem;
}
.btn-secondary {
  padding: 0.6rem 1.2rem; border-radius: 0.5rem; background: white;
  border: 1px solid #d1d5db; cursor: pointer;
}
.btn-danger {
  padding: 0.6rem 1.2rem; border-radius: 0.5rem; background: #fee2e2;
  color: #dc2626; border: none; cursor: pointer;
}

.empty-state, .loading-state { padding: 3rem; text-align: center; color: #9ca3af; }

/* 반응형 */
@media (max-width: 768px) {
  .eval-row {
    grid-template-columns: 1fr; gap: 8px; padding: 16px;
  }
  .row-col.action-col { display: none; }
  .name-wrapper { flex-direction: row; justify-content: space-between; width: 100%; align-items: flex-start;}
  
  .grade-badge { margin-top: 0; }
  .row-col.date-info { flex-direction: row; gap: 8px; align-items: center; }
}
</style>