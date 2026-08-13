package com.transport.reporting.service;

import com.transport.reporting.entity.Passenger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Compose les emails HTML pour les voyageurs
 * (vérification email + reset mot de passe).
 */
@Component
public class PassengerEmailComposer {

    public static final String LOGO_CONTENT_ID = "transtu_logo";

    @Value("${app.frontend.public-base-url:http://localhost:4200}")
    private String frontendBaseUrl;

    // ── Email Verification ────────────────────────────────────────────────────

    public String verificationSubject() {
        return "Transtu — Vérifiez votre adresse email";
    }

    public String buildVerificationHtml(Passenger passenger, String token) {
        final String verifyUrl = frontendBaseUrl + "/verify-email?token=" + token;
        final String name      = passenger.getName() != null
                ? passenger.getName() : "Voyageur";

        return """
                <!DOCTYPE html>
                <html lang="fr">
                <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Vérification email — Transtu</title></head>
                <body style="margin:0;padding:0;background:#F5F6F8;font-family:Inter,Arial,sans-serif;">
                  <table width="100%%" cellpadding="0" cellspacing="0" style="background:#F5F6F8;padding:32px 0;">
                    <tr><td align="center">
                      <table width="560" cellpadding="0" cellspacing="0"
                             style="background:#ffffff;border-radius:16px;overflow:hidden;
                                    box-shadow:0 4px 16px rgba(0,0,0,0.06);">
                        <!-- Header -->
                        <tr>
                          <td style="background:#1B8B3B;padding:28px 32px;text-align:center;">
                            <img src="cid:%s" alt="Transtu" width="130"
                                 style="display:block;margin:0 auto;" />
                          </td>
                        </tr>
                        <!-- Body -->
                        <tr>
                          <td style="padding:36px 32px 28px;">
                            <p style="margin:0 0 12px;font-size:22px;font-weight:700;color:#111827;">
                              Bonjour %s,
                            </p>
                            <p style="margin:0 0 20px;font-size:15px;color:#6B7280;line-height:1.6;">
                              Merci de vous être inscrit sur <strong>Transtu</strong>.
                              Cliquez sur le bouton ci-dessous pour vérifier votre adresse email
                              et activer votre compte.
                            </p>
                            <p style="margin:0 0 28px;font-size:13px;color:#9CA3AF;">
                              Ce lien est valable <strong>24 heures</strong>.
                            </p>
                            <div style="text-align:center;margin-bottom:28px;">
                              <a href="%s"
                                 style="display:inline-block;background:#1B8B3B;color:#ffffff;
                                        font-size:15px;font-weight:600;padding:14px 36px;
                                        border-radius:10px;text-decoration:none;">
                                Vérifier mon email
                              </a>
                            </div>
                            <p style="margin:0;font-size:12px;color:#9CA3AF;line-height:1.5;">
                              Si vous n'avez pas créé de compte, ignorez cet email.<br/>
                              Lien alternatif : <a href="%s" style="color:#1B8B3B;">%s</a>
                            </p>
                          </td>
                        </tr>
                        <!-- Footer -->
                        <tr>
                          <td style="background:#F5F6F8;padding:16px 32px;text-align:center;">
                            <p style="margin:0;font-size:12px;color:#9CA3AF;">
                              © 2026 Transtu — Société des Transports de Tunis
                            </p>
                          </td>
                        </tr>
                      </table>
                    </td></tr>
                  </table>
                </body>
                </html>
                """.formatted(
                LOGO_CONTENT_ID, name, verifyUrl, verifyUrl, verifyUrl
        );
    }

    // ── Password Reset ────────────────────────────────────────────────────────

    public String resetPasswordSubject() {
        return "Transtu — Réinitialisation de votre mot de passe";
    }

    public String buildResetPasswordHtml(Passenger passenger, String token) {
        final String resetUrl = frontendBaseUrl + "/reset-password?token=" + token;
        final String name     = passenger.getName() != null
                ? passenger.getName() : "Voyageur";

        return """
                <!DOCTYPE html>
                <html lang="fr">
                <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
                <title>Réinitialisation mot de passe — Transtu</title></head>
                <body style="margin:0;padding:0;background:#F5F6F8;font-family:Inter,Arial,sans-serif;">
                  <table width="100%%" cellpadding="0" cellspacing="0" style="background:#F5F6F8;padding:32px 0;">
                    <tr><td align="center">
                      <table width="560" cellpadding="0" cellspacing="0"
                             style="background:#ffffff;border-radius:16px;overflow:hidden;
                                    box-shadow:0 4px 16px rgba(0,0,0,0.06);">
                        <!-- Header -->
                        <tr>
                          <td style="background:#1B8B3B;padding:28px 32px;text-align:center;">
                            <img src="cid:%s" alt="Transtu" width="130"
                                 style="display:block;margin:0 auto;" />
                          </td>
                        </tr>
                        <!-- Body -->
                        <tr>
                          <td style="padding:36px 32px 28px;">
                            <p style="margin:0 0 12px;font-size:22px;font-weight:700;color:#111827;">
                              Bonjour %s,
                            </p>
                            <p style="margin:0 0 20px;font-size:15px;color:#6B7280;line-height:1.6;">
                              Vous avez demandé la réinitialisation de votre mot de passe
                              <strong>Transtu</strong>. Cliquez sur le bouton ci-dessous
                              pour choisir un nouveau mot de passe.
                            </p>
                            <p style="margin:0 0 28px;font-size:13px;color:#9CA3AF;">
                              Ce lien est valable <strong>1 heure</strong>.
                              Si vous n'avez pas fait cette demande, ignorez cet email.
                            </p>
                            <div style="text-align:center;margin-bottom:28px;">
                              <a href="%s"
                                 style="display:inline-block;background:#F57C00;color:#ffffff;
                                        font-size:15px;font-weight:600;padding:14px 36px;
                                        border-radius:10px;text-decoration:none;">
                                Réinitialiser mon mot de passe
                              </a>
                            </div>
                            <p style="margin:0;font-size:12px;color:#9CA3AF;line-height:1.5;">
                              Lien alternatif : <a href="%s" style="color:#1B8B3B;">%s</a>
                            </p>
                          </td>
                        </tr>
                        <!-- Footer -->
                        <tr>
                          <td style="background:#F5F6F8;padding:16px 32px;text-align:center;">
                            <p style="margin:0;font-size:12px;color:#9CA3AF;">
                              © 2026 Transtu — Société des Transports de Tunis
                            </p>
                          </td>
                        </tr>
                      </table>
                    </td></tr>
                  </table>
                </body>
                </html>
                """.formatted(
                LOGO_CONTENT_ID, name, resetUrl, resetUrl, resetUrl
        );
    }
}