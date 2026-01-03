<script setup>
import { ref, computed, watch, onMounted } from "vue";
import { useUserStore } from '@/stores/user';
import { Icon } from '@iconify/vue';

// 1. 각 평가 폼 컴포넌트 임포트
import FallRiskAssessmentForm from "@/components/careworker/activity/FallRiskAssessmentForm.vue";
import BedsoreAssessmentForm from "@/components/careworker/activity/BedsoreAssessmentForm.vue";
import CognitiveAssessmentForm from "@/components/careworker/activity/CognitiveAssessmentForm.vue";
import NeedsAssessmentForm from "@/components/careworker/activity/NeedsAssessmentForm.vue";

// 2. API 임포트
import {
  getFallEvaluationListByBeneficiary,
  getFallEvaluationDetail,
  getBedsoreEvaluationListByBeneficiary,
  getBedsoreEvaluationDetail,
  getCognitiveEvaluationListByBeneficiary,
  getCognitiveEvaluationDetail,
  getNeedsEvaluationListByBeneficiary,
  getNeedsEvaluationDetail,
} from '@/api/careworker';

const props = defineProps({
  beneficiaryId: {
    type: [Number, String],
    required: true
  }
});

const userStore = useUserStore();

// 메인 탭 (평가 종류)
const activeCategory = ref("fallRisk");

const evalHistory = ref([]);
const loading = ref(false);
const selectedYear = ref(new Date().getFullYear());
const yearStats = ref({});

// 평가 카테고리 정의
const categories = [
  { key: "fallRisk", label: "낙상위험도", icon: "line-md:alert", component: FallRiskAssessmentForm },
  { key: "bedsore", label: "욕창위험도", icon: "line-md:plus-square", component: BedsoreAssessmentForm },
  { key: "cognitive", label: "인지기능", icon: "line-md:question-circle", component: CognitiveAssessmentForm },
  { key: "needs", label: "욕구사정", icon: "line-md:clipboard-check", component: NeedsAssessmentForm || null },
];

const apiMap = {
  fallRisk: getFallEvaluationListByBeneficiary,
  bedsore: getBedsoreEvaluationListByBeneficiary,
  cognitive: getCognitiveEvaluationListByBeneficiary,
  needs: getNeedsEvaluationListByBeneficiary,
};

