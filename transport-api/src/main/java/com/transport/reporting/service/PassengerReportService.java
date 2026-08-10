package com.transport.reporting.service;

import com.transport.reporting.dto.MyReportResponse;
import com.transport.reporting.exception.BusinessException;
import com.transport.reporting.repository.PassengerRepository;
import com.transport.reporting.repository.ReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Service : historique des signalements d'un voyageur authentifié.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PassengerReportService {

    private final ReportRepository     reportRepository;
    private final PassengerRepository  passengerRepository;

    public List<MyReportResponse> getMyReports(String jwtSubject) {
        // Subject format: "passenger:42"
        final Long passengerId = extractPassengerId(jwtSubject);

        passengerRepository.findById(passengerId)
                .orElseThrow(() -> new BusinessException("Voyageur introuvable."));

        return reportRepository
                .findByPassenger_PassengerIdOrderByCreationDateDesc(passengerId)
                .stream()
                .map(report -> {
                    final String supportLabel =
                            report.getTransportSupport() != null
                                    ? report.getTransportSupport().getLabel()
                                    : null;
                    return MyReportResponse.builder()
                            .uuid(report.getUuid())
                            .reference(report.getReference())
                            .creationDate(report.getCreationDate())
                            .description(report.getDescription())
                            .reportTypeLabel(report.getReportType() != null
                                    ? report.getReportType().getLabel()
                                    : null)
                            .supportLabel(supportLabel)
                            .statusCode(report.getStatus() != null
                                    ? report.getStatus().getCode()
                                    : null)
                            .statusLabel(report.getStatus() != null
                                    ? report.getStatus().getLabel()
                                    : null)
                            .build();
                })
                .toList();
    }

    private Long extractPassengerId(String subject) {
        // subject = "passenger:42"
        try {
            final String[] parts = subject.split(":");
            if (parts.length != 2 || !parts[0].equals("passenger")) {
                throw new BusinessException("Token invalide.");
            }
            return Long.parseLong(parts[1]);
        } catch (NumberFormatException e) {
            throw new BusinessException("Token invalide.");
        }
    }
}