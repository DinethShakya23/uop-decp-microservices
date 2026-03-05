package com.decp.feed_service.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Document(collection = "posts") // Tells MongoDB to store this in a 'posts' collection
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Post {

    @Id
    private String id; // MongoDB uses String (ObjectId) by default instead of Long

    private Long authorId; // The ID of the user from your MySQL database

    private String authorName; // Storing the name here prevents us from having to ask the User Service for the name every single time we load the feed!

    private String content;

    private LocalDateTime createdAt;
}