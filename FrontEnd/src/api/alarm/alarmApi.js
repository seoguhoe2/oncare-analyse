import api from '@/lib/api';

const BASE_URL = '/api/alarms';

// 알림 목록 조회
export const getNotifications = async (userId) => {
    const response = await api.get(`${BASE_URL}/${userId}`);
    return response.data;
};

// 안 읽은 알림 개수 조회
export const getUnreadCount = async (userId) => {
    const response = await api.get(`${BASE_URL}/${userId}/unread-count`);
    return response.data;
};

// 알림 읽음 처리 (상태 변경)
export const markAsRead = async (alarmId) => {
    const response = await api.patch(`${BASE_URL}/${alarmId}/read`);
    return response.data;
};

// 알림 삭제 (DB 삭제)
export const deleteNotification = async (alarmId) => {
    const response = await api.delete(`${BASE_URL}/${alarmId}`);
    return response.data;
};

// 모든 알림 읽음 처리 (일괄)
export const markAllAsRead = async (userId) => {
    const response = await api.patch(`${BASE_URL}/read-all/${userId}`);
    return response.data;
};

// SSE 구독 URL 반환
export const getSubscriptionUrl = (userId) => {
    // 프록시 설정을 따르기 위해 상대 경로 사용
    return `${api.defaults.baseURL}${BASE_URL}/subscribe/${userId}`;
};
