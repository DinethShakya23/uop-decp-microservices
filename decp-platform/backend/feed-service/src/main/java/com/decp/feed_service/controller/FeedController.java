package com.decp.feed_service.controller;

import com.decp.feed_service.dto.PostRequest;
import com.decp.feed_service.model.Post;
import com.decp.feed_service.repository.PostRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/feed")
public class FeedController {

    @Autowired
    private PostRepository postRepository;

    // Endpoint to create a new post
    @PostMapping
    public ResponseEntity<Post> createPost(@RequestBody PostRequest request) {
        Post newPost = Post.builder()
                .authorId(request.getAuthorId())
                .authorName(request.getAuthorName())
                .content(request.getContent())
                .createdAt(LocalDateTime.now()) // Stamp the exact time it was created
                .build();

        Post savedPost = postRepository.save(newPost);
        return ResponseEntity.ok(savedPost);
    }

    // Endpoint to get all posts for the timeline
    @GetMapping
    public ResponseEntity<List<Post>> getAllPosts() {
        List<Post> posts = postRepository.findAll();
        return ResponseEntity.ok(posts);
    }
}