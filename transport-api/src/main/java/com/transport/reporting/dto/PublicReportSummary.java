package com.transport.reporting.dto;

import lombok.Builder;
import lombok.Data;

import java.time.Instant;

/**
 * Vue résumée d'un signalement publié (publish = true).
 * Affiché sur la Home Screen de l'app mobile.
 * Ne contient aucune donnée personnelle du voyageur.
 */
@Data
@Builder
public class PublicReportSummary {
    private String  uuid;
    private String  reference;
    private Instant creationDate;
    private Instant publishDate;
    private String  description;
    private String  reportTypeLabel;
    private String  supportLabel;
    private String  supportTypeCode;
    private String  statusCode;
    private String  statusLabel;
}