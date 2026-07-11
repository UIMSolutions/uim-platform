module uim.platform.workzone.domain.enumerations;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Workspace type.
enum WorkspaceType {
  project,
  team,
  department,
  public_,
  external,
}
WorkspaceType toWorkspaceType(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
    case "project": return WorkspaceType.project;
    case "team": return WorkspaceType.team;
    case "department": return WorkspaceType.department;
    case "public": return WorkspaceType.public_;
    case "external": return WorkspaceType.external;
    default: return WorkspaceType.team; // default
  }
}
///
unittest {
    assert(toWorkspaceType("project") == WorkspaceType.project);
    assert(toWorkspaceType("TEAM") == WorkspaceType.team);
    assert(toWorkspaceType("Department") == WorkspaceType.department);
    assert(toWorkspaceType("public") == WorkspaceType.public_);
    assert(toWorkspaceType("External") == WorkspaceType.external);
    assert(toWorkspaceType("unknown") == WorkspaceType.team);
}

/// Workspace status.
enum WorkspaceStatus {
  active,
  archived,
  suspended,
}
WorkspaceStatus toWorkspaceStatus(string value) {
  mixin(EnumSwitch("WorkspaceStatus", "active"));
}
/// 
unittest {
    assert(toWorkspaceStatus("active") == WorkspaceStatus.active);
    assert(toWorkspaceStatus("ARCHIVED") == WorkspaceStatus.archived);
    assert(toWorkspaceStatus("Suspended") == WorkspaceStatus.suspended);
    assert(toWorkspaceStatus("unknown") == WorkspaceStatus.active);
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
CardType toCardType(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
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
///
unittest {
    assert(toCardType("adaptive") == CardType.adaptive);
    assert(toCardType("ANALYTICAL") == CardType.analytical);
    assert(toCardType("List") == CardType.list);
    assert(toCardType("TABLE") == CardType.table_);
    assert(toCardType("Object") == CardType.object_);
    assert(toCardType("timeline") == CardType.timeline);
    assert(toCardType("Component") == CardType.component);
    assert(toCardType("Calendar") == CardType.calendar);
    assert(toCardType("unknown") == CardType.list);
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
ContentType toContentType(string value) {
  mixin(EnumSwitch("ContentType", "blogPost"));
}
/// 
unittest {
    assert(toContentType("blogPost") == ContentType.blogPost);
    assert(toContentType("WIKIPAGE") == ContentType.wikiPage);
    assert(toContentType("KnowledgeBase") == ContentType.knowledgeBase);
    assert(toContentType("forumPost") == ContentType.forumPost);
    assert(toContentType("Announcement") == ContentType.announcement);
    assert(toContentType("document") == ContentType.document);
    assert(toContentType("unknown") == ContentType.blogPost);
}

/// Content status / lifecycle.
enum ContentStatus {
  draft,
  published,
  archived,
  deleted,
}
ContentStatus toContentStatus(string value) {
  mixin(EnumSwitch("ContentStatus", "draft"));
}
///
unittest {
    assert(toContentStatus("draft") == ContentStatus.draft);
    assert(toContentStatus("PUBLISHED") == ContentStatus.published);
    assert(toContentStatus("Archived") == ContentStatus.archived);
    assert(toContentStatus("deleted") == ContentStatus.deleted);
    assert(toContentStatus("unknown") == ContentStatus.draft);
}

/// Notification priority.
enum NotificationPriority {
  low,
  medium,
  high,
  critical,
}
NotificationPriority toNotificationPriority(string value) {
  mixin(EnumSwitch("NotificationPriority", "medium"));
}
///
unittest {
    assert(toNotificationPriority("low") == NotificationPriority.low);
    assert(toNotificationPriority("MEDIUM") == NotificationPriority.medium);
    assert(toNotificationPriority("High") == NotificationPriority.high);
    assert(toNotificationPriority("CRITICAL") == NotificationPriority.critical);
    assert(toNotificationPriority("unknown") == NotificationPriority.medium);
}

/// Task status.
enum TaskStatus {
  open,
  inProgress,
  completed,
  cancelled,
  overdue,
}
TaskStatus toTaskStatus(string value) {
  mixin(EnumSwitch("TaskStatus", "open"));
}
///
unittest {
    assert(toTaskStatus("open") == TaskStatus.open);
    assert(toTaskStatus("INPROGRESS") == TaskStatus.inProgress);
    assert(toTaskStatus("Completed") == TaskStatus.completed);
    assert(toTaskStatus("cancelled") == TaskStatus.cancelled);
    assert(toTaskStatus("Overdue") == TaskStatus.overdue);
    assert(toTaskStatus("unknown") == TaskStatus.open);
}

/// Task priority.
enum TaskPriority {
  low,
  medium,
  high,
  veryHigh,
}
TaskPriority toTaskPriority(string value) {
  mixin(EnumSwitch("TaskPriority", "medium"));
}
///
unittest {
    assert(toTaskPriority("low") == TaskPriority.low);
    assert(toTaskPriority("MEDIUM") == TaskPriority.medium);
    assert(toTaskPriority("High") == TaskPriority.high);
    assert(toTaskPriority("veryHigh") == TaskPriority.veryHigh);
    assert(toTaskPriority("unknown") == TaskPriority.medium);
}

/// Channel type (content feed source).
enum ChannelType {
  activity,
  notification,
  custom,
  external,
}
ChannelType toChannelType(string value) {
  mixin(EnumSwitch("ChannelType", "custom"));
}
///
unittest {
    assert(toChannelType("activity") == ChannelType.activity);
    assert(toChannelType("NOTIFICATION") == ChannelType.notification);
    assert(toChannelType("Custom") == ChannelType.custom);
    assert(toChannelType("external") == ChannelType.external);
    assert(toChannelType("unknown") == ChannelType.custom);
}

/// Application status (registered app lifecycle).
enum AppStatus {
  active,
  inactive,
  deprecated_,
}
AppStatus toAppStatus(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
    case "active": return AppStatus.active;
    case "inactive": return AppStatus.inactive;
    case "deprecated": return AppStatus.deprecated_;
    default: return AppStatus.active; // default      
  }
}
///
unittest {
    assert(toAppStatus("active") == AppStatus.active);
    assert(toAppStatus("INACTIVE") == AppStatus.inactive);
    assert(toAppStatus("Deprecated") == AppStatus.deprecated_);
    assert(toAppStatus("unknown") == AppStatus.active);
}

/// Widget size on a workspace page.
enum WidgetSize {
  small,
  medium,
  large,
  fullWidth,
}
WidgetSize toWidgetSize(string value) {
  mixin(EnumSwitch("WidgetSize", "medium"));
}
///
unittest {
    assert(toWidgetSize("small") == WidgetSize.small);
    assert(toWidgetSize("MEDIUM") == WidgetSize.medium);
    assert(toWidgetSize("Large") == WidgetSize.large);
    assert(toWidgetSize("fullWidth") == WidgetSize.fullWidth);
    assert(toWidgetSize("unknown") == WidgetSize.medium);
}

/// Member role within a workspace.
enum MemberRole {
  viewer,
  contributor,
  admin,
  owner,
}
MemberRole toMemberRole(string value) {
  mixin(EnumSwitch("MemberRole", "contributor"));
}
///
unittest {
    assert(toMemberRole("viewer") == MemberRole.viewer);
    assert(toMemberRole("CONTRIBUTOR") == MemberRole.contributor);
    assert(toMemberRole("Admin") == MemberRole.admin);
    assert(toMemberRole("owner") == MemberRole.owner);
    assert(toMemberRole("unknown") == MemberRole.contributor);
}

/// Site status.
enum SiteStatus {
  draft,
  published,
  maintenance,  
  archived,
}
SiteStatus toSiteStatus(string value) { 
  mixin(EnumSwitch("SiteStatus", "draft"));
}
///
unittest {
    assert(toSiteStatus("draft") == SiteStatus.draft);
    assert(toSiteStatus("PUBLISHED") == SiteStatus.published);
    assert(toSiteStatus("Maintenance") == SiteStatus.maintenance);
    assert(toSiteStatus("archived") == SiteStatus.archived);
    assert(toSiteStatus("unknown") == SiteStatus.draft);
}

/// Event status.
enum EventStatus {
  scheduled,
  ongoing,
  completed,
  cancelled,
}
EventStatus toEventStatus(string value) {
  mixin(EnumSwitch("EventStatus", "scheduled"));
}
/// 
unittest {
    assert(toEventStatus("scheduled") == EventStatus.scheduled);
    assert(toEventStatus("ONGOING") == EventStatus.ongoing);
    assert(toEventStatus("Completed") == EventStatus.completed);
    assert(toEventStatus("cancelled") == EventStatus.cancelled);
    assert(toEventStatus("unknown") == EventStatus.scheduled);
}

/// Survey status.
enum SurveyStatus {
  draft,
  active,
  closed,
  archived,
}
SurveyStatus toSurveyStatus(string value) {
  mixin(EnumSwitch("SurveyStatus", "draft"));
}
///
unittest {
    assert(toSurveyStatus("draft") == SurveyStatus.draft);
    assert(toSurveyStatus("ACTIVE") == SurveyStatus.active);
    assert(toSurveyStatus("Closed") == SurveyStatus.closed);
    assert(toSurveyStatus("archived") == SurveyStatus.archived);
    assert(toSurveyStatus("unknown") == SurveyStatus.draft);
}

/// Survey question type.
enum QuestionType {
  singleChoice,
  multipleChoice,
  freeText,
  rating,
  scale,
}
QuestionType toQuestionType(string value) {
  mixin(EnumSwitch("QuestionType", "singleChoice"));
}
///
unittest {
    assert(toQuestionType("singleChoice") == QuestionType.singleChoice);
    assert(toQuestionType("MULTIPLECHOICE") == QuestionType.multipleChoice);
    assert(toQuestionType("FreeText") == QuestionType.freeText);
    assert(toQuestionType("rating") == QuestionType.rating);
    assert(toQuestionType("Scale") == QuestionType.scale);
    assert(toQuestionType("unknown") == QuestionType.singleChoice);
}

/// Forum topic status.
enum ForumTopicStatus {
  open,
  closed,
  pinned,   
  archived,
}
ForumTopicStatus toForumTopicStatus(string value) {
  mixin(EnumSwitch("ForumTopicStatus", "open"));
} 
///
unittest {
    assert(toForumTopicStatus("open") == ForumTopicStatus.open);
    assert(toForumTopicStatus("CLOSED") == ForumTopicStatus.closed);
    assert(toForumTopicStatus("Pinned") == ForumTopicStatus.pinned);
    assert(toForumTopicStatus("archived") == ForumTopicStatus.archived);
    assert(toForumTopicStatus("unknown") == ForumTopicStatus.open);
}

/// Notification status.
enum NotificationStatus {
  unread,
  read_,
  dismissed,
  actionRequired,
}
NotificationStatus toNotificationStatus(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
    case "unread": return NotificationStatus.unread;
    case "read": return NotificationStatus.read_;
    case "dismissed": return NotificationStatus.dismissed;
    case "actionrequired": return NotificationStatus.actionRequired;
    default: return NotificationStatus.unread; // default
  }
}
///
unittest {
    assert(toNotificationStatus("unread") == NotificationStatus.unread);
    assert(toNotificationStatus("READ") == NotificationStatus.read_);
    assert(toNotificationStatus("Dismissed") == NotificationStatus.dismissed);
    assert(toNotificationStatus("actionrequired") == NotificationStatus.actionRequired);
    assert(toNotificationStatus("unknown") == NotificationStatus.unread);
}

/// KB article status.
enum KBArticleStatus {
  draft,
  published,
  review,
  archived,
}

KBArticleStatus toKBArticleStatus(string value) {
  mixin(EnumSwitch("KBArticleStatus", "draft"));
  }
  ///
unittest {
    assert(toKBArticleStatus("draft") == KBArticleStatus.draft);
    assert(toKBArticleStatus("PUBLISHED") == KBArticleStatus.published);
    assert(toKBArticleStatus("Review") == KBArticleStatus.review);
    assert(toKBArticleStatus("archived") == KBArticleStatus.archived);
    assert(toKBArticleStatus("unknown") == KBArticleStatus.draft);
}

/// WZGroup type.
enum GroupType {
  security,
  distribution,
  dynamic,
}

GroupType toGroupType(string value) {
  mixin(EnumSwitch("GroupType", "security"));
}
/// 
unittest {
    assert(toGroupType("security") == GroupType.security);
    assert(toGroupType("DISTRIBUTION") == GroupType.distribution);
    assert(toGroupType("Dynamic") == GroupType.dynamic);
    assert(toGroupType("unknown") == GroupType.security);
}

/// Navigation item type.
enum NavigationItemType {
  link,
  group,
  separator,
  app,
  externalLink,
}
NavigationItemType toNavigationItemType(string value) {
  mixin(EnumSwitch("NavigationItemType", "link"));
}
///
unittest {
    assert(toNavigationItemType("link") == NavigationItemType.link);
    assert(toNavigationItemType("GROUP") == NavigationItemType.group);
    assert(toNavigationItemType("Separator") == NavigationItemType.separator);
    assert(toNavigationItemType("app") == NavigationItemType.app);
    assert(toNavigationItemType("ExternalLink") == NavigationItemType.externalLink);
    assert(toNavigationItemType("unknown") == NavigationItemType.link);
}

/// Plugin status.
enum PluginStatus {
  active,
  inactive,
  error,
}
PluginStatus toPluginStatus(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
    case "active": return PluginStatus.active;
    case "inactive": return PluginStatus.inactive;
    case "error": return PluginStatus.error;
    default: return PluginStatus.active; // default
  }
}
///
unittest {
    assert(toPluginStatus("active") == PluginStatus.active);
    assert(toPluginStatus("INACTIVE") == PluginStatus.inactive);
    assert(toPluginStatus("Error") == PluginStatus.error);
    assert(toPluginStatus("unknown") == PluginStatus.active);
}

