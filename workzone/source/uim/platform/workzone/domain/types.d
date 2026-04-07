/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.types;

/// Unique identifier type aliases for type safety.
alias WorkspaceId = string;
alias WorkpageId = string;
alias CardId = string;
alias ContentId = string;
alias FeedEntryId = string;
alias NotificationId = string;
alias TaskId = string;
alias ChannelId = string;
alias AppId = string;
alias WidgetId = string;

alias UserId = string;
alias RoleId = string;
alias SiteId = string;
alias EventId = string;
alias SurveyId = string;
alias ForumTopicId = string;
alias KBArticleId = string;
alias GroupId = string;
alias TagId = string;
alias ThemeId = string;
alias NavigationItemId = string;
alias PageTemplateId = string;
alias ExternalContentProviderId = string;
alias ShellPluginId = string;
alias UserProfileId = string;
alias MemberId = string;

/// Workspace type.
enum WorkspaceType {
  project,
  team,
  department,
  public_,
  external,
}

/// Workspace status.
enum WorkspaceStatus {
  active,
  archived,
  suspended,
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

/// Content type within a workspace.
enum ContentType {
  blogPost,
  wikiPage,
  knowledgeBase,
  forumPost,
  announcement,
  document,
}

/// Content status / lifecycle.
enum ContentStatus {
  draft,
  published,
  archived,
  deleted,
}

/// Notification priority.
enum NotificationPriority {
  low,
  medium,
  high,
  critical,
}

/// Notification status.
enum NotificationStatus {
  unread,
  read_,
  dismissed,
  actionRequired,
}

/// Task status.
enum TaskStatus {
  open,
  inProgress,
  completed,
  cancelled,
  overdue,
}

/// Task priority.
enum TaskPriority {
  low,
  medium,
  high,
  veryHigh,
}

/// Channel type (content feed source).
enum ChannelType {
  activity,
  notification,
  custom,
  external,
}

/// Application status (registered app lifecycle).
enum AppStatus {
  active,
  inactive,
  deprecated_,
}

/// Widget size on a workspace page.
enum WidgetSize {
  small,
  medium,
  large,
  fullWidth,
}

/// Member role within a workspace.
enum MemberRole {
  viewer,
  contributor,
  admin,
  owner,
}

/// Site status.
enum SiteStatus {
  draft,
  published,
  maintenance,
  archived,
}

/// Event status.
enum EventStatus {
  scheduled,
  ongoing,
  completed,
  cancelled,
}

/// Survey status.
enum SurveyStatus {
  draft,
  active,
  closed,
  archived,
}

/// Survey question type.
enum QuestionType {
  singleChoice,
  multipleChoice,
  freeText,
  rating,
  scale,
}

/// Forum topic status.
enum ForumTopicStatus {
  open,
  closed,
  pinned,
  archived,
}

/// KB article status.
enum KBArticleStatus {
  draft,
  published,
  review,
  archived,
}

/// Group type.
enum GroupType {
  security,
  distribution,
  dynamic,
}

/// Navigation item type.
enum NavigationItemType {
  link,
  group,
  separator,
  app,
  externalLink,
}

/// Plugin status.
enum PluginStatus {
  active,
  inactive,
  error,
}

/// External content provider status.
enum ProviderStatus {
  connected,
  disconnected,
  error,
}

/// External content provider type.
enum ProviderType {
  odata,
  rest,
  graphql,
  sapBtp,
  custom,
}
