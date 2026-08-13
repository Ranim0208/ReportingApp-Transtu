package com.transport.reporting.repository;

import com.transport.reporting.entity.PassengerToken;
import com.transport.reporting.entity.PassengerToken.TokenType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface PassengerTokenRepository extends JpaRepository<PassengerToken, Long> {

    Optional<PassengerToken> findByTokenAndTokenType(String token, TokenType tokenType);

    @Modifying
    @Query("UPDATE PassengerToken t SET t.used = true " +
           "WHERE t.passenger.passengerId = :passengerId " +
           "AND t.tokenType = :tokenType AND t.used = false")
    void invalidateAllForPassenger(Long passengerId, TokenType tokenType);
}