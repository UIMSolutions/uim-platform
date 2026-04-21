/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.types;

/// Unique identifier type aliases for type safety.
struct WorkspaceId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct WorkpageId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct CardId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ContentId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct FeedEntryId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct NotificationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct TaskId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ChannelId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct AppId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct WidgetId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct RoleId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct SiteId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct EventId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct SurveyId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ForumTopicId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct KBArticleId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct GroupId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct TagId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ThemeId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct NavigationItemId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct PageTemplateId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ExternalContentProviderId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ShellPluginId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct UserProfileId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct MemberId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

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
