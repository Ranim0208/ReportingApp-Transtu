package com.transport.reporting.dto;

import lombok.*;

/**
 * Réponse renvoyée après un register ou un login voyageur réussi.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PassengerAuthResponse {

    private Long   passengerId;
    private String name;
    private String email;
    private String phoneNumber;
    private String token;

    /** Toujours "Bearer". */
    @Builder.Default
    private String tokenType = "Bearer";
}