package com.decp.research.dto;

import com.decp.research.model.ResearchCategory;
import com.decp.research.model.ResearchTag;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ResearchRequest {

    @NotBlank(message = "Title is required")
    @Size(max = 500, message = "Title must be at most 500 characters")
    private String title;

    @Size(max = 2000, message = "Abstract must be at most 2000 characters")
    private String researchAbstract;

    private List<String> authors;

    private List<ResearchTag> tags;

    private String documentUrl;

    private String doi;

    @NotNull(message = "Category is required")
    private ResearchCategory category;
}
