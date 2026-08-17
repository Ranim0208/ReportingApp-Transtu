package com.transport.reporting.service;

import com.transport.reporting.dto.PublicReportSummary;
import com.transport.reporting.repository.ReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Service : signalements publiés visibles sur la Home Screen.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PublicReportService {

    private final ReportRepository reportRepository;

    /**
     * Retourne les signalements publiés (publish = true),
     * triés du plus récent au plus ancien.
     * Aucune donnée personnelle exposée.
     */
    public List<PublicReportSummary> getPublishedReports() {
        return reportRepository
                .findByPublishTrueOrderByPublishDateDesc()
                .stream()
                .map(report -> PublicReportSummary.builder()
                        .uuid(report.getUuid().toString())
                        .reference(report.getReference())
                        .creationDate(report.getCreationDate())
                        .publishDate(report.getPublishDate())
                        .description(truncate(report.getDescription(), 120))
                        .reportTypeLabel(report.getReportType() != null
                                ? report.getReportType().getLabel()
                                : null)
                        .supportLabel(report.getTransportSupport() != null
                                ? report.getTransportSupport().getLabel()
                                : null)
                        .supportTypeCode(report.getTransportSupport() != null
                                ? report.getTransportSupport().getSupportType() != null
                                        ? report.getTransportSupport().getSupportType().getCode()
                                        : null
                                : null)
                        .statusCode(report.getStatus() != null
                                ? report.getStatus().getCode()
                                : null)
                        .statusLabel(report.getStatus() != null
                                ? report.getStatus().getLabel()
                                : null)
                        .build())
                .toList();
    }

    private String truncate(String text, int maxLength) {
        if (text == null) return null;
        return text.length() <= maxLength
                ? text
                : text.substring(0, maxLength) + "...";
    }
}