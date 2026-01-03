import api from '@/lib/api';
import { PAGE_CONSTANT } from '../constants/common';

export const getMasterCategoryCode = async() => {
    const res = await api.get('/product/master-category');
    return res.data;
};

export const getMasterDetail = async({page, size, codeOrName, categoryCode }) => {

    const params ={
        page,
        ...(size != null ? {size} : PAGE_CONSTANT),
        ...(codeOrName != null && codeOrName != '' ? {codeOrName} : {}),
        ...(categoryCode != null ? {categoryCode} : {})
    }

    const res = await api.get('/product/master-detail',{params});
    return res.data;
};


export const getProductStatus = async() => {
    const res = await api.get('/product/product-status');
    return res.data;
};

export const getProducts = async({page, size, productCode, productStatus })  => {
    const params ={
        page,
        ...(size != null ? {size} : PAGE_CONSTANT),
        productCode,
        ...(productStatus != null ? {productStatus} : {})
    }

    const res = await api.get('/product/product',{params});
    return res.data;
};

export const getProductHistory = async({page, size, productId, historyStatus })  => {
    const params ={
        page,
        ...(size != null ? {size} : PAGE_CONSTANT),
        productId,
        ...(historyStatus != null ? {historyStatus} : {})
    }

    const res = await api.get('/product/product-history',{params});
    return res.data;
};

export const getBeneficaryForRental = async(name) => {
    const res = await api.get(`/api/beneficiaries/rental/${name}`);
    return res.data;
}
