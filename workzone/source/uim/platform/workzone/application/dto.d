/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.dto;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.workspace : WorkspaceMember, WorkspaceSettings;
// import uim.platform.workzone.domain.entities.card : CardDataSource, CardManifest;
// import uim.platform.workzone.domain.entities.channel : ChannelConfig;
// import uim.platform.workzone.domain.entities.app_registration : AppConfig;
// import uim.platform.workzone.domain.entities.widget : WidgetConfig;
// import uim.platform.workzone.domain.entities.site : SiteSettings;
// import uim.platform.workzone.domain.entities.survey : SurveyQuestion;
// import uim.platform.workzone.domain.entities.theme : ThemeColors;
// import uim.platform.workzone.domain.entities.page_template : TemplateSection;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
// ──────────────── Workspace DTOs ────────────────

struct CreateWorkspaceRequest {
  TenantId tenantId;
  string name;
  string description;
  string alias_;
  WorkspaceType type;
  UserId createdBy;
  WorkspaceSettings settings;
}

struct UpdateWorkspaceRequest {
  WorkspaceId id;
  TenantId tenantId;
  string name;
  string description;
  string imageUrl;
  WorkspaceSettings settings;
}

struct AddMemberRequest {
  WorkspaceId workspaceId;
  TenantId tenantId;
  UserId userId;
  string displayName;
  MemberRole role;
}

// ──────────────── Workpage DTOs ────────────────

struct CreateWorkpageRequest {
  WorkspaceId workspaceId;
  TenantId tenantId;
  string title;
  string description;
  int sortOrder;
  bool isDefault;
}

struct UpdateWorkpageRequest {
  WorkpageId id;
  TenantId tenantId;
  string title;
  string description;
  int sortOrder;
  bool visible;
}

// ──────────────── Card DTOs ────────────────

struct CreateCardRequest {
  TenantId tenantId;
  string title;
  string subtitle;
  string description;
  string icon;
  CardType cardType;
  CardDataSource dataSource;
  CardManifest manifest;
}

struct UpdateCardRequest {
  CardId id;
  TenantId tenantId;
  string title;
  string subtitle;
  string description;
  string icon;
  bool active;
  CardDataSource dataSource;
  CardManifest manifest;
}

// ──────────────── Content DTOs ────────────────

struct CreateContentRequest {
  WorkspaceId workspaceId;
  TenantId tenantId;
  string title;
  string body_;
  string summary;
  ContentType contentType;
  UserId authorId;
  string authorName;
  string[] tags;
  string language;
}

struct UpdateContentRequest {
  ContentId id;
  TenantId tenantId;
  string title;
  string body_;
  string summary;
  ContentStatus status;
  string[] tags;
  bool pinned;
}

// ──────────────── Feed DTOs ────────────────

struct CreateFeedEntryRequest {
  WorkspaceId workspaceId;
  TenantId tenantId;
  UserId actorId;
  string actorName;
  string action;
  string objectType;
  string objectId;
  string objectTitle;
  string message;
}

// ──────────────── Notification DTOs ────────────────

struct CreateNotificationRequest {
  TenantId tenantId;
  UserId recipientId;
  string title;
  string body_;
  string sourceApp;
  string sourceObjectType;
  string sourceObjectId;
  string actionUrl;
  NotificationPriority priority;
  long expiresAt;
}

// ──────────────── Task DTOs ────────────────

struct CreateTaskRequest {
  TenantId tenantId;
  UserId assigneeId;
  string assigneeName;
  UserId creatorId;
  string creatorName;
  string title;
  string description;
  TaskPriority priority;
  string sourceApp;
  string sourceTaskId;
  string actionUrl;
  string category;
  string[] tags;
  long dueDate;
}

struct UpdateTaskRequest {
  TaskId id;
  TenantId tenantId;
  TaskStatus status;
  TaskPriority priority;
  string title;
  string description;
  long dueDate;
}

// ──────────────── Channel DTOs ────────────────

struct CreateChannelRequest {
  WorkspaceId workspaceId;
  TenantId tenantId;
  string name;
  string description;
  ChannelType channelType;
  ChannelConfig config;
}

struct UpdateChannelRequest {
  ChannelId id;
  TenantId tenantId;
  string name;
  string description;
  bool active;
  ChannelConfig config;
}

// ──────────────── App Registration DTOs ────────────────

struct CreateAppRequest {
  TenantId tenantId;
  string name;
  string description;
  string launchUrl;
  string icon;
  string vendor;
  string version_;
  string[] supportedPlatforms;
  string[] tags;
  AppConfig appConfig;
}

struct UpdateAppRequest {
  AppId id;
  TenantId tenantId;
  string name;
  string description;
  string launchUrl;
  string icon;
  AppStatus status;
  AppConfig appConfig;
}

// ──────────────── Widget DTOs ────────────────

struct CreateWidgetRequest {
  WorkpageId pageId;
  TenantId tenantId;
  string title;
  CardId cardId;
  AppId appId;
  WidgetSize size;
  int row;
  int col;
  int sortOrder;
  WidgetConfig config;
}

struct UpdateWidgetRequest {
  WidgetId id;
  TenantId tenantId;
  string title;
  WidgetSize size;
  int row;
  int col;
  int sortOrder;
  bool visible;
  WidgetConfig config;
}

// ──────────────── Generic result ────────────────



// ──────────────── Site DTOs ────────────────

struct CreateSiteRequest {
  TenantId tenantId;
  string name;
  string description;
  string alias_;
  string themeId;
  UserId createdBy;
  SiteSettings settings;
}

struct UpdateSiteRequest {
  SiteId id;
  TenantId tenantId;
  string name;
  string description;
  string themeId;
  SiteSettings settings;
}

