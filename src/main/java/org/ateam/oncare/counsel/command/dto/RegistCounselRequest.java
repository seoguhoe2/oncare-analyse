package org.ateam.oncare.counsel.command.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;

import java.math.BigInteger;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class RegistCounselRequest {
    private String counselCategoryName;
    private String detail;
    private String followUp;
    private String followUpNecessary;
    private String churn;
    private String churnReason;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDateTime consultDate;
}
