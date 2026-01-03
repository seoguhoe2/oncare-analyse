// src/mock/product/rentalContractMock.js
export const rentalContractMock = [
    {
      id: 1,
      recipientName: '김영희',
      managerName: '이담당',
      startDate: '2024-01-20',
      endDate: null,          // 종료일 없으면 null
      status: '유지',
      productCount: 2,
      monthlyTotal: 60000,
    },
    {
      id: 2,
      recipientName: '이철수',
      managerName: '박담당',
      startDate: '2024-02-01',
      endDate: null,
      status: '유지',
      productCount: 3,
      monthlyTotal: 108000,
    },
    {
      id: 3,
      recipientName: '박순자',
      managerName: '최담당',
      startDate: '2024-03-10',
      endDate: null,
      status: '유지',
      productCount: 1,
      monthlyTotal: 18000,
    },
    {
      id: 4,
      recipientName: '정민수',
      managerName: '이담당',
      startDate: '2023-06-15',
      endDate: '2024-11-30',
      status: '종료',
      productCount: 1,
      monthlyTotal: 35000,
    },
  ]