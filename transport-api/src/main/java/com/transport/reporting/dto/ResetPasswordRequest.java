package com.transport.reporting.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ResetPasswordRequest {

    @NotBlank(message = "Le token est obligatoire.")
    private String token;

    @NotBlank(message = "Le mot de passe est obligatoire.")
    @Size(min = 8, max = 100, message = "Le mot de passe doit contenir entre 8 et 100 caractères.")
    private String newPassword;
}