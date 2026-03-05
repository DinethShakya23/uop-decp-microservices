package com.decp.user_service.dto;

import lombok.Data;

@Data
public class UserLoginRequest {
    private String email;
    private String password;
}