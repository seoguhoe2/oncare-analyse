<script setup>
import { ref, onMounted, defineProps, watch } from 'vue'; // ✅ defineProps, watch 추가
import { getTodos, getTodoDetail, createTodo, updateTodo, completeTodo, uncompleteTodo, deleteTodo } from '@/api/careworker';
import TodoModal from './TodoModal.vue';

// ✅ 부모 컴포넌트에서 선택된 수급자 ID를 받아옵니다.
const props = defineProps({
  beneficiaryId: {
    type: [Number, String],
    required: false,
    default: null
  }
});

const todos = ref([]);
const isModalOpen = ref(false);
const loading = ref(true);
const modalRef = ref(null);
const editingTodo = ref(null);
const selectedTodoDetail = ref(null);
const detailLoading = ref(false);
const selectedDetailId = ref(null);
const detailError = ref(null);

// ✅ 수급자 ID가 변경되면 목록을 다시 불러오는 기능 추가 (선택 사항)
watch(() => props.beneficiaryId, () => {
  loadTodos();
});

// 오늘 날짜를 확인하고 날짜가 바뀌면 할일을 리셋
const checkAndResetIfNewDay = () => {
  const today = new Date().toDateString();
  const lastCheckDate = localStorage.getItem('lastTodoCheckDate');

  if (lastCheckDate !== today) {
    // 날짜가 바뀌었으면 완료된 할일들을 미완료로 변경
    localStorage.setItem('lastTodoCheckDate', today);
    return true; // 리셋 필요
  }
  return false; // 리셋 불필요
};

const loadTodos = async () => {
  // ✅ 수급자 ID가 없으면 로딩하지 않음
  loading.value = true;

  try {
    const response = await getTodos(props.beneficiaryId); // (참고: API가 ID를 필요로 한다면 여기에 전달)

    // ... 데이터 처리 로직 유지 ...
    const list = Array.isArray(response?.data?.data)
      ? response.data.data
      : Array.isArray(response?.data)
        ? response.data
        : Array.isArray(response)
          ? response
          : [];

    const shouldReset = checkAndResetIfNewDay();

    todos.value = list.map((todo) => ({
      id: todo.todoId,
      text: todo.content ?? todo.todo ?? '',
      checked: shouldReset ? false : todo.isCompleted, // 날짜가 바뀌면 모두 미완료로
      dueDate: todo.dueDate ?? todo.todoDate,
      type: todo.type ?? todo.todoType ?? null,
      beneficiaryId: todo.beneficiaryId ?? todo.beneficiary?.id ?? null,
    }));

    // 날짜가 바뀌었고 완료된 할일이 있었다면 모두 미완료로 변경
    if (shouldReset) {
      for (const todo of todos.value) {
        if (list.find(t => t.todoId === todo.id)?.isCompleted) {
          try {
            await uncompleteTodo(todo.id);
          } catch (error) {
            console.error('할일 리셋 실패:', todo.id, error);
          }
        }
      }
    }
  } catch (error) {
    console.error('할 일 목록 로드 실패:', error);
  } finally {
    loading.value = false;
  }
};

const openAddModal = () => {
  editingTodo.value = null;
  isModalOpen.value = true;
};

const openEditModal = (todo) => {
  editingTodo.value = { ...todo };
  isModalOpen.value = true;
};

const closeModal = () => {
  isModalOpen.value = false;
  editingTodo.value = null;
  if (modalRef.value) {
    modalRef.value.resetForm();
  }
};

// 할 일 추가
const handleAddTodo = async ({ content, type, todoDate, beneficiaryId }) => {
  const targetBeneficiaryId = beneficiaryId || props.beneficiaryId;
  if (!targetBeneficiaryId) {
    alert('수급자를 선택해주세요.');
    return;
  }

  try {
    const newTodo = {
      todo: content,
      todoDate: todoDate || new Date().toISOString().split('T')[0],
      type: type || null,
      beneficiaryId: targetBeneficiaryId,
    };

    console.log('전송할 TODO 데이터:', newTodo);
    await createTodo(newTodo);

    if (modalRef.value) {
      modalRef.value.resetForm();
    }
    isModalOpen.value = false;
    await loadTodos();
    console.log('할 일이 성공적으로 추가되었습니다.');
  } catch (error) {
    console.error('할 일 추가 실패:', error);
    const errorMessage = error.response?.data || error.message || '알 수 없는 오류';
    alert(`할 일 추가 실패: ${errorMessage}\n\n서버 오류일 수 있습니다.`);
  }
};

