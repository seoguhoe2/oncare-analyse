<!-- components/careworker/schedule/ScheduleDetail2.vue -->

<script setup>
import { defineProps, defineEmits, computed, ref, watch } from 'vue';
import { useRouter } from 'vue-router';
import { getBeneficiaryDetail } from '@/api/careworker';

const router = useRouter();

const props = defineProps({
  schedule: {
    type: Object,
    default: null,
  },
});

const emit = defineEmits(['close', 'edit', 'delete']);

// 수급자 상세 정보
const beneficiaryDetail = ref(null);

// 수급자 정보 로드
const loadBeneficiaryDetail = async (beneficiaryId) => {
  if (!beneficiaryId) return;

  try {
    const response = await getBeneficiaryDetail(beneficiaryId);
    const data = response?.data?.data ?? response?.data ?? response;
    beneficiaryDetail.value = data;
  } catch (error) {
    console.error('❌ 수급자 정보 로드 실패:', error);
    beneficiaryDetail.value = null;
  }
};

// 일정 변경 감지
watch(() => props.schedule, (newSchedule) => {
  if (newSchedule?.beneficiaryId && newSchedule?.scheduleType === 'VISIT') {
    loadBeneficiaryDetail(newSchedule.beneficiaryId);
  } else {
    beneficiaryDetail.value = null;
  }
}, { immediate: true });

// 일정 특이사항 존재 여부
const hasScheduleNotes = computed(() => {
  if (!props.schedule) return false;
  const notes = props.schedule.specialNotes || props.schedule.notes || '';
  return notes.trim().length > 0;
});

// 상태 텍스트 및 클래스
const statusText = computed(() => {
  if (!props.schedule) return '예정';
  if (props.schedule.scheduleType === 'PERSONAL') return '개인일정';

  const statusMap = {
    'SCHEDULED': '예정',
    'IN_PROGRESS': '진행중',
    'DONE': '완료',
    'CANCELLED': '취소'
  };
  return statusMap[props.schedule.status] || '예정';
});

const statusBadgeClass = computed(() => {
  if (!props.schedule) return 'badge-blue';
  if (props.schedule.scheduleType === 'PERSONAL') return 'badge-purple';

  const classMap = {
    'SCHEDULED': 'badge-blue',
    'IN_PROGRESS': 'badge-green',
    'DONE': 'badge-red',
    'CANCELLED': 'badge-gray'
  };
  return classMap[props.schedule.status] || 'badge-blue';
});

// 이벤트 핸들러
const onClose = () => emit('close');
const handleEdit = () => emit('edit', props.schedule);
const handleDelete = () => {
  if (confirm('정말 삭제하시겠습니까?')) {
    emit('delete', props.schedule);
  }
};

const handleViewCareLog = () => {
  if (!props.schedule?.beneficiaryId) return;
  router.push({
    name: 'activity-care',
    query: { beneficiaryId: props.schedule.beneficiaryId, tab: 'history' }
  });
};

const handleViewAssessment = () => {
  if (!props.schedule?.beneficiaryId) return;
  router.push({
    name: 'activity-evaluation',
    query: { beneficiaryId: props.schedule.beneficiaryId }
  });
};
</script>

