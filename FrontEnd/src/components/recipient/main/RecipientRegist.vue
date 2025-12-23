<template>
  <Teleport to="body">
    <div v-if="visible" class="overlay">
      <div class="modal">
        <header class="modal-header">
          <h3>수급자 등록</h3>
          <button type="button" class="close-btn" @click="$emit('close')">
            ✕
          </button>
        </header>

        <form class="modal-body" @submit.prevent="submit">
          <!-- 1줄 : 이름 / 생년월일 -->
          <div class="grid-2">
            <label class="form-field">
              <span class="form-label">이름</span>
              <input
                v-model="form.name"
                class="form-input"
                type="text"
              />
            </label>

            <label class="form-field">
              <span class="form-label">생년월일</span>
              <!-- ✅ 달력 아이콘 + 캘린더 팝업 (브라우저 기본) -->
              <input
                v-model="form.birth"
                class="form-input date-input"
                type="date"
              />
            </label>
          </div>

          <!-- 2줄 : 연락처 / 성별 -->
          <div class="grid-2">
            <label class="form-field">
              <span class="form-label">연락처</span>
              <input
                v-model="form.phone"
                class="form-input"
                type="text"
                placeholder="010-0000-0000"
              />
            </label>

            <label class="form-field">
              <span class="form-label">성별</span>
              <select v-model="form.gender" class="form-input">
                <option value="">선택</option>
                <option value="M">남자</option>
                <option value="F">여자</option>
              </select>
            </label>
          </div>

          <!-- 주소 -->
          <label class="form-field">
            <span class="form-label">주소</span>
            <input
              v-model="form.address"
              class="form-input"
              type="text"
            />
          </label>

          <!-- 보호자명 / 보호자관계 / 보호자 연락처 -->
          <div class="grid-3">
            <!-- 왼쪽: 보호자명(70) + 관계(30) -->
            <div class="grid-3-left">
              <!-- 보호자명 -->
              <label class="form-field">
                <span class="form-label">보호자명</span>
                <input
                  v-model="form.guardianName"
                  class="form-input"
                  type="text"
                  placeholder="예: 김민준"
                />
              </label>

              <!-- 보호자관계 -->
              <label class="form-field">
                <span class="form-label">관계</span>
                <select v-model="form.guardianRelation" class="form-input">
                  <option value="">선택</option>
                  <option
                    v-for="rel in relationOptions"
                    :key="rel"
                    :value="rel"
                  >
                    {{ rel }}
                  </option>
                </select>
              </label>
            </div>

            <!-- 오른쪽: 보호자 연락처 (반) -->
            <label class="form-field">
              <span class="form-label">보호자 연락처</span>
              <input
                v-model="form.guardianPhone"
                class="form-input"
                type="text"
                placeholder="010-0000-0000"
              />
            </label>
          </div>

          <!-- 장기요양등급 / 만료일 -->
          <div class="grid-2">
            <label class="form-field">
              <span class="form-label">장기요양등급</span>
              <select v-model="form.careLevel" class="form-input">
                <option value="">선택</option>
                <option
                  v-for="lvl in careLevelOptions"
                  :key="lvl"
                  :value="lvl"
                >
                  {{ lvl }}
                </option>
              </select>
            </label>

            <label class="form-field">
              <span class="form-label">장기요양등급 만료일</span>
              <!-- ✅ 여기도 date 타입으로 변경 -->
              <input
                v-model="form.careLevelExpiry"
                class="form-input date-input"
                type="date"
              />
            </label>
          </div>

          <!-- 인정번호 -->
          <label class="form-field">
            <span class="form-label">장기요양등급 인정번호</span>
            <input
              v-model="form.careLevelNumber"
              class="form-input"
              type="text"
            />
          </label>

          <!-- 태그 (다중 선택) -->
          <div class="form-field">
            <span class="form-label">태그</span>
            <div class="chip-group">
              <button
                v-for="tag in tagOptions"
                :key="tag"
                type="button"
                class="chip-btn"
                :class="{ active: form.tags.includes(tag) }"
                @click="toggleTag(tag)"
              >
                {{ tag }}
              </button>
            </div>
          </div>

          <!-- 위험 요소 (다중 선택) -->
          <div class="form-field">
            <span class="form-label">위험 요소</span>
            <div class="chip-group">
              <button
                v-for="risk in riskOptions"
                :key="risk"
                type="button"
                class="chip-btn"
                :class="{ active: form.riskElements.includes(risk) }"
                @click="toggleRisk(risk)"
              >
                {{ risk }}
              </button>
            </div>
          </div>

          <!-- 버튼 -->
          <footer class="modal-footer">
            <button type="submit" class="btn-submit">등록</button>
            <button
              type="button"
              class="btn-cancel"
              @click="$emit('close')"
            >
              취소
            </button>
          </footer>
        </form>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { reactive } from 'vue'

