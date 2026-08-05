package com.transport.reporting.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

/**
 * Requête d'inscription d'un voyageur.
 */
@Data
public class PassengerRegisterRequest {

    @NotBlank(message = "Le nom est obligatoire.")
    @Size(max = 150, message = "Le nom ne peut pas dépasser 150 caractères.")
    private String name;

    @NotBlank(message = "L'adresse email est obligatoire.")
    @Email(message = "Format d'email invalide.")
    @Size(max = 255, message = "L'email ne peut pas dépasser 255 caractères.")
    private String email;

    @Size(max = 30, message = "Le numéro de téléphone ne peut pas dépasser 30 caractères.")
    private String phoneNumber;

    @NotBlank(message = "Le mot de passe est obligatoire.")
    @Size(min = 8, max = 100, message = "Le mot de passe doit contenir entre 8 et 100 caractères.")
    private String password;
}