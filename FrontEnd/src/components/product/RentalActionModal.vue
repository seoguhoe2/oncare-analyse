<template>
  <div class="modal-backdrop" @click.self="$emit('close')">
    <div class="modal-container">
      <div class="modal-header">
        <h3 class="title">계약 관리 ({{ contract?.beneficiary }} 님)</h3>
        <button class="close-btn" @click="$emit('close')">×</button>
      </div>

      <div class="modal-body">
        <div class="info-box">
          <p><strong>현재 상태:</strong> {{ contract?.statusName }}</p>
          <p><strong>계약 기간:</strong> {{ contract?.startDate }} ~ {{ contract?.endDate || '미정' }}</p>
        </div>

        <div class="action-buttons">
          <button 
            v-if="contract?.statusName === '접수'" 
            @click="selectedAction = 'START_DATE'" 
            :class="{ active: selectedAction === 'START_DATE' }"
          >
            시작일 변경
          </button>

          <button 
            v-if="contract?.statusName === '접수'" 
            @click="handleDelete" 
            class="btn-danger"
          >
            계약 삭제
          </button>

          <button 
            v-if="contract?.statusName === '유지'" 
            @click="selectedAction = 'EXTEND'" 
            :class="{ active: selectedAction === 'EXTEND' }"
          >
            만료일 연장
          </button>

          <button 
            v-if="contract?.statusName === '유지'" 
            @click="selectedAction = 'TERMINATE'" 
            :class="{ active: selectedAction === 'TERMINATE' }"
            class="btn-danger"
          >
            계약 종료
          </button>

          <button 
            v-if="contract?.statusName === '취소'" 
            @click="handleRestore" 
            class="btn-restore"
          >
            계약 취소 철회
          </button>
        </div>

        <div class="action-form" v-if="selectedAction">
          <hr />
          
          <div v-if="selectedAction === 'EXTEND'">
            <h4>만료일 연장</h4>
            <div class="input-group">
              <label>변경할 만료일</label>
              <input type="date" v-model="form.expectedDate" :min="today" />
            </div>
            <p class="desc">계약 기간을 연장합니다.</p>
          </div>

          <div v-if="selectedAction === 'START_DATE'">
            <h4>시작일 변경</h4>
            <div class="input-group">
              <label>변경할 시작일</label>
              <input type="date" v-model="form.wantedDate" />
            </div>
            <p class="desc">아직 시작되지 않은 계약의 시작일을 변경합니다.</p>
          </div>

          <div v-if="selectedAction === 'TERMINATE'">
            <h4>계약 종료 처리</h4>
            <div class="input-group">
              <label>종료일 (반납일)</label>
              <input type="date" v-model="form.endDate" :max="today" />
            </div>
            <p class="desc warning">계약을 조기 종료하거나 만료 처리합니다.</p>
          </div>
        </div>
      </div>

      <div class="modal-footer">
        <button class="cancel-btn" @click="$emit('close')">닫기</button>
        <button 
          v-if="selectedAction" 
          class="save-btn" 
          @click="handleSubmit"
        >
          저장
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue';
import api from '@/lib/api'; 

const props = defineProps({
  contract: Object
});

const emit = defineEmits(['close', 'refresh']);

const selectedAction = ref(null);
const form = reactive({
  expectedDate: '',
  wantedDate: '',
  endDate: new Date().toISOString().split('T')[0]
});

const today = new Date().toISOString().split('T')[0];

// [추가] 계약 삭제 핸들러 (즉시 실행)
const handleDelete = async () => {
  if (!confirm('정말 계약을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) return;

  try {
    // 삭제 API 호출 (REST 표준에 따라 ID를 경로에 포함)
    // 만약 백엔드가 쿼리 파라미터를 원하면: api.delete(`/rental/contract`, { params: { id: props.contract.id } })
    await api.delete(`/rental/contract/${props.contract.id}`);
    
    alert('삭제되었습니다.');
    emit('refresh');
    emit('close');
  } catch (error) {
    console.error(error);
    alert('삭제 중 오류가 발생했습니다.');
  }
};

// 기존 로직들
const extendContract = async () => {
  await api.patch('/rental/contract', {
    id: props.contract.id,
    expectedDate: form.expectedDate
  });
};

const changeStartDate = async () => {
  await api.patch('/rental/contract', {
    id: props.contract.id,
    wantedDate: form.wantedDate
  });
};

const terminateContract = async () => {
  await api.patch('/rental/contract/termination', {
    id: props.contract.id,
    contractStatusCd: 3, 
    endDate: form.endDate
  });
};

const handleRestore = async () => {
  if (!confirm('정말 취소를 철회하시겠습니까?')) return;
  try {
    await api.patch('/rental/contract', {
      id: props.contract.id,
      contractStatusCd: 2 
    });
    alert('철회되었습니다.');
    emit('refresh');
    emit('close');
  } catch (e) {
    alert('처리 중 오류가 발생했습니다.');
  }
};

const handleSubmit = async () => {
  try {
    if (selectedAction.value === 'EXTEND') await extendContract();
    else if (selectedAction.value === 'START_DATE') await changeStartDate();
    else if (selectedAction.value === 'TERMINATE') await terminateContract();
    
    alert('처리되었습니다.');
    emit('refresh');
    emit('close');
  } catch (error) {
    console.error(error);
    alert('오류가 발생했습니다. 입력을 확인해주세요.');
  }
};
</script>

<style scoped>
/* 기존 스타일 유지 */
.modal-backdrop {
  position: fixed; top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 1000;
}
.modal-container {
  background: white; width: 450px; border-radius: 12px; padding: 20px;
  box-shadow: 0 4px 10px rgba(0,0,0,0.1);
}
.modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
.title { margin: 0; font-size: 18px; }
.close-btn { border: none; background: none; font-size: 20px; cursor: pointer; }

.info-box { background: #f9fafb; padding: 12px; border-radius: 8px; margin-bottom: 20px; font-size: 14px; }
.info-box p { margin: 4px 0; }

.action-buttons { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 20px; }
.action-buttons button {
  padding: 8px 12px; border: 1px solid #d1d5db; background: white; border-radius: 6px; cursor: pointer;
  transition: all 0.2s;
}
.action-buttons button:hover { background-color: #f9fafb; }

.action-buttons button.active { background: #eff6ff; border-color: #3b82f6; color: #1d4ed8; font-weight: 600; }

/* 위험(삭제/종료) 버튼 스타일 */
.action-buttons .btn-danger { color: #b91c1c; border-color: #fca5a5; }
.action-buttons .btn-danger:hover { background-color: #fef2f2; }
.action-buttons .btn-danger.active { background: #fee2e2; border-color: #ef4444; }

.action-buttons .btn-restore { color: #047857; border-color: #6ee7b7; }

.action-form h4 { margin: 0 0 10px 0; font-size: 15px; }
.input-group { display: flex; flex-direction: column; gap: 6px; margin-bottom: 8px; }
.input-group input { padding: 8px; border: 1px solid #d1d5db; border-radius: 6px; }
.desc { font-size: 12px; color: #6b7280; }
.warning { color: #dc2626; }

.modal-footer { display: flex; justify-content: flex-end; gap: 8px; margin-top: 20px; }
.cancel-btn { padding: 8px 16px; background: white; border: 1px solid #d1d5db; border-radius: 6px; cursor: pointer; }
.save-btn { padding: 8px 16px; background: #16a34a; color: white; border: none; border-radius: 6px; cursor: pointer; }
</style>