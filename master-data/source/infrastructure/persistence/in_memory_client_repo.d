module infrastructure.persistence.memory.client_repo;

import domain.types;
import domain.entities.client;
import domain.ports.client_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryClientRepository : ClientRepository
{
    private Client[ClientId] store;

    Client findById(ClientId id)
    {
        if (auto p = id in store)
            return *p;
        return Client.init;
    }

    Client[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    Client[] findByStatus(TenantId tenantId, ClientStatus status)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.status == status)
            .array;
    }

    Client[] findByType(TenantId tenantId, ClientType clientType)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.clientType == clientType)
            .array;
    }

    void save(Client client) { store[client.id] = client; }
    void update(Client client) { store[client.id] = client; }
    void remove(ClientId id) { store.remove(id); }
}