const handleUpdateTodo = async ({ id, content, type, todoDate, beneficiaryId }) => {
  const targetBeneficiaryId = beneficiaryId || props.beneficiaryId;
  if (!id) {
    alert('수정할 할 일 ID가 없습니다.');
    return;
  }
  if (!targetBeneficiaryId) {
    alert('수급자를 선택해주세요.');
    return;
  }

  try {
    const updatedTodo = {
      todo: content,
      todoDate: todoDate || new Date().toISOString().split('T')[0],
      type: type || null,
      beneficiaryId: targetBeneficiaryId,
    };

    await updateTodo(id, updatedTodo);

    if (modalRef.value) {
      modalRef.value.resetForm();
    }
    isModalOpen.value = false;
    editingTodo.value = null;
    await loadTodos();
    console.log('할 일이 성공적으로 수정되었습니다.');
  } catch (error) {
    console.error('할 일 수정 실패:', error);
    const errorMessage = error.response?.data || error.message || '알 수 없는 오류';
    alert(`할 일 수정 실패: ${errorMessage}\n\n서버 오류일 수 있습니다.`);
  }
};

const handleSelectTodo = async (todo) => {
  if (!todo?.id) return;

  // 같은 항목을 다시 클릭하면 닫기
  if (selectedDetailId.value === todo.id) {
    selectedDetailId.value = null;
    selectedTodoDetail.value = null;
    detailError.value = null;
    detailLoading.value = false;
    return;
  }

  // 우선 클릭한 목록 데이터로 기본 정보 세팅 후, 상세 API로 보강
  selectedTodoDetail.value = {
    id: todo.id,
    content: todo.text ?? '',
    todoDate: todo.dueDate ?? '',
    type: todo.type ?? '',
    isCompleted: todo.checked ?? false,
    createdAt: '',
    beneficiaryName: '',
    beneficiaryAddress: '',
    beneficiaryPhone: '',
    careLevel: '',
  };
  selectedDetailId.value = todo.id;
  detailError.value = null;
  detailLoading.value = true;

  try {
    const response = await getTodoDetail(todo.id);
    const data = response?.data?.data ?? response?.data ?? response ?? {};

    selectedTodoDetail.value = {
      id: data.todoId ?? data.id ?? todo.id,
      content: data.content ?? data.todo ?? selectedTodoDetail.value.content,
      todoDate: data.todoDate ?? data.dueDate ?? selectedTodoDetail.value.todoDate,
      type: data.type ?? data.todoType ?? selectedTodoDetail.value.type,
      isCompleted: data.isCompleted ?? data.completed ?? selectedTodoDetail.value.isCompleted,
      createdAt: data.createdAt ?? selectedTodoDetail.value.createdAt,
      beneficiaryName: data.beneficiaryName ?? data.beneficiary?.name ?? '',
      beneficiaryAddress: data.beneficiaryAddress ?? data.beneficiary?.address ?? '',
      beneficiaryPhone: data.beneficiaryPhone ?? data.beneficiary?.phone ?? '',
      careLevel: data.careLevel ?? data.beneficiary?.careLevel ?? '',
    };
  } catch (error) {
    console.error('할 일 상세 불러오기 실패:', error);
    detailError.value = '상세 정보를 불러오지 못했습니다.';
  } finally {
    detailLoading.value = false;
  }
};

// 할 일 완료/미완료 토글

const toggleTodo = async (todo) => {

  try {

    if (todo.checked) {

      await uncompleteTodo(todo.id);

    } else {

      await completeTodo(todo.id);

    }

    todo.checked = !todo.checked;

    if (selectedTodoDetail.value && selectedDetailId.value === todo.id) {
      selectedTodoDetail.value = {
        ...selectedTodoDetail.value,
        isCompleted: todo.checked,
      };
    }

  } catch (error) {

    console.error('할 일 상태 변경 실패:', error);

  }

};



// 할 일 삭제

const removeTodo = async (id) => {

  try {

    await deleteTodo(id);

    todos.value = todos.value.filter(todo => todo.id !== id);

  } catch (error) {

    console.error('할 일 삭제 실패:', error);

  }

};



