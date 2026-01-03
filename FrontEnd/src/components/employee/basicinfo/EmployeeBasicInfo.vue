<script setup>
import { computed } from 'vue';

const props = defineProps({
  employee: { type: Object, required: true }
});

// ▼▼▼ [핵심] 총 경력 자동 계산 로직 ▼▼▼
const calculatedCareer = computed(() => {
  const histories = props.employee.workHistory || [];
  
  // 이력이 없으면 '신입'
  if (histories.length === 0) return '신입';

  let totalMonths = 0;

  histories.forEach(item => {
    // workPeriod 형식: "YYYY.MM - YYYY.MM"
    if (item.workPeriod) {
      const parts = item.workPeriod.split(' - ');
      
      if (parts.length === 2) {
        const [startStr, endStr] = parts;
        
        // "2020.01" -> [2020, 1]
        const [startYear, startMonth] = startStr.split('.').map(Number);
        
        // "현재"인 경우 처리 (현재 날짜 기준)
        let endYear, endMonth;
        if (endStr.includes('현재')) {
          const now = new Date();
          endYear = now.getFullYear();
          endMonth = now.getMonth() + 1;
        } else {
          [endYear, endMonth] = endStr.split('.').map(Number);
        }

        if (!isNaN(startYear) && !isNaN(endYear)) {
          const startDate = new Date(startYear, startMonth - 1);
          const endDate = new Date(endYear, endMonth - 1);

          // 월 차이 계산 + 1 (시작월 포함)
          const months = (endDate.getFullYear() - startDate.getFullYear()) * 12 + 
                         (endDate.getMonth() - startDate.getMonth()) + 1;

          if (months > 0) totalMonths += months;
        }
      }
    }
  });

  if (totalMonths === 0) return '1개월 미만';

  const years = Math.floor(totalMonths / 12);
  const months = totalMonths % 12;

  let result = '';
  if (years > 0) result += `${years}년 `;
  if (months > 0) result += `${months}개월`;
  
  return result.trim();
});
</script>

<template>
  <div class="info-layout">
    
    <div class="info-grid-row">
      <div class="info-col">
        <div class="field-group">
          <label>연락처</label>
          <div class="field-value flex-center">
            <svg class="icon-xs text-green" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
            {{ employee.phone }}
          </div>
        </div>
        <div class="field-group">
          <label>이메일</label>
          <div class="field-value flex-center">
            <svg class="icon-xs text-green" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect width="20" height="16" x="2" y="4" rx="2"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/></svg>
            {{ employee.email }}
          </div>
        </div>

        <div class="field-group">
          <label>생년월일</label>
          <div class="field-value flex-center">
            <svg class="icon-xs text-green" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect width="18" height="18" x="3" y="4" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            {{ employee.birth }}
          </div>
        </div>

        <div class="field-group">
          <label>성별</label>
          <div class="field-value flex-center">
            <svg class="icon-xs text-green" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            {{ employee.gender === 'M' ? '남성' : (employee.gender === 'F' ? '여성' : '미입력') }}
          </div>
        </div>

        <div class="field-group">
          <label>주소</label>
          <div class="field-value flex-center">
            <svg class="icon-xs text-green" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/></svg>
            {{ employee.address }}
          </div>
        </div>
      </div>

      <div class="info-col">
        <div class="field-group">
          <label>입사일</label>
          <div class="field-value">{{ employee.hireDate }}</div>
        </div>
        <div class="field-group">
          <label>비상연락처</label>
          <div class="field-value">{{ employee.emergencyNumber || employee.emergencyContact }}</div> 
          </div>
        <div class="field-group">
          <label>경력 연수</label>
          <div class="field-value font-bold text-blue">{{ calculatedCareer }}</div>
        </div>
      </div>
    </div>

    <div class="section-block">
      <h3 class="section-title">근무 이력</h3>
      <div class="history-list">
        <div v-for="(item, index) in employee.workHistory" :key="index" class="history-item">
          <span class="bullet">•</span> 
          <div class="history-content">
            <span class="company">{{ item.companyName }}</span>
            <span class="period">({{ item.workPeriod }})</span>
            <span class="task" v-if="item.task">- {{ item.task }}</span>
          </div>
        </div>
        <div v-if="!employee.workHistory || employee.workHistory.length === 0" class="text-gray-400 text-sm">
          등록된 근무 이력이 없습니다.
        </div>
      </div>
    </div>

    <div class="section-block">
      <h3 class="section-title">자격증</h3>
      <div class="tags">
        <span 
          v-for="(c, index) in (employee.certificates || [])" 
          :key="index" 
          class="tag tag-cert"
        >
          <svg class="icon-tiny" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="8" r="7"/><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"/></svg>
          
          {{ typeof c === 'object' ? (c.certificateName || c.name) : c }}
        </span>

        <span 
          v-if="!employee.certificates || employee.certificates.length === 0" 
          class="text-gray-400 text-sm"
        >
          등록된 자격증이 없습니다.
        </span>
      </div>
    </div>

    <div class="section-block">
      <h3 class="section-title">전문 분야</h3>
      <div class="tags">
        <span v-for="(s, index) in employee.specialties" :key="index" class="tag tag-spec">
          {{ typeof s === 'object' ? s.name : s }}
        </span>
        <span v-if="!employee.specialties || employee.specialties.length === 0" class="text-gray-400 text-sm">
          등록된 전문 분야가 없습니다.
        </span>
      </div>
    </div>

  </div>
</template>

<style scoped>
.info-layout { display: flex; flex-direction: column; gap: 24px; }

.info-grid-row { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; margin-bottom: 10px; }
.info-col { display: flex; flex-direction: column; gap: 20px; }

.field-group { display: flex; flex-direction: column; gap: 4px; }
.field-group label { font-size: 13px; color: #6b7280; font-weight: 500; }
.field-value { font-size: 15px; color: #1f2937; font-weight: 500; display: flex; align-items: center; gap: 6px; }

.section-block { margin-top: 8px; }
.section-title { font-size: 14px; color: #6b7280; margin: 0 0 10px 0; font-weight: 500; }

.history-list { display: flex; flex-direction: column; gap: 8px; }
.history-item { background-color: #f0fdf4; border: 1px solid #dcfce7; color: #166534; padding: 10px 16px; border-radius: 8px; font-size: 14px; display: flex; align-items: flex-start; gap: 8px; }
.history-content { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
.company { font-weight: 600; color: #333; }
.period { font-size: 13px; color: #666; }
.task { font-size: 13px; color: #888; }
.bullet { font-weight: bold; color: #22c55e; font-size: 18px; line-height: 1; margin-top: 2px; }

.tags { display: flex; gap: 8px; flex-wrap: wrap; }
.tag { font-size: 13px; padding: 6px 12px; border-radius: 8px; display: flex; align-items: center; gap: 4px; }
.tag-cert { background-color: #eff6ff; color: #2563eb; border: 1px solid #dbeafe; }
.tag-spec { background-color: #f0fdf4; color: #15803d; border: 1px solid #dcfce7; }

.icon-xs { width: 16px; height: 16px; }
.text-green { color: #16a34a; }
.text-blue { color: #2563eb; } /* 파란색 강조 */
.font-bold { font-weight: 700; }
.icon-tiny { width: 14px; height: 14px; }
.text-gray-400 { color: #9ca3af; font-size: 13px; }
</style>