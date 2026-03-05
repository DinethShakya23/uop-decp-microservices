package com.decp.user_service.controller;

import com.decp.user_service.dto.UserLoginRequest;
import com.decp.user_service.dto.UserRegistrationRequest;
import com.decp.user_service.model.User;
import com.decp.user_service.repository.UserRepository;
import com.decp.user_service.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtUtil jwtUtil; // Injecting our new JWT Utility!

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody UserRegistrationRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body("Error: Email is already registered!");
        }

        User newUser = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(request.getPassword())
                .role(request.getRole())
                .build();

        userRepository.save(newUser);

        return ResponseEntity.ok("User registered successfully as a " + request.getRole() + "!");
    }

    @PostMapping("/login")
    public ResponseEntity<?> loginUser(@RequestBody UserLoginRequest request) {
        var optionalUser = userRepository.findByEmail(request.getEmail());

        if (optionalUser.isEmpty()) {
            return ResponseEntity.status(401).body("Error: Invalid email or password");
        }

        User user = optionalUser.get();

        if (!user.getPassword().equals(request.getPassword())) {
            return ResponseEntity.status(401).body("Error: Invalid email or password");
        }

        // Generate the secure JWT token!
        String token = jwtUtil.generateToken(user.getEmail(), user.getRole().name());

        // Return the token in a clean JSON format
        return ResponseEntity.ok(Map.of(
                "message", "Welcome back, " + user.getName() + "!",
                "token", token,
                "role", user.getRole().name()
        ));
    }
}