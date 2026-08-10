package com.transport.reporting.dto;

import lombok.Builder;
import lombok.Data;
import java.time.Instant;
import java.util.UUID;

/**
 * Vue simplifiée d'un signalement pour l'historique voyageur connecté.
 */
@Data
@Builder
public class MyReportResponse {
    private UUID    uuid;
    private String  reference;
    private Instant creationDate;
    private String  description;
    private String  reportTypeLabel;
    private String  supportLabel;
    private String  statusCode;
    private String  statusLabel;
}