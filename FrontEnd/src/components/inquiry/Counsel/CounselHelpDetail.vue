<template>
    <div class="card detail-section">
    <div class="card-header simple">
      <div class="header-title">상세 페이지</div>
    </div>
    
    <div class="detail-body">
      <div v-if="customer?.customerType === 'potential'">
        <SubscriptProcess 
        :customer="customer" />
      </div>
      <div v-if="counselDetail" class="selected-detail">
        <CounselDetailCard v-bind="counselDetail" />
      </div>
      
      <MatchingHelpForm v-if="category === '가입상담'" />
      <RentalInfoForm v-else-if="category === '렌탈상담'" />
      <ComplainResolutionHelp v-else-if="category === '컴플레인'" />
      
      
      
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
import CounselDetailCard from '@/components/inquiry/Counsel/CounselDetailCard.vue';
import SubscriptProcess from '@/components/inquiry/Counsel/Process/SubscriptProcess.vue';
defineProps({
  category: {
    type: String,
    default: ''
  },
  counselDetail: { type: Object, default: null },
  customer: {
    type: Object,
    default: null
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
.selected-detail {
  border-radius: 10px;
  overflow: hidden;
}
</style>