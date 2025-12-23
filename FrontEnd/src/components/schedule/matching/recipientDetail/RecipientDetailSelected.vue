<template>
    <section class="recipient-detail">
      <!-- 상단 기본 정보 -->
      <header class="header-row">
        <div class="basic-info">
          <div class="name-row">
            <span class="name">{{ recipient.name }}</span>
            <span class="badge grade">{{ recipient.grade }}</span>
            <span
              class="badge gender"
              :class="recipient.gender === '여자' ? 'female' : 'male'"
            >
              {{ recipient.gender }}
            </span>
          </div>
  
          <p class="address">{{ recipient.address }}</p>
        </div>
      </header>
  
      <!-- 중간 상세 정보 -->
      <div class="info-section">
        <div class="column">
          <div class="field">
            <div class="label">연락처</div>
            <div class="value">{{ recipient.phone || '-' }}</div>
          </div>
  
          <div class="field">
            <div class="label">필요 서비스</div>
            <div class="value">
              <template v-if="recipient.needServices?.length">
                <span
                  v-for="s in recipient.needServices"
                  :key="s"
                  class="pill pill-soft"
                >
                  {{ s }}
                </span>
              </template>
              <span v-else>-</span>
            </div>
          </div>
  
          <div class="field">
            <div class="label">필요 태그</div>
            <div class="value">
              <template v-if="recipient.needTags?.length">
                <span
                  v-for="t in recipient.needTags"
                  :key="t"
                  class="pill"
                >
                  {{ t }}
                </span>
              </template>
              <span v-else>-</span>
            </div>
          </div>
  
          <div class="field">
            <div class="label">희망 요일</div>
            <div class="value">
              <template v-if="recipient.preferredDays?.length">
                <span
                  v-for="d in recipient.preferredDays"
                  :key="d"
                  class="day-pill"
                >
                  {{ d }}
                </span>
              </template>
              <span v-else>-</span>
            </div>
          </div>
  
          <div class="field">
            <div class="label">희망 시간</div>
            <div class="time-list">
              <template v-if="recipient.preferredTimes?.length">
                <div
                  v-for="(t, idx) in recipient.preferredTimes"
                  :key="idx"
                  class="time-row"
                >
                  <img :src="clockIcon" alt="" class="clock-icon" />
                  <span>{{ t }}</span>
                </div>
              </template>
              <div v-else class="value">-</div>
            </div>
          </div>
        </div>
  
        <div class="column">
          <div class="field">
            <div class="label">선호 보호사 성별</div>
            <div class="value">
              {{ recipient.preferredCaregiverGender || '선호 없음' }}
            </div>
          </div>
        </div>
      </div>
  
      <!-- 하단 배정된 요양보호사 -->
      <section class="assigned-section">
        <h3 class="assigned-title">배정된 요양보호사</h3>
  
        <div
          v-if="recipient.assignedCaregivers?.length"
          class="assigned-list"
        >
          <article
            v-for="cg in recipient.assignedCaregivers"
            :key="cg.id"
            class="assigned-card"
          >
            <div class="assigned-left">
              <div class="assigned-main">
                <div class="assigned-row">
                  <span class="assigned-name">{{ cg.name }}</span>
                  <span
                    class="badge gender small"
                    :class="cg.gender === '여자' ? 'female' : 'male'"
                  >
                    {{ cg.gender }}
                  </span>
                </div>
                <div class="assigned-meta">
                  <span>배정일: {{ cg.assignedDate }}</span>
                </div>
                <div class="assigned-tags">
                  <span
                    v-for="s in cg.services"
                    :key="s"
                    class="pill"
                  >
                    {{ s }}
                  </span>
                </div>
              </div>
            </div>
  
            <button
              type="button"
              class="remove-btn"
              @click="$emit('remove-caregiver', cg)"
            >
              ✕
            </button>
          </article>
        </div>
  
        <p v-else class="assigned-empty">
          배정된 요양보호사가 없습니다
        </p>
      </section>
    </section>
  </template>
  
  <script setup>
  import { computed } from 'vue'
  import clockIcon from '@/assets/img/schedule/clock.png'
  
  const props = defineProps({
    recipient: {
      type: Object,
      required: true,
    },
  })
  
  const initials = computed(() => {
    if (!props.recipient?.name) return '수'
    return props.recipient.name[0]
  })
  </script>
  
  <style scoped>
  .recipient-detail {
    background: #faf5ff;
    border-radius: 16px;
    border: 1px solid #f3e8ff;
    padding: 24px 32px;
    min-height: 260px;
    display: flex;
    flex-direction: column;
    gap: 20px;
  }
  
  /* 상단 */
  .header-row {
    display: flex;
    gap: 16px;
    align-items: center;
  }
  
  .basic-info {
    flex: 1;
  }
  
  .name-row {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 4px;
  }
  
  .name {
    font-size: 20px;
    font-weight: 700;
    color: #166534;
  }
  
  .badge {
    display: inline-flex;
    align-items: center;
    padding: 4px 10px;
    border-radius: 999px;
    font-size: 12px;
  }
  
  .badge.grade {
    background: #f3e8ff;
    color: #6d28d9;
  }
  
  .badge.gender {
    background: #dbeafe;
    color: #1d4ed8;
  }
  
  .badge.gender.female {
    background: #fee2e2;
    color: #be123c;
  }
  
  .badge.small {
    font-size: 11px;
    padding: 2px 8px;
  }
  
  .address {
    margin: 0;
    font-size: 14px;
    color: #4b5563;
  }
  
  /* 중간 섹션 */
  .info-section {
    display: flex;
    gap: 40px;
    margin-top: 12px;
  }
  
  .column {
    flex: 1;
  }
  
  .field {
    margin-bottom: 14px;
  }
  
  .label {
    font-size: 13px;
    color: #6b7280;
    margin-bottom: 4px;
  }
  
  .value {
    font-size: 14px;
    color: #111827;
  }
  
  .pill {
    display: inline-flex;
    align-items: center;
    padding: 4px 10px;
    border-radius: 999px;
    background: #dcfce7;
    color: #15803d;
    font-size: 12px;
    margin-right: 6px;
  }
  
  .pill-soft {
    background: #eef2ff;
    color: #4f46e5;
  }
  
  .day-pill {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    border-radius: 8px;
    background: #eef2ff;
    color: #4f46e5;
    font-size: 13px;
    margin-right: 6px;
  }
  
  .time-list {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }
  
  .time-row {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 14px;
    color: #111827;
  }
  
  .clock-icon {
    width: 16px;
    height: 16px;
    object-fit: contain;
  }
  
  /* 하단 배정된 요양보호사 */
  .assigned-section {
    margin-top: 12px;
  }
  
  .assigned-title {
    margin: 0 0 8px;
    font-size: 15px;
    font-weight: 600;
    color: #111827;
  }
  
  .assigned-empty {
    margin: 12px 0 0;
    font-size: 14px;
    color: #9ca3af;
    text-align: center;
    padding: 20px 0;
    background: #f9fafb;
    border-radius: 12px;
  }
  
  .assigned-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }
  
  .assigned-card {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #ffffff;
    border-radius: 14px;
    padding: 14px 18px;
    border: 1px solid #e5e7eb;
  }
  
  .assigned-left {
    display: flex;
    gap: 12px;
    align-items: center;
  }
  
  .assigned-main {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }
  
  .assigned-row {
    display: flex;
    align-items: center;
    gap: 6px;
  }
  
  .assigned-name {
    font-size: 15px;
    font-weight: 600;
    color: #111827;
  }
  
  .assigned-meta {
    font-size: 13px;
    color: #6b7280;
  }
  
  .assigned-tags {
    display: flex;
    gap: 6px;
    margin-top: 2px;
  }
  
  .remove-btn {
    border: none;
    background: transparent;
    color: #ef4444;
    cursor: pointer;
    font-size: 18px;
    padding: 0 2px;
  }
  </style>