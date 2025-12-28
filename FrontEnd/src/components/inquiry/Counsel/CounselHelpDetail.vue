<template>
    <div class="card detail-section">
    <div class="card-header simple">
      <div class="header-title">상세 페이지</div>
    </div>
    
    <div class="detail-body">
      <div class="history-box">
        <div class="sub-title">이전 상담 이력</div>
        <div class="history-content">
          <div class="history-top">
            <span class="history-badge">가입 상담</span>
            <span class="history-date">2025.01.02</span>
          </div>
          <div class="history-manager">담당자: 김상담</div>
          <p class="history-desc">
            방문 요양 상담 - 장기 요양 등급 관련 상담 진행, 방문 요양 서비스 신청 희망하심
          </p>
        </div>
      </div>
      <MatchingHelpForm v-if="category === 'subscript'"/>
      <RentalInfoForm v-if="category === 'rental'" />

      <ComplainResolutionHelp v-if="category === 'complain'" />
      
      
      
      <div v-else class="empty-guide">
        상담 카테고리를 선택하면 맞춤 가이드가 표시됩니다.
      </div>

    </div>
  </div>
</template>

<script setup>
import RentalInfoForm from '@/components/inquiry/Counsel/HelpDetail/RentalInfoForm.vue';
import MatchingHelpForm from '@/components/inquiry/Counsel/HelpDetail/MatchingHelpForm.vue';
import ComplainResolutionHelp from '@/components/inquiry/Counsel/HelpDetail/ComplainResolutionHelp.vue';
defineProps({
  category: {
    type: String,
    default: ''
  }
});
</script>

<style scoped>
.card { background: white; border-radius: 10px; border: 1px solid #E5E7EB; display: flex; flex-direction: column; overflow: hidden; height: 100%; min-height: 340px; }
.card-header { padding: 16px; border-bottom: 1px solid #E5E7EB; }
.header-title { color: #388E3C; font-size: 20px; font-weight: 600; line-height: 28px; }

.detail-body { padding: 20px; flex: 1; display: flex; flex-direction: column; gap: 20px; overflow-y: auto; }

.history-box { background: #EFF6FF; border: 1px solid #DBEAFE; border-radius: 14px; padding: 20px; flex-shrink: 0; }
.sub-title { color: #364153; font-size: 14px; margin-bottom: 8px; }
.history-content { display: flex; flex-direction: column; gap: 8px; }
.history-top { display: flex; justify-content: space-between; align-items: center; }
.history-badge { background: #DBEAFE; padding: 4px 8px; border-radius: 4px; font-size: 12px; color: #4A5565; }
.history-date { font-size: 12px; color: #4A5565; }
.history-manager { font-size: 12px; color: #6A7282; }
.history-desc { font-size: 14px; color: #4A5565; line-height: 1.5; margin: 0; }

.empty-guide { text-align: center; color: #999; padding: 40px 0; font-size: 14px; }
</style>