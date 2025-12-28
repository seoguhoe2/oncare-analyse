<template>
    <div>
      <h2>고객 관리</h2>
    </div>

    <div class="management-page">

    <CustomerSearchBy2Criteria />

    <CustomerInfoCard />

  </div>
  </template>
  
<script setup>
  import CustomerSearchBy2Criteria from '@/components/inquiry/Customer/CustomerSearchByTwoCriteria.vue';
  import CustomerInfoCard from '@/components/inquiry/Customer/CustomerInfoCard.vue';
</script>

  <style scoped>
.management-page {
  display: flex;
  flex-direction: column;
  gap: 24px;
  width: 100%;
  max-width: 1600px;
  margin: 0 auto;
  font-family: 'Arimo', 'ABeeZee', sans-serif;
  color: #4A5565;
}

.top-nav-bar {
  background: white;
  border-bottom: 1px solid #E5E7EB;
  padding: 0 24px;
}

.nav-items {
  display: flex;
  gap: 16px;
}

.nav-item {
  padding: 15px 19px;
  font-size: 16px;
  cursor: pointer;
  border-bottom: 2px solid transparent;
}

.nav-item.active {
  color: #00A63E;
  border-bottom: 2px solid #00A63E;
  font-weight: 500;
}
</style>