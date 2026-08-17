package com.transport.reporting.controller.publicapi;

import com.transport.reporting.common.response.ApiResponse;
import com.transport.reporting.dto.PublicReportSummary;
import com.transport.reporting.service.PublicReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Endpoint public — signalements publiés pour la Home Screen.
 */
@RestController
@RequestMapping("/api/public/signalements")
@RequiredArgsConstructor
public class PublicReportFeedController {

    private final PublicReportService publicReportService;

    /**
     * GET /api/public/signalements/publics
     * Retourne les signalements publiés (publish = true).
     * Accessible sans authentification.
     */
    @GetMapping("/publics")
    public ResponseEntity<ApiResponse<List<PublicReportSummary>>> getPublishedReports() {
        final List<PublicReportSummary> reports =
                publicReportService.getPublishedReports();
        return ResponseEntity.ok(ApiResponse.ok(reports));
    }
}