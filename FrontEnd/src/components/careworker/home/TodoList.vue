<script setup>
import { ref } from 'vue';
import { initialTodos } from '@/mock/careworker/homeData';
import TodoModal from './TodoModal.vue'; 

const todos = ref([...initialTodos]);
const isModalOpen = ref(false);

const handleAddTodo = ({ content, type }) => {
  todos.value.unshift({
    id: Date.now(),
    text: `${content} ${type ? '(' + type + ')' : ''}`,
    checked: false
  });
  isModalOpen.value = false;
};

const removeTodo = (id) => {
  todos.value = todos.value.filter(todo => todo.id !== id);
};

// 수정 기능은 간단히 prompt로 구현하거나 모달 재사용 가능 (여기선 생략)
</script>

<template>
  <section class="todo-section">
    <div class="header-row">
      <h2 class="section-title">☑️ 할 일 목록</h2>
      <button class="add-btn-small" @click="isModalOpen = true">+ 할 일 추가</button>
    </div>
    
    <ul class="todo-list">
      <li v-for="todo in todos" :key="todo.id" class="todo-item">
        <div class="todo-left">
          <input type="checkbox" v-model="todo.checked" class="checkbox" />
          <span :class="['todo-text', { 'completed': todo.checked }]">
            {{ todo.text }}
          </span>
        </div>
        <div class="todo-actions">
          <button class="icon-btn edit">✏️</button>
          <button class="icon-btn delete" @click="removeTodo(todo.id)">🗑️</button>
        </div>
      </li>
      <li v-if="todos.length === 0" class="empty-state">
        할 일이 없습니다.
      </li>
    </ul>

    <TodoModal 
      :is-open="isModalOpen" 
      @close="isModalOpen = false" 
      @add="handleAddTodo" 
    />
  </section>
</template>

<style scoped>
.todo-section {
  background-color: white;
  padding: 1.5rem;
  border-radius: 0.75rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  margin-top: 1.5rem;
}

.header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.section-title {
  font-size: 1.125rem;
  font-weight: 800;
  color: #1f2937;
  margin: 0;
}

.add-btn-small {
  background-color: #22c55e;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
}

.add-btn-small:hover {
  background-color: #16a34a;
}

.todo-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.todo-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 1rem;
  background-color: #f9fafb;
  border: 1px solid #f3f4f6;
  border-radius: 0.5rem;
}

.todo-left {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.checkbox {
  width: 1.1rem;
  height: 1.1rem;
  accent-color: #16a34a;
  cursor: pointer;
}

.todo-text {
  font-size: 0.95rem;
  color: #374151;
}

.todo-text.completed {
  text-decoration: line-through;
  color: #9ca3af;
}

.todo-actions {
  display: flex;
  gap: 0.5rem;
}

.icon-btn {
  background: none;
  border: none;
  font-size: 1rem;
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 0.25rem;
}

.icon-btn:hover {
  background-color: #e5e7eb;
}

.edit { color: #3b82f6; }
.delete { color: #ef4444; }

.empty-state {
  text-align: center;
  color: #9ca3af;
  padding: 1rem;
  font-size: 0.875rem;
}
</style>