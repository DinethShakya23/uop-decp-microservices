package com.decp.analytics.config;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {

    // Exchanges (matching publisher services)
    public static final String USER_EXCHANGE = "user.exchange";
    public static final String POST_EXCHANGE = "post.exchange";
    public static final String EVENT_EXCHANGE = "event-exchange";
    public static final String JOB_EXCHANGE = "job.exchange";
    public static final String RESEARCH_EXCHANGE = "research-exchange";

    // Analytics-specific queues
    public static final String ANALYTICS_USER_REGISTERED = "analytics.user.registered";
    public static final String ANALYTICS_POST_CREATED = "analytics.post.created";
    public static final String ANALYTICS_POST_LIKED = "analytics.post.liked";
    public static final String ANALYTICS_POST_COMMENTED = "analytics.post.commented";
    public static final String ANALYTICS_JOB_CREATED = "analytics.job.created";
    public static final String ANALYTICS_JOB_APPLIED = "analytics.job.applied";
    public static final String ANALYTICS_EVENT_CREATED = "analytics.event.created";
    public static final String ANALYTICS_EVENT_RSVP = "analytics.event.rsvp";
    public static final String ANALYTICS_RESEARCH_UPLOADED = "analytics.research.uploaded";
    public static final String ANALYTICS_RESEARCH_CITED = "analytics.research.cited";

    // Exchanges
    @Bean
    public TopicExchange userExchange() {
        return new TopicExchange(USER_EXCHANGE);
    }

    @Bean
    public TopicExchange postExchange() {
        return new TopicExchange(POST_EXCHANGE);
    }

    @Bean
    public TopicExchange eventExchange() {
        return new TopicExchange(EVENT_EXCHANGE);
    }

    @Bean
    public TopicExchange jobExchange() {
        return new TopicExchange(JOB_EXCHANGE);
    }

    @Bean
    public TopicExchange researchExchange() {
        return new TopicExchange(RESEARCH_EXCHANGE);
    }

    // Queues
    @Bean
    public Queue analyticsUserRegisteredQueue() {
        return new Queue(ANALYTICS_USER_REGISTERED, true);
    }

    @Bean
    public Queue analyticsPostCreatedQueue() {
        return new Queue(ANALYTICS_POST_CREATED, true);
    }

    @Bean
    public Queue analyticsPostLikedQueue() {
        return new Queue(ANALYTICS_POST_LIKED, true);
    }

    @Bean
    public Queue analyticsPostCommentedQueue() {
        return new Queue(ANALYTICS_POST_COMMENTED, true);
    }

    @Bean
    public Queue analyticsJobCreatedQueue() {
        return new Queue(ANALYTICS_JOB_CREATED, true);
    }

    @Bean
    public Queue analyticsJobAppliedQueue() {
        return new Queue(ANALYTICS_JOB_APPLIED, true);
    }

    @Bean
    public Queue analyticsEventCreatedQueue() {
        return new Queue(ANALYTICS_EVENT_CREATED, true);
    }

    @Bean
    public Queue analyticsEventRsvpQueue() {
        return new Queue(ANALYTICS_EVENT_RSVP, true);
    }

    @Bean
    public Queue analyticsResearchUploadedQueue() {
        return new Queue(ANALYTICS_RESEARCH_UPLOADED, true);
    }

    @Bean
    public Queue analyticsResearchCitedQueue() {
        return new Queue(ANALYTICS_RESEARCH_CITED, true);
    }

    // Bindings
    @Bean
    public Binding userRegisteredBinding(Queue analyticsUserRegisteredQueue, TopicExchange userExchange) {
        return BindingBuilder.bind(analyticsUserRegisteredQueue).to(userExchange).with("user.registered");
    }

    @Bean
    public Binding postCreatedBinding(Queue analyticsPostCreatedQueue, TopicExchange postExchange) {
        return BindingBuilder.bind(analyticsPostCreatedQueue).to(postExchange).with("post.created");
    }

    @Bean
    public Binding postLikedBinding(Queue analyticsPostLikedQueue, TopicExchange postExchange) {
        return BindingBuilder.bind(analyticsPostLikedQueue).to(postExchange).with("post.liked");
    }

    @Bean
    public Binding postCommentedBinding(Queue analyticsPostCommentedQueue, TopicExchange postExchange) {
        return BindingBuilder.bind(analyticsPostCommentedQueue).to(postExchange).with("post.commented");
    }

    @Bean
    public Binding jobCreatedBinding(Queue analyticsJobCreatedQueue, TopicExchange jobExchange) {
        return BindingBuilder.bind(analyticsJobCreatedQueue).to(jobExchange).with("job.created");
    }

    @Bean
    public Binding jobAppliedBinding(Queue analyticsJobAppliedQueue, TopicExchange jobExchange) {
        return BindingBuilder.bind(analyticsJobAppliedQueue).to(jobExchange).with("job.applied");
    }

    @Bean
    public Binding eventCreatedBinding(Queue analyticsEventCreatedQueue, TopicExchange eventExchange) {
        return BindingBuilder.bind(analyticsEventCreatedQueue).to(eventExchange).with("event.created");
    }

    @Bean
    public Binding eventRsvpBinding(Queue analyticsEventRsvpQueue, TopicExchange eventExchange) {
        return BindingBuilder.bind(analyticsEventRsvpQueue).to(eventExchange).with("event.rsvp");
    }

    @Bean
    public Binding researchUploadedBinding(Queue analyticsResearchUploadedQueue, TopicExchange researchExchange) {
        return BindingBuilder.bind(analyticsResearchUploadedQueue).to(researchExchange).with("research.uploaded");
    }

    @Bean
    public Binding researchCitedBinding(Queue analyticsResearchCitedQueue, TopicExchange researchExchange) {
        return BindingBuilder.bind(analyticsResearchCitedQueue).to(researchExchange).with("research.cited");
    }

    @Bean
    public MessageConverter jsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }
}
