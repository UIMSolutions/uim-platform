module uim.platform.workzone.infrastructure.persistence.memory.channel_repo;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.channel;
import uim.platform.workzone.domain.ports.channel_repository;

// import std.algorithm : filter;
// import std.array : array;

class MemoryChannelRepository : ChannelRepository
{
    private Channel[ChannelId] store;

    Channel[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId)
    {
        return store.byValue().filter!(c => c.tenantId == tenantId && c.workspaceId == workspaceId).array;
    }

    Channel* findById(ChannelId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                return p;
        return null;
    }

    void save(Channel channel) { store[channel.id] = channel; }
    void update(Channel channel) { store[channel.id] = channel; }
    void remove(ChannelId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                store.remove(id);
    }
}
