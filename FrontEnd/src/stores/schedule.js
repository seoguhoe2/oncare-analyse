import { defineStore } from 'pinia';
import { ref } from 'vue';

/**
 * 일정 상태 관리 스토어
 * - 일정 등록/수정/삭제 시 다른 컴포넌트에 알림
 */
export const useScheduleStore = defineStore('schedule', () => {
  // 일정이 변경되었을 때 증가하는 카운터
  const scheduleUpdateCounter = ref(0);

  // 일정이 업데이트되었음을 알림
  const notifyScheduleUpdate = () => {
    scheduleUpdateCounter.value++;
    console.log('📅 일정 업데이트 알림 발생:', scheduleUpdateCounter.value);
  };

  return {
    scheduleUpdateCounter,
    notifyScheduleUpdate,
  };
});
