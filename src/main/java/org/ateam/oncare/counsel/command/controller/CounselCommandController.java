package org.ateam.oncare.counsel.command.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.ateam.oncare.counsel.command.dto.RegistCounselRequest;
import org.ateam.oncare.counsel.command.dto.RegistCounselResponse;
import org.ateam.oncare.counsel.command.service.CounselCommandService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/counsel")
@Slf4j
@Validated
@RequiredArgsConstructor
public class CounselCommandController {

    private final CounselCommandService counselCommandService;

    @PostMapping("/regist")
    public ResponseEntity<RegistCounselResponse> registCounsel(
            @RequestBody RegistCounselRequest,
            @AuthenticationPrincipal CustomUserDetails userDetailsrequest
    ) {

        return ResponseEntity.ok(counselCommandService.registCounsel());
    }
}
