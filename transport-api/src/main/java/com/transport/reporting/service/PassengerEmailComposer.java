package com.transport.reporting.service;

import com.transport.reporting.entity.Passenger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Compose le contenu HTML des e-mails destinés aux voyageurs
 * (vérification email + réinitialisation mot de passe).
 *
 * Le bouton principal pointe vers un deep link personnalisé (custom URL scheme,
 * ex. transtu://verify-email?token=...) qui ouvre l'application mobile si elle
 * est installée — adapté à la phase de développement (aucun domaine/hébergement
 * requis, contrairement à un Universal Link/App Link). Un lien texte secondaire
 * redirige vers le frontend web existant (fallback), sans en modifier le comportement.
 *
 * À migrer vers un Universal Link/App Link (https) plus tard si besoin, en
 * changeant simplement la valeur de app.mobile.deep-link-scheme.
 */
@Component
public class PassengerEmailComposer {

    /** Content-ID de l'image logo embarquée dans l'e-mail (voir EmailService). */
    public static final String LOGO_CONTENT_ID = "transtu-logo";

    private final String mobileDeepLinkScheme;
    private final String frontendBaseUrl;

    public PassengerEmailComposer(
            @Value("${app.mobile.deep-link-scheme:transtu://}") String mobileDeepLinkScheme,
            @Value("${app.frontend.public-base-url:http://localhost:4200}") String frontendBaseUrl) {
        this.mobileDeepLinkScheme = mobileDeepLinkScheme;
        this.frontendBaseUrl = frontendBaseUrl;
    }

    // ── Email Verification ────────────────────────────────────────────────────

    public String verificationSubject() {
        return "Vérifiez votre adresse email – TRANSTU";
    }

public String buildVerificationHtml(Passenger passenger, String code) {
    String name = escapeHtml(passenger.getName() != null ? passenger.getName() : "Voyageur");

    return """
            <!DOCTYPE html>
            <html lang="fr">
            <head><meta charset="UTF-8"><title>Vérification email – TRANSTU</title></head>
            <body style="margin:0;padding:0;background:#f4f6f8;font-family:Arial,Helvetica,sans-serif;color:#1a1a1a;">
              <table role="presentation" width="100%%" cellspacing="0" cellpadding="0" style="background:#f4f6f8;padding:24px 12px;">
                <tr><td align="center">
                  <table role="presentation" width="600" cellspacing="0" cellpadding="0" style="background:#ffffff;border-radius:8px;overflow:hidden;border:1px solid #e5e7eb;">
                    <tr>
                      <td style="padding:24px 28px;background:#ffffff;text-align:center;border-bottom:3px solid #0b8a3e;">
                        <img src="cid:%s" alt="TRANSTU" width="160" height="auto"
                             style="display:inline-block;max-width:160px;height:auto;border:0;outline:none;text-decoration:none;">
                      </td>
                    </tr>
                    <tr>
                      <td style="padding:28px;">
                        <h1 style="margin:0 0 12px;font-size:20px;color:#0b5c3b;">Bonjour %s,</h1>
                        <p style="margin:0 0 20px;line-height:1.5;">
                          Merci de vous être inscrit sur <strong>TRANSTU</strong>.
                          Entrez le code ci-dessous dans l'application pour activer votre compte.
                        </p>
                        <div style="text-align:center;margin:0 0 24px;">
                          <div style="display:inline-block;background:#f0faf4;border:2px solid #0b8a3e;
                                      border-radius:12px;padding:20px 40px;">
                            <p style="margin:0 0 8px;font-size:13px;color:#6b7280;text-transform:uppercase;
                                      letter-spacing:1px;">Code de vérification</p>
                            <p style="margin:0;font-size:36px;font-weight:bold;color:#0b5c3b;
                                      letter-spacing:8px;font-family:monospace;">%s</p>
                          </div>
                        </div>
                        <div style="background:#f8faf9;border-left:4px solid #0b5c3b;padding:14px 16px;
                                    margin:0 0 20px;line-height:1.55;">
                          <p style="margin:0;font-size:13px;color:#6b7280;">
                            Ce code est valable <strong>24 heures</strong>.
                            Si vous n'avez pas créé de compte, ignorez cet email.
                          </p>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td style="padding:16px 28px;background:#f3f4f6;font-size:12px;color:#6b7280;text-align:center;">
                        TRANSTU — Société des Transports de Tunis<br/>
                        Cet e-mail a été envoyé automatiquement, merci de ne pas y répondre directement.
                      </td>
                    </tr>
                  </table>
                </td></tr>
              </table>
            </body>
            </html>
            """.formatted(LOGO_CONTENT_ID, name, code);
}
    // ── Password Reset ────────────────────────────────────────────────────────

    public String resetPasswordSubject() {
        return "Réinitialisation de votre mot de passe – TRANSTU";
    }

    public String buildResetPasswordHtml(Passenger passenger, String token) {
        String appUrl = "intent://app/reset-password?token=" + token
          + "#Intent;scheme=transtu;package=com.transtu.mobile;end";
        String webUrl = frontendBaseUrl + "/reset-password?token=" + token;
        String name = escapeHtml(passenger.getName() != null ? passenger.getName() : "Voyageur");

        return """
                <!DOCTYPE html>
                <html lang="fr">
                <head><meta charset="UTF-8"><title>Réinitialisation mot de passe – TRANSTU</title></head>
                <body style="margin:0;padding:0;background:#f4f6f8;font-family:Arial,Helvetica,sans-serif;color:#1a1a1a;">
                  <table role="presentation" width="100%%" cellspacing="0" cellpadding="0" style="background:#f4f6f8;padding:24px 12px;">
                    <tr><td align="center">
                      <table role="presentation" width="600" cellspacing="0" cellpadding="0" style="background:#ffffff;border-radius:8px;overflow:hidden;border:1px solid #e5e7eb;">
                        <tr>
                          <td style="padding:24px 28px;background:#ffffff;text-align:center;border-bottom:3px solid #0b8a3e;">
                            <img src="cid:%s" alt="TRANSTU" width="160" height="auto"
                                 style="display:inline-block;max-width:160px;height:auto;border:0;outline:none;text-decoration:none;">
                          </td>
                        </tr>
                        <tr>
                          <td style="padding:28px;">
                            <h1 style="margin:0 0 12px;font-size:20px;color:#0b5c3b;">Bonjour %s,</h1>
                            <p style="margin:0 0 16px;line-height:1.5;">
                              Vous avez demandé la réinitialisation de votre mot de passe <strong>TRANSTU</strong>.
                              Appuyez sur le bouton ci-dessous pour choisir un nouveau mot de passe.
                            </p>
                            <div style="background:#fff8f0;border-left:4px solid #f57c00;padding:14px 16px;margin:0 0 24px;line-height:1.55;">
                              <p style="margin:0;font-size:13px;color:#6b7280;">
                                Ce lien est valable <strong>1 heure</strong>. Si vous n'avez pas fait cette demande, ignorez cet email.
                              </p>
                            </div>
                            <p style="text-align:center;margin:0 0 12px;">
                              <a href="%s" style="display:inline-block;background:#f57c00;color:#ffffff;text-decoration:none;padding:12px 22px;border-radius:6px;font-weight:bold;">
                                Réinitialiser mon mot de passe
                              </a>
                            </p>
                            <p style="text-align:center;margin:0 0 16px;font-size:13px;">
                              <a href="%s" style="color:#0b5c3b;">Ou réinitialisez depuis votre navigateur</a>
                            </p>
                            <p style="margin:0;font-size:12px;color:#6b7280;word-break:break-all;line-height:1.4;">
                              Si le bouton ne fonctionne pas, copiez ce lien dans votre navigateur :<br/>
                              <a href="%s" style="color:#0b5c3b;">%s</a>
                            </p>
                          </td>
                        </tr>
                        <tr>
                          <td style="padding:16px 28px;background:#f3f4f6;font-size:12px;color:#6b7280;text-align:center;">
                            TRANSTU — Société des Transports de Tunis<br/>
                            Cet e-mail a été envoyé automatiquement, merci de ne pas y répondre directement.
                          </td>
                        </tr>
                      </table>
                    </td></tr>
                  </table>
                </body>
                </html>
                """.formatted(LOGO_CONTENT_ID, name, appUrl, webUrl, webUrl, webUrl);
    }

    private static String escapeHtml(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}