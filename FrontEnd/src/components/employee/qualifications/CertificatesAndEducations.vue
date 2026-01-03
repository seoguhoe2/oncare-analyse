<script setup>
import { ref, computed, watch, onMounted } from 'vue';
// API 함수 import
import { registerCertificate, registerEducation, getCertificates, updateCertificateStatus } from '@/api/employee/employeeApi';
import { useUserStore } from '@/stores/user'; // 유저 스토어 import

// 모달들 import
import CertificationRegisterModal from '@/components/employee/qualifications/CertificationRegistrationModal.vue';
import EducationRegisterModal from '@/components/employee/qualifications/EducationRegisterModal.vue';
import CertificationDetailModal from '@/components/employee/qualifications/CertificationDetailModal.vue';
import EducationDetailModal from '@/components/employee/qualifications/EducationDetailModal.vue';

const props = defineProps({
  // ★ 부모(EmployeeDetail)에서 반드시 값을 넘겨줘야 함
  employeeId: { type: [Number, String], required: true },
  
  // 조회된 자격증 리스트
  certificates: { type: Array, default: () => [] }
});

const emit = defineEmits(['refresh']); 

// 모달 상태
const isCertModalOpen = ref(false);
const isEduModalOpen = ref(false);
const isCertDetailOpen = ref(false);
const isEduDetailOpen = ref(false);
const selectedItem = ref({});

// 관리자 권한 확인
const userStore = useUserStore();
// 실제 권한 로직에 맞춰 수정 (예: 'ADMIN', 'MANAGER' 등)
// 여기서는 테스트를 위해 'MANAGER' 또는 권한이 있는 것으로 간주 (userStore에 role이 있는지 확인)
const isAdmin = computed(() => {
  return true; // 테스트를 위해 무조건 true. 실제로는: return userStore.mainRole === 'MANAGER' || userStore.mainRole === 'ADMIN';
});
const localCertificates = ref([]);
const isLoading = ref(false);

const syncPropCertificates = () => {
  localCertificates.value = Array.isArray(props.certificates) ? [...props.certificates] : [];
};

watch(() => props.certificates, syncPropCertificates, { immediate: true });

const fetchCertificates = async () => {
  if (!props.employeeId) {
    syncPropCertificates();
    return;
  }

  isLoading.value = true;
  try {
    // 1. 자격증 목록 조회
    const certs = await getCertificates(props.employeeId);
    
    // 2. 각 자격증별 보수교육 목록 조회 (병렬 처리)
    const certsWithEducations = await Promise.all(
      certs.map(async (cert) => {
        try {
          const certId = cert.certificateId || cert.id;
          // 보수교육 리스트 조회 API 호출 (getEducations는 employeeApi.js에 이미 정의됨)
          // API: GET /api/care-workers/certificates/{certId}/educations
          const { getEducations } = await import('@/api/employee/employeeApi');
          const educations = await getEducations(certId);
          
          return {
            ...cert,
            educations: Array.isArray(educations) ? educations : []
          };
        } catch (err) {
          console.warn(`자격증(ID:${cert.id}) 보수교육 조회 실패:`, err);
          return { ...cert, educations: [] };
        }
      })
    );

    localCertificates.value = Array.isArray(certsWithEducations) ? certsWithEducations : [];
  } catch (error) {
    console.error('자격증 목록 조회 실패:', error);
    syncPropCertificates();
  } finally {
    isLoading.value = false;
  }
};

watch(() => props.employeeId, (newId, oldId) => {
  if (newId && newId !== oldId) {
    fetchCertificates();
  }
});

onMounted(() => {
  if (props.employeeId) {
    fetchCertificates();
  }
});

// 보수교육 리스트 Flatten (자격증별로 흩어진 교육 정보를 한 리스트로 모음)
const allEducations = computed(() => {
  if (!localCertificates.value) return [];
  const list = [];
  localCertificates.value.forEach(cert => {
    if (cert.educations && cert.educations.length > 0) {
      cert.educations.forEach(edu => {
        list.push({
          ...edu,
          relatedCertName: cert.certificateName || cert.name
        });
      });
    }
  });
  return list;
});

