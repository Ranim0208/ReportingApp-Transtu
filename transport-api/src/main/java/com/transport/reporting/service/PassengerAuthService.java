package com.transport.reporting.service;

import com.transport.reporting.dto.PassengerAuthResponse;
import com.transport.reporting.dto.PassengerLoginRequest;
import com.transport.reporting.dto.PassengerRegisterRequest;
import com.transport.reporting.entity.Passenger;
import com.transport.reporting.exception.BusinessException;
import com.transport.reporting.repository.PassengerRepository;
import com.transport.reporting.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Gestion de l'authentification des voyageurs (register / login).
 * Les JWT émis ici utilisent le sujet "passenger:{passengerId}".
 */
@Service
@RequiredArgsConstructor
public class PassengerAuthService {

    private final PassengerRepository passengerRepository;
    private final PasswordEncoder     passwordEncoder;
    private final JwtService          jwtService;

    /**
     * Inscription d'un nouveau voyageur.
     * @throws BusinessException si l'email est déjà utilisé.
     */
    @Transactional
    public PassengerAuthResponse register(PassengerRegisterRequest request) {

        // Vérifier unicité de l'email (insensible à la casse)
        passengerRepository.findByEmailIgnoreCase(request.getEmail().trim())
                .ifPresent(existing -> {
                    throw new BusinessException(
                            "Un compte existe déjà avec cet email.");
                });

        Passenger passenger = Passenger.builder()
                .name(request.getName().trim())
                .email(request.getEmail().trim().toLowerCase())
                .phoneNumber(request.getPhoneNumber() != null
                        ? request.getPhoneNumber().trim()
                        : null)
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .emailVerified(false)
                .active(true)
                .build();

        passenger = passengerRepository.save(passenger);

        String subject = "passenger:" + passenger.getPassengerId();
        String token   = jwtService.generateTokenForSubject(subject);

        return toResponse(passenger, token);
    }

    /**
     * Connexion d'un voyageur existant.
     * @throws BusinessException si les identifiants sont incorrects ou le compte inactif.
     */
    @Transactional(readOnly = true)
    public PassengerAuthResponse login(PassengerLoginRequest request) {

        Passenger passenger = passengerRepository
                .findByEmailIgnoreCase(request.getEmail().trim())
                .orElseThrow(() ->
                        new BusinessException("Email ou mot de passe incorrect."));

        // Compte anonyme créé lors d'un signalement — pas de mot de passe défini
        if (passenger.getPasswordHash() == null) {
            throw new BusinessException(
                    "Ce compte n'a pas de mot de passe. "
                    + "Veuillez vous inscrire pour en créer un.");
        }

        if (!passwordEncoder.matches(request.getPassword(), passenger.getPasswordHash())) {
            throw new BusinessException("Email ou mot de passe incorrect.");
        }

        if (!passenger.isActive()) {
            throw new BusinessException(
                    "Ce compte a été désactivé. Veuillez contacter le support.");
        }

        String subject = "passenger:" + passenger.getPassengerId();
        String token   = jwtService.generateTokenForSubject(subject);

        return toResponse(passenger, token);
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private PassengerAuthResponse toResponse(Passenger passenger, String token) {
        return PassengerAuthResponse.builder()
                .passengerId(passenger.getPassengerId())
                .name(passenger.getName())
                .email(passenger.getEmail())
                .phoneNumber(passenger.getPhoneNumber())
                .token(token)
                .tokenType("Bearer")
                .build();
    }
}