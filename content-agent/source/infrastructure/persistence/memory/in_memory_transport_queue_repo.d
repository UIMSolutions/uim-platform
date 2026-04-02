module infrastructure.persistence.memory.in_memory_transport_queue_repo;

import uim.platform.content_agent.domain.types;
import uim.platform.content_agent.domain.entities.transport_queue;
import uim.platform.content_agent.domain.ports.transport_queue_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryTransportQueueRepository : TransportQueueRepository
{
    private TransportQueue[TransportQueueId] store;

    TransportQueue findById(TransportQueueId id)
    {
        if (auto p = id in store)
            return *p;
        return TransportQueue.init;
    }

    TransportQueue[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    TransportQueue findDefault(TenantId tenantId)
    {
        foreach (ref e; store.byValue())
            if (e.tenantId == tenantId && e.isDefault)
                return e;
        return TransportQueue.init;
    }

    TransportQueue findByName(TenantId tenantId, string name)
    {
        foreach (ref e; store.byValue())
            if (e.tenantId == tenantId && e.name == name)
                return e;
        return TransportQueue.init;
    }

    void save(TransportQueue queue) { store[queue.id] = queue; }
    void update(TransportQueue queue) { store[queue.id] = queue; }
    void remove(TransportQueueId id) { store.remove(id); }
}
