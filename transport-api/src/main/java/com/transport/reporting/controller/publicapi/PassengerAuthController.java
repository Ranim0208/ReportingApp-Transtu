package com.transport.reporting.controller.publicapi;

import com.transport.reporting.common.response.ApiResponse;
import com.transport.reporting.dto.PassengerAuthResponse;
import com.transport.reporting.dto.PassengerLoginRequest;
import com.transport.reporting.dto.PassengerRegisterRequest;
import com.transport.reporting.exception.BusinessException;
import com.transport.reporting.security.RecaptchaService;
import com.transport.reporting.service.PassengerAuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

/**
 * Endpoints publics d'authentification voyageur.
 */
@RestController
@RequestMapping("/api/public/auth")
@RequiredArgsConstructor
public class PassengerAuthController {

    private final PassengerAuthService passengerAuthService;
    private final RecaptchaService     recaptchaService;

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<PassengerAuthResponse> register(
            @Valid @RequestBody PassengerRegisterRequest request,
            @RequestHeader(value = "X-Recaptcha-Token", required = false)
            String recaptchaToken) {

        if (!recaptchaService.verify(recaptchaToken, "register")) {
            throw new BusinessException(
                    "Vérification de sécurité échouée. Veuillez réessayer.");
        }

        PassengerAuthResponse response = passengerAuthService.register(request);
        return ApiResponse.created("Compte créé avec succès.", response);
    }

    @PostMapping("/login")
    @ResponseStatus(HttpStatus.OK)
    public ApiResponse<PassengerAuthResponse> login(
            @Valid @RequestBody PassengerLoginRequest request,
            @RequestHeader(value = "X-Recaptcha-Token", required = false)
            String recaptchaToken) {

        if (!recaptchaService.verify(recaptchaToken, "login")) {
            throw new BusinessException(
                    "Vérification de sécurité échouée. Veuillez réessayer.");
        }

        PassengerAuthResponse response = passengerAuthService.login(request);
        return ApiResponse.ok("Connexion réussie.", response);
    }
}