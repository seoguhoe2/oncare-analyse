import api from '@/lib/api';

/**
 * 할 일(TODO) API
 */

// 1. 할 일 등록
export const createTodo = async (data) => {
  const res = await api.post('/api/todos', data);
  return res.data;
};

// 2. 할 일 수정
export const updateTodo = async (todoId, data) => {
  if (!todoId) throw new Error('todoId is required');

  const res = await api.patch(`/api/todos/${todoId}`, data);
  return res.data;
};

// 3. 할 일 완료 체크
export const completeTodo = async (todoId) => {
  if (!todoId) throw new Error('todoId is required');

  const res = await api.patch(`/api/todos/${todoId}/complete`);
  return res.data;
};

// 4. 할 일 완료 취소
export const uncompleteTodo = async (todoId) => {
  if (!todoId) throw new Error('todoId is required');

  const res = await api.patch(`/api/todos/${todoId}/uncomplete`);
  return res.data;
};

// 5. 할 일 삭제
export const deleteTodo = async (todoId) => {
  if (!todoId) throw new Error('todoId is required');

  const res = await api.delete(`/api/todos/${todoId}`);
  return res.data;
};
