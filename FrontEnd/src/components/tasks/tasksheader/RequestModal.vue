<template>
  <div class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-container">
      
      <div class="modal-header">
        <div class="header-title">
          <span>결재 요청</span>
        </div>
        <button class="close-btn" @click="$emit('close')">✕</button>
      </div>

      <div class="modal-body">
        
        <section class="form-section">
          <h3 class="section-title">기본 정보</h3>
          
          <div class="form-group">
            <label>제목 <span class="required">*</span></label>
            <input 
              v-model="form.title" 
              type="text" 
              placeholder="결재 문서 제목을 입력하세요" 
              class="form-input" 
            />
          </div>

          <div class="form-row">
            <div class="form-group half">
              <label>유형 <span class="required">*</span></label>
              <select v-model="form.categoryId" class="form-select">
                <option value="" disabled>선택하세요</option>
                <option 
                  v-for="cat in categories" 
                  :key="cat.id" 
                  :value="cat.id"
                >
                  {{ cat.name }}
                </option>
              </select>
            </div>
            <div class="form-group half">
              <label>우선순위 <span class="required">*</span></label>
              <select v-model="form.priority" class="form-select">
                <option :value="1">보통</option>
                <option :value="2">긴급</option>
                <option :value="0">낮음</option>
              </select>
            </div>
          </div>

          <!-- 금액 입력 -->
          <div class="form-group" v-if="form.categoryId !== 3"> 
            <label>금액</label>
            <div class="input-with-icon">
              <span class="currency-icon">₩</span>
              <input 
                v-model="form.amount" 
                type="number" 
                placeholder="금액을 입력하세요" 
                class="form-input padding-left" 
              />
            </div>
          </div>

          <!-- 날짜 입력 -->
          <div class="form-row" v-if="form.categoryId === 3">
            <div class="form-group half">
              <label>시작일</label>
              <input v-model="form.startDate" type="date" class="form-input" />
            </div>
            <div class="form-group half">
              <label>종료일</label>
              <input v-model="form.endDate" type="date" class="form-input" />
            </div>
          </div>

          <div class="form-group">
            <label>내용</label>
            <textarea 
              v-model="form.content" 
              placeholder="결재 요청 사유 및 상세 내용을 입력하세요" 
              class="form-textarea"
            ></textarea>
          </div>
        </section>

        <!-- 첨부 파일 섹션 제거됨 -->

        <section class="form-section">
          <div class="section-header">
            <h3 class="section-title success-color">승인자 지정 <span class="required">*</span></h3>
          </div>
          
          <!-- 승인자 선택 영역 (개선된 UI) -->
          <div class="approver-selection-area">
             <!-- 퀵 필터 칩 -->
             <div class="quick-filters">
                <button 
                  class="chip" 
                  :class="{ active: filterTab === 'recent' }" 
                  @click="switchTab('recent')"
                >최근</button>
                <button 
                  class="chip" 
                  :class="{ active: filterTab === 'team' }" 
                  @click="switchTab('team')"
                >우리팀 </button>
                <button 
                  class="chip" 
                  :class="{ active: filterTab === 'org' }" 
                  @click="switchTab('org')"
                >조직도</button>
                <button 
                  class="chip" 
                  :class="{ active: filterTab === 'all' }" 
                  @click="switchTab('all')"
                > 전체</button>
             </div>

             <!-- 검색 및 드롭다운 -->
             <div class="search-dropdown-container">
                <input 
                  type="text"
                  v-model="approverSearchQuery" 
                  placeholder="이름, 부서 또는 직책 검색..." 
                  class="form-input search-input"
                  @focus="showDropdown = true"
                  @input="handleSearchInput"
                />
                <span class="search-icon-inner">🔍</span>

                <!-- 드롭다운 리스트 -->
                <div v-if="showDropdown" class="dropdown-list">
                   <!-- 1. 검색 결과 또는 일반 리스트 -->
                   <template v-if="filterTab !== 'org' || approverSearchQuery">
                      <template v-if="displayedList.length > 0">
                          <div 
                            v-for="emp in displayedList" 
                            :key="emp.id" 
                            class="dropdown-item"
                            @click="selectApprover(emp)"
                          >
                             <span class="emp-name">{{ emp.name }}</span>
                             <span class="emp-info">{{ emp.jobTitle || emp.position || '직원' }} / {{ emp.departmentName || emp.department || '팀미정' }}</span>
                          </div>
                      </template>
                      <div v-else class="dropdown-empty">
                         {{ isLoading ? '검색 중...' : '데이터가 없습니다.' }}
                      </div>
                   </template>

                   <!-- 2. 조직도 트리 (검색어가 없을 때만) -->
                   <template v-else>
                      <div class="org-tree-container">
                         <div v-for="dept in deptTree" :key="dept.deptId" class="dept-node">
                            <div class="dept-name" @click="toggleDept(dept.deptId)">
                               <span class="toggle-icon">{{ expandedDepts.has(dept.deptId) ? '▼' : '▶' }}</span>
                               {{ dept.deptName }} <span class="member-count">({{ dept.members?.length || 0 }})</span>
                            </div>
                            <div v-if="expandedDepts.has(dept.deptId)" class="dept-members">
                               <div 
                                 v-for="member in dept.members" 
                                 :key="member.id" 
                                 class="dropdown-item member-item"
                                 @click="selectApprover(member)"
                               >
                                  <span class="emp-name">{{ member.name }}</span>
                                  <span class="emp-info">{{ member.jobTitle }}</span>
                               </div>
                               <div v-if="!dept.members?.length" class="empty-dept">팀원 없음</div>
                            </div>
                         </div>
                         <div v-if="deptTree.length === 0" class="dropdown-empty">조직도 정보가 없습니다.</div>
                      </div>
                   </template>
                </div>
             </div>
          </div>
          
          <div class="approver-list" v-if="selectedApprovers.length > 0">
             <div 
               v-for="(emp, idx) in selectedApprovers" 
               :key="emp.id" 
               class="approver-tag"
             >
               {{ emp.name }}
               <span class="remove-x" @click="removeApprover(idx)">✕</span>
             </div>
          </div>
          <div v-else class="empty-approver-box">
            승인자를 지정해주세요
          </div>
        </section>

      </div>

      <div class="modal-footer">
        <button class="btn btn-cancel" @click="$emit('close')">취소</button>
        <button class="btn btn-submit" @click="handleSubmit">📄 결재 요청</button>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, reactive, computed } from 'vue';
