package com.decp.user_service.security;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

@Component
public class JwtUtil {

    // Generate a secure, random cryptographic key for signing the tokens
    // In production, this should be a long string saved in your application.yml!
    private final Key key = Keys.secretKeyFor(SignatureAlgorithm.HS256);

    // Set token expiration time (e.g., 24 hours)
    private final long EXPIRATION_TIME = 86400000;

    public String generateToken(String email, String role) {
        return Jwts.builder()
                .setSubject(email)
                .claim("role", role) // Store the user's role inside the token
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(key)
                .compact();
    }
}