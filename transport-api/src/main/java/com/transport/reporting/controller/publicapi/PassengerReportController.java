package com.transport.reporting.controller.publicapi;

import com.transport.reporting.common.response.ApiResponse;
import com.transport.reporting.dto.MyReportResponse;
import com.transport.reporting.security.JwtService;
import com.transport.reporting.service.PassengerReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Endpoint public sécurisé : historique des signalements d'un voyageur.
 * Utilise le JWT voyageur (passenger:{id}) pour identifier l'appelant.
 */
@RestController
@RequestMapping("/api/public/passenger")
@RequiredArgsConstructor
@Tag(name = "Public - Passenger")
public class PassengerReportController {

    private final PassengerReportService passengerReportService;
    private final JwtService             jwtService;

    @GetMapping("/my-reports")
    @Operation(summary = "Historique des signalements du voyageur connecté")
    public ResponseEntity<ApiResponse<List<MyReportResponse>>> getMyReports(
            @RequestHeader("Authorization") String authHeader) {

        // Extract JWT subject from "Bearer {token}"
        final String token   = authHeader.replace("Bearer ", "").trim();
        final String subject = jwtService.extractUsername(token);

        final List<MyReportResponse> reports =
                passengerReportService.getMyReports(subject);

        return ResponseEntity.ok(ApiResponse.ok(reports));
    }
}