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
alias TenantId = string;
alias UserId = string;
alias RoleId = string;

/// Workspace type.
enum WorkspaceType
{
  project,
  team,
  department,
  public_,
  external,
}

/// Workspace status.
enum WorkspaceStatus
{
  active,
  archived,
  suspended,
}

/// Card type (integration card manifest type).
enum CardType
{
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
enum ContentType
{
  blogPost,
  wikiPage,
  knowledgeBase,
  forumPost,
  announcement,
  document,
}

/// Content status / lifecycle.
enum ContentStatus
{
  draft,
  published,
  archived,
  deleted,
}

/// Notification priority.
enum NotificationPriority
{
  low,
  medium,
  high,
  critical,
}

/// Notification status.
enum NotificationStatus
{
  unread,
  read_,
  dismissed,
  actionRequired,
}

/// Task status.
enum TaskStatus
{
  open,
  inProgress,
  completed,
  cancelled,
  overdue,
}

/// Task priority.
enum TaskPriority
{
  low,
  medium,
  high,
  veryHigh,
}

/// Channel type (content feed source).
enum ChannelType
{
  activity,
  notification,
  custom,
  external,
}

/// Application status (registered app lifecycle).
enum AppStatus
{
  active,
  inactive,
  deprecated_,
}

/// Widget size on a workspace page.
enum WidgetSize
{
  small,
  medium,
  large,
  fullWidth,
}

/// Member role within a workspace.
enum MemberRole
{
  viewer,
  contributor,
  admin,
  owner,
}
