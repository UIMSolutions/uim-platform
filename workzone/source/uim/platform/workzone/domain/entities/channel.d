module uim.platform.xyz.domain.entities.channel;

import uim.platform.xyz.domain.types;

/// A content channel — a feed source within a workspace for activity streams.
struct Channel
{
    ChannelId id;
    WorkspaceId workspaceId;
    TenantId tenantId;
    string name;
    string description;
    ChannelType channelType = ChannelType.activity;
    bool active = true;
    RoleId[] allowedRoleIds;
    ChannelConfig config;
    long createdAt;
    long updatedAt;
}

/// Channel-specific configuration.
struct ChannelConfig
{
    string sourceUrl;        // external feed URL
    int pollIntervalSec;     // how often to poll
    string authType;
    string authToken;
    int maxItems;
}