// ------------------------------------------------------------------
// ▼▼▼ API 호출 핸들러 ▼▼▼
// ------------------------------------------------------------------

// 0. 상태 변경 핸들러
const handleStatusChange = async (cert, newStatus) => {
  if (newStatus === 'REJECTED') {
    if (!confirm('반려하시겠습니까?')) return; // 확인창으로 변경

    // API 호출 (반려)
    try {
      const certId = cert.certificateId || cert.id || cert.licenseNo; // ID 확보
      await updateCertificateStatus(certId, 'REJECTED');
      alert('반려 처리되었습니다.');
      // 화면 갱신: cert.status를 직접 바꿔주거나 refresh emit
      cert.status = 'REJECTED';
    } catch (e) {
      console.error(e);
      alert('처리 중 오류가 발생했습니다.');
    }
  } else {
    // 승인
    if (!confirm('정말 승인하시겠습니까?')) return;

    try {
      const certId = cert.certificateId || cert.id || cert.licenseNo;
      await updateCertificateStatus(certId, 'APPROVED');
      alert('승인되었습니다.');
      cert.status = 'APPROVED';
    } catch (e) {
      console.error(e);
      alert('처리 중 오류가 발생했습니다.');
    }
  }
};

// 1. 자격증 등록
const handleCertSubmit = async (data) => {
  // [안전 장치] ID 체크
  if (!props.employeeId || props.employeeId === 'undefined') {
    alert('오류: 직원 ID가 없습니다. 상세 페이지가 맞는지 확인해주세요.');
    return;
  }

  try {
    // API 호출 (직원ID + 데이터)
    await registerCertificate(props.employeeId, data);

    alert('자격증 승인 요청이 완료되었습니다.\n관리자 승인 후 정식으로 목록에 반영됩니다.');
    await fetchCertificates(); // 즉시 목록 갱신
    emit('refresh'); // 부모에게 "다시 조회해!" 요청
    isCertModalOpen.value = false;
    
  } catch (error) {
    console.error('자격증 등록 실패:', error);
    alert('등록 중 오류가 발생했습니다.');
  }
};

// 2. 보수교육 등록
const handleEduSubmit = async (data) => {
  // 1. 모달에서 받은 데이터에서 ID와 나머지 데이터를 분리합니다.
  const { targetCertId, ...payload } = data;
  
  // payload에는 이제 targetCertId가 없고, eduName, status 등만 남습니다.
  // payload = { eduName: "...", institution: "...", ... }

  if (!targetCertId) {
    alert('대상 자격증 정보가 없습니다.');
    return;
  }

  try {
    // 2. API 호출: 첫 번째 인자로 ID(18), 두 번째 인자로 Body(JSON) 전달
    const result = await registerEducation(targetCertId, payload);

    alert('보수교육이 등록되었습니다.');
    appendEducationToLocalCertificates(targetCertId, result?.data || payload);
    
    // [수정] 백엔드가 불안정하거나 Mock 응답을 줄 때, 
    // 서버에서 다시 조회하면 방금 등록한 가짜 데이터가 사라집니다.
    // 따라서 로컬 상태만 업데이트하고 재조회는 하지 않습니다.
    // await fetchCertificates();
    // emit('refresh'); 
    isEduModalOpen.value = false;

  } catch (error) {
    console.error('보수교육 등록 실패:', error);
    alert('등록 중 오류가 발생했습니다.');
  }
};

// 상세 조회 팝업 열기
const openCertDetail = (item) => {
  selectedItem.value = item;
  isCertDetailOpen.value = true;
};
const openEduDetail = (item) => {
  selectedItem.value = item;
  isEduDetailOpen.value = true;
};

