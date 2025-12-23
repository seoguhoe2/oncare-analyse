<template>
    <section class="caregiver-detail">
      <!-- 상단 기본 정보 -->
      <header class="header-row">
        <div class="basic-info">
          <div class="name-row">
            <span class="name">{{ caregiver.name }}</span>
          </div>
          <p class="address">{{ caregiver.address }}</p>
        </div>
  
        <div class="meta-right">
          <div class="meta-item">
            <div class="label">연락처</div>
            <div class="value">{{ caregiver.phone || '-' }}</div>
          </div>
          <div class="meta-item">
            <div class="label">나이</div>
            <div class="value">{{ caregiver.age ? caregiver.age + '세' : '-' }}</div>
          </div>
        </div>
      </header>
  
      <!-- 중간 상세 정보 -->
      <div class="info-section">
        <div class="column">
          <div class="field">
            <div class="label">가능 요일</div>
            <div class="value">
              <template v-if="caregiver.availableDays?.length">
                <span
                  v-for="d in caregiver.availableDays"
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
            <div class="label">서비스</div>
            <div class="value">
              <template v-if="caregiver.services?.length">
                <span
                  v-for="s in caregiver.services"
                  :key="s"
                  class="pill"
                >
                  {{ s }}
                </span>
              </template>
              <span v-else>-</span>
            </div>
          </div>
  
          <div class="field">
            <div class="label">태그</div>
            <div class="value">
              <template v-if="caregiver.tags?.length">
                <span
                  v-for="t in caregiver.tags"
                  :key="t"
                  class="pill soft"
                >
                  {{ t }}
                </span>
              </template>
              <span v-else>-</span>
            </div>
          </div>
        </div>
  
        <div class="column">
          <div class="field">
            <div class="label">자격증</div>
            <div class="value">
              <template v-if="caregiver.certifications?.length">
                <span
                  v-for="c in caregiver.certifications"
                  :key="c"
                  class="badge-cert"
                >
                  {{ c }}
                </span>
              </template>
              <span v-else>-</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  </template>
  
  <script setup>
  import { computed } from 'vue'
  
  const props = defineProps({
    caregiver: {
      type: Object,
      required: true,
    },
  })
  
  const initials = computed(() => {
    if (!props.caregiver?.name) return '요'
    return props.caregiver.name[0]
  })
  </script>
  
  <style scoped>
  .caregiver-detail {
    background: #f0fdf4; /* 연한 연두색 */
    border-radius: 16px;
    border: 1px solid #bbf7d0;
    padding: 24px 32px;
    min-height: 260px;
    display: flex;
    flex-direction: column;
    gap: 20px;
  }
  
  /* 상단 영역 */
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
  
  .address {
    margin: 0;
    font-size: 14px;
    color: #4b5563;
  }
  
  .meta-right {
    display: flex;
    flex-direction: column;
    gap: 4px;
    min-width: 160px;
  }
  
  .meta-item .label {
    font-size: 12px;
    color: #6b7280;
  }
  
  .meta-item .value {
    font-size: 14px;
    color: #111827;
  }
  
  /* 중간 섹션 */
  .info-section {
    display: flex;
    gap: 40px;
    margin-top: 16px;
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
  
  /* pill 스타일 */
  .pill {
    display: inline-flex;
    align-items: center;
    padding: 4px 10px;
    border-radius: 999px;
    background: #dcfce7;
    color: #15803d;
    font-size: 12px;
    margin-right: 6px;
    margin-bottom: 4px;
  }
  
  .pill.soft {
    background: #e0f2fe;
    color: #0369a1;
  }
  
  /* 요일 pill */
  .day-pill {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    border-radius: 8px;
    background: #ecfdf5;
    color: #15803d;
    font-size: 13px;
    margin-right: 6px;
  }
  
  /* 자격증 배지 */
  .badge-cert {
    display: inline-flex;
    align-items: center;
    padding: 4px 10px;
    border-radius: 999px;
    background: #f5f3ff;
    color: #6d28d9;
    font-size: 12px;
    margin-right: 6px;
    margin-bottom: 4px;
  }
  </style>