import { createRouter, createWebHistory } from 'vue-router'

import SignInPage from '@/views/signPage/SignInPage.vue'
import DashboardPage from '@/views/dashboard/DashboardPage.vue'

import SchedulePage from '@/views/schedule/SchedulePage.vue'
import CalendarPage from '@/views/schedule/CalendarPage.vue'
import MatchingPage from '@/views/schedule/MatchingPage.vue'

import EmployeesPage from '@/views/employees/EmployeesPage.vue'

import RecipientLayoutPage from '@/views/recipient/RecipientLayoutPage.vue'
import RecipientListPage from '@/views/recipient/RecipientListPage.vue'
import LongCarePage from '@/views/recipient/LongCarePage.vue'

import InquiryPage from '@/views/inquiry/InquiryPage.vue'
import ConsultManagePage from '@/views/inquiry/ConsultManagePage.vue'
import CustomerManagePage from '@/views/inquiry/CustomerManagePage.vue'

import ProductPage from '@/views/product/ProductPage.vue'
import ProductMasterPage from '@/views/product/ProductMasterPage.vue'
import ProductManagePage from '@/views/product/ProductManagePage.vue'
import RentalContractPage from '@/views/product/RentalContractPage.vue'
import InoutPlanPage from '@/views/product/InoutPlanPage.vue'

import TasksPage from '@/views/tasks/TasksPage.vue'
import ApprovalPage from '@/views/tasks/ApprovalPage.vue'

import HomePage from '@/views/careworker/home/HomePage.vue'

import ActivityPage from '@/views/careworker/activity/ActivityPage.vue'
import DailyCarePage from '@/views/careworker/activity/DailyCarePage.vue'
import BasicEvalPage from '@/views/careworker/activity/BasicEvalPage.vue'
import VisitCounselPage from '@/views/careworker/activity/VisitCounselPage.vue'

import WorkschedulePage from '@/views/careworker/workschedule/WorkschedulePage.vue'

const routes = [
  {
    path: '/',
    name: 'signin',
    component: SignInPage,
  },
  {
    path: '/dashboard',
    name: 'dashboard',
    component: DashboardPage,
    meta: { requiresAuth: true },
  },

  {
    path: '/schedule',
    name: 'schedule',
    component: SchedulePage,
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        redirect: { name: 'schedule-calendar' },
      },
      {
        path: 'calendar',
        name: 'schedule-calendar',
        component: CalendarPage,
      },
      {
        path: 'matching',
        name: 'schedule-matching',
        component: MatchingPage,
      },
    ],
  },

  {
    path: '/employees',
    name: 'employees',
    component: EmployeesPage,
    meta: { requiresAuth: true },
  },

  {
    path: '/recipient',
    name: 'recipient',
    component: RecipientLayoutPage,
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        redirect: { name: 'recipient-list' },
      },
      {
        path: 'list',
        name: 'recipient-list',
        component: RecipientListPage,
      },
      {
        path: 'longcare',
        name: 'recipient-longcare',
        component: LongCarePage,
      },
    ],
  },

  {
    path: '/inquiry',
    name: 'inquiry',
    component: InquiryPage,
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        redirect: { name: 'inquiry-consult' },
      },
      {
        path: 'consult',
        name: 'inquiry-consult',
        component: ConsultManagePage,
      },
      {
        path: 'customer',
        name: 'inquiry-customer',
        component: CustomerManagePage,
      },
    ],
  },

  {
    path: '/product',
    name: 'product',
    component: ProductPage,
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        redirect: { name: 'product-master' },
      },
      {
        path: 'master',
        name: 'product-master',
        component: ProductMasterPage,
      },
      {
        path: 'manage',
        name: 'product-manage',
        component: ProductManagePage,
      },
      {
        path: 'rental-contract',
        name: 'product-rental-contract',
        component: RentalContractPage,
      },
      {
        path: 'inout-plan',
        name: 'product-inout-plan',
        component: InoutPlanPage,
      },
    ],
  },

  {
    path: '/tasks',
    name: 'tasks',
    component: TasksPage,
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        redirect: { name: 'tasks-approval' },
      },
      {
        path: 'approval',
        name: 'tasks-approval',
        component: ApprovalPage,
      },
    ],
  },

  {
    path: '/home',
    name: 'home',
    component: HomePage,
    meta: { requiresAuth: true },
  },

  {
    path: '/activity',
    name: 'activity',
    component: ActivityPage,
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        redirect: { name: 'activity-care' },
      },
      {
        path: 'care',
        name: 'activity-care',
        component: DailyCarePage,
      },
      {
        path: 'basic',
        name: 'activity-basic',
        component: BasicEvalPage,
      },
      {
        path: 'counsel',
        name: 'activity-counsel',
        component: VisitCounselPage,
      },
    ],
  },

  {
    path: '/workschedule',
    name: 'workschedule',
    component: WorkschedulePage,
    meta: { requiresAuth: true },
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router