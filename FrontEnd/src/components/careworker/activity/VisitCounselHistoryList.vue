<script setup>
import { defineProps, ref } from 'vue';
import { Icon } from '@iconify/vue';

const props = defineProps({
  items: {
    type: Array,
    default: () => []
  }
});

// 상세 모달 상태
const showModal = ref(false);
const selectedItem = ref(null);

const openDetail = async (item) => {
  // 이미 상세 정보가 로드되지 않았다면 로드
  if (!item.detailsLoaded) {
    try {
      const { getCounselingLogDetail } = await import('@/api/careworker/counselingLogApi');
      const detailResponse = await getCounselingLogDetail(item.counselingId);
      const detailData = detailResponse?.data ?? detailResponse;

      item.visitPurpose = detailData.visitPurpose || '정보 없음';
      item.observedCondition = detailData.attendees || '정보 없음'; // attendees 필드가 관찰내용인지는 확인 필요하지만 기존 코드 따름
      item.subjectiveNeeds = detailData.discussionContent || '정보 없음';
      item.counselorNotes = detailData.agreementContent || '정보 없음';
      item.nextVisit = detailData.nextVisitDate ? detailData.nextVisitDate.split('T')[0] : '-';
      
      if (detailData.guardianSignUrl) {
        item.guardianSignUrl = detailData.guardianSignUrl;
        item.recipientSigned = true;
      }
      if (detailData.counselorSignUrl) {
        item.counselorSignUrl = detailData.counselorSignUrl;
        item.caregiverSigned = true;
      }
      
      item.detailsLoaded = true;
    } catch (error) {
      console.error('상세 정보 조회 실패:', error);
      alert('상세 정보를 불러올 수 없습니다.');
      return;
    }
  }
  
  selectedItem.value = item;
  showModal.value = true;
};

const closeModal = () => {
  showModal.value = false;
  selectedItem.value = null;
};
</script>

<template>
  <div class="counsel-history-list">
    <!-- 헤더 (선택 사항, 필요 없으면 제거) -->
    <!-- <div class="list-header">
      <span>수급자</span>
      <span>방문일자</span>
      <span>유형/만족도</span>
      <span>상태</span>
    </div> -->

    <div 
      v-for="item in items" 
      :key="item.id" 
      class="list-row"
      @click="openDetail(item)"
    >
      <div class="row-left">
        <span class="recipient-name">{{ item.recipientName }}</span>
      </div>
      
      <div class="row-center">
        <span class="visit-date">{{ item.date }}</span>
      </div>

      <div class="row-right">
        <span class="badge type">{{ item.counselType }}</span>
        <span class="satisfaction-text" :class="{'good': item.reaction.includes('만족'), 'bad': item.reaction.includes('불만')}">
          {{ item.reaction }}
        </span>
        <span 
          class="status-badge" 
          :class="{ completed: (item.status === '완료'), draft: (item.status === '임시저장') }"
        >
          {{ item.status }}
        </span>
        <span class="arrow-icon"><Icon icon="line-md:chevron-right" width="20" height="20" /></span>
      </div>
    </div>
    
    <div v-if="items.length === 0" class="empty-text">
      등록된 상담 내역이 없습니다.
    </div>

    <!-- 상세 모달 -->
    <div v-if="showModal && selectedItem" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>방문상담 상세정보</h3>
          <button class="close-btn" @click="closeModal">×</button>
        </div>
        
        <div class="modal-body">
          <div class="detail-header-info">
            <div class="info-group">
              <span class="label">수급자</span>
              <span class="value">{{ selectedItem.recipientName }}</span>
            </div>
            <div class="info-group">
              <span class="label">방문일</span>
              <span class="value">{{ selectedItem.date }}</span>
            </div>
            <div class="info-group">
              <span class="label">유형</span>
              <span class="value">{{ selectedItem.counselType }}</span>
            </div>
          </div>

          <div class="section-box">
            <h4 class="section-title">방문 목적</h4>
            <p class="section-content">{{ selectedItem.visitPurpose }}</p>
          </div>

          <div class="section-box">
            <h4 class="section-title">관찰 내용</h4>
            <p class="section-content">{{ selectedItem.observedCondition }}</p>
          </div>

          <div class="section-box highlight">
            <h4 class="section-title">주요 요구사항</h4>
            <p class="section-content">{{ selectedItem.subjectiveNeeds }}</p>
          </div>

          <div class="section-box success">
            <h4 class="section-title">조치 및 상담 내용</h4>
            <p class="section-content">{{ selectedItem.counselorNotes }}</p>
          </div>

          <div class="next-visit">
            <span class="calendar-icon"><Icon icon="line-md:calendar" width="20" height="20" /></span>
            <span class="next-visit-label">다음 방문 예정:</span>
            <span class="next-visit-date">{{ selectedItem.nextVisit }}</span>
          </div>

          <!-- 서명 이미지 섹션 -->
          <div class="signature-section-view">
            <div class="signature-item">
              <span class="sig-label">수급자(보호자) 서명</span>
              <div class="sig-image-box">
                <img v-if="selectedItem.guardianSignUrl" :src="selectedItem.guardianSignUrl" alt="수급자 서명" class="sig-img" />
                <span v-else class="no-sig">미서명</span>
              </div>
            </div>
            <div class="signature-item">
              <span class="sig-label">요양보호사 서명</span>
              <div class="sig-image-box">
                <img v-if="selectedItem.counselorSignUrl" :src="selectedItem.counselorSignUrl" alt="요양보호사 서명" class="sig-img" />
                <span v-else class="no-sig">미서명</span>
              </div>
            </div>
          </div>
        </div>
        
        <div class="modal-footer">
          <button class="btn-confirm" @click="closeModal">확인</button>
        </div>
      </div>
    </div>

  </div>
