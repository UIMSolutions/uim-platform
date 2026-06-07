module uim.platform.workzone.domain.enumerations;

import uim.platform.workzone;

// mixin(ShowModule!());

@safe:

/// Workspace type.
enum WorkspaceType {
  project,
  team,
  department,
  public_,
  external,
}
WorkspaceType toWorkspaceType(string s) {
  switch (s.toLower()) {
    case "project": return WorkspaceType.project;
    case "team": return WorkspaceType.team;
    case "department": return WorkspaceType.department;
    case "public": return WorkspaceType.public_;
    case "external": return WorkspaceType.external;
    default: return WorkspaceType.team; // default
  }
}
/// Workspace status.
enum WorkspaceStatus {
  active,
  archived,
  suspended,
}
WorkspaceStatus toWorkspaceStatus(string s) {
  switch (s.toLower()) {
    case "active": return WorkspaceStatus.active;
    case "archived": return WorkspaceStatus.archived;
    case "suspended": return WorkspaceStatus.suspended;
    default: return WorkspaceStatus.active; // default
  }
}
/// Card type (integration card manifest type).
enum CardType {
  adaptive,
  analytical,
  list,
  table_,
  object_,
  timeline,
  component,
  calendar,
}
CardType toCardType(string s) {
  switch (s.toLower()) {
    case "adaptive": return CardType.adaptive;
    case "analytical": return CardType.analytical;
    case "list": return CardType.list;
    case "table": return CardType.table_;
    case "object": return CardType.object_;
    case "timeline": return CardType.timeline;
    case "component": return CardType.component;
    case "calendar": return CardType.calendar;
    default: return CardType.list; // default
  }
}
/// Content type within a workspace.
enum ContentType {
  blogPost,
  wikiPage,
  knowledgeBase,
  forumPost,
  announcement,
  document,
}
ContentType toContentType(string s) {
  switch (s.toLower()) {
    case "blogpost": return ContentType.blogPost;
    case "wikipage": return ContentType.wikiPage;
    case "knowledgebase": return ContentType.knowledgeBase;
    case "forumpost": return ContentType.forumPost;
    case "announcement": return ContentType.announcement;
    case "document": return ContentType.document;
    default: return ContentType.document; // default
  }
}
/// Content status / lifecycle.
enum ContentStatus {
  draft,
  published,
  archived,
  deleted,
}
ContentStatus toContentStatus(string s) {
  switch (s.toLower()) {
    case "draft": return ContentStatus.draft;
    case "published": return ContentStatus.published;
    case "archived": return ContentStatus.archived;
    case "deleted": return ContentStatus.deleted;
    default: return ContentStatus.draft; // default
  }
}
/// Notification priority.
enum NotificationPriority {
  low,
  medium,
  high,
  critical,
}
NotificationPriority toNotificationPriority(string s) {
  switch (s.toLower()) {
    case "low": return NotificationPriority.low;
    case "medium": return NotificationPriority.medium;
    case "high": return NotificationPriority.high;
    case "critical": return NotificationPriority.critical;
    default: return NotificationPriority.medium; // default
  }
}
/// Task status.
enum TaskStatus {
  open,
  inProgress,
  completed,
  cancelled,
  overdue,
}
TaskStatus toTaskStatus(string s) {
  switch (s.toLower()) {
    case "open": return TaskStatus.open;
    case "inprogress": return TaskStatus.inProgress;
    case "completed": return TaskStatus.completed;
    case "cancelled": return TaskStatus.cancelled;
    case "overdue": return TaskStatus.overdue;
    default: return TaskStatus.open; // default
  }
}
/// Task priority.
enum TaskPriority {
  low,
  medium,
  high,
  veryHigh,
}
TaskPriority toTaskPriority(string s) {
  switch (s.toLower()) {
    case "low": return TaskPriority.low;
    case "medium": return TaskPriority.medium;
    case "high": return TaskPriority.high;
    case "veryhigh": return TaskPriority.veryHigh;
    default: return TaskPriority.medium; // default
  }
}
/// Channel type (content feed source).
enum ChannelType {
  activity,
  notification,
  custom,
  external,
}
ChannelType toChannelType(string s) {
  switch (s.toLower()) {
    case "activity": return ChannelType.activity;
    case "notification": return ChannelType.notification;
    case "custom": return ChannelType.custom;
    case "external": return ChannelType.external;
    default: return ChannelType.custom; // default
  }
}
/// Application status (registered app lifecycle).
enum AppStatus {
  active,
  inactive,
  deprecated_,
}
AppStatus toAppStatus(string s) {
  switch (s.toLower()) {
    case "active": return AppStatus.active;
    case "inactive": return AppStatus.inactive;
    case "deprecated": return AppStatus.deprecated_;
    default: return AppStatus.active; // default      
  }
}