const detailApiMap = {
  fallRisk: getFallEvaluationDetail,
  bedsore: getBedsoreEvaluationDetail,
  cognitive: getCognitiveEvaluationDetail,
  needs: getNeedsEvaluationDetail,
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
  if (!props.beneficiaryId) return;

  loading.value = true;
  evalHistory.value = [];
  yearStats.value = {};

  try {
    const currentApi = apiMap[activeCategory.value];
    if (!currentApi) return;

    // ByBeneficiary API expects beneficiaryId
    const response = await currentApi(props.beneficiaryId);
    const data = response?.data ?? response;

    const formattedData = (data || []).map(item => {
      let totalScore = item.totalScore ?? 0;
      let resultGrade = item.resultGrade || '-';

      // evalData 파싱 로직
      let parsedIsDraft = false;
      if (item.evalData) {
        try {
          const parsedData = typeof item.evalData === 'string' ? JSON.parse(item.evalData) : item.evalData;
          
          if (parsedData.isDraft) parsedIsDraft = true; 

          if (parsedData.result) {
            totalScore = parsedData.result.total_score ?? totalScore;
            resultGrade = parsedData.result.grade || resultGrade;
          }
        } catch (error) { /* Ignore */ }
      }

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
        evaluatorName: item.employeeName || item.evaluatorName || item.writerName || item.createdByName || item.careWorkerName || '-', 
        comment: item.specialNote || item.comment || '',
        scoreDetails: item.scoreDetails || ''
      };
    });

    // 날짜 최신순 정렬
    formattedData.sort((a, b) => new Date(b.evalDate) - new Date(a.evalDate));

    evalHistory.value = formattedData;
    yearStats.value = calculateYearStats(formattedData);
    
    // 연도 선택 초기화
    const years = Object.keys(yearStats.value).sort((a, b) => b - a);
    if (years.length > 0 && !yearStats.value[selectedYear.value]) {
       // 현재 선택된 연도가 데이터에 없으면 가장 최신 연도로
       selectedYear.value = parseInt(years[0]);
    } else if (years.length === 0) {
       selectedYear.value = new Date().getFullYear();
    }

  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const searchQuery = ref('');

const filteredByYear = computed(() => {
  if (!yearStats.value[selectedYear.value]) return [];
  let items = yearStats.value[selectedYear.value].items || [];

  // beneficiaryId 기준이라 이름 검색은 덜 중요할 수 있지만 유지
  if (searchQuery.value) {
    const query = searchQuery.value.trim().toLowerCase();
    items = items.filter(item => item.beneficiaryName.toLowerCase().includes(query));
  }
  
  return items;
});

const availableYears = computed(() => {
  return Object.keys(yearStats.value).sort((a, b) => b - a);
});

const showDetailModal = ref(false);
const detailItem = ref(null);

// 상세 데이터 파싱 유틸 함수
const parseDetailData = (item) => {
  let parsed = { ...item };
  
  parsed.recipientName = item.beneficiaryName || item.recipientName;

  if (item.evalData) {
    try {
      const evalJson = typeof item.evalData === 'string' ? JSON.parse(item.evalData) : item.evalData;
      
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

    data.id = data.id || data.evalId || item.id;
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

// watch beneficiariesId -> load
watch(() => props.beneficiaryId, loadEvaluationHistory, { immediate: true });
// watch activeCategory -> load
watch(activeCategory, loadEvaluationHistory);
</script>

<template>
  <div class="evaluation-history">
    <div class="category-tabs">
      <button
        v-for="cat in categories"
        :key="cat.key"
        class="category-btn"
        :class="{ active: activeCategory === cat.key }"
        @click="activeCategory = cat.key"
      >
        <span class="tab-icon"><Icon :icon="cat.icon" width="20" height="20" /></span>
        <span>{{ cat.label }}</span>
      </button>
    </div>

    <div class="history-container">
      <div class="history-header">
        <div class="header-left">
          <h2 class="history-title">{{ categories.find(c => c.key === activeCategory)?.label }} 평가 내역</h2>
          <p class="history-count">총 {{ filteredByYear.length }}건</p>
        </div>
        
        <div class="header-controls">
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
          </div>

          <div class="row-col score-info">
             <div v-if="activeCategory !== 'needs'" class="score-wrapper">
                <span class="score-label">총점</span>
                <span class="score-value">{{ item.totalScore }}점</span>
             </div>
             <div v-if="item.comment" class="comment-preview">
                <span class="comment-icon"><Icon icon="line-md:chat" width="16" height="16" /></span>
                <span class="comment-text">{{ item.comment }}</span>
             </div>
          </div>

          <div class="row-col action-col">
             <span class="chevron"><Icon icon="line-md:chevron-right" width="20" height="20" /></span>
          </div>
        </div>
      </div>

      <div v-else class="empty-state">
        <p>평가 내역이 없습니다.</p>
      </div>
    </div>

    <!-- 상세 모달 -->
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
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.evaluation-history { width: 100%; }

.category-tabs {
  display: flex; gap: 0.5rem; margin-bottom: 1rem; overflow-x: auto; padding-bottom: 0.5rem;
}
.category-btn {
  display: flex; align-items: center; gap: 0.5rem; padding: 0.75rem 1.25rem;
  border: 1px solid #e5e7eb; background: white; color: #6b7280; border-radius: 0.75rem;
  font-weight: 600; font-size: 0.9rem; cursor: pointer; transition: all 0.2s;
  white-space: nowrap;
}
.category-btn.active {
  background: #16a34a; color: white; border-color: #16a34a;
  box-shadow: 0 4px 6px rgba(22, 163, 74, 0.2);
}

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

.history-list {
  display: flex; flex-direction: column; gap: 12px;
}

.eval-row {
  background: white; border: 1px solid #e5e7eb; border-radius: 12px;
  padding: 16px 24px; display: grid;
  grid-template-columns: 1.2fr 1.2fr 2fr 40px;
  align-items: center; gap: 16px; transition: all 0.2s; cursor: pointer;
}

.eval-row:hover {
  border-color: #16a34a; box-shadow: 0 4px 12px rgba(22, 163, 74, 0.1); transform: translateX(4px);
}

.info-stack {
  display: flex; flex-direction: column; gap: 8px; align-items: flex-start;
}
.recipient-name { font-size: 1.1rem; font-weight: 800; color: #1f2937; margin-bottom: 2px; }

.badge-row { display: flex; gap: 6px; align-items: center; }

.grade-badge {
  display: inline-block; padding: 4px 8px; border-radius: 6px;
  font-size: 0.8rem; font-weight: 600; width: fit-content;
}
.grade-badge.grade-low { background: #dcfce7; color: #16a34a; }
.grade-badge.grade-mid { background: #fef3c7; color: #d97706; }
.grade-badge.grade-high { background: #fee2e2; color: #dc2626; }

.status-badge {
  display: inline-block; padding: 2px 8px; background: #dcfce7; color: #16a34a;
  font-size: 0.7rem; font-weight: 600; border-radius: 4px;
}
.status-badge.draft { background: #fef3c7; color: #d97706; }

.date-info { display: flex; flex-direction: column; gap: 4px; }
.row-date { font-weight: 600; color: #374151; font-size: 0.95rem; }
.row-evaluator { font-size: 0.85rem; color: #6b7280; }

.score-info { display: flex; flex-direction: column; gap: 6px; }
.score-wrapper { display: flex; align-items: center; gap: 8px; }
.score-label { font-size: 0.85rem; color: #6b7280; }
.score-value { font-weight: 700; color: #16a34a; font-size: 1rem; }

.comment-preview {
  display: flex; align-items: center; gap: 6px;
  background: #f9fafb; padding: 6px 10px; border-radius: 6px;
}
.comment-icon { font-size: 0.9rem; }
.comment-text {
  font-size: 0.85rem; color: #4b5563;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 250px;
}

.action-col { text-align: right; color: #9ca3af; font-size: 1.2rem; }

.loading-state, .empty-state {
  text-align: center; padding: 40px; color: #6b7280; background: #f9fafb; border-radius: 12px;
}

/* Modal Styles */
.modal-overlay {
  position: fixed; top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex; justify-content: center; align-items: center;
  z-index: 1000; backdrop-filter: blur(4px);
}

.modal-content {
  background: white; width: 90%; max-width: 800px;
  height: 90vh; max-height: 900px;
  border-radius: 16px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
  display: flex; flex-direction: column; overflow: hidden;
}

.modal-header {
  padding: 20px 24px; border-bottom: 1px solid #e5e7eb;
  display: flex; justify-content: space-between; align-items: center;
  background: #fff;
}
.modal-header h3 { font-size: 1.25rem; font-weight: 700; color: #111; margin: 0; }

.modal-close-btn {
  background: transparent; border: none; font-size: 24px; color: #9ca3af; cursor: pointer; padding: 4px;
}

.modal-body {
  flex: 1; overflow-y: auto; padding: 24px; background: #f9fafb;
}

.modal-footer {
  padding: 16px 24px; border-top: 1px solid #e5e7eb; background: white;
  display: flex; justify-content: flex-end; gap: 8px;
}

.btn-secondary {
  padding: 8px 16px; border: 1px solid #d1d5db; background: white;
  color: #374151; border-radius: 6px; font-weight: 500; cursor: pointer;
}
.btn-secondary:hover { background: #f9fafb; }
</style>