<template>
  <div class="schedule-detail">
    <!-- 빈 상태 -->
    <div v-if="!schedule" class="empty-state">
      <div class="empty-icon">📅</div>
      <p class="empty-title">일정을 선택하면</p>
      <p class="empty-subtitle">상세 정보가 표시됩니다</p>
    </div>

    <!-- 일정 상세 내용 -->
    <div v-else class="detail-container">
      <!-- 헤더 -->
      <header class="detail-header">
        <h2 class="header-title">
          {{ schedule.scheduleType === 'PERSONAL' ? '개인 일정' : '일정 상세' }}
        </h2>
        <div class="header-actions">
          <span :class="['status-badge', statusBadgeClass]">{{ statusText }}</span>
          <span class="date-badge">{{ schedule.date }}</span>
          <button class="close-btn" @click="onClose">✕</button>
        </div>
      </header>

      <!-- 스크롤 영역 -->
      <div class="detail-body">
        <!-- 개인 일정 -->
        <template v-if="schedule.scheduleType === 'PERSONAL'">
          <!-- 개인 일정 정보 박스 -->
          <div class="personal-box">
            <div class="personal-header">
              <div class="personal-title-section">
                <h3 class="personal-name">
                  {{ schedule.title || schedule.recipient }}
                </h3>
                <div class="personal-badges">
                  <span class="badge badge-purple">개인일정</span>
                </div>
              </div>
            </div>

            <div class="personal-details">
              <div class="detail-row full" v-if="schedule.serviceLabel || schedule.type">
                <span class="detail-label">일정 유형</span>
                <span class="detail-value">{{ schedule.serviceLabel || schedule.type }}</span>
              </div>
              <div class="detail-row full" v-if="schedule.location || schedule.address">
                <span class="detail-label">장소</span>
                <span class="detail-value">{{ schedule.location || schedule.address }}</span>
              </div>
            </div>

            <div class="schedule-time">
              <span class="time-icon">🕐</span>
              <div class="time-content">
                <span class="time-range">{{ schedule.startTime }} - {{ schedule.endTime }}</span>
                <span class="service-type">개인 일정</span>
              </div>
            </div>
          </div>

          <!-- 메모 -->
          <div v-if="schedule.notes && schedule.notes.trim()" class="info-section">
            <div class="section-header">
              <span class="section-icon">📝</span>
              <h4 class="section-title">메모</h4>
            </div>
            <div class="memo-box">{{ schedule.notes }}</div>
          </div>

          <!-- 수정/삭제 버튼 -->
          <div class="action-footer">
            <button class="btn btn-edit" @click="handleEdit">
              <span>✏️</span> 수정
            </button>
            <button class="btn btn-delete" @click="handleDelete">
              <span>🗑️</span> 삭제
            </button>
          </div>
        </template>

        <!-- 방문 일정 -->
        <template v-else>
          <!-- 수급자 정보 박스 -->
          <div class="beneficiary-box">
            <div class="beneficiary-header">
              <div class="beneficiary-name-section">
                <h3 class="beneficiary-name">
                  {{ beneficiaryDetail?.name || schedule.recipient || '수급자' }}
                  <span v-if="beneficiaryDetail?.gender" class="gender-label">
                    {{ beneficiaryDetail.gender === 'M' ? '남' : '여' }}
                  </span>
                </h3>
                <div class="beneficiary-badges">
                  <span v-if="beneficiaryDetail?.age" class="badge badge-age">{{ beneficiaryDetail.age }}세</span>
                  <span v-if="beneficiaryDetail?.careLevel" class="badge badge-care-level">{{ beneficiaryDetail.careLevel }}</span>
                </div>
              </div>
            </div>

            <div class="beneficiary-details">
              <div class="detail-row">
                <span class="detail-label">전화번호</span>
                <span class="detail-value">{{ beneficiaryDetail?.phone || schedule.phone || '-' }}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">생년월일</span>
                <span class="detail-value">{{ beneficiaryDetail?.birthdate || '-' }}</span>
              </div>
              <div class="detail-row full">
                <span class="detail-label">주소</span>
                <span class="detail-value">{{ beneficiaryDetail?.address || schedule.address || '-' }}</span>
              </div>
            </div>

            <div class="schedule-time">
              <span class="time-icon">🕐</span>
              <div class="time-content">
                <span class="time-range">{{ schedule.startTime }} - {{ schedule.endTime }}</span>
                <span class="service-type">{{ schedule.serviceLabel || '방문요양' }}</span>
              </div>
            </div>
          </div>

          <!-- 액션 버튼 -->
          <div class="action-buttons">
            <button class="btn btn-primary" @click="handleViewCareLog">
              <span>📋</span> 요양일지 기록보기
            </button>
            <button class="btn btn-secondary" @click="handleViewAssessment">
              <span>📊</span> 기초평가 기록보기
            </button>
          </div>

          <!-- 보호자 정보 -->
          <div v-if="beneficiaryDetail?.guardians?.length" class="info-section">
            <div class="section-header">
              <span class="section-icon">👨‍👩‍👧</span>
              <h4 class="section-title">보호자 정보</h4>
            </div>
            <div class="guardian-list">
              <div v-for="(guardian, idx) in beneficiaryDetail.guardians" :key="idx" class="guardian-item">
                <div class="guardian-info">
                  <span class="guardian-name">{{ guardian.name }}</span>
                  <span class="guardian-relation">({{ guardian.relation }})</span>
                  <span v-if="guardian.isPrimary" class="badge badge-primary">주</span>
                </div>
                <a :href="`tel:${guardian.phone}`" class="guardian-phone">{{ guardian.phone }}</a>
              </div>
            </div>
          </div>

          <!-- 위험요소 -->
          <div v-if="beneficiaryDetail?.riskFactors?.length" class="info-section warning">
            <div class="section-header">
              <span class="section-icon">⚠️</span>
              <h4 class="section-title">위험요소</h4>
            </div>
            <div class="tag-list">
              <span v-for="(risk, idx) in beneficiaryDetail.riskFactors" :key="idx" class="tag tag-red">
                {{ risk }}
              </span>
            </div>
          </div>

          <!-- 수급자 특이사항 (태그) -->
          <div v-if="beneficiaryDetail?.significants?.length" class="info-section special">
            <div class="section-header">
              <span class="section-icon">⚡</span>
              <h4 class="section-title">수급자 특이사항</h4>
            </div>
            <div class="tag-list">
              <span v-for="(item, idx) in beneficiaryDetail.significants" :key="idx" class="tag tag-yellow">
                {{ item }}
              </span>
            </div>
          </div>

          <!-- 태그 -->
          <div v-if="beneficiaryDetail?.tags?.length" class="info-section">
            <div class="section-header">
              <span class="section-icon">🏷️</span>
              <h4 class="section-title">태그</h4>
            </div>
            <div class="tag-list">
              <span v-for="(tag, idx) in beneficiaryDetail.tags" :key="idx" class="tag tag-blue">
                {{ tag }}
              </span>
            </div>
          </div>

          <!-- 메모 -->
          <div v-if="hasScheduleNotes" class="info-section">
            <div class="section-header">
              <span class="section-icon">📝</span>
              <h4 class="section-title">메모</h4>
            </div>
            <div class="memo-box">{{ schedule.specialNotes || schedule.notes }}</div>
          </div>


          <!-- 장기요양인정 정보 -->
          <div v-if="beneficiaryDetail?.careLevelNumber" class="info-section">
            <div class="section-header">
              <span class="section-icon">📄</span>
              <h4 class="section-title">장기요양인정 정보</h4>
            </div>
            <div class="care-level-info">
              <div class="info-row">
                <span class="info-label">인정번호</span>
                <span class="info-value">{{ beneficiaryDetail.careLevelNumber }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">유효기간</span>
                <span class="info-value">
                  {{ beneficiaryDetail.careLevelStartDate }} ~ {{ beneficiaryDetail.careLevelEndDate }}
                </span>
              </div>
            </div>
          </div>

          <!-- 수정/삭제 버튼 -->
          <div class="action-footer">
            <button class="btn btn-edit" @click="handleEdit">
              <span>✏️</span> 수정
            </button>
            <button class="btn btn-delete" @click="handleDelete">
              <span>🗑️</span> 삭제
            </button>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 컨테이너 */
.schedule-detail {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  background: #ffffff;
}

/* 빈 상태 */
.empty-state {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #9ca3af;
}

.empty-icon {
  width: 52px;
  height: 52px;
  border: 3px solid #e5e7eb;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  margin-bottom: 16px;
}

.empty-title {
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 4px;
}

.empty-subtitle {
  font-size: 14px;
  margin: 0;
}

/* 상세 컨테이너 */
.detail-container {
  display: flex;
  flex-direction: column;
  height: 100%;
}

/* 헤더 */
.detail-header {
  padding: 20px 24px;
  border-bottom: 1px solid #f1f5f9;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-shrink: 0;
}

.header-title {
  font-size: 18px;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.status-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
}

.badge-blue {
  background: #dbeafe;
  color: #1e40af;
}

.badge-green {
  background: #dcfce7;
  color: #166534;
}

.badge-red {
  background: #fee2e2;
  color: #991b1b;
}

.badge-purple {
  background: #f3e8ff;
  color: #7c3aed;
}

.badge-gray {
  background: #f3f4f6;
  color: #6b7280;
}

.date-badge {
  font-size: 13px;
  color: #64748b;
  font-weight: 500;
}

.close-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  color: #94a3b8;
  padding: 4px;
  line-height: 1;
  transition: color 0.2s;
}

