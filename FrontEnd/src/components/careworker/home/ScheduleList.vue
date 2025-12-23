<script setup>
import { scheduleItems } from '@/mock/careworker/homeData';

const handleAction = (action, item) => {
  console.log(`Action: ${action}, Target: ${item.name}`);
  // 추후 라우터 이동이나 API 호출 로직 추가
};
</script>

<template>
  <section class="schedule-section">
    <h2 class="section-title">📅 오늘의 일정</h2>

    <div class="schedule-grid">
      <div v-for="item in scheduleItems" :key="item.id" class="schedule-card">
        <div class="card-header">
          <div class="user-profile">
            <div class="avatar-placeholder">{{ item.name.charAt(0) }}</div>
            <div>
              <h3 class="user-name">{{ item.name }}</h3>
              <p class="user-grade">{{ item.grade }}</p>
            </div>
          </div>
          <div class="status-wrapper">
            <button class="call-btn">📞</button>
            <span :class="['status-badge', item.statusColor]">{{ item.status }}</span>
          </div>
        </div>

        <div v-if="item.tags" class="tag-list">
          <span v-for="(tag, index) in item.tags" :key="index" class="tag">
            💊 {{ tag }}
          </span>
        </div>

        <div class="info-list">
          <div class="info-item">
            <span class="info-icon">🕒</span>
            <span class="info-text">{{ item.time }}</span>
          </div>
          <div class="info-item">
            <span class="info-icon">📋</span>
            <span class="info-text">{{ item.service }}</span>
          </div>
          <div class="info-item">
            <span class="info-icon">📍</span>
            <span class="info-text address">{{ item.address }}</span>
          </div>
        </div>

        <div v-if="item.showAttendance" class="attendance-btns">
          <button class="att-btn check-in">출근하기</button>
          <button class="att-btn check-out">퇴근하기</button>
        </div>

        <div class="action-buttons">
          <button v-for="(btn, index) in item.buttons" :key="index"
            :class="['main-btn', btn.type, btn.color]"
            @click="handleAction(btn.action, item)">
            {{ btn.text }}
          </button>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.schedule-section { margin-top: 1.5rem; }
.section-title { font-size: 1.125rem; font-weight: 800; color: #1f2937; margin-bottom: 1rem; }

.schedule-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr); /* 2x2 그리드로 고정 */
  grid-template-rows: repeat(2, 1fr);
  gap: 1rem;
  max-height: 600px; /* 그리드 최대 높이 */
}

/* 최대 4개 항목만 표시 */
.schedule-card:nth-child(n+5) {
  display: none;
}

/* 반응형: 모바일에서는 1열로 */
@media (max-width: 768px) {
  .schedule-grid {
    grid-template-columns: 1fr;
    grid-template-rows: auto;
  }

  .schedule-card:nth-child(n+5) {
    display: flex; /* 모바일에서는 모든 항목 표시 */
  }
}

.schedule-card {
  background-color: white; padding: 1.25rem; border-radius: 0.75rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1); display: flex; flex-direction: column; gap: 1rem;
  border: 1px solid #f3f4f6;
}

/* Header */
.card-header { display: flex; justify-content: space-between; align-items: center; }
.user-profile { display: flex; align-items: center; gap: 0.75rem; }
.avatar-placeholder { 
  width: 2.5rem; height: 2.5rem; background-color: #e5e7eb; border-radius: 50%; 
  display: flex; align-items: center; justify-content: center; font-weight: 700; color: #6b7280;
}

.user-name { font-size: 1rem; font-weight: 700; color: #1f2937; margin: 0; }
.user-grade { font-size: 0.75rem; color: #6b7280; margin: 0; }

.status-wrapper { display: flex; align-items: center; gap: 0.5rem; }
.call-btn { 
  background-color: #f3f4f6; border: none; padding: 0.4rem; border-radius: 50%; 
  cursor: pointer; font-size: 0.875rem;
}
.call-btn:hover { background-color: #e5e7eb; }

.status-badge { padding: 0.25rem 0.6rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 700; }
.status-badge.green { background-color: #dcfce7; color: #16a34a; }
.status-badge.blue { background-color: #dbeafe; color: #2563eb; }
.status-badge.gray { background-color: #f3f4f6; color: #4b5563; }

/* Tags */
.tag-list { display: flex; gap: 0.5rem; flex-wrap: wrap; }
.tag { padding: 0.25rem 0.6rem; background-color: #fee2e2; color: #dc2626; border-radius: 9999px; font-size: 0.75rem; font-weight: 600; }

/* Info List */
.info-list { display: flex; flex-direction: column; gap: 0.5rem; }
.info-item { display: flex; align-items: center; gap: 0.5rem; font-size: 0.875rem; color: #4b5563; }
.info-icon { width: 1.25rem; text-align: center; }
.info-text.address { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

/* Buttons */
.attendance-btns { display: flex; gap: 0.5rem; }
.att-btn {
  flex: 1; padding: 0.6rem; border-radius: 0.5rem; font-size: 0.875rem; font-weight: 700;
  border: none; cursor: pointer; transition: background 0.2s;
}
.check-in { background-color: #dcfce7; color: #16a34a; }
.check-in:hover { background-color: #bbf7d0; }
.check-out { background-color: #f3f4f6; color: #4b5563; }
.check-out:hover { background-color: #e5e7eb; }

.action-buttons { display: flex; gap: 0.5rem; flex-wrap: wrap; margin-top: auto; }
.main-btn {
  flex: 1; padding: 0.75rem; border-radius: 0.5rem; font-size: 0.875rem; font-weight: 700;
  border: none; cursor: pointer; text-align: center; white-space: nowrap;
}
.main-btn.secondary { background-color: white; border: 1px solid #e5e7eb; color: #4b5563; }
.main-btn.secondary:hover { background-color: #f9fafb; border-color: #d1d5db; }
.main-btn.primary.green { background-color: #22c55e; color: white; }
.main-btn.primary.green:hover { background-color: #16a34a; }
.main-btn.primary.blue { background-color: #3b82f6; color: white; }
.main-btn.primary.blue:hover { background-color: #2563eb; }
</style>