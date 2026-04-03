module uim.platform.xyz.domain.ports.client_repository;

import uim.platform.xyz.domain.entities.client;
import uim.platform.xyz.domain.types;

/// Port: outgoing — connected client system persistence.
interface ClientRepository
{
    Client findById(ClientId id);
    Client[] findByTenant(TenantId tenantId);
    Client[] findByStatus(TenantId tenantId, ClientStatus status);
    Client[] findByType(TenantId tenantId, ClientType clientType);
    void save(Client client);
    void update(Client client);
    void remove(ClientId id);
}
