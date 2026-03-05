package com.decp.research.repository;

import com.decp.research.model.Research;
import com.decp.research.model.ResearchCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ResearchRepository extends JpaRepository<Research, Long> {

    List<Research> findAllByOrderByCreatedAtDesc();

    List<Research> findByCreatedByOrderByCreatedAtDesc(Long createdBy);

    List<Research> findByCategoryOrderByCreatedAtDesc(ResearchCategory category);

    @Query("SELECT r FROM Research r JOIN r.tags t WHERE t = :tag ORDER BY r.createdAt DESC")
    List<Research> findByTag(@Param("tag") com.decp.research.model.ResearchTag tag);

    @Query("SELECT r FROM Research r WHERE LOWER(r.title) LIKE LOWER(CONCAT('%', :query, '%')) " +
           "OR LOWER(r.researchAbstract) LIKE LOWER(CONCAT('%', :query, '%')) ORDER BY r.createdAt DESC")
    List<Research> searchByTitleOrAbstract(@Param("query") String query);
}
