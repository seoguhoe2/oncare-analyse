<template>
  <div class="inout-page">
    <table class="inout-table">
      <thead>
        <tr>
          <th>날짜</th>
          <th>구분</th>
          <th>용품명</th>
          <th>관리코드</th>
          <th>수량</th>
          <th>사유</th>
          <th>위치</th>
          <th>상태</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in inoutList" :key="item.id">
          <td>{{ item.date }}</td>

          <td>
            <span
              class="badge io-type"
              :class="item.type === '입고' ? 'badge-in' : 'badge-out'"
            >
              {{ item.type }}
            </span>
          </td>

          <td>{{ item.productName }}</td>

          <td>
            <span class="badge code-badge">
              {{ item.managementCode }}
            </span>
          </td>

          <td class="align-center">
            {{ item.quantity }}
          </td>

          <td>{{ item.reason }}</td>
          <td>{{ item.location }}</td>

          <td>
            <span
              class="badge status-badge"
              :class="item.status === '완료' ? 'status-done' : 'status-planned'"
            >
              {{ item.status }}
            </span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { productInOutScheduleMock } from '@/mock/product/productInOutScheduleMock.js'

const inoutList = ref(productInOutScheduleMock)
</script>

<style scoped>
  .inout-page {
    padding: 24px 32px 32px;
    box-sizing: border-box;
  }
  
  /* 기본 테이블 */
  .inout-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
  }
  
  /* 헤더 – 배경색 없이 흰색 */
  .inout-table thead {
    background: transparent;
  }
  
  .inout-table th,
  .inout-table td {
    padding: 10px 8px;
    border-bottom: 1px solid #f3f4f6;
  }
  
  .inout-table thead th {
    font-weight: 600;
    color: #6b7280;
    text-align: left;
  }
  
  .inout-table tbody tr:last-child td {
    border-bottom: none;
  }
  
  .align-center {
    text-align: center;
  }
  
  /* 뱃지 공통 */
  .badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 3px 10px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 500;
  }
  
  /* 입고 / 출고 */
  .io-type.badge-in {
    background: #eef2ff;
    color: #4f46e5;
  }
  
  .io-type.badge-out {
    background: #fff7ed;
    color: #ea580c;
  }
  
  /* 관리코드 */
  .code-badge {
    background: #f5f3ff;
    color: #7c3aed;
  }
  
  /* 상태 */
  .status-badge.status-planned {
    background: #fef9c3;
    color: #92400e;
  }
  
  .status-badge.status-done {
    background: #dcfce7;
    color: #166534;
  }
  </style>