package org.ateam.oncare.counsel.command.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.ateam.oncare.counsel.command.dto.Subscription;
import org.ateam.oncare.counsel.command.dto.SubscriptionResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigInteger;

@Service
@RequiredArgsConstructor
@Slf4j
public class CounselFacadeService {
    private final CounselRegistrationService counselRegistrationService;
    private final PotentialStageService potentialStageService;
    private final PotentialCustomerService potentialCustomerService;

    public ResponseEntity<SubscriptionResponse> registNewSubscription(Subscription request) {
        // 신규 잠재고객 등록 + Id값 받아오기 (필수)
        BigInteger potentialId = potentialCustomerService.registPotentialCustomer(request);
        request.setCustomerId(potentialId);
        request.setCustomerType("POTENTIAL");

        // 가입상담 관리 1단계 처리
        potentialStageService.registPotentialStage(request,potentialId);

        // 상담 이력에 저장
        SubscriptionResponse subscriptionResponse = counselRegistrationService.registSubscription(request);


    }
}
