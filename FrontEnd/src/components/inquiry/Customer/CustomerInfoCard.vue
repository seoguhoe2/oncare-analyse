<template>
    <div class="customer-info-card">
    <div class="card-content-wrapper">
      
      <div class="profile-section">
        <div class="profile-header">
          <span class="name">박순자</span>
          <span class="age">(78세)</span>
        </div>
        <div class="profile-details">
          <div class="detail-row">
            <span class="icon-box"></span>
            <span class="detail-text">2등급</span>
          </div>
          <div class="detail-row">
            <span class="icon-box"></span>
            <span class="detail-text">김미영</span>
          </div>
          <div class="detail-row">
            <span class="icon-box"></span>
            <span class="detail-text">010-1234-5678</span>
          </div>
        </div>
      </div>

      <CustomerProcess />

      <div class="more-options-btn">
        <div class="dots-icon"></div>
      </div>

    </div>
  </div>
</template>

<script setup>
import CustomerProcess from '@/components/inquiry/Customer/Process/CustomerProcess.vue';
</script>

<style scoped>
.customer-info-card {
  background: white;
  border-radius: 16px;
  border: 1px solid #F3F4F6;
  box-shadow: 0px 1px 2px rgba(0,0,0,0.1);
  padding: 24px;
  position: relative;
}

.card-content-wrapper {
  display: flex;
  gap: 40px;
  align-items: flex-start;
}

.profile-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-width: 200px;
}

.profile-header {
  display: flex;
  align-items: baseline;
  gap: 8px;
}

.name { font-size: 18px; color: #101828; font-weight: 600; }
.age { font-size: 14px; color: #6A7282; }

.profile-details {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.detail-row {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
}

.icon-box {
  width: 16px; height: 16px;
  border: 1px solid #99A1AF;
  display: inline-block;
}

.detail-text { color: #4A5565; }

.more-options-btn {
  position: absolute;
  top: 24px; right: 24px;
  width: 40px; height: 40px;
  border-radius: 50%;
  background: #F9FAFB;
  display: flex; justify-content: center; align-items: center;
  cursor: pointer;
}

.dots-icon {
  width: 4px; height: 16px;
  border-left: 2px dotted #99A1AF;
}

@media (max-width: 1200px) {
  .card-content-wrapper { flex-direction: column; }
}
</style>