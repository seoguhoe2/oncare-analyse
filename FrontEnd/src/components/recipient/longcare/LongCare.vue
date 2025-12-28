<template>
  <div class="card longcare-wrap">
    <header class="longcare-header">
      <h3>⚠ 장기요양등급 만료 예정</h3>

      <div class="filters">
        <button
          v-for="btn in rangeButtons"
          :key="btn.key"
          type="button"
          class="range-btn"
          :class="{ active: activeRange === btn.key }"
          @click="activeRange = btn.key"
        >
          {{ btn.label }}
        </button>
      </div>
    </header>

    <!-- 상태 -->
    <div v-if="loading" class="state">불러오는 중...</div>
    <div v-else-if="errorMsg" class="state error">{{ errorMsg }}</div>

    <div v-else class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>수급자명</th>
            <th>만료일</th>
            <th>담당요양사</th>
            <th>D-Day</th>
            <th>안내여부</th>
          </tr>
        </thead>

        <tbody>
          <tr
            v-for="row in filteredItems"
            :key="row.expirationId"
            :class="[
              'clickable-row',
              ddayClass(row.ddayNum),
              row.expirationId === selectedId ? 'is-active' : ''
            ]"
            @click="selectRow(row)"
          >
            <td>{{ row.beneficiaryName }}</td>
            <td>{{ row.endDate }}</td>
            <td>{{ row.careWorkerName || '-' }}</td>
            <td>
              <span class="dday-pill">{{ row.ddayLabel || '-' }}</span>
            </td>
            <td>
              <span
                v-if="String(row.noticeLabel || '').startsWith('완료')"
                class="status-pill complete"
              >
                {{ row.noticeLabel }}
              </span>
              <span v-else class="status-pill pending">
                {{ row.noticeLabel || '미완료' }}
              </span>
            </td>
          </tr>

          <tr v-if="filteredItems.length === 0">
            <td colspan="5" class="empty-row">표시할 항목이 없습니다.</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch, onMounted } from 'vue'
import api from '@/lib/api'

/**
 * ✅ v-model:selected-id 로 사용하기
 * - selectedId = expirationId
 */
const props = defineProps({
  items: { // (옵션) 외부에서 주입도 가능하게 열어둠
    type: Array,
    default: () => []
  },
  selectedId: {
    type: [Number, String, null],
    default: null
  }
})
const emit = defineEmits(['update:selectedId', 'select', 'loaded'])

const rangeButtons = [
  { key: 'all', label: '전체' },
  { key: '45', label: '45일 이내' },
  { key: '60', label: '60일 이내' },
  { key: '90', label: '90일 이내' }
]
const activeRange = ref('all')

const loading = ref(false)
const errorMsg = ref('')

/**
 * ✅ 서버에서 받아온 원본 리스트
 * - props.items 가 있으면 그걸 우선 사용
 * - 없으면 API 호출해서 채움
 */
const serverItems = ref([])

const parseDday = (ddayLabel) => {
  // "D-40" => 40
  const s = String(ddayLabel || '').trim()
  const m = s.match(/D-\s*(\d+)/i)
  return m ? Number(m[1]) : 999999
}

/**
 * ✅ 백엔드 응답 -> 화면에서 쓰는 row 형태로 정규화
 */
const normalized = computed(() => {
  const list = (props.items && props.items.length) ? props.items : serverItems.value
  return (list || []).map((it) => ({
    expirationId: it.expirationId,
    beneficiaryName: it.beneficiaryName,
    endDate: it.endDate,
    careWorkerName: it.careWorkerName,
    ddayLabel: it.ddayLabel,
    ddayNum: parseDday(it.ddayLabel),
    noticeLabel: it.noticeLabel,
    extendsStatus: it.extendsStatus,
    outboundStatus: it.outboundStatus,
    noticeCount: it.noticeCount,
    lastNoticeDate: it.lastNoticeDate
  }))
})

const filteredItems = computed(() => {
  // ✅ 백엔드가 extends_status가 NULL 또는 'Y'만 내려주도록 되어 있으므로
  // 프론트에서 굳이 한번 더 제외할 필요는 없지만,
  // 혹시 props.items로 들어오는 경우를 대비해 안전필터만 추가
  let list = normalized.value.filter((i) => i.extendsStatus !== 'N')

  if (activeRange.value === 'all') return list
  const limit = Number(activeRange.value)
  return list.filter((i) => i.ddayNum <= limit)
})

const ddayClass = (ddayNum) => {
  if (ddayNum <= 45) return 'row-red'
  if (ddayNum <= 60) return 'row-yellow'
  if (ddayNum <= 90) return 'row-normal'
  return ''
}

const selectRow = (row) => {
  emit('update:selectedId', row.expirationId)
  emit('select', row) // ✅ 부모가 row 자체도 받고 싶으면 사용
}

const fetchList = async () => {
  loading.value = true
  errorMsg.value = ''
  try {
    const { data } = await api.get('/api/care-level/expirations')
    serverItems.value = data?.items ?? []
    emit('loaded', serverItems.value)
  } catch (e) {
    console.error(e)
    errorMsg.value = '목록을 불러오지 못했습니다.'
    serverItems.value = []
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  // props.items로 받지 않는 경우만 API 호출
  if (!props.items || props.items.length === 0) fetchList()
})

// 부모에서 “완료 처리 후 목록 새로고침” 하고 싶을 때 쓸 수 있게 watch 예시
watch(
  () => props.items,
  (v) => {
    // 외부 items가 주입되면 API list 대신 그걸 표시
    // (별도 로직 없음)
  }
)
</script>

<style scoped>
.longcare-wrap {
  background-color: #fff;
  border-radius: 12px;
  padding: 14px 16px;
  box-shadow: 0 0 0 1px rgba(15, 23, 42, 0.04);
}
.longcare-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}
.longcare-header h3 {
  margin: 0;
  font-size: 15px;
}
.filters {
  display: flex;
  gap: 4px;
}
.range-btn {
  border: 1px solid #e5e7eb;
  background: #f9fafb;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 11px;
  cursor: pointer;
}
.range-btn.active {
  background-color: #111827;
  color: #fff;
}

/* 상태 */
.state {
  padding: 10px 0;
  font-size: 12px;
  color: #6b7280;
}
.state.error {
  color: #b91c1c;
}

/* 테이블 */
.table-wrap {
  overflow-x: auto;
}
table {
  width: 100%;
  border-collapse: collapse;
  font-size: 12px;
}
thead th {
  text-align: left;
  padding: 8px 10px;
  background-color: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
}
tbody td {
  padding: 8px 10px;
  border-bottom: 1px solid #f3f4f6;
}
.empty-row {
  text-align: center;
  color: #9ca3af;
  padding: 16px 10px;
}

/* 행 색 */
.row-red { background-color: #fef2f2; }
.row-yellow { background-color: #fff7ed; }
.row-normal { background-color: #fefce8; }

/* 선택 가능 행 */
.clickable-row { cursor: pointer; }
.clickable-row.is-active {
  outline: 2px solid rgba(34, 197, 94, 0.6);
  outline-offset: -2px;
}

/* D-day / 상태 */
.dday-pill {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 999px;
  background-color: #fee2e2;
  color: #b91c1c;
  font-size: 10px;
}
.status-pill {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 999px;
  font-size: 10px;
}
.status-pill.complete {
  background-color: #dcfce7;
  color: #15803d;
}
.status-pill.pending {
  background-color: #f3f4f6;
  color: #6b7280;
}
</style>
