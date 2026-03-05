package com.decp.research.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CitationResponse {

    private Long researchId;
    private String title;
    private String authors;
    private String doi;
    private String year;
    private String category;
    private String bibtex;
    private String apa;
}