onMounted(() => {

  loadTodos();

});

</script>



<template>
  <section class="todo-section">
    <div class="header-row">
      <h2 class="section-title">📋 오늘의 할일</h2>
      <button class="add-btn-small" @click="openAddModal">+ 할 일 추가</button>
    </div>

    <ul class="todo-list">
      <li v-if="loading" class="empty-state">
        할 일을 불러오는 중...
      </li>
      <li v-else-if="todos.length === 0" class="empty-state">
        할 일이 없습니다.
      </li>
      <li
        v-else
        v-for="todo in todos"
        :key="todo.id"
        :class="['todo-item', { 'has-detail': selectedDetailId === todo.id }]"
        @click="handleSelectTodo(todo)"
      >
        <div class="todo-main">
          <div class="todo-left">
            <input
              type="checkbox"
              :checked="todo.checked"
              @change.stop="toggleTodo(todo)"
              class="checkbox"
            />
            <div class="todo-content">
              <span :class="['todo-text', { 'completed': todo.checked }]">
                {{ todo.text }}
              </span>
              <div class="todo-meta">
                <span v-if="todo.type" class="type-badge">{{ todo.type }}</span>
              </div>
            </div>
          </div>
          <div class="todo-actions">
            <button class="icon-btn edit" @click.stop="openEditModal(todo)">✏️</button>
            <button class="icon-btn delete" @click.stop="removeTodo(todo.id)">🗑️</button>
          </div>
        </div>

        <div
          v-if="selectedTodoDetail && selectedDetailId === todo.id"
          class="detail-block"
        >
          <div class="detail-header">
            <h4 class="detail-title">상세 정보</h4>
          </div>
          <div v-if="detailLoading" class="detail-loading">상세 정보를 불러오는 중...</div>
          <div v-else-if="detailError" class="detail-error">{{ detailError }}</div>
          <div v-else class="detail-body">
            <div class="info-sections-grid">
              <!-- Basic Info Section -->
              <div class="info-section">
                <div class="section-title-small">할 일 정보</div>
                <div class="info-grid">
                  <div class="info-row">
                    <span class="label">내용</span>
                    <span class="value">{{ selectedTodoDetail.content || '-' }}</span>
                  </div>
                  <div class="info-row">
                    <span class="label">유형</span>
                    <span class="value">{{ selectedTodoDetail.type || '-' }}</span>
                  </div>
                  <div class="info-row">
                    <span class="label">상태</span>
                    <span :class="['value', 'status-badge', selectedTodoDetail.isCompleted ? 'status-done' : 'status-progress']">
                      {{ selectedTodoDetail.isCompleted ? '완료' : '진행중' }}
                    </span>
                  </div>
                </div>
              </div>

              <!-- Beneficiary Info Section -->
              <div class="info-section">
                <div class="section-title-small">수급자 정보</div>
                <div class="info-grid">
                  <div class="info-row">
                    <span class="label">수급자</span>
                    <span class="value">{{ selectedTodoDetail.beneficiaryName || '-' }}</span>
                  </div>
                  <div class="info-row">
                    <span class="label">등급</span>
                    <span class="value">{{ selectedTodoDetail.careLevel || '-' }}</span>
                  </div>
                  <div class="info-row">
                    <span class="label">주소</span>
                    <span class="value">{{ selectedTodoDetail.beneficiaryAddress || '-' }}</span>
                  </div>
                  <div class="info-row">
                    <span class="label">전화</span>
                    <span class="value">{{ selectedTodoDetail.beneficiaryPhone || '-' }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </li>
    </ul>

    <TodoModal
      ref="modalRef"
      :is-open="isModalOpen"
      :initial-todo="editingTodo"
      @close="closeModal"
      @add="handleAddTodo"
      @update="handleUpdateTodo"
    />
  </section>
</template>



<style scoped>
.todo-section {
  background-color: white;
  padding: 1.5rem;
  border-radius: 24px;
  border: 1px solid #d7f3dd;
  box-shadow: 0 4px 16px rgba(15, 23, 42, 0.05);
  margin-top: 1.5rem;
}

.header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.25rem;
}

.section-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: #388e3c;
  margin: 0;
}

