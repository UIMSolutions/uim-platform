module uim.platform.xyz.domain.ports.channel_repository;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.channel;

interface ChannelRepository
{
    Channel[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId);
    Channel* findById(ChannelId id, TenantId tenantId);
    void save(Channel channel);
    void update(Channel channel);
    void remove(ChannelId id, TenantId tenantId);
}
