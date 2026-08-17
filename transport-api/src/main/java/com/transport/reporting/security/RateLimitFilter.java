package com.transport.reporting.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Map;

/**
 * Filtre HTTP appliquant le rate limiting par IP.
 * Intercepte les endpoints sensibles avant qu'ils atteignent les controllers.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class RateLimitFilter extends OncePerRequestFilter {

    private final RateLimiterService rateLimiterService;
    private final ObjectMapper       objectMapper;

    @Override
    protected void doFilterInternal(
            HttpServletRequest  request,
            HttpServletResponse response,
            FilterChain         filterChain
    ) throws ServletException, IOException {

        final String ip   = extractIp(request);
        final String path = request.getRequestURI();
        final String method = request.getMethod();

        boolean allowed = true;

        if ("POST".equals(method)) {
            if (path.endsWith("/auth/login")) {
                allowed = rateLimiterService.tryConsumeLogin(ip);
            } else if (path.endsWith("/auth/register")) {
                allowed = rateLimiterService.tryConsumeRegister(ip);
            } else if (path.endsWith("/auth/forgot-password")) {
                allowed = rateLimiterService.tryConsumeForgotPassword(ip);
            } else if (path.endsWith("/auth/resend-verification")) {
                allowed = rateLimiterService.tryConsumeResendVerification(ip);
            } else if (path.endsWith("/auth/verify-email")) {
                allowed = rateLimiterService.tryConsumeVerifyEmail(ip);
            } else if (path.endsWith("/signalements")) {
                allowed = rateLimiterService.tryConsumeSubmitReport(ip);
            }
        }

        if (!allowed) {
            log.warn("Rate limit exceeded for IP {} on {}", ip, path);
            rejectRequest(response);
            return;
        }

        filterChain.doFilter(request, response);
    }

    private void rejectRequest(HttpServletResponse response) throws IOException {
        response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");

        final Map<String, Object> body = Map.of(
                "success", false,
                "status",  429,
                "message", "Trop de tentatives. Veuillez réessayer dans quelques minutes."
        );

        response.getWriter().write(objectMapper.writeValueAsString(body));
    }

    /**
     * Extrait l'IP réelle en tenant compte des proxies (X-Forwarded-For).
     */
    private String extractIp(HttpServletRequest request) {
        final String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}