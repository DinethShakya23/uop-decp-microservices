package com.decp.research.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "research")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Research {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 500)
    private String title;

    @Column(name = "research_abstract", columnDefinition = "TEXT")
    private String researchAbstract;

    @ElementCollection
    @CollectionTable(name = "research_authors", joinColumns = @JoinColumn(name = "research_id"))
    @Column(name = "author")
    @Builder.Default
    private List<String> authors = new ArrayList<>();

    @ElementCollection
    @CollectionTable(name = "research_tags", joinColumns = @JoinColumn(name = "research_id"))
    @Column(name = "tag")
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private List<ResearchTag> tags = new ArrayList<>();

    private String documentUrl;

    @Column(unique = true)
    private String doi;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ResearchCategory category;

    @Builder.Default
    private Long views = 0L;

    @Builder.Default
    private Long downloads = 0L;

    @Builder.Default
    private Long citations = 0L;

    private Long createdBy;

    private String createdByName;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
