package com.decp.api_gateway.filter;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.security.Key;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    // MUST match the exact secret string from the User Service!
    private final String SECRET = "ThisIsASuperSecretKeyForDepartmentEngagementPlatformMakeItLongEnough";
    private final Key key = Keys.hmacShaKeyFor(SECRET.getBytes());

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        // Allow CORS preflight requests to pass through without a token
        if (request.getMethod().equals("OPTIONS")) {
            filterChain.doFilter(request, response);
            return;
        }
        // ------------------------------------------------------------------
        String path = request.getRequestURI();

        // 1. Allow login and registration requests to pass through without a token
        if (path.startsWith("/api/users/login") || path.startsWith("/api/users/register")) {
            filterChain.doFilter(request, response);
            return;
        }

        // 2. For everything else (like /api/feed), demand a token
        String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Missing or invalid Authorization header!");
            return;
        }

        // 3. Extract and verify the token
        String token = authHeader.substring(7); // Remove "Bearer " prefix

        try {
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();

            // If the code reaches here, the token is valid! Let the request through to the Feed Service.
            filterChain.doFilter(request, response);

        } catch (Exception e) {
            System.out.println("TOKEN REJECTED BECAUSE: " + e.getMessage()); // <-- Add this
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("Token validation failed!");
        }
    }
}