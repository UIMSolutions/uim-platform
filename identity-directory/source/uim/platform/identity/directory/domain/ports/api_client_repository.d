module uim.platform.xyz.domain.ports.api_client_repository;

import uim.platform.xyz.domain.entities.api_client;
import uim.platform.xyz.domain.types;

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
