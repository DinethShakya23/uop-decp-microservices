package com.decp.feed_service.repository;

import com.decp.feed_service.model.Post;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PostRepository extends MongoRepository<Post, String> {

    // We can add custom queries here. For example, finding all posts by a specific user:
    List<Post> findByAuthorIdOrderByCreatedAtDesc(Long authorId);

}