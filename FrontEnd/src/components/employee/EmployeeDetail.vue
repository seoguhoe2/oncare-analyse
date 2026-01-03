<script setup>
import { ref } from 'vue';
import EmployeeScheduleCalendar from '@/components/employee/emplschedule/EmployeeScheduleCalendar.vue';
import EmployeeBasicInfo from '@/components/employee/basicinfo/EmployeeBasicInfo.vue'; 
import CertificatesAndEducations from '@/components/employee/qualifications/CertificatesAndEducations.vue';
import AssignedBeneficiaries from '@/components/employee/recipients/AssignedBeneficiaries.vue';
import BeneficiaryLogList from '@/components/employee/diary/BeneficiaryLogList.vue';

defineProps({
  employee: { type: Object, default: null }
});

const emit = defineEmits(['edit', 'refresh']);
const activeTab = ref('info');

const fetchEmployeeData = () => {
  emit('refresh');
};

const tabs = [
  { key: 'info', label: '기본정보' },
  { key: 'schedule', label: '일정' },
  { key: 'careLogs', label: '요양일지' },
  { key: 'recipients', label: '담당 수급자' },
  { key: 'cert', label: '자격증' }
];
</script>

<template>
  <div class="content-area">
    <div v-if="employee" class="card detail-card">
      
      <div class="detail-header">
        <div class="profile-area">
          <div>
            <h2>{{ employee.name }} <span class="role-badge">{{ employee.role }}</span></h2>
          </div>
        </div>
        <button @click="$emit('edit')" class="btn btn-outline">
          수정
        </button>
      </div>

      <div class="tabs">
        <button v-for="tab in tabs" :key="tab.key" @click="activeTab = tab.key" class="tab-btn" :class="{ 'active': activeTab === tab.key }">
          {{ tab.label }}
        </button>
      </div>

      <div class="tab-content">
        
        <div v-if="activeTab === 'info'">
          <EmployeeBasicInfo :employee="employee" />
        </div>

        <div v-else-if="activeTab === 'schedule'" class="schedule-view-full">
          <EmployeeScheduleCalendar :schedules="employee.schedules || []" />
        </div>

        <div v-else-if="activeTab === 'careLogs'">
          <BeneficiaryLogList :employeeId="employee.id" />
        </div>

        <div v-else-if="activeTab === 'recipients'">
          <AssignedBeneficiaries :employeeId="employee.id" />
        </div>

        <div v-else-if="activeTab === 'cert'">
          <CertificatesAndEducations 
            :employeeId="employee.id" 
            :certificates="employee.certificates || []" 
            @refresh="fetchEmployeeData" 
          />
        </div>

      </div>
    </div>

    <div v-else class="card empty-state">
      <p>직원을 선택해주세요</p>
    </div>
  </div>
</template>

<style scoped>
/* 스타일은 기존과 동일 */
.content-area { height: 100%; }
.card { width: 100%; background: white; border: 1px solid #e5e7eb; border-radius: 12px; overflow: hidden; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
.detail-card { height: 100%; display: flex; flex-direction: column; min-height: 500px; }
.empty-state { display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; min-height: 500px; color: #9ca3af; font-size: 16px; font-weight: bold; }

.detail-header { padding: 24px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; }
.profile-area h2 { margin: 0; font-size: 24px; color: #111; font-weight: bold; display: flex; align-items: center; gap: 8px; }
.role-badge { font-size: 13px; background: #f3f4f6; padding: 3px 10px; border-radius: 16px; font-weight: 500; color: #555; vertical-align: middle; }

.tabs { display: flex; padding: 0 24px; border-bottom: 1px solid #f0f0f0; overflow-x: auto; }
.tab-btn { flex: 1; width: 100%; text-align: center; justify-content: center; display: flex; align-items: center; gap: 6px; padding: 12px 16px; background: none; border: none; border-bottom: 2px solid transparent; cursor: pointer; color: #666; font-weight: 500; font-size: 14px; white-space: nowrap; }
.tab-btn.active { color: #059669; border-bottom-color: #059669; font-weight: bold; }

.tab-content { padding: 24px; flex: 1; overflow-y: auto; background-color: #fff; }

.icon-sm { width: 16px; height: 16px; color: #666; }
.icon-lg { width: 48px; height: 48px; color: #ddd; margin-bottom: 10px; }
.btn-outline { background-color: white; border: 1px solid #ddd; color: #555; padding: 8px 16px; border-radius: 6px; cursor: pointer; display: flex; align-items: center; gap: 6px; font-size: 14px; }
.btn-outline:hover { background-color: #f9fafb; }
.empty-view { text-align: center; padding: 40px; color: #999; }
.schedule-view-full { height: 100%; display: flex; flex-direction: column; }
</style>
