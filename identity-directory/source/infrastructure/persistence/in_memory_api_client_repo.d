module infrastructure.persistence.in_memory_api_client_repo;

import domain.entities.api_client;
import domain.types;
import domain.ports.api_client_repository;

/// In-memory adapter for API client persistence.
class InMemoryApiClientRepository : ApiClientRepository
{
    private ApiClient[ApiClientId] store;

    ApiClient findById(ApiClientId id)
    {
        if (auto p = id in store)
            return *p;
        return ApiClient.init;
    }

    ApiClient findByClientId(string clientId)
    {
        foreach (c; store.byValue())
        {
            if (c.clientId == clientId)
                return c;
        }
        return ApiClient.init;
    }

    ApiClient[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        ApiClient[] result;
        uint idx;
        foreach (c; store.byValue())
        {
            if (c.tenantId == tenantId)
            {
                if (idx >= offset && result.length < limit)
                    result ~= c;
                idx++;
            }
        }
        return result;
    }

    void save(ApiClient client)
    {
        store[client.id] = client;
    }

    void update(ApiClient client)
    {
        store[client.id] = client;
    }

    void remove(ApiClientId id)
    {
        store.remove(id);
    }
}
