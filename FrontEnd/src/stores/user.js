// stores/user.js
import { defineStore } from 'pinia'
import { ref, computed } from 'vue' 

export const useUserStore = defineStore(
  'user',
  () => {

    // ----- 외부 노출: 
    const name          = ref('');
    const userId        = ref(0);
    const email         = ref('');
    const roles         = ref([]);
    const profile       = ref('');
    const token         = ref('');
    const isLoggedIn    = ref(false); 
    const birth         = ref('');
    const gender        = ref('');
    const phone         = ref('');
    const jobName       = ref('');
    
    // ----- Actions -----
    function logIn(
      {
        username,
        sub,
        auth,
        id,
        jobname : job
      }
    ) {
      // console.log('asd',in_weight)
      name.value       = username
      email.value      = sub
      roles.value      = auth
      userId.value     = id
      isLoggedIn.value = true
      jobName.value    = job
    }

    function logOut() {
      name.value       = ''
      email.value      = ''
      profile.value    = ''
      roles.value      = []
      token.value      = ''
      userId.value     = 0
      isLoggedIn.value = false
      birth.value      = ''
      gender.value     = ''
      phone.value      = ''
      jobName.value    = ''
      sessionStorage.removeItem('aiDietPlan')
      sessionStorage.removeItem('aiExercisePlan')
    }

    function setToken(jwtToken) {
      token.value = jwtToken 
    }

    function changeProfile(newProfile) {
      profile.value = newProfile
    }

    function hasAllAuthorities(authorities) {
      return authorities.every(permission =>
        roles.value.includes(permission)
      )
    }

    function hasSomeAuthorities(authorities) {
      return authorities.some(permission =>
        roles.value.includes(permission)
      )
    }

    // ✅ roles 배열에서 대표 역할 하나만 뽑아서 헤더에서 쓰기 좋게 만든 computed
    // const mainRole = computed(() => {
    //   const r = roles.value && roles.value.length > 0 ? roles.value[0] : null
    //   if (!r) return null
    //   // 백엔드에서 'ROLE_MANAGER' 이런 식으로 온다면 접두사 제거
    //   if (typeof r === 'string' && r.startsWith('ROLE_')) {
    //     return r.replace('ROLE_', '')
    //   }
    //   return r
    // })

    // ----- 반환 -----
    return {
      // state
      name,
      email,
      roles,
      profile,
      token,
      isLoggedIn,
      userId,
      gender,
      birth,
      phone,
      jobName,

      // ✅ 대표 역할 (MANAGER / SALES / MATERIAL / CAREGIVER 등)
      // mainRole,

      // actions
      logIn,
      logOut,
      changeProfile,
      setToken,
      hasAllAuthorities,
      hasSomeAuthorities,
    }
  },
  {
    persist: {
      enabled: true, //storage 저장유무
      storage: localStorage,
      paths: [
        'name',
        'email',
        'roles',
        'profile',
        'gender',
        'phone',
        'birth',
        'token',
        'isLoggedIn',
        'userId',
        'jobName'
      ],
    },
  }
)