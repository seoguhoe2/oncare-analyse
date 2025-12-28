<template>
  <div class="matching-form-container">
    
    <div class="form-header">
      <div class="title">수급자 매칭에 도움이 될 수 있습니다.</div>
      <div class="desc">고객과 요양보호사의 최적 매칭을 위한 정보입니다</div>
    </div>

    <div class="form-content">
      
      <div class="question-section">
        <div class="question-title">매치 태그</div>
        <div class="options-list">
          <div class="option-item" v-for="tag in matchTags" :key="tag.id" @click="toggleTag(tag.id)">
            <div class="checkbox" :class="{ checked: selectedTags.includes(tag.id) }">
              <div v-if="selectedTags.includes(tag.id)" class="check-mark"></div>
            </div>
            <span class="option-label">{{ tag.label }}</span>
          </div>
        </div>
      </div>

      <div class="question-section">
        <div class="question-title">위험요소 수집</div>
        <div class="options-list">
          <div class="option-item" v-for="risk in riskFactors" :key="risk.id" @click="toggleRisk(risk.id)">
            <div class="checkbox" :class="{ checked: selectedRisks.includes(risk.id) }">
              <div v-if="selectedRisks.includes(risk.id)" class="check-mark"></div>
            </div>
            <span class="option-label">{{ risk.label }}</span>
          </div>
        </div>
      </div>

      <div class="question-section last-section">
        <div class="question-title">어떤 서비스를 희망하시나요?</div>
        <div class="options-list">
          <div class="option-item" v-for="service in services" :key="service.id" @click="toggleService(service.id)">
            <div class="checkbox" :class="{ checked: selectedServices.includes(service.id) }">
              <div v-if="selectedServices.includes(service.id)" class="check-mark"></div>
            </div>
            <span class="option-label">{{ service.label }}</span>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

// [1] 매치 태그 데이터
const matchTags = [
  { id: 'talk', label: '말벗' },
  { id: 'walk', label: '산책' },
  { id: 'music', label: '음악' },
  { id: 'movie', label: '영화' },
  { id: 'game', label: '게임' },
  { id: 'calligraphy', label: '서예' },
  { id: 'cooking', label: '요리' },
];
const selectedTags = ref([]);
const toggleTag = (id) => {
  if (selectedTags.value.includes(id)) {
    selectedTags.value = selectedTags.value.filter(t => t !== id);
  } else {
    selectedTags.value.push(id);
  }
};

// [2] 위험요소 데이터
const riskFactors = [
  { id: 'stroke', label: '뇌졸증' },
  { id: 'dementia', label: '치매' },
  { id: 'mobility', label: '거동불편' },
  { id: 'diabetes', label: '당뇨' },
  { id: 'hypertension', label: '고혈압' },
  { id: 'aggression', label: '공격성' },
  { id: 'sleepwalking', label: '몽유병' },
  { id: 'fall', label: '낙상위험' },
  { id: 'bedsore', label: '욕창위험' },
];
const selectedRisks = ref([]);
const toggleRisk = (id) => {
  if (selectedRisks.value.includes(id)) {
    selectedRisks.value = selectedRisks.value.filter(r => r !== id);
  } else {
    selectedRisks.value.push(id);
  }
};

// [3] 희망 서비스 데이터
const services = [
  { id: 'bath', label: '방문목욕' },
  { id: 'nursing', label: '방문간호' },
  { id: 'care', label: '방문요양' },
];
const selectedServices = ref([]);
const toggleService = (id) => {
  if (selectedServices.value.includes(id)) {
    selectedServices.value = selectedServices.value.filter(s => s !== id);
  } else {
    selectedServices.value.push(id);
  }
};
</script>

<style scoped>
.matching-form-container {
  width: 100%;
  padding: 24px;
  background: #F9FAFB;
  border-radius: 14px;
  display: flex;
  flex-direction: column;
  gap: 24px;
  box-sizing: border-box;
}

/* 헤더 스타일 */
.form-header {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.title {
  color: #101828;
  font-size: 16px;
  font-weight: 400;
  line-height: 24px;
}

.desc {
  color: #6A7282;
  font-size: 14px;
  font-weight: 400;
  line-height: 20px;
}

/* 컨텐츠 영역 */
.form-content {
  display: flex;
  flex-direction: column;
  gap: 16px; /* 섹션 간 간격 */
}

/* 각 질문 섹션 */
.question-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding-bottom: 24px; /* 섹션 하단 여백 */
  border-bottom: 1px solid #E5E7EB;
}

.question-section.last-section {
  border-bottom: none;
  padding-bottom: 0;
}

.question-title {
  color: #101828;
  font-size: 16px;
  font-weight: 400;
  line-height: 24px;
}

/* 옵션 리스트 (세로 나열) */
.options-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.option-item {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  width: fit-content; /* 클릭 영역을 텍스트 길이만큼 */
}

/* 체크박스 스타일 (커스텀) */
.checkbox {
  width: 16px;
  height: 16px;
  background: #F3F3F5;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 4px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
  display: flex;
  justify-content: center;
  align-items: center;
  transition: all 0.2s;
}

.checkbox.checked {
  background: #3B82F6; /* 선택 시 파란색 (테마에 맞춤) */
  border-color: #3B82F6;
}

.check-mark {
  width: 4px;
  height: 8px;
  border: solid white;
  border-width: 0 2px 2px 0;
  transform: rotate(45deg);
  margin-bottom: 2px;
}

.option-label {
  color: #0A0A0A;
  font-size: 14px;
  line-height: 14px;
  user-select: none; /* 드래그 방지 */
}
</style>