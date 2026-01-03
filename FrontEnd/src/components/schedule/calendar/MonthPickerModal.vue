<template>
    <div class="month-picker-backdrop" @click="$emit('close')">
      <div class="month-picker" @click.stop>
        <div class="head">
          <div class="title">{{ title }}</div>
          <button type="button" class="icon-close" @click="$emit('close')">✕</button>
        </div>
  
        <div class="ym-row">
          <!-- ✅ YEAR -->
          <div class="picker-col">
            <button
              ref="yearBtn"
              type="button"
              class="picker-btn"
              @click="toggleOpen('year')"
            >
              <span class="picker-text">{{ tempYear }}년</span>
              <span class="caret">▾</span>
            </button>
  
            <div
              v-if="open === 'year'"
              class="dropdown"
              :style="{ width: `${dropdownWidthYear}px` }"
            >
              <div class="list">
                <button
                  v-for="y in yearOptions"
                  :key="y"
                  type="button"
                  class="list-item"
                  :class="{ active: y === tempYear }"
                  @click="selectYear(y)"
                >
                  <span>{{ y }}년</span>
                  <span v-if="y === tempYear" class="check">✓</span>
                </button>
              </div>
            </div>
          </div>
  
          <!-- ✅ MONTH -->
          <div class="picker-col">
            <button
              ref="monthBtn"
              type="button"
              class="picker-btn"
              @click="toggleOpen('month')"
            >
              <span class="picker-text">{{ String(tempMonth).padStart(2, '0') }}월</span>
              <span class="caret">▾</span>
            </button>
  
            <div
              v-if="open === 'month'"
              class="dropdown"
              :style="{ width: `${dropdownWidthMonth}px` }"
            >
              <div class="list grid">
                <button
                  v-for="m in 12"
                  :key="m"
                  type="button"
                  class="list-item"
                  :class="{ active: m === tempMonth }"
                  @click="selectMonth(m)"
                >
                  <span>{{ String(m).padStart(2, '0') }}월</span>
                  <span v-if="m === tempMonth" class="check">✓</span>
                </button>
              </div>
            </div>
          </div>
        </div>
  
        <div class="actions">
          <button type="button" class="btn ghost" @click="$emit('close')">취소</button>
          <button type="button" class="btn primary" @click="$emit('apply')">적용</button>
        </div>
      </div>
    </div>
  </template>
  
<script setup>
  import { ref, watch, nextTick, onMounted, onBeforeUnmount } from 'vue'

    const props = defineProps({
    title: { type: String, default: '년/월 선택' },
    yearValue: { type: Number, required: true },
    monthValue: { type: Number, required: true },
    yearOptions: { type: Array, default: () => [] },
    })

    const emit = defineEmits(['close', 'apply', 'update:yearValue', 'update:monthValue'])

    const open = ref(null)
    const tempYear = ref(props.yearValue)
    const tempMonth = ref(props.monthValue)

    watch(
    () => [props.yearValue, props.monthValue],
    () => {
        tempYear.value = props.yearValue
        tempMonth.value = props.monthValue
    }
    )

    const yearBtn = ref(null)
    const monthBtn = ref(null)
    const dropdownWidthYear = ref(0)
    const dropdownWidthMonth = ref(0)

    const measureWidths = () => {
    dropdownWidthYear.value = yearBtn.value?.getBoundingClientRect?.().width || 0
    dropdownWidthMonth.value = monthBtn.value?.getBoundingClientRect?.().width || 0
    }

    const toggleOpen = async (type) => {
    open.value = open.value === type ? null : type
    await nextTick()
    measureWidths()
    }

    const selectYear = (y) => {
    tempYear.value = y
    emit('update:yearValue', y)
    open.value = null
    }

    const selectMonth = (m) => {
    tempMonth.value = m
    emit('update:monthValue', m)
    open.value = null
    }

    const onResize = () => measureWidths()

    const lockBodyScroll = () => {
    const scrollY = window.scrollY || document.documentElement.scrollTop || 0
    document.body.dataset.scrollY = String(scrollY)
    document.body.style.position = 'fixed'
    document.body.style.top = `-${scrollY}px`
    document.body.style.left = '0'
    document.body.style.right = '0'
    document.body.style.width = '100%'
    }

    const unlockBodyScroll = () => {
    const y = Number(document.body.dataset.scrollY || 0)
    document.body.style.position = ''
    document.body.style.top = ''
    document.body.style.left = ''
    document.body.style.right = ''
    document.body.style.width = ''
    delete document.body.dataset.scrollY
    window.scrollTo(0, y)
    }

    onMounted(async () => {
    lockBodyScroll()
    await nextTick()
    measureWidths()
    window.addEventListener('resize', onResize)
    })

    onBeforeUnmount(() => {
    window.removeEventListener('resize', onResize)
    unlockBodyScroll()
    })
</script>
  
  <style scoped>
  .month-picker-backdrop {
    position: fixed;
    inset: 0;
    background: rgba(15, 23, 42, 0.35);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 999;
  }
  
  .month-picker {
    width: 360px;
    background: #fff;
    border-radius: 16px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 12px 36px rgba(15, 23, 42, 0.18);
    padding: 14px;
  }
  
  .head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 12px;
  }
  
  .title {
    font-size: 14px;
    font-weight: 700;
    color: #0f172a;
  }
  
  .icon-close {
    width: 30px;
    height: 30px;
    border-radius: 10px;
    border: 1px solid #e2e8f0;
    background: #fff;
    cursor: pointer;
    font-size: 14px;
    line-height: 1;
  }
  
  .ym-row {
    display: flex;
    gap: 10px;
  }
  
  .picker-col {
    position: relative;
    flex: 1;
  }
  
  .picker-btn {
    width: 100%;
    height: 44px;
    border-radius: 12px;
    border: 1px solid #e2e8f0;
    background: #fff;
    padding: 0 12px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    cursor: pointer;
  }
  
  .picker-text {
    font-size: 14px;
    color: #0f172a;
    font-weight: 600;
  }
  
  .caret {
    color: #64748b;
  }
  
  /* ✅ 드롭다운: 버튼 폭 그대로 */
  .dropdown {
    position: absolute;
    top: calc(44px + 8px);
    left: 0;
    border: 1px solid #e2e8f0;
    border-radius: 14px;
    overflow: hidden;
    background: #fff;
    box-shadow: 0 10px 24px rgba(15, 23, 42, 0.12);
    z-index: 2;
  }
  
  .list {
    max-height: 220px;
    overflow: auto;
  }
  
  .list.grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    max-height: none;
  }
  
  .list-item {
    width: 100%;
    border: none;
    background: #fff;
    cursor: pointer;
    padding: 12px 12px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 13px;
    color: #0f172a;
    border-top: 1px solid #f1f5f9;
  }
  
  .list-item:first-child {
    border-top: none;
  }
  
  .list-item:hover {
    background: #f8fafc;
  }
  
  .list-item.active {
    background: #f0fdf4;
  }
  
  .check {
    color: #22c55e;
    font-weight: 800;
  }
  
  .actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 14px;
  }
  
  .btn {
    height: 40px;
    padding: 0 14px;
    border-radius: 12px;
    border: 1px solid #e2e8f0;
    background: #fff;
    cursor: pointer;
    font-size: 13px;
  }
  
  .btn.primary {
    border-color: #22c55e;
  }
  .btn.primary:hover {
    background: #f0fdf4;
  }
  </style>