// ──────────────── Role DTOs ────────────────

struct CreateRoleRequest {
  TenantId tenantId;
  string name;
  string description;
  string[] permissions;
  bool isDefault;
}

struct UpdateRoleRequest {
  RoleId id;
  TenantId tenantId;
  string name;
  string description;
  string[] permissions;
}

// ──────────────── Event DTOs ────────────────

struct CreateEventRequest {
  TenantId tenantId;
  WorkspaceId workspaceId;
  string title;
  string description;
  string location;
  string meetingUrl;
  UserId organizerId;
  string organizerName;
  bool allDay;
  long startTime;
  long endTime;
  string timezone;
  string recurrenceRule;
}

struct UpdateEventRequest {
  EventId id;
  TenantId tenantId;
  string title;
  string description;
  string location;
  string meetingUrl;
  long startTime;
  long endTime;
}

// ──────────────── Survey DTOs ────────────────

struct CreateSurveyRequest {
  TenantId tenantId;
  WorkspaceId workspaceId;
  string title;
  string description;
  UserId creatorId;
  string creatorName;
  bool anonymous;
  bool allowMultipleResponses;
  long startsAt;
  long endsAt;
  SurveyQuestion[] questions;
}

struct UpdateSurveyRequest {
  SurveyId id;
  TenantId tenantId;
  string title;
  string description;
}

// ──────────────── Forum Topic DTOs ────────────────

struct CreateForumTopicRequest {
  TenantId tenantId;
  WorkspaceId workspaceId;
  string title;
  string body_;
  UserId authorId;
  string authorName;
  string[] tags;
}

struct UpdateForumTopicRequest {
  ForumTopicId id;
  TenantId tenantId;
  string title;
  string body_;
  bool pinned;
  bool locked;
}

// ──────────────── Knowledge Base Article DTOs ────────────────

struct CreateKBArticleRequest {
  TenantId tenantId;
  WorkspaceId workspaceId;
  string title;
  string body_;
  string summary;
  UserId authorId;
  string authorName;
  string category;
  string[] tags;
  string language;
}

struct UpdateKBArticleRequest {
  KBArticleId id;
  TenantId tenantId;
  string title;
  string body_;
  string summary;
  string category;
  string[] tags;
}

// ──────────────── User Profile DTOs ────────────────

struct CreateUserProfileRequest {
  TenantId tenantId;
  UserId userId;
  string displayName;
  string email;
  string firstName;
  string lastName;
  string jobTitle;
  string department;
  string timezone;
  string language;
}

struct UpdateUserProfileRequest {
  UserProfileId id;
  TenantId tenantId;
  string displayName;
  string email;
  string jobTitle;
  string avatarUrl;
}

// ──────────────── Group DTOs ────────────────

struct CreateGroupRequest {
  TenantId tenantId;
  string name;
  string description;
  GroupType type;
}

struct UpdateGroupRequest {
  GroupId id;
  TenantId tenantId;
  string name;
  string description;
  bool active;
}

// ──────────────── Tag DTOs ────────────────

struct CreateTagRequest {
  TenantId tenantId;
  string name;
  string description;
  string color;
  string parentTagId;
}

struct UpdateTagRequest {
  TagId id;
  TenantId tenantId;
  string name;
  string description;
  string color;
}

// ──────────────── Theme DTOs ────────────────

struct CreateThemeRequest {
  TenantId tenantId;
  string name;
  string description;
  string baseTheme;
  string logoUrl;
  string faviconUrl;
  string customCss;
  bool isDefault;
  ThemeColors colors;
}

struct UpdateThemeRequest {
  ThemeId id;
  TenantId tenantId;
  string name;
  string description;
  string customCss;
  bool isDefault;
  ThemeColors colors;
}

// ──────────────── Navigation Item DTOs ────────────────

struct CreateNavigationItemRequest {
  TenantId tenantId;
  SiteId siteId;
  string title;
  string icon;
  string targetUrl;
  string targetAppId;
  string targetPageId;
  NavigationItemId parentId;
  int sortOrder;
  bool openInNewWindow;
  NavigationItemType type;
}

struct UpdateNavigationItemRequest {
  NavigationItemId id;
  TenantId tenantId;
  string title;
  string icon;
  string targetUrl;
  int sortOrder;
  bool visible;
}

// ──────────────── Page Template DTOs ────────────────

struct CreatePageTemplateRequest {
  TenantId tenantId;
  string name;
  string description;
  string thumbnailUrl;
  bool isDefault;
  bool isPublic;
  TemplateSection[] sections;
}

struct UpdatePageTemplateRequest {
  PageTemplateId id;
  TenantId tenantId;
  string name;
  string description;
  bool isDefault;
  bool isPublic;
  TemplateSection[] sections;
}

// ──────────────── External Content Provider DTOs ────────────────

struct CreateExternalContentProviderRequest {
  TenantId tenantId;
  string name;
  string description;
  ProviderType type;
  string endpointUrl;
  string authType;
  string authConfig;
  int refreshIntervalSec;
}

struct UpdateExternalContentProviderRequest {
  ExternalContentProviderId id;
  TenantId tenantId;
  string name;
  string description;
  string endpointUrl;
}

// ──────────────── Shell Plugin DTOs ────────────────

struct CreateShellPluginRequest {
  TenantId tenantId;
  string name;
  string description;
  string version_;
  string vendor;
  string scriptUrl;
  string configSchemaUrl;
  string[] hookPoints;
}

struct UpdateShellPluginRequest {
  ShellPluginId id;
  TenantId tenantId;
  string name;
  string description;
  string scriptUrl;
}
