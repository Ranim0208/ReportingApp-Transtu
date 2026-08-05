package com.transport.reporting.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * Requête de connexion d'un voyageur.
 */
@Data
public class PassengerLoginRequest {

    @NotBlank(message = "L'adresse email est obligatoire.")
    private String email;

    @NotBlank(message = "Le mot de passe est obligatoire.")
    private String password;
}