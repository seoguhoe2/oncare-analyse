package org.ateam.oncare.counsel.command.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.*;

import java.math.BigInteger;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class Subscription {
    // potential_customer 등록 필요한 정보
    private String name;
    private String phone;

    // counsel_history 부분
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime consultDate;
    private String detail;
    private int guardianSt; // 0이면 본인, 1이면 보호자
    private String followUp;
    private String followUpNecessary;
    private String churn;   // DEFAULT 'N'
    private String churnReason;
    private int reservationChannelId;
    // 차후 Entity에 넣을 땐 beneficiary_id or potential_id로 넣어야 함
    private BigInteger customerId;
    private String customerType;
    private int counselCategoryId;
    private int employeeId;
}