import { 
  createPayment, 
  getPaymentCategories, 
  searchUsers, 
  getRecentApprovers, 
  getMyDepartmentMembers, 
  getDepartmentTree 
} from '@/api/payment/paymentApi';
import { getEmployeeList } from '@/api/employee/employeeApi'; 

const emit = defineEmits(['close', 'success']);

// 데이터 상태
const categories = ref([]);
const recentList = ref([]);
const teamList = ref([]);
const deptTree = ref([]);
const allEmployees = ref([]); // 초기 로드용 (페이징된 전체 일부)
const searchResultList = ref([]); // 검색 결과

// UI 상태
const approverSearchQuery = ref('');
const showDropdown = ref(false);
const filterTab = ref('recent'); // Default to recent
const isLoading = ref(false);
const expandedDepts = ref(new Set()); // 펼쳐진 부서 ID

// 선택된 승인자들 (객체로 관리)
const selectedApprovers = ref([]);

const form = reactive({
  categoryId: '',
  title: '',
  content: '',
  priority: 1, 
  amount: null,
  startDate: '',
  endDate: '',
  // approverIds는 submit 할 때 매핑
});

let searchTimeout = null;

// 키보드 이벤트
const handleKeydown = (e) => {
  if (e.key === 'Escape') {
    if (showDropdown.value) {
      showDropdown.value = false;
    } else {
      emit('close');
    }
  } else if (e.key === 'Enter' && !e.shiftKey) { 
    if (e.target.tagName !== 'TEXTAREA' && !showDropdown.value) {
        e.preventDefault();
        handleSubmit();
    }
  }
};

onMounted(async () => {
  window.addEventListener('keydown', handleKeydown);
  window.addEventListener('click', closeDropdownOutside);

  try {
    // 1. 카테고리
    categories.value = await getPaymentCategories() || [];

    // 2. 기초 데이터 병렬 로드
    const [recentData, teamData, treeData] = await Promise.all([
       getRecentApprovers(),
       getMyDepartmentMembers(),
       getDepartmentTree()
    ]);
    
    recentList.value = recentData || [];
    teamList.value = teamData || [];
    deptTree.value = treeData || [];
    
    // 전체 목록 초기값 (검색 없을때 '전체' 탭용) - 기존 API 활용
    const allData = await getEmployeeList({ size: 20 });
    allEmployees.value = allData.content || allData || [];

  } catch (e) {
    console.error('Failed to load initial data:', e);
  }
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown);
  window.removeEventListener('click', closeDropdownOutside);
});

