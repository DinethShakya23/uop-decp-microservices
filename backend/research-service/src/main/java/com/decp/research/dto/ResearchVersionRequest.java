package com.decp.research.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ResearchVersionRequest {

    @NotBlank(message = "Document URL is required")
    private String documentUrl;

    private String changelog;
}
