<script setup>
import { ref, computed } from 'vue';

const props = defineProps({
  isOpen: Boolean,
  certifications: { type: Array, default: () => [] }
});

const emit = defineEmits(['close', 'approve', 'reject']);

const activeTab = ref('대기중');
const selectedCert = ref(null);
const rejectReason = ref('');

const filteredList = computed(() => {
  return props.certifications.filter(c => c.status === activeTab.value);
});

const getCount = (status) => props.certifications.filter(c => c.status === status).length;

const handleApprove = (id) => emit('approve', id);
const handleReject = (id) => emit('reject', id);
</script>

<template>
  <div v-if="isOpen" class="modal-overlay">
    <div class="modal-box">
      <div class="modal-header">
        <h3 class="header-title">자격증 승인 관리</h3>
        <button @click="$emit('close')" class="close-btn">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
        </button>
      </div>

      <div class="modal-body">
        <div class="title-row">
          <svg class="icon-purple" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="8" r="7"/><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"/></svg>
          <span class="main-title">승인 대기 중인 자격증</span>
          <span class="count-badge">{{ getCount('대기중') }}건</span>
        </div>

        <div class="tabs">
          <button 
            v-for="tab in ['대기중', '승인', '반려']" 
            :key="tab"
            @click="activeTab = tab"
            class="tab-btn"
            :class="{ 'active': activeTab === tab }"
          >
            {{ tab }} ({{ getCount(tab) }})
          </button>
        </div>

        <div class="list-container custom-scrollbar">
          <div v-for="cert in filteredList" :key="cert.id" class="cert-card">
            <div class="card-header">
              <div class="profile-group">
                <div class="avatar-purple">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="8" r="7"/><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"/></svg>
                </div>
                <div>
                  <div class="name-row">
                    <h4 class="cert-name">{{ cert.name }}</h4>
                    <span class="status-badge">{{ cert.status }}</span>
                  </div>
                  <p class="emp-name">{{ cert.employeeName }}</p>
                  <p class="date-text">신청일: {{ cert.requestDate }}</p>
                </div>
              </div>
            </div>

            <div class="info-box">
              <div class="info-row"><span class="label">자격증 번호:</span> <span class="val">{{ cert.number }}</span></div>
              <div class="info-row"><span class="label">발급일:</span> <span class="val">{{ cert.issueDate }}</span></div>
              <div class="info-row"><span class="label">발급기관:</span> <span class="val">{{ cert.issuer }}</span></div>
              <div class="info-row"><span class="label">첨부파일:</span> <span class="val link">{{ cert.fileName }}</span></div>
            </div>

            <div v-if="activeTab === '대기중'" class="action-buttons">
              <button @click="handleApprove(cert.id)" class="btn-approve">승인</button>
              <button @click="handleReject(cert.id)" class="btn-reject">반려</button>
            </div>
          </div>
          
          <div v-if="filteredList.length === 0" class="empty-msg">
            해당 상태의 내역이 없습니다.
          </div>
        </div>
      </div>

      <div class="modal-footer">
        <button @click="$emit('close')" class="btn-close">닫기</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 50; }
.modal-box { background: white; width: 500px; border-radius: 12px; overflow: hidden; box-shadow: 0 10px 25px rgba(0,0,0,0.1); max-height: 90vh; display: flex; flex-direction: column; }
.modal-header { padding: 16px 20px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; }
.header-title { font-size: 18px; font-weight: 700; color: #166534; margin: 0; }
.close-btn { background: none; border: none; cursor: pointer; color: #9ca3af; }
.close-btn:hover { color: #4b5563; }

.modal-body { padding: 20px; overflow-y: auto; flex: 1; }
.modal-footer { padding: 16px 20px; border-top: 1px solid #f0f0f0; display: flex; justify-content: flex-end; background: #fff; }

/* 타이틀 & 뱃지 */
.title-row { display: flex; align-items: center; gap: 8px; margin-bottom: 16px; }
.icon-purple { color: #9333ea; }
.main-title { font-weight: 700; color: #1f2937; }
.count-badge { padding: 2px 8px; background-color: #f3e8ff; color: #9333ea; font-size: 12px; font-weight: 700; border-radius: 9999px; }

/* 탭 */
.tabs { display: flex; border-bottom: 1px solid #e5e7eb; margin-bottom: 16px; }
.tab-btn { padding: 8px 16px; font-size: 14px; font-weight: 500; border-bottom: 2px solid transparent; background: none; border: none; color: #6b7280; cursor: pointer; transition: all 0.2s; }
.tab-btn:hover { color: #374151; }
.tab-btn.active { border-bottom: 2px solid #9333ea; color: #7e22ce; font-weight: 700; }

/* 리스트 */
.list-container { display: flex; flex-direction: column; gap: 16px; padding-right: 4px; max-height: 500px; overflow-y: auto; }
.cert-card { border: 1px solid #e5e7eb; border-radius: 12px; padding: 20px; background: white; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }

/* 카드 내부 */
.card-header { display: flex; justify-content: space-between; align-items: start; margin-bottom: 16px; }
.profile-group { display: flex; gap: 12px; }
.avatar-purple { width: 40px; height: 40px; border-radius: 50%; background-color: #f3e8ff; display: flex; align-items: center; justify-content: center; color: #9333ea; flex-shrink: 0; }
.name-row { display: flex; align-items: center; gap: 8px; }
.cert-name { font-weight: 700; color: #111827; margin: 0; font-size: 16px; }
.status-badge { font-size: 12px; padding: 2px 8px; background-color: #ffedd5; color: #c2410c; border-radius: 4px; font-weight: 500; }
.emp-name { font-size: 14px; color: #4b5563; margin: 2px 0 0 0; }
.date-text { font-size: 12px; color: #9ca3af; margin-top: 4px; }

.info-box { background-color: #f9fafb; border-radius: 8px; padding: 16px; font-size: 14px; margin-bottom: 16px; display: flex; flex-direction: column; gap: 8px; }
.info-row { display: flex; justify-content: space-between; }
.label { color: #6b7280; }
.val { color: #1f2937; }
.val.link { color: #3b82f6; cursor: pointer; }
.val.link:hover { text-decoration: underline; }

/* 버튼 */
.action-buttons { display: flex; gap: 8px; }
.btn-approve { flex: 1; padding: 10px; background-color: #22c55e; color: white; border-radius: 8px; font-size: 14px; font-weight: 700; border: none; cursor: pointer; }
.btn-approve:hover { background-color: #16a34a; }
.btn-reject { flex: 1; padding: 10px; background-color: #ef4444; color: white; border-radius: 8px; font-size: 14px; font-weight: 700; border: none; cursor: pointer; }
.btn-reject:hover { background-color: #dc2626; }
.btn-close { padding: 8px 16px; background-color: #6b7280; color: white; border-radius: 8px; font-size: 14px; border: none; cursor: pointer; }
.btn-close:hover { background-color: #4b5563; }

.empty-msg { text-align: center; padding: 40px 0; color: #9ca3af; font-size: 14px; }
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 2px; }
</style>