</template>

<style scoped>
.counsel-history-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.list-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 16px 20px;
  cursor: pointer;
  transition: all 0.2s ease;
}
.list-row:hover {
  border-color: #22c55e;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

.row-left { flex: 1; font-weight: 700; color: #111; font-size: 16px; }
.row-center { flex: 2; text-align: center; font-weight: 600; color: #374151; }
.row-right { flex: 2; display: flex; align-items: center; justify-content: flex-end; gap: 12px; }

.badge {
  padding: 4px 8px;
  border-radius: 6px;
  background: #f3f4f6;
  color: #4b5563;
  font-size: 13px;
  font-weight: 600;
}
.satisfaction-text {
  font-size: 13px;
  font-weight: 700;
  color: #10b981; /* Default Green for '보통'/'만족' */
}
.satisfaction-text.bad { color: #ef4444; }

.status-badge {
  padding: 4px 10px;
  border-radius: 99px;
  font-size: 12px;
  font-weight: 600;
  background: #dcfce7;
  color: #16a34a;
}
.status-badge.draft {
  background: #fef3c7;
  color: #d97706;
}

.arrow-icon { color: #d1d5db; font-size: 18px; margin-left: 4px; }

.empty-text { text-align: center; color: #999; padding: 40px; }

/* Modal Styles */
.modal-overlay {
  position: fixed; top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(0,0,0,0.5); z-index: 1000;
  display: flex; justify-content: center; align-items: center;
  backdrop-filter: blur(4px);
}
.modal-content {
  background: white; width: 90%; max-width: 600px;
  max-height: 90vh; border-radius: 16px;
  display: flex; flex-direction: column;
  overflow: hidden;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}
.modal-header {
  padding: 20px 24px; border-bottom: 1px solid #e5e7eb;
  display: flex; justify-content: space-between; align-items: center;
}
.modal-header h3 { margin: 0; font-size: 18px; font-weight: 700; }
.close-btn { background: none; border: none; font-size: 24px; cursor: pointer; color: #999; }

.modal-body { padding: 24px; overflow-y: auto; background: #f9fafb; }

.detail-header-info {
  display: flex; gap: 20px; margin-bottom: 24px;
  background: white; padding: 16px; border-radius: 8px; border: 1px solid #eee;
}
.info-group { display: flex; flex-direction: column; gap: 4px; }
.info-group .label { font-size: 12px; color: #666; }
.info-group .value { font-weight: 600; color: #111; }

.section-box {
  background: white; border: 1px solid #e5e7eb;
  border-radius: 8px; padding: 16px; margin-bottom: 12px;
}
.section-box.highlight { border-left: 4px solid #3b82f6; }
.section-box.success { border-left: 4px solid #16a34a; }

.section-title { margin: 0 0 8px 0; font-size: 14px; color: #374151; font-weight: 700; }
.section-content { margin: 0; font-size: 14px; color: #4b5563; line-height: 1.6; }

.next-visit {
  display: flex; align-items: center; gap: 8px;
  background: #fffbeb; padding: 12px 16px; border-radius: 8px;
  border: 1px solid #fcd34d; margin-top: 20px;
}
.next-visit-label { font-weight: 600; color: #92400e; font-size: 14px; }
.next-visit-date { font-weight: 700; color: #92400e; font-size: 14px; }

.signature-section-view {
  margin-top: 24px; border-top: 1px solid #eee; padding-top: 20px;
  display: grid; grid-template-columns: 1fr 1fr; gap: 16px;
}
.signature-item { display: flex; flex-direction: column; gap: 8px; }
.sig-label { font-size: 12px; color: #666; font-weight: 600; }
.sig-image-box {
  height: 80px; background: #f3f4f6; border: 1px dashed #d1d5db;
  border-radius: 6px; display: flex; align-items: center; justify-content: center;
}
.sig-img { max-height: 100%; max-width: 100%; object-fit: contain; }
.no-sig { font-size: 12px; color: #999; }

.modal-footer {
  padding: 16px 24px; border-top: 1px solid #e5e7eb;
  display: flex; justify-content: flex-end;
}
.btn-confirm {
  padding: 10px 20px; background: #111; color: white;
  border: none; border-radius: 8px; font-weight: 600; cursor: pointer;
}
.btn-confirm:hover { opacity: 0.9; }
</style>
