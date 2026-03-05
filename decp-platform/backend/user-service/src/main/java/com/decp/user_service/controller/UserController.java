package com.decp.user_service.controller;

import com.decp.user_service.dto.UserRegistrationRequest;
import com.decp.user_service.dto.UserLoginRequest;
import com.decp.user_service.model.User;
import com.decp.user_service.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody UserRegistrationRequest request) {
        // 1. Check if the email is already taken
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body("Error: Email is already registered!");
        }

        // 2. Build the new User object
        User newUser = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(request.getPassword()) // Note: We will add password hashing later!
                .role(request.getRole())
                .build();

        // 3. Save to the MySQL database
        userRepository.save(newUser);

        return ResponseEntity.ok("User registered successfully as a " + request.getRole() + "!");
    }




    @PostMapping("/login")
    public ResponseEntity<?> loginUser(@RequestBody UserLoginRequest request) {
        // 1. Find the user by email
        var optionalUser = userRepository.findByEmail(request.getEmail());

        // 2. If user doesn't exist, return an error
        if (optionalUser.isEmpty()) {
            return ResponseEntity.status(401).body("Error: Invalid email or password");
        }

        User user = optionalUser.get();

        // 3. Check the password
        // WARNING: This is plain text comparison for development only!
        // We will implement proper BCrypt password hashing later.
        if (!user.getPassword().equals(request.getPassword())) {
            return ResponseEntity.status(401).body("Error: Invalid email or password");
        }

        // 4. Success! (Later, we will generate and return a JWT Token here)
        return ResponseEntity.ok("Welcome back, " + user.getName() + "! You are logged in as a " + user.getRole() + ".");
    }
}