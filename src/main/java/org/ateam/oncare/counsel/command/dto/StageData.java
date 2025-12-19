package org.ateam.oncare.counsel.command.dto;

import lombok.*;

import java.math.BigInteger;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class StageData {
    private int stage;    // 1, 2, 3, 4
    private String process_status;
    private LocalDateTime processTime;
    private LocalDateTime month;
    private String htmlCode;
    private BigInteger potentialId;
}
