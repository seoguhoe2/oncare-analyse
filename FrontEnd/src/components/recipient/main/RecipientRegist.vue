<template>
  <!-- suggesting 제거 -->
  <Teleport to="body">
    <div v-if="visible" class="overlay">
      <div class="modal">
        <header class="modal-header">
          <h3>수급자 정보 수정</h3>
          <button type="button" class="close-btn" @click="$emit('close')">✕</button>
        </header>

        <form class="modal-body" @submit.prevent="submit">
          <!-- 1줄 : 이름 / 생년월일 -->
          <div class="grid-2">
            <label class="form-field">
              <span class="form-label">이름</span>
              <input v-model="form.name" class="form-input" type="text" />
            </label>

            <label class="form-field">
              <span class="form-label">생년월일</span>
              <input v-model="form.birthdate" class="form-input date-input" type="date" />
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
            <input v-model="form.address" class="form-input" type="text" />
          </label>

          <!-- 보호자명 / 보호자관계 / 보호자 연락처 -->
          <div class="grid-3">
            <div class="grid-3-left">
              <label class="form-field">
                <span class="form-label">보호자명</span>
                <input
                  v-model="form.guardianName"
                  class="form-input"
                  type="text"
                  placeholder="예: 김민준"
                />
              </label>

              <label class="form-field">
                <span class="form-label">관계</span>
                <select v-model="form.guardianRelation" class="form-input">
                  <option value="">선택</option>
                  <option v-for="rel in relationOptions" :key="rel" :value="rel">
                    {{ rel }}
                  </option>
                </select>
              </label>
            </div>

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
              <select v-model="form.careLevelId" class="form-input" :disabled="metaLoading">
                <option :value="null">선택</option>
                <option v-for="lvl in careLevelOptions" :key="lvl.id" :value="lvl.id">
                  {{ lvl.label }}
                </option>
              </select>
            </label>

            <label class="form-field">
              <span class="form-label">장기요양등급 만료일</span>
              <input v-model="form.careLevelEndDate" class="form-input date-input" type="date" />
            </label>
          </div>

          <!-- 인정번호 -->
          <label class="form-field">
            <span class="form-label">장기요양등급 인정번호</span>
            <input v-model="form.careLevelNumber" class="form-input" type="text" />
          </label>

          <!-- ✅ 태그 (다중 선택) : API로 가져온 options -->
          <div class="form-field">
            <div class="field-head">
              <span class="form-label">태그</span>
              <span v-if="metaLoading" class="meta-hint">불러오는 중...</span>
              <span v-else-if="metaError" class="meta-hint error">옵션 로드 실패</span>
            </div>

            <div class="chip-group">
              <button
                v-for="tag in tagOptions"
                :key="tag.id"
                type="button"
                class="chip-btn"
                :class="{ active: form.tagIds.includes(tag.id) }"
                :disabled="metaLoading || metaError"
                @click="toggleTag(tag.id)"
              >
                {{ tag.label }}
              </button>

              <div v-if="!metaLoading && tagOptions.length === 0" class="empty-meta">
                등록된 태그가 없습니다.
              </div>
            </div>
          </div>

          <!-- ✅ 위험 요소 (다중 선택) : API로 가져온 options -->
          <div class="form-field">
            <div class="field-head">
              <span class="form-label">위험 요소</span>
              <span v-if="metaLoading" class="meta-hint">불러오는 중...</span>
              <span v-else-if="metaError" class="meta-hint error">옵션 로드 실패</span>
            </div>

            <div class="chip-group">
              <button
                v-for="risk in riskOptions"
                :key="risk.id"
                type="button"
                class="chip-btn"
                :class="{ active: form.riskFactorIds.includes(risk.id) }"
                :disabled="metaLoading || metaError"
                @click="toggleRisk(risk.id)"
              >
                {{ risk.label }}
              </button>

              <div v-if="!metaLoading && riskOptions.length === 0" class="empty-meta">
                등록된 위험요소가 없습니다.
              </div>
            </div>
          </div>

          <!-- 버튼 -->
          <footer class="modal-footer">
            <button type="submit" class="btn-submit" :disabled="saving || metaLoading">
              {{ saving ? '저장 중...' : metaLoading ? '옵션 로딩 중...' : '수정' }}
            </button>
            <button type="button" class="btn-cancel" @click="$emit('close')">취소</button>
          </footer>
        </form>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { reactive, ref, watch } from 'vue'
import api from '@/lib/api'

const props = defineProps({
  visible: { type: Boolean, default: false },
  // ✅ 어떤 수급자를 수정할지 반드시 필요
  beneficiaryId: { type: Number, default: null }
})

