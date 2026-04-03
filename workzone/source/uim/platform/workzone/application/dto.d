module uim.platform.xyz.application.dto;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.workspace : WorkspaceMember, WorkspaceSettings;
import uim.platform.xyz.domain.entities.card : CardDataSource, CardManifest;
import uim.platform.xyz.domain.entities.channel : ChannelConfig;
import uim.platform.xyz.domain.entities.app_registration : AppConfig;
import uim.platform.xyz.domain.entities.widget : WidgetConfig;

// ──────────────── Workspace DTOs ────────────────

struct CreateWorkspaceRequest
{
    TenantId tenantId;
    string name;
    string description;
    string alias_;
    WorkspaceType type;
    string createdBy;
    WorkspaceSettings settings;
}

struct UpdateWorkspaceRequest
{
    WorkspaceId id;
    TenantId tenantId;
    string name;
    string description;
    string imageUrl;
    WorkspaceSettings settings;
}

struct AddMemberRequest
{
    WorkspaceId workspaceId;
    TenantId tenantId;
    UserId userId;
    string displayName;
    MemberRole role;
}

// ──────────────── Workpage DTOs ────────────────

struct CreateWorkpageRequest
{
    WorkspaceId workspaceId;
    TenantId tenantId;
    string title;
    string description;
    int sortOrder;
    bool isDefault;
}

struct UpdateWorkpageRequest
{
    WorkpageId id;
    TenantId tenantId;
    string title;
    string description;
    int sortOrder;
    bool visible;
}

// ──────────────── Card DTOs ────────────────

struct CreateCardRequest
{
    TenantId tenantId;
    string title;
    string subtitle;
    string description;
    string icon;
    CardType cardType;
    CardDataSource dataSource;
    CardManifest manifest;
}

struct UpdateCardRequest
{
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

struct CreateContentRequest
{
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

struct UpdateContentRequest
{
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

struct CreateFeedEntryRequest
{
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

struct CreateNotificationRequest
{
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

struct CreateTaskRequest
{
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

struct UpdateTaskRequest
{
    TaskId id;
    TenantId tenantId;
    TaskStatus status;
    TaskPriority priority;
    string title;
    string description;
    long dueDate;
}

// ──────────────── Channel DTOs ────────────────

struct CreateChannelRequest
{
    WorkspaceId workspaceId;
    TenantId tenantId;
    string name;
    string description;
    ChannelType channelType;
    ChannelConfig config;
}

struct UpdateChannelRequest
{
    ChannelId id;
    TenantId tenantId;
    string name;
    string description;
    bool active;
    ChannelConfig config;
}

// ──────────────── App Registration DTOs ────────────────

struct CreateAppRequest
{
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

struct UpdateAppRequest
{
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

struct CreateWidgetRequest
{
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

struct UpdateWidgetRequest
{
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

struct CommandResult
{
    string id;
    string error;

    bool isSuccess() const
    {
        return error.length == 0;
    }
}