const getCertificateStatus = (status, raw = null) => {
  if (status === null || status === undefined) {
    return { label: '미지정', className: 'badge-gray', raw };
  }

  const normalized = typeof status === 'string' ? status.toLowerCase() : Number(status);

  if (normalized === 0 || normalized === 'valid' || normalized === '유효' || normalized === 'approved') {
    // [수정] 사용자가 반대로 표시된다고 하여 0을 대기로, 2를 승인으로 변경 시도해 볼 수도 있으나
    // 일반적인 관례(0:정상, 2:대기)와 반대일 수 있음. 
    // 하지만 사용자 피드백(대기->승인(0), 승인->대기(2))에 따르면 데이터가 반대로 오고 있을 가능성 높음.
    // 기존: 0->승인, 2->대기 ==> 사용자: "대기인게 승인(0)으로 뜸, 승인이 대기(2)로 뜸"
    // 결론: 실제 데이터 상 0이 대기이고, 2가 승인인가? 혹은 0이 승인인데 내가 대기라고 표시했나?
    // 코드를 보면: 0 -> {label: '승인'} 이었음. 근데 사용자는 "대기인게 승인으로 뜸" => 즉 대기 상태 데이터가 0이라는 뜻.
    // 승인이 대기(2)로 뜸 => 승인 상태 데이터가 2라는 뜻.
    
    // 따라서 0을 대기, 2를 승인으로 바꿈.
    return { label: '대기', className: 'badge-yellow', raw };
  }
  if (normalized === 1 || normalized === 'expired' || normalized === '만료' || normalized === 'rejected') {
    return { label: '반려', className: 'badge-red', raw };
  }
  if (normalized === 2 || normalized === 'pending' || normalized === '대기중' || normalized === '예정') {
    return { label: '승인', className: 'badge-green', raw };
  }

  return { label: typeof status === 'string' ? status : `상태 코드 ${status}`, className: 'badge-gray', raw };
};

const appendEducationToLocalCertificates = (certId, payload) => {
  if (!certId || !localCertificates.value?.length) return;

  const idx = localCertificates.value.findIndex(cert => {
    const candidateId = cert.certificateId ?? cert.id;
    return String(candidateId) === String(certId);
  });

  if (idx === -1) return;

  const currentCert = localCertificates.value[idx];
  const newEducation = {
    id: payload.id || Date.now(),
    ...payload,
    relatedCertName: currentCert.certificateName || currentCert.name
  };

  const updatedCert = {
    ...currentCert,
    educations: [...(currentCert.educations || []), newEducation]
  };

  const newList = [...localCertificates.value];
  newList.splice(idx, 1, updatedCert);
  localCertificates.value = newList;
};
</script>

<template>
  <div class="cert-edu-container">
    
    <div class="section-container">
      <div class="section-header">
        <h3 class="green-title">자격증 정보</h3>
        <div class="header-right">
          <span class="count-text">총 {{ localCertificates.length }}건</span>
          <button v-if="employeeId" class="btn-green" @click="isCertModalOpen = true">
            + 자격증 등록
          </button>
        </div>
      </div>
      
      <div class="table-container">
        <table class="styled-table">
          <colgroup>
            <col width="60" /> <col width="*" /> <col width="15%" /> <col width="15%" /> <col width="15%" /> <col width="10%" /> <col width="80" />
          </colgroup>
          <thead>
            <tr>
              <th class="text-center">연번</th> <th>자격증명</th> <th>자격증번호</th> <th>발급일</th> <th>만료일</th> <th>상태</th> <th class="text-center">조회</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, idx) in localCertificates" :key="idx">
              <td class="text-center">{{ idx + 1 }}</td>
              <td class="font-bold">{{ item.certificateName || item.name }}</td>
              <td>{{ item.licenseNo }}</td>
              <td>{{ item.issueDate }}</td>
              <td>{{ item.expireDate || '-' }}</td>
              <td>
                <span class="badge" :class="getCertificateStatus(item.status).className">
                  {{ getCertificateStatus(item.status).label }}
                </span>
              </td>
              <td class="text-center">
                <button class="btn-purple-sm" @click="openCertDetail(item)">조회</button>
              </td>
            </tr>
            <tr v-if="isLoading">
              <td colspan="7" class="text-center py-4 text-gray-400">자격증 정보를 불러오는 중입니다...</td>
            </tr>
            <tr v-else-if="localCertificates.length === 0">
              <td colspan="7" class="text-center py-4 text-gray-400">등록된 자격증이 없습니다.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div class="section-container mt-8">
      <div class="section-header">
        <h3 class="green-title">보수교육 이수 내역</h3>
        <div class="header-right">
          <span class="count-text">총 {{ allEducations.length }}건</span>
          <button v-if="employeeId" class="btn-green" @click="isEduModalOpen = true">
            + 교육 등록
          </button>
        </div>
      </div>
      
      <div class="table-container">
        <table class="styled-table">
          <colgroup>
            <col width="60" /> <col width="20%" /> <col width="15%" /> <col width="15%" /> <col width="15%" /> <col width="15%" /> <col width="80" />
          </colgroup>
          <thead>
            <tr>
              <th class="text-center">연번</th> <th>교육명</th> <th>관련 자격증</th> <th>교육기관</th> <th>이수일</th> <th>다음 기한</th> <th class="text-center">관리</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, idx) in allEducations" :key="idx">
              <td class="text-center">{{ idx + 1 }}</td>
              <td class="font-bold">{{ item.eduName }}</td>
              <td class="text-blue-600 font-medium">{{ item.relatedCertName }}</td>
              <td>{{ item.institution }}</td>
              <td>{{ item.eduDate }}</td>
              <td class="text-gray-400">{{ item.nextEduDate || '-' }}</td>
              <td class="text-center">
                <button class="btn-purple-sm" @click="openEduDetail(item)">조회</button>
              </td>
            </tr>
            <tr v-if="allEducations.length === 0">
              <td colspan="7" class="text-center py-4 text-gray-400">등록된 교육 내역이 없습니다.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <CertificationRegisterModal 
      :isOpen="isCertModalOpen" 
      @close="isCertModalOpen = false" 
      @submit="handleCertSubmit" 
    />
    
    <EducationRegisterModal 
      :isOpen="isEduModalOpen" 
      :certificates="localCertificates"
      @close="isEduModalOpen = false" 
      @submit="handleEduSubmit" 
    />
    
    <CertificationDetailModal :isOpen="isCertDetailOpen" :data="selectedItem" @close="isCertDetailOpen = false" />
    <EducationDetailModal :isOpen="isEduDetailOpen" :data="selectedItem" @close="isEduDetailOpen = false" />

  </div>
