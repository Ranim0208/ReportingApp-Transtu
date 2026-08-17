package com.transport.reporting.security;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.Refill;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Service de rate limiting par IP.
 * Utilise Bucket4j avec stockage en mémoire (ConcurrentHashMap).
 * Chaque IP a son propre bucket avec des limites différentes selon l'endpoint.
 */
@Service
public class RateLimiterService {

    // ── Buckets par IP ────────────────────────────────────────────────────────

    // Login : 5 tentatives / minute
    private final Map<String, Bucket> loginBuckets =
            new ConcurrentHashMap<>();

    // Register : 3 tentatives / minute
    private final Map<String, Bucket> registerBuckets =
            new ConcurrentHashMap<>();

    // Forgot password : 3 tentatives / 5 minutes
    private final Map<String, Bucket> forgotPasswordBuckets =
            new ConcurrentHashMap<>();

    // Resend verification : 3 tentatives / 5 minutes
    private final Map<String, Bucket> resendBuckets =
            new ConcurrentHashMap<>();

    // Submit report : 10 signalements / minute
    private final Map<String, Bucket> reportBuckets =
            new ConcurrentHashMap<>();

    // Verify email : 5 tentatives / minute
    private final Map<String, Bucket> verifyEmailBuckets =
            new ConcurrentHashMap<>();

    // ── API publique ──────────────────────────────────────────────────────────

    public boolean tryConsumeLogin(String ip) {
        return loginBuckets
                .computeIfAbsent(ip, k -> buildBucket(5, Duration.ofMinutes(1)))
                .tryConsume(1);
    }

    public boolean tryConsumeRegister(String ip) {
        return registerBuckets
                .computeIfAbsent(ip, k -> buildBucket(3, Duration.ofMinutes(1)))
                .tryConsume(1);
    }

    public boolean tryConsumeForgotPassword(String ip) {
        return forgotPasswordBuckets
                .computeIfAbsent(ip, k -> buildBucket(3, Duration.ofMinutes(5)))
                .tryConsume(1);
    }

    public boolean tryConsumeResendVerification(String ip) {
        return resendBuckets
                .computeIfAbsent(ip, k -> buildBucket(3, Duration.ofMinutes(5)))
                .tryConsume(1);
    }

    public boolean tryConsumeSubmitReport(String ip) {
        return reportBuckets
                .computeIfAbsent(ip, k -> buildBucket(10, Duration.ofMinutes(1)))
                .tryConsume(1);
    }

    public boolean tryConsumeVerifyEmail(String ip) {
        return verifyEmailBuckets
                .computeIfAbsent(ip, k -> buildBucket(5, Duration.ofMinutes(1)))
                .tryConsume(1);
    }

    // ── Helper ────────────────────────────────────────────────────────────────

    private Bucket buildBucket(int capacity, Duration refillDuration) {
        final Bandwidth limit = Bandwidth.classic(
                capacity,
                Refill.intervally(capacity, refillDuration)
        );
        return Bucket.builder().addLimit(limit).build();
    }
}