/// Widget size on a workspace page.
enum WidgetSize {
  small,
  medium,
  large,
  fullWidth,
}
WidgetSize toWidgetSize(string s) {
  switch (s.toLower()) {
    case "small": return WidgetSize.small;
    case "medium": return WidgetSize.medium;
    case "large": return WidgetSize.large;
    case "fullwidth": return WidgetSize.fullWidth;
    default: return WidgetSize.medium; // default
  }
}
/// Member role within a workspace.
enum MemberRole {
  viewer,
  contributor,
  admin,
  owner,
}
MemberRole toMemberRole(string s) {
  switch (s.toLower()) {
    case "viewer": return MemberRole.viewer;
    case "contributor": return MemberRole.contributor;
    case "admin": return MemberRole.admin;
    case "owner": return MemberRole.owner;
    default: return MemberRole.contributor; // default
  }
}
/// Site status.
enum SiteStatus {
  draft,
  published,
  maintenance,  
  archived,
}
SiteStatus toSiteStatus(string s) { 
  switch (s.toLower()) {
    case "draft": return SiteStatus.draft;
    case "published": return SiteStatus.published;
    case "maintenance": return SiteStatus.maintenance;
    case "archived": return SiteStatus.archived;
    default: return SiteStatus.draft; // default
  }
}
/// Event status.
enum EventStatus {
  scheduled,
  ongoing,
  completed,
  cancelled,
}
EventStatus toEventStatus(string s) {
  switch (s.toLower()) {
    case "scheduled": return EventStatus.scheduled;
    case "ongoing": return EventStatus.ongoing;
    case "completed": return EventStatus.completed;   
    case "cancelled": return EventStatus.cancelled;
    default: return EventStatus.scheduled; // default
  }
}
/// Survey status.
enum SurveyStatus {
  draft,
  active,
  closed,
  archived,
}
SurveyStatus toSurveyStatus(string s) {
  switch (s.toLower()) {
    case "draft": return SurveyStatus.draft;
    case "active": return SurveyStatus.active;
    case "closed": return SurveyStatus.closed;
    case "archived": return SurveyStatus.archived;
    default: return SurveyStatus.draft; // default
  }
}
/// Survey question type.
enum QuestionType {
  singleChoice,
  multipleChoice,
  freeText,
  rating,
  scale,
}
QuestionType toQuestionType(string s) {
  switch (s.toLower()) {
    case "singlechoice": return QuestionType.singleChoice;
    case "multiplechoice": return QuestionType.multipleChoice;
    case "freetext": return QuestionType.freeText;
    case "rating": return QuestionType.rating;
    case "scale": return QuestionType.scale;
    default: return QuestionType.singleChoice; // default
  }
}
/// Forum topic status.
enum ForumTopicStatus {
  open,
  closed,
  pinned,   
  archived,
}
ForumTopicStatus toForumTopicStatus(string s) {
  switch (s.toLower()) {
    case "open": return ForumTopicStatus.open;
    case "closed": return ForumTopicStatus.closed;
    case "pinned": return ForumTopicStatus.pinned;
    case "archived": return ForumTopicStatus.archived;
    default: return ForumTopicStatus.open; // default
  }
} 
/// Notification status.
enum NotificationStatus {
  unread,
  read_,
  dismissed,
  actionRequired,
}
NotificationStatus toNotificationStatus(string s) {
  switch (s.toLower()) {
    case "unread": return NotificationStatus.unread;
    case "read": return NotificationStatus.read_;
    case "dismissed": return NotificationStatus.dismissed;
    case "actionrequired": return NotificationStatus.actionRequired;
    default: return NotificationStatus.unread; // default
  }
}
/// KB article status.
enum KBArticleStatus {
  draft,
  published,
  review,
  archived,
}

KBArticleStatus toKBArticleStatus(string s) {
  switch (s.toLower()) {
    case "draft": return KBArticleStatus.draft;
    case "published": return KBArticleStatus.published;
    case "review": return KBArticleStatus.review;
    case "archived": return KBArticleStatus.archived;
    default: return KBArticleStatus.draft; // default
  }
}
/// WZGroup type.
enum GroupType {
  security,
  distribution,
  dynamic,
}

GroupType toGroupType(string s) {
  switch (s.toLower()) {
    case "security": return GroupType.security;
    case "distribution": return GroupType.distribution;
    case "dynamic": return GroupType.dynamic;
    default: return GroupType.security; // default
  }
}
/// Navigation item type.
enum NavigationItemType {
  link,
  group,
  separator,
  app,
  externalLink,
}
NavigationItemType toNavigationItemType(string s) {
  switch (s.toLower()) {
    case "link": return NavigationItemType.link;
    case "group": return NavigationItemType.group;
    case "separator": return NavigationItemType.separator;
    case "app": return NavigationItemType.app;
    case "externallink": return NavigationItemType.externalLink;
    default: return NavigationItemType.link; // default
  }
}
/// Plugin status.
enum PluginStatus {
  active,
  inactive,
  error,
}
PluginStatus toPluginStatus(string s) {
  switch (s.toLower()) {
    case "active": return PluginStatus.active;
    case "inactive": return PluginStatus.inactive;
    case "error": return PluginStatus.error;
    default: return PluginStatus.active; // default
  }
}
/// External content provider status.
enum ProviderStatus {
  connected,
  disconnected,
  error,
}

ProviderStatus toProviderStatus(string s) {
  switch (s.toLower()) {
    case "connected": return ProviderStatus.connected;
    case "disconnected": return ProviderStatus.disconnected;
    case "error": return ProviderStatus.error;
    default: return ProviderStatus.disconnected; // default
  }
}
/// External content provider type.
enum ProviderType {
  odata,
  rest,
  graphql,
  sapBtp,
  custom,
}
ProviderType toProviderType(string s) {
  switch (s.toLower()) {
    case "odata": return ProviderType.odata;
    case "rest": return ProviderType.rest;
    case "graphql": return ProviderType.graphql;
    case "sapbtp": return ProviderType.sapBtp;
    case "custom": return ProviderType.custom;
    default: return ProviderType.custom; // default
  }
}