defineProps({
  visible: {
    type: Boolean,
    default: false
  }
})
const emit = defineEmits(['close', 'submit'])

/** 카테고리 옵션들 */
const relationOptions = ['아들', '딸', '손자', '손녀', '친구', '기타']
const tagOptions = ['말벗', '산책', '음악', '영화', '게임', '서예', '요리', '기타']
const riskOptions = [
  '뇌졸증',
  '치매',
  '거동불편',
  '당뇨',
  '고혈압',
  '공격성',
  '몽유병',
  '낙상위험',
  '욕창위험'
]
const careLevelOptions = [
  '1등급',
  '2등급',
  '3등급',
  '4등급',
  '5등급',
  '인지지원등급'
]

const form = reactive({
  name: '',
  birth: '',
  phone: '',
  gender: '',
  address: '',
  guardianName: '',
  guardianRelation: '',
  guardianPhone: '',
  careLevel: '',
  careLevelExpiry: '',
  careLevelNumber: '',
  // 다중 선택
  tags: [],
  riskElements: []
})

const toggleTag = (tag) => {
  const idx = form.tags.indexOf(tag)
  if (idx === -1) form.tags.push(tag)
  else form.tags.splice(idx, 1)
}

const toggleRisk = (risk) => {
  const idx = form.riskElements.indexOf(risk)
  if (idx === -1) form.riskElements.push(risk)
  else form.riskElements.splice(idx, 1)
}

const submit = () => {
  emit('submit', { ...form })
}
</script>

<style scoped>
.overlay {
  position: fixed;
  inset: 0;
  background-color: rgba(15, 23, 42, 0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 40;
  backdrop-filter: blur(3px);
}
.modal {
  width: 760px;
  max-width: calc(100% - 40px);
  background-color: #fff;
  border-radius: 14px;
  box-shadow: 0 20px 40px rgba(15, 23, 42, 0.3);
}
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 18px;
  border-bottom: 1px solid #e5e7eb;
}
.modal-header h3 {
  margin: 0;
  font-size: 16px;
}
.close-btn {
  border: none;
  background: transparent;
  cursor: pointer;
  font-size: 14px;
}

.modal-body {
  padding: 16px 18px 14px;
  font-size: 13px;
}
.grid-2 {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px 14px;
  margin-bottom: 10px;
}

/* 보호자 영역 : 좌/우 반반 */
.grid-3 {
  display: grid;
  grid-template-columns: 1fr 1fr;  /* 왼쪽(보호자명+관계) / 오른쪽(보호자 연락처) */
  gap: 10px 14px;
  margin-bottom: 10px;
}

/* 왼쪽 내부 : 보호자명 7 / 관계 3 */
.grid-3-left {
  display: grid;
  grid-template-columns: 7fr 3fr;
  gap: 10px 14px;
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-bottom: 10px;
}
.form-label {
  font-size: 12px;
  color: #6b7280;
}
.form-input {
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  padding: 6px 10px;
  font-size: 13px;
}

/* 날짜 인풋 공통 스타일 (필요하면 커스터마이징 가능) */
.date-input {
  /* 브라우저 기본 스타일 유지하면서 폭·높이만 폼과 맞추는 용도 */
}

/* 카테고리(칩) 스타일 */
.chip-group {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}
.chip-btn {
  border-radius: 999px;
  border: 1px solid #e5e7eb;
  padding: 4px 10px;
  font-size: 12px;
  background-color: #f9fafb;
  cursor: pointer;
}
.chip-btn.active {
  background-color: #22c55e;
  border-color: #16a34a;
  color: #fff;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 12px;
}
.btn-submit,
.btn-cancel {
  min-width: 90px;
  border-radius: 8px;
  padding: 8px 14px;
  font-size: 13px;
  cursor: pointer;
  border: none;
}
.btn-submit {
  background-color: #22c55e;
  color: #fff;
}
.btn-cancel {
  background-color: #f3f4f6;
  color: #4b5563;
}

@media (max-width: 720px) {
  .grid-2,
  .grid-3,
  .grid-3-left {
    grid-template-columns: 1fr;
  }
}
</style>
