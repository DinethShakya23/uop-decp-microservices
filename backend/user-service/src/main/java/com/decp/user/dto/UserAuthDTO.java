package com.decp.user.dto;

import com.decp.user.model.UserRole;
import lombok.Data;

@Data
public class UserAuthDTO {
    private Long id;
    private String username;
    private String password; // This will be the hashed password
    private String email;
    private String fullName;
    private UserRole role;
}