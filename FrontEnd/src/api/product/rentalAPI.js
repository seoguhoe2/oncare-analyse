import api from '@/lib/api';
import { PAGE_CONSTANT } from '../constants/common';

export const getRenal = async({page, size, beneficiaryOrEmployee, contractStatus }) => {
    console.log("getRental:",beneficiaryOrEmployee,",,,,",contractStatus)
    const params ={
        page,
        ...(size != null ? {size} : PAGE_CONSTANT),
        ...(beneficiaryOrEmployee != null && beneficiaryOrEmployee != '' ? {beneficiaryOrEmployee} : {}),
        ...(contractStatus != null ? {contractStatus} : {})
    }

    const res = await api.get('/rental/rental',{params});
    return res.data;
};

export const getRentalStatus = async() => {
    const res = await api.get('/rental/rental-product/status');
    return res.data;
};

export const getContractStatus = async() => {
    const res = await api.get('/rental/contract/type');
    return res.data;
};

export const getRentalItems = async(id) => {
    const params = {
            contractCode : id
        };
    const res = await api.get('/rental/rental-product',{params});
    return res.data;
};

export const createRentalContract = async({
    beneficiaryId, empId, productCd, wantedDate, termMonth}) => {

    const params = {
        beneficiaryId,
        empId,
        productCd,
        wantedDate,
        termMonth
    }
    const res = await api.post('/rental/contract',params);

    return res.data;
}