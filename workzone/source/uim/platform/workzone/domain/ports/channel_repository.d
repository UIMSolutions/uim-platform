module uim.platform.workzone.domain.ports.channel_repository;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.channel;

interface ChannelRepository
{
    Channel[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId);
    Channel* findById(ChannelId id, TenantId tenantId);
    void save(Channel channel);
    void update(Channel channel);
    void remove(ChannelId id, TenantId tenantId);
}
