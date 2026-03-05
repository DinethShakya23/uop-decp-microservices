// ==================== User ====================
export interface User {
  id: number;
  username: string;
  email: string;
  fullName: string;
  bio?: string;
  profilePictureUrl?: string;
  role: "STUDENT" | "ALUMNI" | "ADMIN";
}

export interface UserRegistrationRequest {
  username: string;
  email: string;
  password: string;
  fullName: string;
  role: "STUDENT" | "ALUMNI";
}

// ==================== Auth ====================
export interface AuthRequest {
  username: string;
  password: string;
}

export interface AuthResponse {
  token: string;
  user: User;
}

// ==================== Post ====================
export interface PostComment {
  userId: string;
  username: string;
  text: string;
  timestamp: string;
}

export interface Post {
  id: string;
  userId: string;
  username: string;
  fullName: string;
  content: string;
  mediaUrls: string[];
  likedBy: string[];
  comments: PostComment[];
  createdAt: string;
  updatedAt: string;
}

export interface PostRequest {
  userId: string;
  fullName: string;
  content: string;
  mediaUrls?: string[];
}

// ==================== Job ====================
export interface Job {
  id: number;
  title: string;
  description: string;
  company: string;
  location: string;
  type: string;
  postedBy: string;
  posterName: string;
  createdAt: string;
  updatedAt: string;
}

export interface JobApplication {
  id: number;
  jobId: number;
  userId: string;
  applicantName: string;
  coverLetter: string;
  resumeUrl?: string;
  status: "PENDING" | "REVIEWED" | "ACCEPTED" | "REJECTED";
  appliedAt: string;
}

// ==================== Event ====================
export type EventCategory =
  | "ACADEMIC"
  | "SOCIAL"
  | "WORKSHOP"
  | "NETWORKING"
  | "CAREER"
  | "ALUMNI";

export interface EventResponse {
  id: number;
  title: string;
  description: string;
  location: string;
  eventDate: string;
  startTime: string;
  endTime: string;
  organizer: string;
  organizerName: string;
  category: EventCategory;
  maxAttendees: number;
  createdAt: string;
  attendeeCount: number;
}

export interface EventRequest {
  title: string;
  description: string;
  location: string;
  eventDate: string;
  startTime: string;
  endTime: string;
  category: EventCategory;
  maxAttendees: number;
}

export type RsvpStatus = "GOING" | "MAYBE" | "NOT_GOING";

export interface RsvpResponse {
  eventId: number;
  userId: string;
  userName: string;
  status: RsvpStatus;
  respondedAt: string;
}

// ==================== Research ====================
export type ResearchTag =
  | "MACHINE_LEARNING"
  | "AI"
  | "BLOCKCHAIN"
  | "IOT"
  | "CLOUD"
  | "DATA_SCIENCE"
  | "QUANTUM"
  | string;
export type ResearchCategory =
  | "PAPER"
  | "THESIS"
  | "PROJECT"
  | "ARTICLE"
  | "CONFERENCE"
  | "WORKSHOP";

export interface ResearchResponse {
  id: number;
  title: string;
  researchAbstract: string;
  authors: string[];
  tags: ResearchTag[];
  documentUrl?: string;
  doi?: string;
  category: ResearchCategory;
  views: number;
  downloads: number;
  citations: number;
  createdBy: string;
  createdByName: string;
  createdAt: string;
  updatedAt: string;
}

export interface ResearchRequest {
  title: string;
  researchAbstract: string;
  authors: string[];
  tags: ResearchTag[];
  documentUrl?: string;
  doi?: string;
  category: ResearchCategory;
}

export interface ResearchVersionResponse {
  id: number;
  researchId: number;
  versionNumber: number;
  changeLog: string;
  documentUrl: string;
  createdBy: string;
  createdAt: string;
}

// ==================== Messaging ====================
export interface ConversationResponse {
  id: string;
  participants: number[];
  participantNames: string[];
  lastMessage: string;
  lastMessageAt: string;
  createdAt: string;
  updatedAt: string;
}

export interface MessageResponse {
  id: string;
  conversationId: string;
  senderId: number;
  senderName: string;
  content: string;
  readBy: number[];
  createdAt: string;
}

export interface ChatMessageRequest {
  conversationId: string;
  content: string;
}

export interface TypingIndicator {
  conversationId: string;
  userId?: number;
  userName?: string;
}

// ==================== Notification ====================
export type NotificationType =
  | "POST_LIKED"
  | "COMMENT"
  | "MENTORSHIP_REQUEST"
  | "JOB_APPLICATION"
  | "EVENT_CREATED"
  | "EVENT_RSVP"
  | "SYSTEM"
  | string;
