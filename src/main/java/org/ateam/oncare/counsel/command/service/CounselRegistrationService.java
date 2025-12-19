package org.ateam.oncare.counsel.command.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.ateam.oncare.beneficiary.command.service.BeneficiaryUpdateService;
import org.ateam.oncare.counsel.command.dto.GeneralCounselResponse;
import org.ateam.oncare.counsel.command.dto.GeneralCounsel;
import org.ateam.oncare.counsel.command.dto.Subscription;
import org.ateam.oncare.counsel.command.dto.SubscriptionResponse;
import org.ateam.oncare.counsel.command.entity.CounselHistory;
import org.ateam.oncare.counsel.command.repository.CounselHistoryRepository;
import org.ateam.oncare.counsel.command.repository.PotentialCustomerRepository;
import org.ateam.oncare.counsel.command.repository.PotentialStageRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigInteger;
import java.time.LocalDateTime;

@Service
@Slf4j
@RequiredArgsConstructor
@Transactional
public class CounselRegistrationService {
    private final CounselHistoryRepository counselHistoryRepository;
    private final BeneficiaryUpdateService beneficiaryUpdateService;
    private final PotentialCustomerRepository potentialCustomerRepository;

    public SubscriptionResponse registSubscription(Subscription request) {
        CounselHistory counselHistory = saveCounselHistory(request);
        SubscriptionResponse response = buildSubscriptionResponse(counselHistory);
    }

    private CounselHistory saveCounselHistory(Subscription request) {
        CounselHistory.CounselHistoryBuilder counselHistoryBuilder = CounselHistory.builder()
                .consultDate(request.getConsultDate())
                .detail(request.getDetail())
                .guardianSt(request.getGuardianSt())
                .followUp(request.getFollowUp())
                .followUpNecessary(request.getFollowUpNecessary())
                .churn(request.getChurn())
                .churnReason(request.getChurnReason())
                .reservationChannelId(request.getReservationChannelId())
                .counselCategoryId(request.getCounselCategoryId())
                .counselorId(request.getEmployeeId());

        if ("beneficiary".equalsIgnoreCase(request.getCustomerType())) {
            // 수급자라면 -> beneficiaryId 칸에 넣기
            counselHistoryBuilder.beneficiaryId(request.getCustomerId().longValue());
            counselHistoryBuilder.potentialId(null); // 잠재고객 칸은 비움
            beneficiaryUpdateService.updateLastCounselDate(request.getCustomerId().longValue(), request.getConsultDate());

        } else if ("potential".equalsIgnoreCase(request.getCustomerType())) {
            // 잠재고객이라면 -> potentialId 칸에 넣기
            counselHistoryBuilder.potentialId(request.getCustomerId().longValue());
            counselHistoryBuilder.beneficiaryId(null); // 수급자 칸은 비움
            potentialCustomerRepository.updateLastCounselDate(request.getCustomerId().longValue(), request.getConsultDate());
        }
//        else {
//            // 타입이 이상하면 에러 처리 = 내가 Exception 만들어서 처리하기
//            throw new CustomException(ErrorCode.INVALID_CUSTOMER_TYPE);
//        }
        return counselHistoryRepository.save(counselHistoryBuilder.build());

    }

    private SubscriptionResponse buildSubscriptionResponse(CounselHistory counselHistory) {
        
    }
}
