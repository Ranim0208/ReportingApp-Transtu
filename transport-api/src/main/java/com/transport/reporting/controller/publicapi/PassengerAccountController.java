package com.transport.reporting.controller.publicapi;

import com.transport.reporting.common.response.ApiResponse;
import com.transport.reporting.dto.ForgotPasswordRequest;
import com.transport.reporting.dto.ResendVerificationRequest;
import com.transport.reporting.dto.ResetPasswordRequest;
import com.transport.reporting.service.PassengerAccountService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Endpoints publics — vérification email et reset mot de passe voyageur.
 */
@RestController
@RequestMapping("/api/public/auth")
@RequiredArgsConstructor
public class PassengerAccountController {

    private final PassengerAccountService passengerAccountService;

    /**
     * GET /api/public/auth/verify-email?token=xxx
     * Vérifie le token et active le compte.
     */
    @GetMapping("/verify-email")
    public ResponseEntity<ApiResponse<Void>> verifyEmail(
            @RequestParam String token) {
        passengerAccountService.verifyEmail(token);
        return ResponseEntity.ok(
                ApiResponse.ok("Email vérifié avec succès. Vous pouvez maintenant vous connecter.", null));
    }

    /**
     * POST /api/public/auth/resend-verification
     * Renvoie l'email de vérification.
     */
    @PostMapping("/resend-verification")
    public ResponseEntity<ApiResponse<Void>> resendVerification(
            @Valid @RequestBody ResendVerificationRequest request) {
        passengerAccountService.resendVerification(request);
        return ResponseEntity.ok(
                ApiResponse.ok("Email de vérification renvoyé.", null));
    }

    /**
     * POST /api/public/auth/forgot-password
     * Envoie un email de reset (toujours 200 — anti-enumération).
     */
    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<Void>> forgotPassword(
            @Valid @RequestBody ForgotPasswordRequest request) {
        passengerAccountService.forgotPassword(request);
        return ResponseEntity.ok(
                ApiResponse.ok(
                        "Si un compte existe avec cet email, un lien de réinitialisation a été envoyé.",
                        null));
    }

    /**
     * POST /api/public/auth/reset-password
     * Réinitialise le mot de passe avec le token.
     */
    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Void>> resetPassword(
            @Valid @RequestBody ResetPasswordRequest request) {
        passengerAccountService.resetPassword(request);
        return ResponseEntity.ok(
                ApiResponse.ok("Mot de passe réinitialisé avec succès.", null));
    }
}