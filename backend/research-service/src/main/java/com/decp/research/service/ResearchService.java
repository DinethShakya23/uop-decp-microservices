package com.decp.research.service;

import com.decp.research.config.ResearchEventPublisher;
import com.decp.research.dto.*;
import com.decp.research.model.Research;
import com.decp.research.model.ResearchCategory;
import com.decp.research.model.ResearchTag;
import com.decp.research.model.ResearchVersion;
import com.decp.research.repository.ResearchRepository;
import com.decp.research.repository.ResearchVersionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ResearchService {

    private final ResearchRepository researchRepository;
    private final ResearchVersionRepository versionRepository;
    private final ResearchEventPublisher eventPublisher;

    @Transactional
    public ResearchResponse uploadResearch(ResearchRequest request, Long userId, String userName) {
        Research research = Research.builder()
                .title(request.getTitle())
                .researchAbstract(request.getResearchAbstract())
                .authors(request.getAuthors() != null ? request.getAuthors() : new ArrayList<>())
                .tags(request.getTags() != null ? request.getTags() : new ArrayList<>())
                .documentUrl(request.getDocumentUrl())
                .doi(request.getDoi())
                .category(request.getCategory())
                .createdBy(userId)
                .createdByName(userName)
                .build();

        Research saved = researchRepository.save(research);

        // Create initial version
        if (saved.getDocumentUrl() != null) {
            ResearchVersion version = ResearchVersion.builder()
                    .researchId(saved.getId())
                    .versionNumber(1)
                    .documentUrl(saved.getDocumentUrl())
                    .changelog("Initial upload")
                    .uploadedByName(userName)
                    .build();
            versionRepository.save(version);
        }

        eventPublisher.publishResearchUploaded(saved.getId(), saved.getTitle(), userName);

        return toResponse(saved);
    }

    public List<ResearchResponse> getAllResearch() {
        return researchRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public ResearchResponse getResearchById(Long id) {
        Research research = researchRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Research not found with id: " + id));
        research.setViews(research.getViews() + 1);
        researchRepository.save(research);
        return toResponse(research);
    }

    public ResearchResponse updateResearch(Long id, ResearchRequest request, String userName) {
        Research research = researchRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Research not found with id: " + id));

        if (!userName.equals(research.getCreatedByName())) {
            throw new RuntimeException("Only the author can update this research");
        }

        research.setTitle(request.getTitle());
        research.setResearchAbstract(request.getResearchAbstract());
        if (request.getAuthors() != null) {
            research.setAuthors(request.getAuthors());
        }
        if (request.getTags() != null) {
            research.setTags(request.getTags());
        }
        research.setDocumentUrl(request.getDocumentUrl());
        research.setDoi(request.getDoi());
        research.setCategory(request.getCategory());

        Research updated = researchRepository.save(research);
        return toResponse(updated);
    }

    public void deleteResearch(Long id, String userName, String userRole) {
        Research research = researchRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Research not found with id: " + id));

        if (!"ADMIN".equals(userRole) && !userName.equals(research.getCreatedByName())) {
            throw new RuntimeException("Only the author or an admin can delete this research");
        }

        researchRepository.delete(research);
    }

    public List<ResearchResponse> getResearchByUser(Long userId) {
        return researchRepository.findByCreatedByOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public List<ResearchResponse> getResearchByTag(ResearchTag tag) {
        return researchRepository.findByTag(tag)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public List<ResearchResponse> getResearchByCategory(ResearchCategory category) {
        return researchRepository.findByCategoryOrderByCreatedAtDesc(category)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public List<ResearchResponse> searchResearch(String query) {
        return researchRepository.searchByTitleOrAbstract(query)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public ResearchVersionResponse addVersion(Long researchId, ResearchVersionRequest request, String userName) {
        Research research = researchRepository.findById(researchId)
                .orElseThrow(() -> new RuntimeException("Research not found with id: " + researchId));

        if (!userName.equals(research.getCreatedByName())) {
            throw new RuntimeException("Only the author can add versions to this research");
        }

        int nextVersion = versionRepository.findTopByResearchIdOrderByVersionNumberDesc(researchId)
                .map(v -> v.getVersionNumber() + 1)
                .orElse(1);

        ResearchVersion version = ResearchVersion.builder()
                .researchId(researchId)
                .versionNumber(nextVersion)
                .documentUrl(request.getDocumentUrl())
                .changelog(request.getChangelog())
                .uploadedByName(userName)
                .build();

        // Update the main research document URL to the latest version
        research.setDocumentUrl(request.getDocumentUrl());
        researchRepository.save(research);

        ResearchVersion saved = versionRepository.save(version);
        return toVersionResponse(saved);
    }

    public List<ResearchVersionResponse> getVersionHistory(Long researchId) {
        researchRepository.findById(researchId)
                .orElseThrow(() -> new RuntimeException("Research not found with id: " + researchId));

        return versionRepository.findByResearchIdOrderByVersionNumberDesc(researchId)
                .stream()
                .map(this::toVersionResponse)
                .toList();
    }

    @Transactional
    public ResearchResponse incrementDownloads(Long id) {
        Research research = researchRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Research not found with id: " + id));
        research.setDownloads(research.getDownloads() + 1);
        return toResponse(researchRepository.save(research));
    }

    @Transactional
    public CitationResponse getCitation(Long id) {
        Research research = researchRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Research not found with id: " + id));

        research.setCitations(research.getCitations() + 1);
        researchRepository.save(research);

        eventPublisher.publishResearchCited(research.getId(), research.getTitle());

        String authorsStr = research.getAuthors() != null
                ? String.join(", ", research.getAuthors())
                : research.getCreatedByName();

        String year = research.getCreatedAt() != null
                ? String.valueOf(research.getCreatedAt().getYear())
                : "n.d.";

        // BibTeX format
        String bibtex = String.format(
                "@%s{decp%d,\n  title={%s},\n  author={%s},\n  year={%s}%s\n}",
                research.getCategory().name().toLowerCase(),
                research.getId(),
                research.getTitle(),
                authorsStr,
                year,
                research.getDoi() != null ? ",\n  doi={" + research.getDoi() + "}" : ""
        );

        // APA format
        String apa = String.format("%s (%s). %s.%s",
                authorsStr,
                year,
                research.getTitle(),
                research.getDoi() != null ? " https://doi.org/" + research.getDoi() : ""
        );

        return CitationResponse.builder()
                .researchId(research.getId())
                .title(research.getTitle())
                .authors(authorsStr)
                .doi(research.getDoi())
                .year(year)
                .category(research.getCategory().name())
                .bibtex(bibtex)
                .apa(apa)
                .build();
    }

    private ResearchResponse toResponse(Research research) {
        return ResearchResponse.builder()
                .id(research.getId())
                .title(research.getTitle())
                .researchAbstract(research.getResearchAbstract())
                .authors(research.getAuthors())
                .tags(research.getTags())
                .documentUrl(research.getDocumentUrl())
                .doi(research.getDoi())
                .category(research.getCategory())
                .views(research.getViews())
                .downloads(research.getDownloads())
                .citations(research.getCitations())
                .createdBy(research.getCreatedBy())
                .createdByName(research.getCreatedByName())
                .createdAt(research.getCreatedAt())
                .updatedAt(research.getUpdatedAt())
                .build();
    }

    private ResearchVersionResponse toVersionResponse(ResearchVersion version) {
        return ResearchVersionResponse.builder()
                .id(version.getId())
                .researchId(version.getResearchId())
                .versionNumber(version.getVersionNumber())
                .documentUrl(version.getDocumentUrl())
                .changelog(version.getChangelog())
                .uploadedAt(version.getUploadedAt())
                .uploadedByName(version.getUploadedByName())
                .build();
    }
}