export type ReferenceType =
  | "POST"
  | "COMMENT"
  | "USER"
  | "JOB"
  | "EVENT"
  | string;

export interface NotificationResponse {
  id: string;
  userId: string;
  type: NotificationType;
  title: string;
  message: string;
  referenceId: string;
  referenceType: ReferenceType;
  read: boolean;
  createdAt: string;
}

export interface UnreadCountResponse {
  count: number;
}

// ==================== Analytics ====================
export interface AnalyticsOverview {
  totalUsers: number;
  totalPosts: number;
  totalJobs: number;
  totalEvents: number;
  totalResearch: number;
  totalMessages: number;
  activeUsers: number;
}

export interface UserMetrics {
  totalUsers: number;
  newUsersToday: number;
  newUsersThisWeek: number;
  newUsersThisMonth: number;
  studentCount: number;
  alumniCount: number;
  adminCount: number;
}

export interface PostMetrics {
  totalPosts: number;
  postsToday: number;
  postsThisWeek: number;
  totalLikes: number;
  totalComments: number;
}

export interface JobMetrics {
  totalJobs: number;
  totalApplications: number;
  pendingApplications: number;
  acceptedApplications: number;
}

export interface EventMetrics {
  totalEvents: number;
  upcomingEvents: number;
  totalRsvps: number;
  goingCount: number;
}

export interface TimelineEntry {
  date: string;
  users: number;
  posts: number;
  jobs: number;
  events: number;
}

// ==================== Mentorship ====================
export type MentorshipRole = "MENTOR" | "MENTEE";
export type Availability = "FULL_TIME" | "PART_TIME" | "WEEKENDS_ONLY";
export type ProposedDuration =
  | "ONE_MONTH"
  | "THREE_MONTHS"
  | "SIX_MONTHS"
  | "ONE_YEAR";
export type MentorshipRequestStatus =
  | "PENDING"
  | "ACCEPTED"
  | "REJECTED"
  | "CANCELLED";
export type RelationshipStatus = "ACTIVE" | "PAUSED" | "COMPLETED";
export type MeetingFrequency = "WEEKLY" | "BIWEEKLY" | "MONTHLY";
export type PreferredChannel = "EMAIL" | "VIDEO_CALL" | "PHONE" | "IN_PERSON";

export interface MentorshipProfileResponse {
  id: number;
  userId: number;
  userName: string;
  role: MentorshipRole;
  userRole: string;
  department: string;
  yearsOfExperience: number;
  expertise: string[];
  interests: string[];
  bio: string;
  availability: Availability;
  timezone: string;
  isVerified: boolean;
  rating: number;
  ratingCount: number;
  linkedInUrl?: string;
  createdAt: string;
  updatedAt: string;
}

export interface MentorshipProfileRequest {
  role: MentorshipRole;
  department: string;
  yearsOfExperience: number;
  expertise: string[];
  interests: string[];
  bio: string;
  availability: Availability;
  timezone: string;
  linkedInUrl?: string;
}

export interface MentorshipMatchDTO {
  userId: number;
  userName: string;
  profile: MentorshipProfileResponse;
  compatibilityScore: number;
  commonInterests: string[];
  distanceScore: number;
}

export interface MentorshipRequestResponse {
  id: number;
  mentorId: number;
  mentorUserName: string;
  menteeId: number;
  menteeUserName: string;
  message: string;
  topics: string[];
  proposedDuration: ProposedDuration;
  status: MentorshipRequestStatus;
  rejectionReason?: string;
  respondedAt?: string;
  createdAt: string;
}

export interface MentorshipRequestRequest {
  mentorId: number;
  message: string;
  topics: string[];
  proposedDuration: ProposedDuration;
}

export interface MentorshipRelationshipResponse {
  id: number;
  mentorId: number;
  mentorUserName: string;
  menteeId: number;
  menteeUserName: string;
  mentorshipRequestId: number;
  goals: string;
  frequency: MeetingFrequency;
  preferredChannel: PreferredChannel;
  startDate: string;
  endDate?: string;
  status: RelationshipStatus;
  createdAt: string;
  updatedAt: string;
}

export interface MentorshipFeedbackDTO {
  id: number;
  relationshipId: number;
  rating: number;
  message: string;
  role: MentorshipRole;
  createdAt: string;
}

// ==================== Paginated ====================
export interface Page<T> {
  content: T[];
  totalPages: number;
  totalElements: number;
  size: number;
  number: number;
}
