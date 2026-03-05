package com.decp.research.controller;

import com.decp.research.dto.*;
import com.decp.research.model.ResearchCategory;
import com.decp.research.model.ResearchTag;
import com.decp.research.service.ResearchService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/research")
@RequiredArgsConstructor
public class ResearchController {

    private final ResearchService researchService;

    @PostMapping
    public ResponseEntity<ResearchResponse> uploadResearch(
            @RequestHeader("X-User-Name") String userName,
            @RequestHeader("X-User-Role") String userRole,
            @Valid @RequestBody ResearchRequest request) {
        if (!"ALUMNI".equals(userRole) && !"ADMIN".equals(userRole)) {
            return ResponseEntity.status(403).build();
        }
        return ResponseEntity.ok(researchService.uploadResearch(request, userName));
    }

    @GetMapping
    public ResponseEntity<List<ResearchResponse>> getAllResearch(
            @RequestParam(required = false) ResearchCategory category,
            @RequestParam(required = false) String search) {
        if (category != null) {
            return ResponseEntity.ok(researchService.getResearchByCategory(category));
        }
        if (search != null && !search.isBlank()) {
            return ResponseEntity.ok(researchService.searchResearch(search));
        }
        return ResponseEntity.ok(researchService.getAllResearch());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ResearchResponse> getResearchById(@PathVariable Long id) {
        return ResponseEntity.ok(researchService.getResearchById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ResearchResponse> updateResearch(
            @PathVariable Long id,
            @RequestHeader("X-User-Name") String userName,
            @Valid @RequestBody ResearchRequest request) {
        return ResponseEntity.ok(researchService.updateResearch(id, request, userName));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteResearch(
            @PathVariable Long id,
            @RequestHeader("X-User-Name") String userName,
            @RequestHeader("X-User-Role") String userRole) {
        researchService.deleteResearch(id, userName, userRole);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<ResearchResponse>> getResearchByUser(@PathVariable Long userId) {
        return ResponseEntity.ok(researchService.getResearchByUser(userId));
    }

    @GetMapping("/tag/{tag}")
    public ResponseEntity<List<ResearchResponse>> getResearchByTag(@PathVariable ResearchTag tag) {
        return ResponseEntity.ok(researchService.getResearchByTag(tag));
    }

    @PostMapping("/{id}/version")
    public ResponseEntity<ResearchVersionResponse> addVersion(
            @PathVariable Long id,
            @RequestHeader("X-User-Name") String userName,
            @Valid @RequestBody ResearchVersionRequest request) {
        return ResponseEntity.ok(researchService.addVersion(id, request, userName));
    }

    @GetMapping("/{id}/versions")
    public ResponseEntity<List<ResearchVersionResponse>> getVersionHistory(@PathVariable Long id) {
        return ResponseEntity.ok(researchService.getVersionHistory(id));
    }

    @PostMapping("/{id}/cite")
    public ResponseEntity<CitationResponse> getCitation(@PathVariable Long id) {
        return ResponseEntity.ok(researchService.getCitation(id));
    }

    @PostMapping("/{id}/download")
    public ResponseEntity<ResearchResponse> trackDownload(@PathVariable Long id) {
        return ResponseEntity.ok(researchService.incrementDownloads(id));
    }
}