.close-btn:hover {
  color: #64748b;
}

/* 스크롤 영역 */
.detail-body {
  flex: 1;
  overflow-y: auto;
  padding: 20px 24px;
}

.detail-body::-webkit-scrollbar {
  width: 6px;
}

.detail-body::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

.detail-body::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}

/* 개인 일정 박스 */
.personal-box {
  background: linear-gradient(135deg, #faf5ff 0%, #ffffff 100%);
  border-radius: 16px;
  border: 2px solid #e9d5ff;
  overflow: hidden;
  margin-bottom: 20px;
  box-shadow: 0 4px 12px rgba(168, 85, 247, 0.08);
}

.personal-header {
  padding: 24px;
  background: white;
  border-bottom: 2px solid #e9d5ff;
}

.personal-title-section {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.personal-name {
  font-size: 24px;
  font-weight: 700;
  color: #0f172a;
  margin: 0;
}

.personal-badges {
  display: flex;
  gap: 8px;
}

.badge-purple {
  background: linear-gradient(135deg, #f3e8ff, #e9d5ff);
  color: #7c3aed;
  border: 1px solid #d8b4fe;
}

.personal-details {
  padding: 24px;
  background: white;
  display: grid;
  grid-template-columns: 1fr;
  gap: 16px;
}

/* 수급자 정보 박스 */
.beneficiary-box {
  background: linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
  border-radius: 16px;
  border: 2px solid #e2e8f0;
  overflow: hidden;
  margin-bottom: 20px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
}

.beneficiary-header {
  padding: 24px;
  background: white;
  border-bottom: 2px solid #e2e8f0;
}

.beneficiary-name-section {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.beneficiary-name {
  font-size: 24px;
  font-weight: 700;
  color: #0f172a;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.gender-label {
  font-size: 18px;
  font-weight: 600;
  color: #64748b;
}

.beneficiary-badges {
  display: flex;
  gap: 8px;
}

.badge {
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
}

.badge-age {
  background: linear-gradient(135deg, #dbeafe, #bfdbfe);
  color: #1e40af;
  border: 1px solid #93c5fd;
}

.badge-care-level {
  background: linear-gradient(135deg, #fef3c7, #fde68a);
  color: #92400e;
  border: 1px solid #fcd34d;
}

.beneficiary-details {
  padding: 24px;
  background: white;
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.detail-row {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.detail-row.full {
  grid-column: 1 / -1;
}

.detail-label {
  font-size: 12px;
  font-weight: 600;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.detail-value {
  font-size: 15px;
  font-weight: 600;
  color: #1e293b;
}

.schedule-time {
  background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
  padding: 16px 24px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.time-icon {
  font-size: 24px;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1));
}

.time-content {
  display: flex;
  flex-direction: column;
  gap: 4px;
  flex: 1;
}

.time-range {
  font-size: 16px;
  font-weight: 700;
  color: #1e3a8a;
  letter-spacing: -0.3px;
}

.service-type {
  font-size: 12px;
  font-weight: 600;
  color: #3b82f6;
  background: white;
  padding: 3px 10px;
  border-radius: 10px;
  display: inline-block;
  align-self: flex-start;
  border: 1px solid #93c5fd;
}

/* 섹션 */
.info-section {
  margin-bottom: 24px;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.section-icon {
  font-size: 18px;
}

.section-title {
  font-size: 15px;
  font-weight: 700;
  color: #334155;
  margin: 0;
}

.info-section.warning .section-header {
  color: #dc2626;
}

.info-section.warning .section-title {
  color: #dc2626;
}

.info-section.special .section-header {
  color: #d97706;
}

.info-section.special .section-title {
  color: #d97706;
}

.section-text {
  margin: 0;
  padding-left: 26px;
  font-size: 14px;
  color: #475569;
  line-height: 1.6;
}

/* 메모 박스 */
.memo-box {
  background: linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
  border: 1px solid #e2e8f0;
  border-left: 3px solid #3b82f6;
  border-radius: 8px;
  padding: 16px;
  font-size: 16px;
  color: #1e293b;
  line-height: 1.6;
  white-space: pre-wrap;
  word-break: break-word;
}

/* 보호자 목록 */
.guardian-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.guardian-item {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.guardian-info {
  display: flex;
  align-items: center;
  gap: 6px;
}

.guardian-name {
  font-size: 15px;
  font-weight: 600;
  color: #1e293b;
}

.guardian-relation {
  font-size: 14px;
  color: #64748b;
}

.badge-primary {
  background: linear-gradient(135deg, #3b82f6, #2563eb);
  color: white;
  font-size: 11px;
  padding: 2px 8px;
  border-radius: 10px;
  box-shadow: 0 1px 3px rgba(59, 130, 246, 0.3);
}

.guardian-phone {
  font-size: 14px;
  font-weight: 500;
  color: #3b82f6;
  background: #eff6ff;
  padding: 6px 12px;
  border-radius: 6px;
  text-decoration: none;
}

/* 태그 */
.tag-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
  display: inline-block;
}

.tag-red {
  background: #fee2e2;
  color: #dc2626;
}

.tag-yellow {
  background: #fef3c7;
  color: #d97706;
}

.tag-blue {
  background: linear-gradient(135deg, #dbeafe, #bfdbfe);
  color: #1e40af;
  border: 1px solid #93c5fd;
}

/* 요양등급 정보 */
.care-level-info {
  background: linear-gradient(135deg, #faf5ff 0%, #f3e8ff 100%);
  border-radius: 10px;
  padding: 16px;
  border-left: 4px solid #a855f7;
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 10px 0;
}

.info-row:not(:last-child) {
  border-bottom: 1px solid #e9d5ff;
}

.info-label {
  font-size: 14px;
  font-weight: 600;
  color: #6b21a8;
}

.info-value {
  font-size: 14px;
  font-weight: 700;
  color: #581c87;
}

/* 버튼 */
.action-buttons {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
}

.action-footer {
  display: flex;
  gap: 12px;
  padding-top: 20px;
  margin-top: 20px;
  border-top: 1px solid #f1f5f9;
}

.btn {
  flex: 1;
  padding: 14px 20px;
  border: none;
  border-radius: 10px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.btn span {
  font-size: 18px;
}

.btn-primary {
  background: linear-gradient(135deg, #3b82f6, #2563eb);
  color: white;
  box-shadow: 0 2px 8px rgba(59, 130, 246, 0.25);
}

.btn-primary:hover {
  background: linear-gradient(135deg, #2563eb, #1d4ed8);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.35);
  transform: translateY(-1px);
}

.btn-secondary {
  background: white;
  color: #3b82f6;
  border: 2px solid #3b82f6;
}

.btn-secondary:hover {
  background: #eff6ff;
  border-color: #2563eb;
  color: #2563eb;
  transform: translateY(-1px);
}

.btn-edit {
  background: #f0f9ff;
  color: #0369a1;
  border: 1px solid #bae6fd;
}

.btn-edit:hover {
  background: #e0f2fe;
  border-color: #7dd3fc;
}

.btn-delete {
  background: #fef2f2;
  color: #dc2626;
  border: 1px solid #fecaca;
}

.btn-delete:hover {
  background: #fee2e2;
  border-color: #fca5a5;
}

/* 반응형 */
@media (max-width: 768px) {
  .personal-name,
  .beneficiary-name {
    font-size: 20px;
  }

  .personal-title-section,
  .beneficiary-name-section {
    flex-direction: column;
    gap: 12px;
  }

  .beneficiary-details {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .time-range {
    font-size: 18px;
  }

  .guardian-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }

  .btn {
    padding: 12px 16px;
    font-size: 14px;
  }
}
</style>
