module infrastructure.persistence.memory.channel_repo;

import domain.types;
import domain.entities.service_channel;
import domain.ports.channel_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryChannelRepository : ChannelRepository
{
    private ServiceChannel[ChannelId] store;

    ServiceChannel findById(ChannelId id)
    {
        if (auto p = id in store)
            return *p;
        return ServiceChannel.init;
    }

    ServiceChannel[] findByConnector(ConnectorId connectorId)
    {
        return store.byValue().filter!(e => e.connectorId == connectorId).array;
    }

    ServiceChannel[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    ServiceChannel[] findByStatus(TenantId tenantId, ChannelStatus status)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.status == status)
            .array;
    }

    void save(ServiceChannel entity) { store[entity.id] = entity; }
    void update(ServiceChannel entity) { store[entity.id] = entity; }
    void remove(ChannelId id) { store.remove(id); }
}
