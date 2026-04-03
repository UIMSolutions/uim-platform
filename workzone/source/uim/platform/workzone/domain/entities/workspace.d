module uim.platform.workzone.domain.entities.workspace;

import uim.platform.workzone.domain.types;

/// A collaborative workspace — teams, projects, or departments.
struct Workspace
{
    WorkspaceId id;
    TenantId tenantId;
    string name;
    string description;
    string alias_;          // URL-friendly slug
    WorkspaceType type = WorkspaceType.team;
    WorkspaceStatus status = WorkspaceStatus.active;
    string imageUrl;
    WorkspaceMember[] members;
    WorkpageId[] pageIds;
    ChannelId[] channelIds;
    WorkspaceSettings settings;
    long createdAt;
    long updatedAt;
    string createdBy;
}

/// Membership record within a workspace.
struct WorkspaceMember
{
    UserId userId;
    string displayName;
    MemberRole role = MemberRole.contributor;
    long joinedAt;
}

/// Workspace-level settings.
struct WorkspaceSettings
{
    bool allowExternalMembers;
    bool enableNotifications;
    bool enableFeeds;
    bool enableWiki;
    bool enableKnowledgeBase;
    bool enableForum;
    string defaultLanguage;
}