const emit = defineEmits(['close', 'updated'])

const saving = ref(false)

/** ✅ 관계 옵션(고정 UI) */
const relationOptions = ['아들', '딸', '손자', '손녀', '친구', '기타']

/** ✅ (중요) 하드코딩 제거: 서버에서 옵션 받아서 넣을 ref 배열 */
const tagOptions = ref([])      // [{id, label}]
const riskOptions = ref([])     // [{id, label}]
const careLevelOptions = ref([]) // [{id, label, validity?, monthlyLimit?}]

/** ✅ 옵션 로딩 상태 */
const metaLoading = ref(false)
const metaError = ref(false)
const metaLoaded = ref(false)

const form = reactive({
  // beneficiary
  name: '',
  birthdate: '',
  phone: '',
  gender: '',
  address: '',
  // status는 화면엔 없지만 PUT에 필요해서 내부 보관
  status: 1,

  // guardian
  guardianName: '',
  guardianRelation: '',
  guardianPhone: '',

  // care level
  careLevelId: null,
  careLevelEndDate: '',
  careLevelNumber: '',

  // multi
  tagIds: [],
  riskFactorIds: []
})

const resetForm = () => {
  form.name = ''
  form.birthdate = ''
  form.phone = ''
  form.gender = ''
  form.address = ''
  form.status = 1

  form.guardianName = ''
  form.guardianRelation = ''
  form.guardianPhone = ''

  form.careLevelId = null
  form.careLevelEndDate = ''
  form.careLevelNumber = ''

  form.tagIds = []
  form.riskFactorIds = []
}

/**
 * ✅ 마스터 옵션 API 연동 (백엔드에서 이미 추가했다고 했던 메타 API들)
 * - GET /api/beneficiaries/meta/tags         -> [{id,label}]
 * - GET /api/beneficiaries/meta/risk-factors -> [{id,label}]
 * - GET /api/beneficiaries/meta/care-levels  -> [{id,label,validity,monthlyLimit}]
 *
 * ⚠️ 응답 키가 label이 아니라 name이면 아래 map에서 흡수하도록 해둠.
 */
const fetchMetaOnce = async () => {
  if (metaLoaded.value) return

  metaLoading.value = true
  metaError.value = false
  try {
    const [tagsRes, risksRes, levelsRes] = await Promise.all([
      api.get('/api/beneficiaries/meta/tags'),
      api.get('/api/beneficiaries/meta/risk-factors'),
      api.get('/api/beneficiaries/meta/care-levels')
    ])

    // ✅ 안전하게 배열인지 확인 + label/name 흡수
    tagOptions.value = (Array.isArray(tagsRes.data) ? tagsRes.data : [])
      .map((t) => ({ id: t.id, label: t.label ?? t.name ?? t.tag ?? '' }))
      .filter((t) => typeof t.id === 'number' && t.label)

    riskOptions.value = (Array.isArray(risksRes.data) ? risksRes.data : [])
      .map((r) => ({ id: r.id, label: r.label ?? r.name ?? '' }))
      .filter((r) => typeof r.id === 'number' && r.label)

    careLevelOptions.value = (Array.isArray(levelsRes.data) ? levelsRes.data : [])
      .map((c) => ({
        id: c.id,
        label: c.label ?? c.level ?? '',
        validity: c.validity,
        monthlyLimit: c.monthlyLimit
      }))
      .filter((c) => typeof c.id === 'number' && c.label)

    metaLoaded.value = true
  } catch (e) {
    console.error(e)
    metaError.value = true
    // ✅ 옵션 로드 실패 시 빈 배열 유지(선택 불가 처리)
    tagOptions.value = []
    riskOptions.value = []
    careLevelOptions.value = []
  } finally {
    metaLoading.value = false
  }
}

/**
 * ✅ 상세조회 값을 폼에 채우기
 * - tagOptions(마스터)를 받은 뒤에 해야 label->id 매핑이 정확함
 */
