import api from '@/lib/api';
import { PAGE_CONSTANT } from '../constants/common';

export const getProductMaster = async({page, size, codeOrName, categoryCode }) => {

    const params ={
        page,
        ...(size != null ? {size} : PAGE_CONSTANT),
        ...(codeOrName != null && codeOrName != '' ? {codeOrName} : {}),
        ...(categoryCode != null ? {categoryCode} : {})
    }

    const res = await api.get('/product/master',{params});
    return res.data;
};


export const getMasterCategoryCode = async() => {
    const res = await api.get('/product/master-category');
    return res.data;
};

export const registMaster = async({
    id,
    name,
    categoryCd,
    amount,
    rentalAmount,
    explanation
}) => {

    const params ={
        id,
        name,
        categoryCd,
        amount,
        ...(rentalAmount != null ? {rentalAmount} : {}),
        ...(explanation != null ? {explanation} : {})
    }

    const res = await api.post('product/master',params)
    return res.data;
}


export const updateMaster = async({
    id,
    name,
    categoryCd,
    amount,
    rentalAmount,
    explanation
}) => {

    const params ={
        id,
        name,
        categoryCd,
        amount,
        ...(rentalAmount != null ? {rentalAmount} : {}),
        ...(explanation != null ? {explanation} : {})
    }

    const res = await api.patch('product/master',params)
    return res.data;
}