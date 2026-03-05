package com.decp.research.dto;

import com.decp.research.model.ResearchCategory;
import com.decp.research.model.ResearchTag;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ResearchResponse {

    private Long id;
    private String title;
    private String researchAbstract;
    private List<String> authors;
    private List<ResearchTag> tags;
    private String documentUrl;
    private String doi;
    private ResearchCategory category;
    private Long views;
    private Long downloads;
    private Long citations;
    private Long createdBy;
    private String createdByName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
