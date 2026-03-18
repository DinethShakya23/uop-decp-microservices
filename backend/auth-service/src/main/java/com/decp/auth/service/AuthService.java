package com.decp.auth.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.decp.auth.dto.AuthRequest;
import com.decp.auth.dto.AuthResponse;
import com.decp.auth.dto.UserDTO;
import com.decp.auth.util.JwtUtils;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final JwtUtils jwtUtils;
    private final RestTemplate restTemplate;
    private final org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;

    @Value("${user.service.internal-url:http://localhost:8082/api/users/internal}")
    private String userServiceInternalUrl;

    public AuthResponse login(AuthRequest request) {
        try {
            UserDTO user = restTemplate.getForObject(userServiceInternalUrl + "/" + request.getUsername(), UserDTO.class);
            
            if (user == null || !passwordEncoder.matches(request.getPassword(), user.getPassword())) {
                throw new RuntimeException("Invalid credentials");
            }

            Map<String, Object> claims = new HashMap<>();
            claims.put("role", user.getRole());
            claims.put("userId", user.getId());

            String token = jwtUtils.generateToken(user.getUsername(), claims);
            
            // Strip password before sending to client
            user.setPassword(null);
            return new AuthResponse(token, user);
        } catch (Exception e) {
            throw new RuntimeException("Authentication failed: " + e.getMessage());
        }
    }

    public boolean validate(String token) {
        return jwtUtils.validateToken(token);
    }
}