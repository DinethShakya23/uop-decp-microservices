package com.decp.user_service.controller;

import com.decp.user_service.dto.UserLoginRequest;
import com.decp.user_service.dto.UserRegistrationRequest;
import com.decp.user_service.model.Connection;
import com.decp.user_service.model.User;
import com.decp.user_service.repository.ConnectionRepository;
import com.decp.user_service.repository.UserRepository;
import com.decp.user_service.security.JwtUtil;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ConnectionRepository connectionRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody UserRegistrationRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body("Error: Email is already registered!");
        }

        String hashedPassword = BCrypt.hashpw(request.getPassword(), BCrypt.gensalt());

        User newUser = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .passwordHash(hashedPassword)
                .role(request.getRole())
                .status("ACTIVE")
                .profileViews(0L)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        User savedUser = userRepository.save(newUser);

        return ResponseEntity.status(201).body(Map.of(
            "id", savedUser.getId(),
            "name", savedUser.getName(),
            "email", savedUser.getEmail(),
            "role", savedUser.getRole().name(),
            "createdAt", savedUser.getCreatedAt()
        ));
    }

    @PostMapping("/login")
    public ResponseEntity<?> loginUser(@RequestBody UserLoginRequest request) {
        var optionalUser = userRepository.findByEmail(request.getEmail());

        if (optionalUser.isEmpty()) {
            return ResponseEntity.status(401).body("Error: Invalid email or password");
        }

        User user = optionalUser.get();

        if (!BCrypt.checkpw(request.getPassword(), user.getPasswordHash())) {
            return ResponseEntity.status(401).body("Error: Invalid email or password");
        }

        String token = jwtUtil.generateToken(user.getId(), user.getName(), user.getEmail(), user.getRole().name());

        return ResponseEntity.ok(Map.of(
                "token", token,
                "role", user.getRole().name(),
                "id", user.getId(),
                "name", user.getName()
        ));
    }
    
    @GetMapping("/{id}/profile")
    public ResponseEntity<?> getProfile(@PathVariable Long id, @RequestHeader(value = "X-User-Id", required = false) String viewerIdStr) {
        Optional<User> optionalUser = userRepository.findById(id);
        if (optionalUser.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        
        User user = optionalUser.get();

        // Increment view count if the viewer is not the owner
        if (viewerIdStr != null) {
            Long viewerId = Long.parseLong(viewerIdStr);
            if (!viewerId.equals(id)) {
                user.setProfileViews(user.getProfileViews() + 1);
                userRepository.save(user);
            }
        }
        
        long connections = connectionRepository.countByUserId(id);

        return ResponseEntity.ok(Map.of(
            "id", user.getId(),
            "name", user.getName(),
            "email", user.getEmail(),
            "role", user.getRole().name(),
            "bio", user.getBio() != null ? user.getBio() : "",
            "department", user.getDepartment() != null ? user.getDepartment() : "",
            "graduationYear", user.getGraduationYear() != null ? user.getGraduationYear() : 0,
            "profileViews", user.getProfileViews(),
            "connections", connections,
            "createdAt", user.getCreatedAt() != null ? user.getCreatedAt() : ""
        ));
    }

    @PutMapping("/{id}/profile")
    public ResponseEntity<?> updateProfile(@PathVariable Long id, @RequestBody Map<String, Object> updates) {
        Optional<User> optionalUser = userRepository.findById(id);
        if (optionalUser.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        User user = optionalUser.get();
        if (updates.containsKey("name")) user.setName((String) updates.get("name"));
        if (updates.containsKey("bio")) user.setBio((String) updates.get("bio"));
        if (updates.containsKey("department")) user.setDepartment((String) updates.get("department"));
        if (updates.containsKey("graduationYear")) user.setGraduationYear((Integer) updates.get("graduationYear"));
        
        user.setUpdatedAt(LocalDateTime.now());
        User updatedUser = userRepository.save(user);

        return ResponseEntity.ok(updatedUser);
    }

    @PostMapping("/{id}/connect")
    public ResponseEntity<?> connect(@PathVariable Long id, @RequestHeader("X-User-Id") String userIdStr) {
        Long currentUserId = Long.parseLong(userIdStr);
        if (currentUserId.equals(id)) {
            return ResponseEntity.badRequest().body("You cannot connect with yourself!");
        }

        // Check if already connected
        if (connectionRepository.findByUserIdAndConnectedUserId(currentUserId, id).isPresent()) {
            return ResponseEntity.ok("Already connected!");
        }

        // Bidi-connection for this prototype (LinkedIn style usually has requests, but we'll do direct follow/connect)
        Connection c1 = Connection.builder().userId(currentUserId).connectedUserId(id).build();
        Connection c2 = Connection.builder().userId(id).connectedUserId(currentUserId).build();
        
        connectionRepository.save(c1);
        connectionRepository.save(c2);

        return ResponseEntity.ok("Connected successfully!");
    }

    @GetMapping("/list")
    public ResponseEntity<?> listUsers() {
        return ResponseEntity.ok(userRepository.findAll());
    }
}