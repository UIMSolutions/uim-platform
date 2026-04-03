module domain.ports.api_client_repository;

import domain.entities.api_client;
import domain.types;

/// Port: outgoing — API client persistence.
interface ApiClientRepository
{
    ApiClient findById(ApiClientId id);
    ApiClient findByClientId(string clientId);
    ApiClient[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
    void save(ApiClient client);
    void update(ApiClient client);
    void remove(ApiClientId id);
}