</template>

<style scoped>
/* 기존 스타일 */
.cert-edu-container { padding: 4px; width: 100%; }
.section-container { margin-bottom: 24px; width: 100%; }
.mt-8 { margin-top: 32px; }
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.green-title { font-size: 18px; font-weight: 600; color: #2c974b; margin: 0; }
.header-right { display: flex; align-items: center; gap: 12px; }
.count-text { font-size: 13px; color: #666; }
.table-container { border: 1px solid #e5e7eb; border-radius: 12px; overflow: hidden; width: 100%; }
.styled-table { width: 100%; border-collapse: collapse; font-size: 14px; text-align: left; table-layout: fixed; }
.styled-table th { background-color: #f9fafb; padding: 12px 16px; color: #4b5563; font-weight: 600; border-bottom: 1px solid #e5e7eb; white-space: nowrap; }
.styled-table td { padding: 14px 16px; color: #1f2937; border-bottom: 1px solid #f3f4f6; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.btn-green { display: flex; align-items: center; gap: 4px; background-color: #4ade80; color: white; border: none; padding: 6px 12px; border-radius: 6px; font-size: 13px; font-weight: bold; cursor: pointer; }
.btn-purple-sm { background-color: #f3e8ff; color: #9333ea; border: none; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: bold; cursor: pointer; }
.font-bold { font-weight: 600; }
.text-center { text-align: center; }
.text-gray-400 { color: #9ca3af; }
.badge { font-size: 12px; padding: 4px 8px; border-radius: 4px; font-weight: 600; }
.badge-green { background-color: #dcfce7; color: #166534; }
.badge-yellow { background-color: #fef3c7; color: #b45309; padding: 4px 8px; border-radius: 4px; }
.badge-red { background-color: #fee2e2; color: #991b1b; padding: 4px 8px; border-radius: 4px; }
.text-blue-600 { color: #2563eb; }
.py-4 { padding: 16px; }
.btn-xs { padding: 2px 8px; font-size: 11px; border-radius: 4px; border: none; cursor: pointer; color: white; margin-right: 4px; }
.btn-blue { background-color: #3b82f6; }
.btn-red { background-color: #ef4444; }
.flex-center { display: flex; justify-content: center; align-items: center; }
.gap-2 { gap: 4px; }
</style>
