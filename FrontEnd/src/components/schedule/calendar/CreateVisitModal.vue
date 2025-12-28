<template>
    <teleport to="body">
      <div v-if="show" class="overlay" @click.self="emit('close')">
        <div class="modal">
          <div class="modal-header">
            <h3 class="modal-title">방문 일정 추가</h3>
          </div>
  
          <div class="modal-body">
            <div class="grid">
              <RecipientMatchingList @select-recipient="onSelectRecipient" />
  
              <div>
                <div v-if="!canFetchCaregivers" class="hint-box">
                  <div class="hint-card">
                    <div class="hint-texts">
                      <p class="hint-title">시간과 서비스 유형을 선택하면 요양보호사가 필터링 됩니다</p>
                      <p class="hint-sub">오른쪽에서 서비스 유형 · 날짜 · 시작 · 종료 시간을 먼저 입력해 주세요.</p>
                    </div>
                  </div>
                </div>
  
                <CaregiverMatchingList
                    v-else
                    :recipient="selectedRecipient"
                    :startDt="startDt"
                    :endDt="endDt"
                    :serviceTypeId="serviceTypeIdNum"
                    @select-caregiver="onSelectCaregiver"
                />
              </div>
  
              <div class="memo-area">
                <textarea
                  v-model="memo"
                  class="memo"
                  placeholder="특이사항이나 전달사항을 입력하세요"
                />
  
                <div class="service-type">
                  <label class="service-label">서비스 유형</label>
                  <div class="select-wrap">
                    <select v-model="serviceTypeId" class="service-select">
                      <option disabled value="">선택하세요</option>
                      <option value="1">방문 요양</option>
                      <option value="2">방문 목욕</option>
                      <option value="3">방문 간호</option>
                    </select>
                    <span class="select-arrow">▾</span>
                  </div>
                </div>
  
                <div class="schedule-fields">
                  <div class="field-row">
                    <div class="field-label">날짜:</div>
                    <input v-model="date" type="date" class="field-input" />
                  </div>
  
                  <div class="field-row">
                    <div class="field-label">시작:</div>
                    <input v-model="startTime" type="time" class="field-input" />
                  </div>
  
                  <div class="field-row">
                    <div class="field-label">종료:</div>
                    <input v-model="endTime" type="time" class="field-input" />
                  </div>
                </div>
  
                <button class="create-btn" type="button" @click="onClickCreate">
                  일정 생성하기
                </button>
              </div>
            </div>
          </div>
  
          <div class="modal-footer">
            <button class="btn" type="button" @click="emit('close')">닫기</button>
          </div>
        </div>
      </div>
    </teleport>
  </template>
  
  <script setup>
    import { ref, computed, watch } from 'vue'
    import RecipientMatchingList from '@/components/schedule/matching/RecipientMatchingList.vue'
    import CaregiverMatchingList from '@/components/schedule/matching/CaregiverMatchingList.vue'
    
    const props = defineProps({
      show: { type: Boolean, default: false },
    })
    
    const emit = defineEmits(['close', 'create'])
    
    const memo = ref('')
    const serviceTypeId = ref('')
    
    const selectedRecipient = ref(null)
    const selectedCaregiver = ref(null)
    
    const date = ref('')
    const startTime = ref('06:00')
    const endTime = ref('06:00')
    
    watch(
      () => props.show,
      (v) => {
        if (!v) return
    
        // 모달 열릴 때 초기화
        startTime.value = '06:00'
        endTime.value = '06:00'
        serviceTypeId.value = ''
        memo.value = ''
    
        selectedRecipient.value = null
        selectedCaregiver.value = null
        date.value = ''
      }
    )
    
    const toDateTimeString = (d, t) => {
      if (!d || !t) return ''
      return `${d}T${t}:00` // LocalDateTime용 ISO 형태
    }
    
    const startDt = computed(() => toDateTimeString(date.value, startTime.value))
    const endDt = computed(() => toDateTimeString(date.value, endTime.value))
    
    const beneficiaryId = computed(
      () => selectedRecipient.value?.beneficiaryId ?? selectedRecipient.value?.id ?? null
    )
    
    const careWorkerId = computed(
      () => selectedCaregiver.value?.careWorkerId ?? selectedCaregiver.value?.id ?? null
    )
    
    const serviceTypeIdNum = computed(() => {
      const v = String(serviceTypeId.value).trim()
      return v ? Number(v) : null
    })
    
    const canFetchCaregivers = computed(() => {
      return (
        !!beneficiaryId.value &&
        !!serviceTypeIdNum.value &&
        !!startDt.value &&
        !!endDt.value
      )
    })
    
    watch(
      () => [beneficiaryId.value, serviceTypeIdNum.value, startDt.value, endDt.value],
      () => {
        // 조건 바뀌면 선택한 요양보호사는 무효 처리
        selectedCaregiver.value = null
      }
    )
    
    const onSelectRecipient = (item) => {
      selectedRecipient.value = item
      selectedCaregiver.value = null
    }
    
    const onSelectCaregiver = (item) => {
      selectedCaregiver.value = item
    }
    
    const onClickCreate = () => {
      if (!beneficiaryId.value || !careWorkerId.value || !serviceTypeIdNum.value || !startDt.value || !endDt.value) {
        alert('수급자/요양보호사/서비스유형/날짜/시간을 모두 선택해 주세요.')
        return
      }
    
      emit('create', {
        beneficiaryId: beneficiaryId.value,
        careWorkerId: careWorkerId.value,
        serviceTypeId: serviceTypeIdNum.value,
        startDt: startDt.value,
        endDt: endDt.value,
        note: memo.value,
      })
    }
    </script>
  
  <style scoped>
  .overlay {
    position: fixed;
    inset: 0;
    background: rgba(15, 23, 42, 0.45);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
  }
  
  .modal {
    width: 1200px;
    max-width: calc(100vw - 40px);
    max-height: calc(100vh - 80px);
    background: #fff;
    border-radius: 14px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 18px 48px rgba(15, 23, 42, 0.18);
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }
  
  .modal-header {
    padding: 16px 18px;
    border-bottom: 1px solid #e2e8f0;
  }
  
  .modal-title {
    margin: 0;
    font-size: 16px;
    font-weight: 700;
  }
  
  .modal-body {
    padding: 14px 18px;
    overflow: hidden;
  }
  
  .grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 16px;
    height: 100%;
  }
  
  .memo-area {
    display: flex;
    flex-direction: column;
    height: 100%;
  }
  
  .memo {
    flex: 1;
    resize: none;
    border: 1px solid #e2e8f0;
    border-radius: 10px;
    padding: 12px;
    font-size: 14px;
    outline: none;
  }
  
  .memo:focus {
    border-color: rgba(0, 201, 80, 0.55);
    box-shadow: 0 0 0 4px rgba(0, 201, 80, 0.12);
  }
  
  .service-type {
    margin-top: 12px;
    display: flex;
    flex-direction: column;
    gap: 6px;
  }
  
  .service-label {
    font-size: 13px;
    font-weight: 600;
    color: #64748b;
  }
  
  .select-wrap {
    position: relative;
  }
  
  .service-select {
    width: 100%;
    height: 42px;
    border-radius: 10px;
    border: 1px solid #e2e8f0;
    padding: 0 38px 0 12px;
    font-size: 14px;
    background: #fff;
    color: #0f172a;
    outline: none;
    appearance: none;
  }
  
  .service-select:hover {
    background: #f8fafc;
  }
  
  .service-select:focus {
    border-color: rgba(0, 201, 80, 0.55);
    box-shadow: 0 0 0 4px rgba(0, 201, 80, 0.12);
  }
  
  .select-arrow {
    position: absolute;
    right: 12px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 14px;
    color: #64748b;
    pointer-events: none;
  }
  
  .schedule-fields {
    margin-top: 12px;
    border-top: 1px solid #f1f5f9;
    padding-top: 12px;
    display: flex;
    flex-direction: column;
    gap: 10px;
  }
  
  .field-row {
    display: grid;
    grid-template-columns: 56px 1fr;
    align-items: center;
    gap: 10px;
  }
  
  .field-label {
    font-size: 14px;
    font-weight: 600;
    color: #64748b;
  }
  
  .field-input {
    width: 100%;
    border: none;
    outline: none;
    background: transparent;
    font-size: 16px;
    color: #0f172a;
    padding: 6px 0;
    border-bottom: 1px solid #e2e8f0;
  }
  
  .create-btn {
    margin-top: 12px;
    padding: 12px 0;
    border-radius: 10px;
    border: none;
    background: #00c950;
    color: #fff;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
  }
  
  .modal-footer {
    padding: 12px 18px;
    border-top: 1px solid #e2e8f0;
    display: flex;
    justify-content: flex-end;
  }
  
  .btn {
    border: 1px solid #e2e8f0;
    background: #fff;
    border-radius: 10px;
    padding: 10px 14px;
    cursor: pointer;
  }
  
  .hint-box {
    height: 460px;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 25px;
  }
  
  .hint-card {
    width: 100%;
    height: 100%;
    border: 1px dashed #e2e8f0;
    border-radius: 16px;
    background: #f8fafc;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 14px;
    padding: 22px;
  }
  
  .hint-title {
    margin: 0;
    font-size: 15px;
    font-weight: 600;
    color: #0f172a;
    line-height: 1.3;
  }
  
  .hint-sub {
    margin: 6px 0 0;
    font-size: 12px;
    color: #64748b;
    line-height: 1.4;
  }
  </style>