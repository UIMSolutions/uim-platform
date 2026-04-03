module uim.platform.master_data_integration.domain.ports.client_repository;

import uim.platform.master_data_integration.domain.entities.client;
import uim.platform.master_data_integration.domain.types;

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
