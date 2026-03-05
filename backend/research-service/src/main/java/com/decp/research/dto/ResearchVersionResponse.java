package com.decp.research.dto;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ResearchVersionResponse {

    private Long id;
    private Long researchId;
    private Integer versionNumber;
    private String documentUrl;
    private String changelog;
    private LocalDateTime uploadedAt;
    private String uploadedByName;
}
