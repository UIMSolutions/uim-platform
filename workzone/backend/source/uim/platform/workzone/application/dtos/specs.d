/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.dtos.specs;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

// Field names equal the entity's (see requests.d); defaults equal the entity defaults.

// ── Workspaces and their content (parent = workspace) ───────────────────────

struct WorkspaceSpec {
  string name;
  string description;
  string alias_;
  WorkspaceType type = WorkspaceType.team;
  string imageUrl;
  string defaultLanguage = "en";
  bool allowExternalMembers;
  bool enableNotifications = true;
  bool enableFeeds = true;
  bool enableWiki = true;
  bool enableKnowledgeBase = true;
  bool enableForum = true;
  WorkspaceMember[] members;
}

alias CreateWorkspaceRequest = CreateRootRequest!WorkspaceSpec;
alias UpdateWorkspaceRequest = UpdateRequest!(WorkspaceId, WorkspaceSpec);

struct WorkpageSpec {
  string title;
  string description;
  PageTemplateId templateId;
  int sortOrder;
  bool visible = true;
  bool isDefault;
  string[] allowedRoles;
}

alias CreateWorkpageRequest = CreateRequest!(WorkspaceId, WorkpageSpec);
alias UpdateWorkpageRequest = UpdateRequest!(WorkpageId, WorkpageSpec);

struct WidgetSpec {
  string title;
  CardId cardId;
  AppId appId;
  WidgetSize size = WidgetSize.medium;
  int row;
  int col;
  int sortOrder;
  bool visible = true;
  string customTitle;
  int maxItems;
  int refreshIntervalSec;
  string filterExpression;
  KeyValue[] parameters;
}

alias CreateWidgetRequest = CreateRequest!(WorkpageId, WidgetSpec);
alias UpdateWidgetRequest = UpdateRequest!(WidgetId, WidgetSpec);

struct ChannelSpec {
  string name;
  string description;
  ChannelType channelType = ChannelType.activity;
  string sourceUrl;
  int pollIntervalSec = 300;
  string authType = "none";
  string authToken;
  int maxItems = 20;
  string[] allowedRoles;
}

alias CreateChannelRequest = CreateRequest!(WorkspaceId, ChannelSpec);
alias UpdateChannelRequest = UpdateRequest!(ChannelId, ChannelSpec);

struct ContentSpec {
  string title;
  string body_;
  string summary;
  ContentType contentType = ContentType.blogPost;
  string authorName;
  string[] tags;
  string[] attachmentUrls;
  string language = "en";
  bool commentsEnabled = true;
}

alias CreateContentRequest = CreateRequest!(WorkspaceId, ContentSpec);
alias UpdateContentRequest = UpdateRequest!(ContentId, ContentSpec);

struct FeedEntrySpec {
  string actorName;
  string action = "posted";
  string objectType;
  string objectId;
  string objectTitle;
  string message;
  string[] mentionedUserIds;
}

alias CreateFeedEntryRequest = CreateRequest!(WorkspaceId, FeedEntrySpec);
alias UpdateFeedEntryRequest = UpdateRequest!(FeedEntryId, FeedEntrySpec);

struct EventSpec {
  string title;
  string description;
  string location;
  string meetingUrl;
  string organizerName;
  string[] attendeeIds;
  bool allDay;
  long startsAt;
  long endsAt;
  string timezone = "UTC";
  string recurrenceRule;
}

alias CreateEventRequest = CreateRequest!(WorkspaceId, EventSpec);
alias UpdateEventRequest = UpdateRequest!(EventId, EventSpec);

struct SurveySpec {
  string title;
  string description;
  string creatorName;
  SurveyQuestion[] questions;
  bool anonymous;
  bool allowMultipleResponses;
  long startsAt;
  long endsAt;
}

alias CreateSurveyRequest = CreateRequest!(WorkspaceId, SurveySpec);
alias UpdateSurveyRequest = UpdateRequest!(SurveyId, SurveySpec);

struct ForumTopicSpec {
  string title;
  string body_;
  string authorName;
  string[] tags;
}

alias CreateForumTopicRequest = CreateRequest!(WorkspaceId, ForumTopicSpec);
alias UpdateForumTopicRequest = UpdateRequest!(ForumTopicId, ForumTopicSpec);

struct ArticleSpec {
  string title;
  string body_;
  string summary;
  string authorName;
  string category;
  string[] tags;
  string[] relatedArticleIds;
  string language = "en";
}

alias CreateArticleRequest = CreateRequest!(WorkspaceId, ArticleSpec);
alias UpdateArticleRequest = UpdateRequest!(KBArticleId, ArticleSpec);

// ── Inbox ────────────────────────────────────────────────────────────────────

struct TaskSpec {
  UserId assigneeId;
  string assigneeName;
  string title;
  string description;
  TaskPriority priority = TaskPriority.medium;
  string sourceApp;
  string sourceTaskId;
  string actionUrl;
  string category;
  string[] tags;
  long dueAt;
}

alias CreateTaskRequest = CreateRootRequest!TaskSpec;
alias UpdateTaskRequest = UpdateRequest!(TaskId, TaskSpec);

struct NotificationSpec {
  UserId recipientId;
  string title;
  string body_;
  string sourceApp;
  string sourceObjectType;
  string sourceObjectId;
  string actionUrl;
  NotificationPriority priority = NotificationPriority.medium;
  long expiresAt;
}

alias CreateNotificationRequest = CreateRootRequest!NotificationSpec;
alias UpdateNotificationRequest = UpdateRequest!(NotificationId, NotificationSpec);

