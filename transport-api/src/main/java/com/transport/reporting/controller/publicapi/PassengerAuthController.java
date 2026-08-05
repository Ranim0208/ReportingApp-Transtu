package com.transport.reporting.controller.publicapi;

import com.transport.reporting.common.response.ApiResponse;
import com.transport.reporting.dto.PassengerAuthResponse;
import com.transport.reporting.dto.PassengerLoginRequest;
import com.transport.reporting.dto.PassengerRegisterRequest;
import com.transport.reporting.service.PassengerAuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

/**
 * Endpoints publics d'authentification voyageur.
 * Pas de @PreAuthorize — déjà permis via /api/public/** dans SecurityConfig.
 */
@RestController
@RequestMapping("/api/public/auth")
@RequiredArgsConstructor
public class PassengerAuthController {

    private final PassengerAuthService passengerAuthService;

    /**
     * POST /api/public/auth/register
     * Inscription d'un nouveau voyageur.
     * Retourne 201 Created + token JWT.
     */
    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<PassengerAuthResponse> register(
            @Valid @RequestBody PassengerRegisterRequest request) {

        PassengerAuthResponse response = passengerAuthService.register(request);
        return ApiResponse.created("Compte créé avec succès.", response);
    }

    /**
     * POST /api/public/auth/login
     * Connexion d'un voyageur existant.
     * Retourne 200 OK + token JWT.
     */
    @PostMapping("/login")
    @ResponseStatus(HttpStatus.OK)
    public ApiResponse<PassengerAuthResponse> login(
            @Valid @RequestBody PassengerLoginRequest request) {

        PassengerAuthResponse response = passengerAuthService.login(request);
        return ApiResponse.ok("Connexion réussie.", response);
    }
}