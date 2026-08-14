package com.transport.reporting.service;

import com.transport.reporting.dto.ForgotPasswordRequest;
import com.transport.reporting.dto.ResendVerificationRequest;
import com.transport.reporting.dto.ResetPasswordRequest;
import com.transport.reporting.dto.VerifyEmailRequest;
import com.transport.reporting.entity.Passenger;
import com.transport.reporting.entity.PassengerToken;
import com.transport.reporting.entity.PassengerToken.TokenType;
import com.transport.reporting.exception.BusinessException;
import com.transport.reporting.repository.PassengerRepository;
import com.transport.reporting.repository.PassengerTokenRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;

/**
 * Gestion de la vérification email et reset mot de passe voyageur.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class PassengerAccountService {

    private static final int    TOKEN_BYTES              = 32;
    private static final long   VERIFICATION_EXPIRY_HOURS = 24;
    private static final long   RESET_EXPIRY_HOURS        = 1;

    private final PassengerRepository      passengerRepository;
    private final PassengerTokenRepository passengerTokenRepository;
    private final PasswordEncoder          passwordEncoder;
    private final EmailService             emailService;
    private final PassengerEmailComposer   emailComposer;

    // ── Email Verification ────────────────────────────────────────────────────

    /**
     * Envoie un email de vérification après inscription.
     * Appelé automatiquement depuis PassengerAuthService.register().
     */
    @Transactional
    public void sendVerificationEmail(Passenger passenger) {
        if (passenger.isEmailVerified()) {
            log.info("Passenger {} already verified — skipping", passenger.getPassengerId());
            return;
        }
        if (passenger.getEmail() == null) {
            log.warn("Passenger {} has no email — cannot send verification", passenger.getPassengerId());
            return;
        }

        // Invalidate previous verification tokens
        passengerTokenRepository.invalidateAllForPassenger(
                passenger.getPassengerId(), TokenType.EMAIL_VERIFICATION);

        final String token = generateToken();
        passengerTokenRepository.save(PassengerToken.builder()
                .token(token)
                .tokenType(TokenType.EMAIL_VERIFICATION)
                .passenger(passenger)
                .expiresAt(Instant.now().plus(VERIFICATION_EXPIRY_HOURS, ChronoUnit.HOURS))
                .build());

        final String html = emailComposer.buildVerificationHtml(passenger, token);
        final var result  = emailService.sendHtml(
                passenger.getEmail(),
                emailComposer.verificationSubject(),
                html
        );

        if (!result.isSuccess()) {
            log.error("Failed to send verification email to {}: {}",
                    passenger.getEmail(), result.getMessage());
        }
    }

    /**
     * Renvoie un email de vérification à la demande du voyageur.
     */
@Transactional
public void resendVerification(ResendVerificationRequest request) {
    final Passenger passenger = passengerRepository
            .findByEmailIgnoreCase(request.getEmail().trim())
            .orElseThrow(() -> new BusinessException(
                    "Aucun compte trouvé avec cet email."));

    // Si déjà vérifié → succès silencieux (pas d'erreur)
    if (passenger.isEmailVerified()) {
        log.info("Resend requested but passenger {} already verified — ignoring",
                passenger.getPassengerId());
        return;
    }

    sendVerificationEmail(passenger);
}
/**
 * Vérifie le code OTP et active le compte voyageur.
 */
@Transactional
public void verifyEmail(VerifyEmailRequest request) {
    // Trouve le voyageur par email
    final Passenger passenger = passengerRepository
            .findByEmailIgnoreCase(request.getEmail().trim())
            .orElseThrow(() -> new BusinessException(
                    "Aucun compte trouvé avec cet email."));

    if (passenger.isEmailVerified()) {
        throw new BusinessException("Cet email est déjà vérifié.");
    }

    // Trouve le token correspondant au code
    final PassengerToken pt = passengerTokenRepository
            .findByTokenAndTokenType(request.getCode(), TokenType.EMAIL_VERIFICATION)
            .orElseThrow(() -> new BusinessException(
                    "Code invalide. Vérifiez le code reçu par email."));

    // Vérifie que le token appartient bien à ce voyageur
    if (!pt.getPassenger().getPassengerId().equals(passenger.getPassengerId())) {
        throw new BusinessException("Code invalide.");
    }

    if (pt.isExpired()) {
        throw new BusinessException(
                "Ce code a expiré. Veuillez en demander un nouveau.");
    }

    if (pt.isUsed()) {
        throw new BusinessException(
                "Ce code a déjà été utilisé.");
    }

    pt.setUsed(true);
    passengerTokenRepository.save(pt);

    passenger.setEmailVerified(true);
    passengerRepository.save(passenger);

    log.info("Email verified for passenger {}", passenger.getPassengerId());
}
    // ── Password Reset ────────────────────────────────────────────────────────

    /**
     * Envoie un email de reset mot de passe.
     * Ne révèle jamais si l'email existe ou non (sécurité anti-enumération).
     */
    @Transactional
    public void forgotPassword(ForgotPasswordRequest request) {
        final var optPassenger = passengerRepository
                .findByEmailIgnoreCase(request.getEmail().trim());

        // Always return success — never reveal if email exists
        if (optPassenger.isEmpty()) {
            log.info("Forgot password requested for unknown email: {}",
                    request.getEmail());
            return;
        }

        final Passenger passenger = optPassenger.get();

        if (passenger.getPasswordHash() == null) {
            log.info("Forgot password for anonymous passenger {} — skipping",
                    passenger.getPassengerId());
            return;
        }

        // Invalidate previous reset tokens
        passengerTokenRepository.invalidateAllForPassenger(
                passenger.getPassengerId(), TokenType.PASSWORD_RESET);

        final String token = generateToken();
        passengerTokenRepository.save(PassengerToken.builder()
                .token(token)
                .tokenType(TokenType.PASSWORD_RESET)
                .passenger(passenger)
                .expiresAt(Instant.now().plus(RESET_EXPIRY_HOURS, ChronoUnit.HOURS))
                .build());

        final String html = emailComposer.buildResetPasswordHtml(passenger, token);
        final var result  = emailService.sendHtml(
                passenger.getEmail(),
                emailComposer.resetPasswordSubject(),
                html
        );

        if (!result.isSuccess()) {
            log.error("Failed to send reset email to {}: {}",
                    passenger.getEmail(), result.getMessage());
        }
    }

    /**
     * Réinitialise le mot de passe avec le token.
     */
    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        final PassengerToken pt = passengerTokenRepository
                .findByTokenAndTokenType(request.getToken(), TokenType.PASSWORD_RESET)
                .orElseThrow(() -> new BusinessException(
                        "Lien de réinitialisation invalide."));

        if (pt.isExpired()) {
            throw new BusinessException(
                    "Ce lien a expiré. Veuillez en demander un nouveau.");
        }
        if (pt.isUsed()) {
            throw new BusinessException(
                    "Ce lien a déjà été utilisé.");
        }

        pt.setUsed(true);
        passengerTokenRepository.save(pt);

        final Passenger passenger = pt.getPassenger();
        passenger.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        passengerRepository.save(passenger);

        log.info("Password reset for passenger {}", passenger.getPassengerId());
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    /**
 * Génère un code OTP numérique à 6 chiffres.
 */
private String generateToken() {
    int code = 100000 + new SecureRandom().nextInt(900000);
    return String.valueOf(code);
}
}