const closeDropdownOutside = (e) => {
  const dropdown = document.querySelector('.search-dropdown-container');
  // 칩 클릭 시에는 닫히지 않도록
  const chipContainer = document.querySelector('.quick-filters');
  
  if (dropdown && !dropdown.contains(e.target) && (!chipContainer || !chipContainer.contains(e.target))) {
    showDropdown.value = false;
  }
};

// 탭 변경
const switchTab = (tab) => {
    filterTab.value = tab;
    showDropdown.value = true;
    approverSearchQuery.value = ''; // 탭 바꾸면 검색어 초기화? or 유지? 보통 초기화가 자연스러움
    searchResultList.value = [];
};

// 조직도 토글
const toggleDept = (deptId) => {
    if (expandedDepts.value.has(deptId)) {
        expandedDepts.value.delete(deptId);
    } else {
        expandedDepts.value.add(deptId);
    }
};

// 검색 입력 핸들러 (Debounce)
const handleSearchInput = () => {
    showDropdown.value = true;
    if (searchTimeout) clearTimeout(searchTimeout);
    
    if (!approverSearchQuery.value.trim()) {
        searchResultList.value = [];
        return;
    }

    isLoading.value = true;
    searchTimeout = setTimeout(async () => {
        try {
            const results = await searchUsers(approverSearchQuery.value);
            searchResultList.value = results || [];
        } catch(e) {
            console.error(e);
        } finally {
            isLoading.value = false;
        }
    }, 300);
};

// 화면에 보여줄 리스트 계산
const displayedList = computed(() => {
    // 1. 검색어가 있으면 검색 결과 우선
    if (approverSearchQuery.value.trim()) {
        return searchResultList.value.filter(emp => !selectedApprovers.value.some(sel => sel.id === emp.id));
    }

    // 2. 탭에 따른 리스트 반환
    let list = [];
    if (filterTab.value === 'recent') list = recentList.value;
    else if (filterTab.value === 'team') list = teamList.value;
    else if (filterTab.value === 'all') list = allEmployees.value;
    // 'org' 탭은 템플릿에서 별도 처리 (트리 구조)

    // 이미 선택된 사람 제외
    return list.filter(emp => !selectedApprovers.value.some(sel => sel.id === emp.id));
});

const selectApprover = (emp) => {
    if(!selectedApprovers.value.some(sel => sel.id === emp.id)) {
        // 필수 필드 표준화 (API마다 필드명이 다를 수 있음 대비)
        selectedApprovers.value.push({
            id: emp.id,
            name: emp.name,
            position: emp.jobTitle || emp.position,
            department: emp.departmentName || emp.department
        });
    }
    // 검색어 초기화하지 않고 계속 추가할 수 있게 유지하거나, 초기화 할수도 있음. 
    // 사용자 경험상 여러명 추가할 땐 유지하는게 좋지만, 
    // 보통 선택 후 닫히거나 초기화됨. 여기선 초기화.
    approverSearchQuery.value = '';
    searchResultList.value = [];
};

const removeApprover = (index) => {
    selectedApprovers.value.splice(index, 1);
};

const handleSubmit = async () => {
  if(!form.title || !form.categoryId || selectedApprovers.value.length === 0) {
      alert('필수 정보를 입력해주세요 (제목, 유형, 승인자)');
      return;
  }

  // ID 배열로 변환
  const payload = {
      ...form,
      approverIds: selectedApprovers.value.map(user => user.id)
  };

  try {
    await createPayment(payload);
    alert('결재 요청이 등록되었습니다.');
    emit('success'); 
    emit('close');
  } catch(e) {
    console.error('Create Payment Failed:', e);
    alert('결재 요청 등록 중 오류가 발생했습니다.');
  }
};
</script>

<style scoped>
/* 모달 레이아웃 */
.modal-overlay {
  position: fixed; top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(0, 0, 0, 0.4);
  z-index: 1000;
  display: flex; justify-content: center; align-items: center;
}

.modal-container {
  background: white;
  width: 600px;
  max-height: 90vh; 
  border-radius: 12px;
  display: flex; flex-direction: column;
  box-shadow: 0 10px 25px rgba(0,0,0,0.15);
  overflow: hidden;
}

.modal-header {
  background-color: #4ade80; 
  color: white;
  padding: 16px 24px;
  display: flex; justify-content: space-between; align-items: center;
}
.header-title { font-size: 18px; font-weight: 600; display: flex; align-items: center; gap: 8px; }
.close-btn { background: none; border: none; color: white; font-size: 20px; cursor: pointer; }

