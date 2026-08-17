package com.transport.reporting.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

/**
 * Service de vérification du token reCAPTCHA v3 côté backend.
 * Vérifie le token auprès de l'API Google et valide le score.
 */
@Service
@Slf4j
public class RecaptchaService {

    @Value("${app.recaptcha.secret-key}")
    private String secretKey;

    @Value("${app.recaptcha.verify-url}")
    private String verifyUrl;

    @Value("${app.recaptcha.min-score:0.5}")
    private double minScore;

    @Value("${app.recaptcha.enabled:true}")
    private boolean enabled;

    private final RestTemplate restTemplate = new RestTemplate();

    /**
     * Vérifie le token reCAPTCHA v3.
     *
     * @param token  Token reçu depuis Flutter
     * @param action Action attendue (ex: "login", "register")
     * @return true si humain, false si bot
     */
    public boolean verify(String token, String action) {
        // Si désactivé (ex: tests) → toujours valide
        if (!enabled) {
            log.debug("reCAPTCHA disabled — skipping verification");
            return true;
        }

        if (token == null || token.isBlank()) {
            log.warn("reCAPTCHA token is null or blank");
            return false;
        }

        try {
            final MultiValueMap<String, String> params =
                    new LinkedMultiValueMap<>();
            params.add("secret",   secretKey);
            params.add("response", token);

            @SuppressWarnings("unchecked")
            final Map<String, Object> response =
                    restTemplate.postForObject(verifyUrl, params, Map.class);

            if (response == null) {
                log.warn("reCAPTCHA API returned null response");
                return false;
            }

            final boolean success = Boolean.TRUE.equals(response.get("success"));
            final double  score   = response.containsKey("score")
                    ? ((Number) response.get("score")).doubleValue()
                    : 0.0;
            final String  responseAction = (String) response.get("action");

            log.debug("reCAPTCHA result: success={}, score={}, action={}",
                    success, score, responseAction);

            if (!success) {
                log.warn("reCAPTCHA verification failed: {}",
                        response.get("error-codes"));
                return false;
            }

            if (score < minScore) {
                log.warn("reCAPTCHA score too low: {} < {}", score, minScore);
                return false;
            }

            // Vérifie que l'action correspond
            if (action != null && responseAction != null
                    && !action.equals(responseAction)) {
                log.warn("reCAPTCHA action mismatch: expected={}, got={}",
                        action, responseAction);
                return false;
            }

            return true;

        } catch (Exception e) {
            log.error("reCAPTCHA verification error: {}", e.getMessage());
            // En cas d'erreur réseau → on laisse passer (fail open)
            return true;
        }
    }
}