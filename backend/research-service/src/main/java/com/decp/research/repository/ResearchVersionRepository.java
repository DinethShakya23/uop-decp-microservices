package com.decp.research.repository;

import com.decp.research.model.ResearchVersion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ResearchVersionRepository extends JpaRepository<ResearchVersion, Long> {

    List<ResearchVersion> findByResearchIdOrderByVersionNumberDesc(Long researchId);

    Optional<ResearchVersion> findTopByResearchIdOrderByVersionNumberDesc(Long researchId);
}
