module infrastructure.persistence.memory.transport_request_repo;

import domain.types;
import domain.entities.transport_request;
import domain.ports.transport_request_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryTransportRequestRepository : TransportRequestRepository
{
    private TransportRequest[TransportRequestId] store;

    TransportRequest findById(TransportRequestId id)
    {
        if (auto p = id in store)
            return *p;
        return TransportRequest.init;
    }

    TransportRequest[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    TransportRequest[] findByStatus(TenantId tenantId, TransportStatus status)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.status == status)
            .array;
    }

    void save(TransportRequest request) { store[request.id] = request; }
    void update(TransportRequest request) { store[request.id] = request; }
    void remove(TransportRequestId id) { store.remove(id); }
}