.add-btn-small {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  color: white;
  border: none;
  padding: 0.625rem 1.25rem;
  border-radius: 12px;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 2px 8px rgba(34, 197, 94, 0.25);
}

.add-btn-small:hover {
  background: linear-gradient(135deg, #16a34a 0%, #15803d 100%);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.3);
}

.todo-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.todo-item {
  background: #ffffff;
  border: 2px solid #e5e7eb;
  border-radius: 14px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.2s ease;
}

.todo-item:hover {
  border-color: #22c55e;
  box-shadow: 0 2px 12px rgba(34, 197, 94, 0.1);
}

.todo-item.has-detail {
  border-color: #22c55e;
  background: #f9fafb;
}

.todo-main {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.25rem;
  background: white;
}

.todo-left {
  display: flex;
  align-items: flex-start;
  gap: 0.875rem;
  flex: 1;
}

.checkbox {
  width: 1.25rem;
  height: 1.25rem;
  margin-top: 0.125rem;
  accent-color: #22c55e;
  cursor: pointer;
  flex-shrink: 0;
}

.todo-content {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  flex: 1;
}

.todo-text {
  font-size: 1rem;
  font-weight: 500;
  color: #101828;
  line-height: 1.5;
}

.todo-text.completed {
  text-decoration: line-through;
  color: #9ca3af;
}

.todo-meta {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.type-badge {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  background: #dcfce7;
  color: #15803d;
  border: 1px solid rgba(21, 128, 61, 0.25);
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: 600;
}

.due-date {
  font-size: 0.8125rem;
  color: #6b7280;
  font-weight: 500;
}

.todo-actions {
  display: flex;
  gap: 0.375rem;
  flex-shrink: 0;
}

.icon-btn {
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  font-size: 1.125rem;
  cursor: pointer;
  padding: 0.5rem 0.625rem;
  border-radius: 8px;
  transition: all 0.2s ease;
  line-height: 1;
}

.icon-btn:hover {
  background-color: #f3f4f6;
  transform: scale(1.05);
}

.icon-btn.edit:hover {
  background-color: #dbeafe;
  border-color: #3b82f6;
}

.icon-btn.delete:hover {
  background-color: #fee2e2;
  border-color: #ef4444;
}

.detail-block {
  border-top: 2px solid #e5e7eb;
  background: #f9fafb;
}

.detail-header {
  padding: 1rem 1.25rem 0.75rem;
  background: #ecfdf1;
  border-bottom: 1px solid #d1fae5;
}

.detail-title {
  font-size: 1.0625rem;
  font-weight: 600;
  color: #388e3c;
  margin: 0;
}

.detail-loading {
  padding: 1.5rem 1.25rem;
  color: #6b7280;
  font-size: 0.9rem;
  text-align: center;
}

.detail-error {
  padding: 1.5rem 1.25rem;
  color: #b91c1c;
  font-size: 0.9rem;
  text-align: center;
}

.detail-body {
  padding: 1rem 1.25rem 1.25rem;
}

.info-sections-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

@media (max-width: 768px) {
  .info-sections-grid {
    grid-template-columns: 1fr;
  }
}

.info-section {
  background: white;
  border-radius: 12px;
  border: 2px solid #e5e7eb;
  padding: 1rem;
}

.section-title-small {
  font-size: 0.875rem;
  font-weight: 600;
  color: #4a5565;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #e5e7eb;
}

.info-grid {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem;
  font-size: 0.875rem;
  background: #f9fafb;
  border-radius: 8px;
  border: 1px solid #f3f4f6;
}

.info-row .label {
  color: #4a5565;
  font-weight: 600;
  flex-shrink: 0;
  min-width: 70px;
}

.info-row .value {
  color: #101828;
  font-weight: 500;
  text-align: right;
  word-break: break-word;
  flex: 1;
}

.status-badge {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: 600;
}

.status-done {
  background: #dcfce7;
  color: #16a34a;
  border: 1px solid rgba(22, 163, 74, 0.25);
}

.status-progress {
  background: #fef3c7;
  color: #d97706;
  border: 1px solid rgba(217, 119, 6, 0.25);
}

.empty-state {
  text-align: center;
  color: #9ca3af;
  padding: 2.5rem 1rem;
  font-size: 0.9375rem;
  background: #f9fafb;
  border: 2px dashed #e5e7eb;
  border-radius: 14px;
}
</style>