// ── Integration ──────────────────────────────────────────────────────────────

struct CardSpec {
  string title;
  string subtitle;
  string description;
  string icon;
  CardType cardType = CardType.list;
  string dataSourceUrl;
  string dataSourceMethod = "GET";
  string dataSourcePath;
  int refreshIntervalSec;
  string authType = "none";
  string authToken;
  string manifestType = "sap.card";
  string manifestVersion = "1.0.0";
  string headerTitle;
  string headerSubtitle;
  string headerIcon;
  string headerStatus;
  int maxItems = 5;
  string[] allowedRoles;
}

alias CreateCardRequest = CreateRootRequest!CardSpec;
alias UpdateCardRequest = UpdateRequest!(CardId, CardSpec);

struct AppSpec {
  string name;
  string description;
  string launchUrl;
  string icon;
  string vendor;
  string version_ = "1.0.0";
  AppPlatform[] supportedPlatforms;
  string[] tags;
  string[] allowedRoles;
  string authType = "none";
  string authEndpoint;
  bool enableSso;
  string sapSystemAlias;
  string odataServiceUrl;
  string componentId;
}

alias CreateAppRequest = CreateRootRequest!AppSpec;
alias UpdateAppRequest = UpdateRequest!(AppId, AppSpec);

struct ProviderSpec {
  string name;
  string description;
  ProviderType providerType = ProviderType.rest;
  string endpointUrl;
  string authType = "none";
  string authConfig;
  string[] contentTypes;
  int refreshIntervalSec = 3600;
}

alias CreateProviderRequest = CreateRootRequest!ProviderSpec;
alias UpdateProviderRequest = UpdateRequest!(ExternalContentProviderId, ProviderSpec);

struct PluginSpec {
  string name;
  string description;
  string version_ = "1.0.0";
  string vendor;
  string scriptUrl;
  string configSchemaUrl;
  string[] assignedSites;
  HookPoint[] hookPoints;
}

alias CreatePluginRequest = CreateRootRequest!PluginSpec;
alias UpdatePluginRequest = UpdateRequest!(ShellPluginId, PluginSpec);

// ── Sites & administration ───────────────────────────────────────────────────

struct SiteSpec {
  string name;
  string description;
  string alias_;
  ThemeId themeId;
  string[] allowedRoles;
  string logoUrl;
  string faviconUrl;
  string footerText;
  string defaultLanguage = "en";
  bool enableSearch = true;
  bool enableNotifications = true;
  bool enableUserMenu = true;
  bool enableFeedback;
}

alias CreateSiteRequest = CreateRootRequest!SiteSpec;
alias UpdateSiteRequest = UpdateRequest!(SiteId, SiteSpec);

struct NavigationItemSpec {
  string title;
  string icon;
  NavigationItemType itemType = NavigationItemType.link;
  string targetUrl;
  AppId targetAppId;
  WorkpageId targetWorkpageId;
  NavigationItemId parentId;
  int sortOrder;
  bool visible = true;
  bool openInNewWindow;
  string[] allowedRoles;
}

alias CreateNavigationItemRequest = CreateRequest!(SiteId, NavigationItemSpec);
alias UpdateNavigationItemRequest = UpdateRequest!(NavigationItemId, NavigationItemSpec);

struct ThemeSpec {
  string name;
  string description;
  BaseTheme baseTheme = BaseTheme.sapHorizon;
  string primaryColor;
  string secondaryColor;
  string backgroundColor;
  string headerColor;
  string textColor;
  string linkColor;
  string accentColor;
  string logoUrl;
  string faviconUrl;
  string customCss;
  bool isDefault;
}

alias CreateThemeRequest = CreateRootRequest!ThemeSpec;
alias UpdateThemeRequest = UpdateRequest!(ThemeId, ThemeSpec);

struct PageTemplateSpec {
  string name;
  string description;
  string thumbnailUrl;
  TemplateSection[] sections;
  bool isDefault;
  bool isPublic = true;
}

alias CreatePageTemplateRequest = CreateRootRequest!PageTemplateSpec;
alias UpdatePageTemplateRequest = UpdateRequest!(PageTemplateId, PageTemplateSpec);

struct RoleSpec {
  string name;
  string description;
  string[] permissions;
  bool isDefault;
}

alias CreateRoleRequest = CreateRootRequest!RoleSpec;
alias UpdateRoleRequest = UpdateRequest!(RoleId, RoleSpec);

struct GroupSpec {
  string name;
  string description;
  GroupType groupType = GroupType.security;
  string[] memberIds;
  string[] roles;
  bool active = true;
}

alias CreateGroupRequest = CreateRootRequest!GroupSpec;
alias UpdateGroupRequest = UpdateRequest!(GroupId, GroupSpec);

struct TagSpec {
  string name;
  string description;
  string color = "#0A6ED1";
  string parentTag;
}

alias CreateTagRequest = CreateRootRequest!TagSpec;
alias UpdateTagRequest = UpdateRequest!(TagId, TagSpec);

struct UserProfileSpec {
  UserId userId;
  string displayName;
  string email;
  string firstName;
  string lastName;
  string avatarUrl;
  string jobTitle;
  string department;
  string phone;
  string timezone = "UTC";
  string language = "en";
  string[] roles;
  string[] groups;
}

alias CreateUserProfileRequest = CreateRootRequest!UserProfileSpec;
alias UpdateUserProfileRequest = UpdateRequest!(UserProfileId, UserProfileSpec);