.modal-body {
  padding: 24px;
  overflow-y: auto;
  flex: 1;
}

.form-section { margin-bottom: 24px; }
.section-title { font-size: 16px; font-weight: 600; color: #1a5928; margin-bottom: 12px; display: block; }

.form-group { margin-bottom: 16px; display: flex; flex-direction: column; gap: 6px; }
.form-group label { font-size: 14px; font-weight: 600; color: #333; }
.required { color: #ef4444; margin-left: 2px; }

.form-input, .form-select, .form-textarea {
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  padding: 10px 12px;
  font-size: 14px;
  outline: none;
  width: 100%; box-sizing: border-box;
}
.form-input:focus, .form-select:focus, .form-textarea:focus { border-color: #4ade80; }
.form-textarea { height: 100px; resize: none; }
.form-row { display: flex; gap: 16px; }
.half { flex: 1; }
.input-with-icon { position: relative; }
.currency-icon { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #888; font-size: 14px; }
.padding-left { padding-left: 30px; }
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }

/* 승인자 선택 영역 스타일 */
.approver-selection-area { margin-bottom: 12px; }

.quick-filters { display: flex; gap: 8px; margin-bottom: 8px; }
.chip {
  padding: 6px 12px;
  border-radius: 20px;
  border: 1px solid #e2e8f0;
  background-color: white;
  color: #64748b;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s;
}
.chip:hover { background-color: #f8fafc; }
.chip.active { background-color: #dcfce7; color: #166534; border-color: #86efac; font-weight: 600; }

.search-dropdown-container { position: relative; }
.search-input { width: 100%; padding-right: 36px; }
.search-icon-inner { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); font-size: 16px; color: #94a3b8; pointer-events: none; }

.dropdown-list {
  position: absolute; top: 100%; left: 0; width: 100%;
  background: white; border: 1px solid #e2e8f0; border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  max-height: 250px; overflow-y: auto; z-index: 50;
  margin-top: 4px;
}
.dropdown-item {
  padding: 10px 14px; cursor: pointer; display: flex; justify-content: space-between; align-items: center;
  border-bottom: 1px solid #f1f5f9;
}
.dropdown-item:last-child { border-bottom: none; }
.dropdown-item:hover { background-color: #f8fafc; }

.emp-name { font-weight: 600; font-size: 14px; color: #334155; }
.emp-info { font-size: 12px; color: #94a3b8; }
.dropdown-empty { padding: 16px; text-align: center; color: #94a3b8; font-size: 13px; }

/* 조직도 스타일 */
.org-tree-container { padding: 8px 0; }
.dept-node { border-bottom: 1px solid #f1f5f9; }
.dept-name { 
  padding: 10px 14px; font-size: 14px; font-weight: 600; color: #475569; 
  cursor: pointer; display: flex; align-items: center; 
}
.dept-name:hover { background-color: #f8fafc; }
.toggle-icon { margin-right: 6px; font-size: 10px; color: #94a3b8; width: 12px; }
.member-count { font-weight: normal; color: #94a3b8; margin-left: 4px; font-size: 12px; }
.dept-members { background-color: #fcfcfc; }
.member-item { padding-left: 32px; border-bottom: 1px solid #f8fafc; }
.empty-dept { padding: 8px 0 8px 32px; font-size: 12px; color: #cbd5e1; font-style: italic; }

.approver-list { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 8px; }
.approver-tag {
  background-color: #f0fdf4; border: 1px solid #bbf7d0; color: #166534;
  padding: 6px 12px; border-radius: 20px; font-size: 14px; display: flex; align-items: center; gap: 6px;
}
.remove-x { cursor: pointer; color: #15803d; font-weight: bold; }

.empty-approver-box {
  background-color: #f8f9fa; border: 1px solid #e2e8f0; border-radius: 6px;
  padding: 24px; text-align: center; color: #64748b; font-size: 14px;
}

.modal-footer {
  padding: 16px 24px;
  border-top: 1px solid #e2e8f0;
  display: flex; gap: 12px;
}
.btn {
  flex: 1; padding: 12px; border-radius: 8px; font-weight: 600; cursor: pointer; font-size: 15px;
}
.btn-cancel { background: white; border: 1px solid #e2e8f0; color: #64748b; }
.btn-cancel:hover { background: #f1f5f9; }
.btn-submit { background: #4ade80; border: none; color: white; }
.btn-submit:hover { background: #22c55e; }
</style>