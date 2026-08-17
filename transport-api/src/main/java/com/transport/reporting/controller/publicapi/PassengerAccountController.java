package com.transport.reporting.controller.publicapi;

import com.transport.reporting.common.response.ApiResponse;
import com.transport.reporting.dto.ForgotPasswordRequest;
import com.transport.reporting.dto.ResendVerificationRequest;
import com.transport.reporting.dto.ResetPasswordRequest;
import com.transport.reporting.dto.VerifyEmailRequest;
import com.transport.reporting.exception.BusinessException;
import com.transport.reporting.security.RecaptchaService;
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
    private final RecaptchaService        recaptchaService;

    @PostMapping("/verify-email")
    public ResponseEntity<ApiResponse<Void>> verifyEmail(
            @Valid @RequestBody VerifyEmailRequest request) {
        passengerAccountService.verifyEmail(request);
        return ResponseEntity.ok(
                ApiResponse.ok("Email vérifié avec succès.", null));
    }

    @PostMapping("/resend-verification")
    public ResponseEntity<ApiResponse<Void>> resendVerification(
            @Valid @RequestBody ResendVerificationRequest request) {
        passengerAccountService.resendVerification(request);
        return ResponseEntity.ok(
                ApiResponse.ok("Email de vérification renvoyé.", null));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<Void>> forgotPassword(
            @Valid @RequestBody ForgotPasswordRequest request,
            @RequestHeader(value = "X-Recaptcha-Token", required = false)
            String recaptchaToken) {

        if (!recaptchaService.verify(recaptchaToken, "forgot_password")) {
            throw new BusinessException(
                    "Vérification de sécurité échouée. Veuillez réessayer.");
        }

        passengerAccountService.forgotPassword(request);
        return ResponseEntity.ok(
                ApiResponse.ok(
                        "Si un compte existe avec cet email, un lien a été envoyé.",
                        null));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Void>> resetPassword(
            @Valid @RequestBody ResetPasswordRequest request) {
        passengerAccountService.resetPassword(request);
        return ResponseEntity.ok(
                ApiResponse.ok("Mot de passe réinitialisé avec succès.", null));
    }
}