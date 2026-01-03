/**
 * 요양보호사(Careworker) API 모듈
 *
 * 백엔드 컨트롤러 매핑:
 * - DashboardQueryController → dashboardApi.js
 * - ScheduleQueryController → scheduleApi.js
 * - CareLogCommandController → careLogApi.js
 * - TodoCommandController → todoApi.js
 * - VisitScheduleCommandController → visitScheduleApi.js
 * - PersonalScheduleCommandController → personalScheduleApi.js
 * - BedsoreEvaluationCommandController → evaluationApi.js (욕창)
 * - CognitiveEvaluationCommandController → evaluationApi.js (인지기능)
 * - FallEvaluationCommandController → evaluationApi.js (낙상)
 * - NeedsEvaluationCommandController → evaluationApi.js (욕구사정)
 * - CounselingLogCommandController → counselingLogApi.js
 */

// Dashboard API
export {
  getDashboardSummary,
  getUrgentNotifications,
  getTodaySchedules,
  getTodos,
  getBeneficiaryDetail,
  getTodoDetail,
  getCareLogBySchedule,
  getMyBeneficiaries,
} from './dashboardApi';

// Schedule API
export {
  getSchedules,
  getScheduleDetail,
  getPersonalTypes,
} from './scheduleApi';

// Care Log API
export {
  getCareLogList,
  getCareLogListByBeneficiary,
  getCareLogDetail,
  createCareLog,
  updateCareLog,
  deleteCareLog,
} from './careLogApi';

// Todo API
export {
  createTodo,
  updateTodo,
  completeTodo,
  uncompleteTodo,
  deleteTodo,
} from './todoApi';

// Visit Schedule API
export {
  startVisit,
  completeVisit,
  createVisitSchedule,
  updateVisitSchedule,
  deleteVisitSchedule,
} from './visitScheduleApi';

// Personal Schedule API
export {
  createPersonalSchedule,
  updatePersonalSchedule,
  deletePersonalSchedule,
} from './personalScheduleApi';

// Evaluation API (욕창, 인지기능, 낙상, 욕구사정)
export {
  getBedsoreEvaluationList,
  getBedsoreEvaluationListByBeneficiary,
  getBedsoreEvaluationDetail,
  createBedsoreEvaluation,
  updateBedsoreEvaluation,
  deleteBedsoreEvaluation,
  getCognitiveEvaluationList,
  getCognitiveEvaluationListByBeneficiary,
  getCognitiveEvaluationDetail,
  createCognitiveEvaluation,
  updateCognitiveEvaluation,
  deleteCognitiveEvaluation,
  getFallEvaluationList,
  getFallEvaluationListByBeneficiary,
  getFallEvaluationDetail,
  createFallEvaluation,
  updateFallEvaluation,
  deleteFallEvaluation,
  getNeedsEvaluationList,
  getNeedsEvaluationListByBeneficiary,
  getNeedsEvaluationDetail,
  createNeedsEvaluation,
  updateNeedsEvaluation,
  deleteNeedsEvaluation,
} from './evaluationApi';

// Counseling Log API
export {
  getCounselingLogList,
  getCounselingLogListByBeneficiary,
  getCounselingLogDetail,
  createCounselingLog,
  updateCounselingLog,
  deleteCounselingLog,
} from './counselingLogApi';
