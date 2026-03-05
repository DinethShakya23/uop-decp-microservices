package com.decp.research.model;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "research_versions")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ResearchVersion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long researchId;

    @Column(nullable = false)
    private Integer versionNumber;

    private String documentUrl;

    @Column(length = 1000)
    private String changelog;

    private LocalDateTime uploadedAt;

    private String uploadedByName;

    @PrePersist
    protected void onCreate() {
        uploadedAt = LocalDateTime.now();
    }
}