/// External content provider status.
enum ProviderStatus {
  connected,
  disconnected,
  error,
}

ProviderStatus toProviderStatus(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
    case "connected": return ProviderStatus.connected;
    case "disconnected": return ProviderStatus.disconnected;
    case "error": return ProviderStatus.error;
    default: return ProviderStatus.disconnected; // default
  }
}
///
unittest {
    assert(toProviderStatus("connected") == ProviderStatus.connected);
    assert(toProviderStatus("DISCONNECTED") == ProviderStatus.disconnected);
    assert(toProviderStatus("Error") == ProviderStatus.error);
    assert(toProviderStatus("unknown") == ProviderStatus.disconnected);
}

/// External content provider type.
enum ProviderType {
  odata,
  rest,
  graphql,
  sapBtp,
  custom,
}
ProviderType toProviderType(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
    case "odata": return ProviderType.odata;
    case "rest": return ProviderType.rest;
    case "graphql": return ProviderType.graphql;
    case "sapbtp": return ProviderType.sapBtp;
    case "custom": return ProviderType.custom;
    default: return ProviderType.custom; // default
  }
}
///
unittest {
    assert(toProviderType("odata") == ProviderType.odata);
    assert(toProviderType("REST") == ProviderType.rest);
    assert(toProviderType("GraphQL") == ProviderType.graphql);
    assert(toProviderType("sapBTP") == ProviderType.sapBtp);
    assert(toProviderType("Custom") == ProviderType.custom);
    assert(toProviderType("unknown") == ProviderType.custom);
}