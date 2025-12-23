<script setup>
import { ref, computed } from 'vue';

const props = defineProps({
  employees: { type: Array, required: true },
  selectedId: { type: Number, default: null }
});

const emit = defineEmits(['select']);

const searchTerm = ref('');
const filterRole = ref('');
const filterStatus = ref('');
const filterCert = ref('');
const currentPage = ref(1);

// 페이징 처리 부분
const itemsPerPage = 8;

const filteredEmployees = computed(() => {
  return props.employees.filter(emp => {
    const matchesSearch = emp.name.includes(searchTerm.value) || emp.phone.includes(searchTerm.value);
    const matchesRole = !filterRole.value || emp.role === filterRole.value;
    const matchesStatus = !filterStatus.value || emp.status === filterStatus.value;
    const matchesCert = !filterCert.value || (emp.certifications && emp.certifications.includes(filterCert.value));
    
    return matchesSearch && matchesRole && matchesStatus && matchesCert;
  });
});

const totalPages = computed(() => Math.ceil(filteredEmployees.value.length / itemsPerPage));
const paginatedEmployees = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  const end = start + itemsPerPage;
  return filteredEmployees.value.slice(start, end);
});

const selectEmployee = (emp) => emit('select', emp);

const getStatusClass = (status) => {
  if (status === '활동중') return 'status-active';
  if (status === '휴가') return 'status-vacation';
  return 'status-inactive';
};
</script>

<template>
  <div class="sidebar card">
    <div class="filter-area">
      <div class="search-box">
        <svg class="search-icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
        <input v-model="searchTerm" type="text" placeholder="이름, 전화번호 검색" />
      </div>

      <select v-model="filterRole" class="dropdown">
        <option value="">전체 직군</option>
        <option value="센터장">센터장</option>
        <option value="요양보호사">요양보호사</option>
      </select>

      <select v-model="filterStatus" class="dropdown">
        <option value="">전체 상태</option>
        <option value="활동중">활동중</option>
        <option value="휴가">휴가</option>
        <option value="휴직">휴직</option>
      </select>

      <select v-model="filterCert" class="dropdown">
        <option value="">전체 자격증</option>
        <option value="요양보호사">요양보호사</option>
        <option value="사회복지사 1급">사회복지사 1급</option>
        <option value="간호조무사">간호조무사</option>
      </select>
    </div>

    <div class="employee-list">
      <div 
        v-for="employee in paginatedEmployees" 
        :key="employee.id"
        @click="selectEmployee(employee)"
        class="employee-item"
        :class="{ 'selected': selectedId === employee.id }"
      >
        <div class="item-header">
          <div class="name-area">
            <span class="name">{{ employee.name }}</span>
            <span class="badge" :class="getStatusClass(employee.status)">{{ employee.status }}</span>
          </div>
          <span class="role">{{ employee.role }}</span>
        </div>
        <div class="phone">
          <svg class="icon-sm" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
          {{ employee.phone }}
        </div>
      </div>
      <div v-if="paginatedEmployees.length === 0" class="empty-list">검색 결과가 없습니다.</div>
    </div>

    <div class="pagination">
      <button @click="currentPage = Math.max(1, currentPage - 1)" :disabled="currentPage === 1">
        <svg class="icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m15 18-6-6 6-6"/></svg>
      </button>
      <span>{{ currentPage }} / {{ totalPages }}</span>
      <button @click="currentPage = Math.min(totalPages, currentPage + 1)" :disabled="currentPage === totalPages">
        <svg class="icon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>
      </button>
    </div>
  </div>
</template>

<style scoped>
.card { background: white; border: 1px solid #e5e7eb; border-radius: 12px; overflow: hidden; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
.sidebar { display: flex; flex-direction: column; height: 100%; min-height: 500px; }
.filter-area { padding: 16px; border-bottom: 1px solid #f0f0f0; display: flex; flex-direction: column; gap: 10px; }
.search-box { position: relative; }
.search-icon { position: absolute; left: 10px; top: 10px; width: 16px; color: #999; }
.search-box input { width: 100%; padding: 8px 8px 8px 36px; border: 1px solid #ddd; border-radius: 6px; outline: none; }
.dropdown { padding: 8px; border: 1px solid #ddd; border-radius: 6px; width: 100%; }
.employee-list { flex: 1; overflow-y: auto; padding: 8px; }
.employee-item { padding: 12px; border: 1px solid #f0f0f0; border-radius: 8px; margin-bottom: 8px; cursor: pointer; transition: 0.2s; }
.employee-item:hover { background-color: #f9fafb; }
.employee-item.selected { background-color: #ecfdf5; border-color: #34d399; }
.item-header { display: flex; justify-content: space-between; margin-bottom: 4px; }
.name { font-weight: bold; font-size: 15px; }
.role { font-size: 12px; color: #888; }
.phone { font-size: 12px; color: #666; display: flex; align-items: center; gap: 4px; }
.badge { font-size: 10px; padding: 2px 6px; border-radius: 4px; margin-left: 6px; }
.status-active { background: #d1fae5; color: #065f46; }
.status-vacation { background: #fef3c7; color: #92400e; }
.status-inactive { background: #f3f4f6; color: #666; }
.pagination { padding: 10px; border-top: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; background: #f9fafb; }
.pagination button { background: none; border: none; cursor: pointer; padding: 4px; border-radius: 4px; display: flex; align-items: center; justify-content: center; }
.pagination button:hover { background-color: #e5e7eb; }
.pagination button:disabled { opacity: 0.3; cursor: not-allowed; }
.icon { width: 18px; height: 18px; }
.icon-sm { width: 14px; height: 14px; }
.empty-list { text-align: center; padding: 20px; color: #999; font-size: 13px; }
</style>