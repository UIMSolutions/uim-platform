module infrastructure.persistence.in_memory_communication_arrangement_repo;

import domain.types;
import domain.entities.communication_arrangement;
import domain.ports.communication_arrangement_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryCommunicationArrangementRepository : CommunicationArrangementRepository
{
    private CommunicationArrangement[CommunicationArrangementId] store;

    CommunicationArrangement* findById(CommunicationArrangementId id)
    {
        if (auto p = id in store)
            return p;
        return null;
    }

    CommunicationArrangement[] findBySystem(SystemInstanceId systemId)
    {
        return store.byValue().filter!(e => e.systemInstanceId == systemId).array;
    }

    CommunicationArrangement[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    CommunicationArrangement[] findByDirection(SystemInstanceId systemId, CommunicationDirection dir)
    {
        return store.byValue()
            .filter!(e => e.systemInstanceId == systemId && e.direction == dir)
            .array;
    }

    void save(CommunicationArrangement arrangement) { store[arrangement.id] = arrangement; }
    void update(CommunicationArrangement arrangement) { store[arrangement.id] = arrangement; }
    void remove(CommunicationArrangementId id) { store.remove(id); }
}
