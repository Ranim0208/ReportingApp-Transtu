package com.transport.reporting.service;

import com.transport.reporting.config.FrontendProperties;
import com.transport.reporting.entity.Report;
import org.springframework.stereotype.Component;

import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/**
 * Compose le contenu HTML de l'e-mail de confirmation envoyé au voyageur
 * à la création d'un signalement. Contient la référence lisible ainsi que
 * le lien de suivi sécurisé (UUID) nécessaire pour consulter l'avancement.
 */
@Component
public class ReportConfirmationEmailComposer {

    private static final DateTimeFormatter DATE_FMT =
            DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm").withLocale(Locale.FRENCH);

    /** Content-ID de l'image logo embarquée dans l'e-mail (voir EmailService). */
    public static final String LOGO_CONTENT_ID = ReplyEmailComposer.LOGO_CONTENT_ID;

    private final FrontendProperties frontendProperties;

    public ReportConfirmationEmailComposer(FrontendProperties frontendProperties) {
        this.frontendProperties = frontendProperties;
    }

    public String subject() {
        return "Confirmation de votre signalement – TRANSTU";
    }

    public String buildHtml(Report report) {
        String trackingUrl = frontendProperties.buildTrackingUrl(report.getUuid().toString());
        String reference = escapeHtml(report.getReference());
        String trackingCode = escapeHtml(report.getUuid().toString());
        String creationDate = report.getCreationDate() != null
                ? DATE_FMT.format(report.getCreationDate().atZone(ZoneId.systemDefault()))
                : "";
        String descriptionHtml = escapeHtml(report.getDescription()).replace("\n", "<br/>");

        return """
                <!DOCTYPE html>
                <html lang="fr">
                <head><meta charset="UTF-8"><title>Confirmation TRANSTU</title></head>
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
                            <h1 style="margin:0 0 12px;font-size:20px;color:#0b5c3b;">Merci pour votre signalement</h1>
                            <p style="margin:0 0 16px;line-height:1.5;">
                              Bonjour,<br/>
                              Nous avons bien enregistré votre signalement. Conservez cet e-mail : il contient
                              le lien qui vous permet d'en suivre le traitement.
                            </p>
                            <p style="margin:0 0 8px;"><strong>Référence :</strong> %s</p>
                            <p style="margin:0 0 16px;"><strong>Date :</strong> %s</p>
                            <div style="background:#f8faf9;border-left:4px solid #0b5c3b;padding:14px 16px;margin:0 0 24px;line-height:1.55;">
                              %s
                            </div>
                            <p style="text-align:center;margin:0 0 12px;">
                              <a href="%s" style="display:inline-block;background:#0b5c3b;color:#ffffff;text-decoration:none;padding:12px 22px;border-radius:6px;font-weight:bold;">
                                Suivre mon signalement
                              </a>
                            </p>
                            <p style="margin:0;font-size:12px;color:#6b7280;word-break:break-all;line-height:1.4;">
                              Si le bouton ne fonctionne pas, copiez ce lien dans votre navigateur :<br/>
                              <a href="%s" style="color:#0b5c3b;">%s</a><br/><br/>
                              Code de suivi : %s
                            </p>
                          </td>
                        </tr>
                        <tr>
                          <td style="padding:16px 28px;background:#f3f4f6;font-size:12px;color:#6b7280;text-align:center;">
                            TRANSTU — Service réclamations<br/>
                            Cet e-mail a été envoyé automatiquement, merci de ne pas y répondre directement.
                          </td>
                        </tr>
                      </table>
                    </td></tr>
                  </table>
                </body>
                </html>
                """.formatted(LOGO_CONTENT_ID, reference, escapeHtml(creationDate), descriptionHtml,
                trackingUrl, trackingUrl, trackingUrl, trackingCode);
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