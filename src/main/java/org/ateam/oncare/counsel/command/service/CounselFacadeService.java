package org.ateam.oncare.counsel.command.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.ateam.oncare.counsel.command.dto.*;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigInteger;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class CounselFacadeService {
    private final CounselRegistrationService counselRegistrationService;
    private final PotentialStageService potentialStageService;
    private final PotentialCustomerService potentialCustomerService;

    @Transactional
    public ResponseEntity<NewSubscriptionResponse> registNewSubscription(Subscription request) {
        // 신규 잠재고객 등록 + Id값 받아오기 (필수)
        BigInteger potentialId = potentialCustomerService.registPotentialCustomer(request.getName(), request.getPhone());
        request.setCustomerId(potentialId);
        request.setCustomerType("POTENTIAL");

        // 가입상담 관리 1단계 처리
        potentialStageService.registPotentialStage(request,potentialId);

        // 상담 이력에 저장
        NewSubscriptionResponse newSubscriptionResponse = counselRegistrationService.registSubscription(request);
        return  ResponseEntity.ok(newSubscriptionResponse);
    }

    @Transactional
    public ResponseEntity<GeneralCounselResponse> registNewGeneralCounsel(GeneralCounsel request) {
        // 신규 잠재 고객 등록
        BigInteger potentialId = potentialCustomerService.registPotentialCustomer(request.getName(), request.getPhone());
        request.setCustomerId(potentialId);
        request.setCustomerType("POTENTIAL");

        // 신규 상담 이력으로 저장
        GeneralCounselResponse generalCounselResponse = counselRegistrationService.registGeneralCounsel(request);
        return ResponseEntity.ok(generalCounselResponse);
    }

    @Transactional
    public ResponseEntity<SubscriptionResponse> registSubscription(Subscription request, BigInteger customerId,
                                                                   String customerType, String customerCategoryName) {
        switch (customerCategoryName) {
            case "잠재고객":        // 잠재 고객의 가입상담 = 이전 상담 내역에서 이어서 진행
                Long potentialId = request.getCustomerId().longValue();
                Map<Integer,String> stageData = potentialStageService.findStageDataByPotentialId(potentialId);


        }

        // 기존 고객의 가입상담 = 서비스 연장

        // 이탈 고객의 가입상담 = 서비스 재가입
    }
}