const hydrateFromDetail = (d) => {
  // 기본
  form.name = d?.name ?? ''
  form.phone = d?.phone ?? ''
  form.address = d?.address ?? ''
  form.birthdate = d?.birthdate ?? ''
  form.gender = d?.gender ?? ''

  // status: 상세조회는 '서비스 중'/'서비스 해지' 문자열이므로 숫자로 변환
  form.status = d?.status === '서비스 해지' ? 0 : 1

  // 보호자
  form.guardianName = d?.guardianName ?? ''
  form.guardianRelation = d?.guardianRelation ?? ''
  form.guardianPhone = d?.guardianPhone ?? ''

  // 등급 만료일
  form.careLevelEndDate = d?.careLevelEndDate ?? ''

  /**
   * ✅ 등급 id 세팅
   * - 상세조회 응답이 careLevel: "1등급" 같은 라벨이면 label->id로 매핑
   * - 만약 백엔드가 careLevelId까지 내려주면 그 값을 우선 사용
   */
  if (typeof d?.careLevelId === 'number') {
    form.careLevelId = d.careLevelId
  } else {
    const careLabel = d?.careLevel
    form.careLevelId =
      careLevelOptions.value.find((x) => x.label === careLabel)?.id ?? null
  }

  // 인정번호
  form.careLevelNumber = d?.careLevelNumber ?? ''

  /**
   * ✅ 태그 매핑
   * - 상세조회: tags: ["말벗","산책"]
   * - label -> id 매핑은 "서버에서 받은 tagOptions"로 수행(하드코딩 제거)
   */
  const tags = Array.isArray(d?.tags) ? d.tags : []
  form.tagIds = tags
    .map((t) => tagOptions.value.find((x) => x.label === t)?.id)
    .filter((id) => typeof id === 'number')

  /**
   * ✅ 위험요소 매핑
   * - 상세조회: riskFactors: [{id,name,score}]
   * - id로 바로 세팅(가장 안전)
   */
  const risks = Array.isArray(d?.riskFactors) ? d.riskFactors : []
  form.riskFactorIds = risks
    .map((r) => r?.id)
    .filter((id) => typeof id === 'number')
}

const fetchDetail = async () => {
  if (!props.beneficiaryId) return
  const { data } = await api.get(`/api/beneficiaries/${props.beneficiaryId}`)
  hydrateFromDetail(data)
}

/**
 * ✅ 모달이 열릴 때 동작 순서
 * 1) reset
 * 2) 메타(태그/위험요소/등급) 로드
 * 3) 상세 조회 후 프리필
 */
watch(
  () => props.visible,
  async (v) => {
    if (!v) return
    resetForm()

    // ✅ 마스터 옵션 먼저 (label->id 매핑 위해 필수)
    await fetchMetaOnce()

    if (props.beneficiaryId) {
      try {
        await fetchDetail()
      } catch (e) {
        console.error(e)
        // 프리필 실패해도 모달은 열리게 유지
      }
    }
  }
)

const toggleTag = (tagId) => {
  const idx = form.tagIds.indexOf(tagId)
  if (idx === -1) form.tagIds.push(tagId)
  else form.tagIds.splice(idx, 1)
}

const toggleRisk = (riskId) => {
  const idx = form.riskFactorIds.indexOf(riskId)
  if (idx === -1) form.riskFactorIds.push(riskId)
  else form.riskFactorIds.splice(idx, 1)
}

const submit = async () => {
  if (!props.beneficiaryId) return

  // ✅ 옵션 로딩 실패 상태면 잘못 저장 위험 → 막기
  if (metaError.value) {
    alert('태그/위험요소 옵션을 불러오지 못해 저장할 수 없습니다.\n잠시 후 다시 시도해주세요.')
    return
  }

  saving.value = true
  try {
    // ✅ 백엔드 컬럼명에 맞춘 payload
    const payload = {
      name: form.name,
      phone: form.phone,
      address: form.address,
      birthdate: form.birthdate,
      gender: form.gender,
      status: form.status,

      guardianName: form.guardianName,
      guardianPhone: form.guardianPhone,
      guardianRelation: form.guardianRelation,

      careLevelId: form.careLevelId,
      careLevelEndDate: form.careLevelEndDate,

      // number는 Long이라 숫자로 보내는 게 안전 (빈값이면 null)
      careLevelNumber:
        form.careLevelNumber === '' || form.careLevelNumber == null
          ? null
          : Number(form.careLevelNumber),

      // ✅ id 기반 (정합성)
      tagIds: form.tagIds,
      riskFactorIds: form.riskFactorIds
    }

    const { data } = await api.put(`/api/beneficiaries/${props.beneficiaryId}`, payload)

    emit('updated', data)
    emit('close')
  } catch (e) {
    console.error(e)
  } finally {
    saving.value = false
  }
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

.grid-3 {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px 14px;
  margin-bottom: 10px;
}

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

.field-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.meta-hint {
  font-size: 12px;
  color: #9ca3af;
}
.meta-hint.error {
  color: #ef4444;
}
.empty-meta {
  font-size: 12px;
  color: #9ca3af;
  padding: 6px 2px;
}

.date-input {
}

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
.chip-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
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
.btn-submit:disabled {
  opacity: 0.6;
  cursor: not-allowed;
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
