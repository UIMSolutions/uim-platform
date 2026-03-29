module domain.ports.channel_repository;

import domain.types;
import domain.entities.channel;

interface ChannelRepository
{
    Channel[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId);
    Channel* findById(ChannelId id, TenantId tenantId);
    void save(Channel channel);
    void update(Channel channel);
    void remove(ChannelId id, TenantId tenantId);
}
