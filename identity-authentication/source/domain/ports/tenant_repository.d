module domain.ports.tenant_repository;

import domain.entities.tenant;
import domain.types;

/// Port: outgoing — tenant persistence.
interface TenantRepository
{
    Tenant findById(TenantId id);
    Tenant findBySubdomain(string subdomain);
    Tenant[] findAll(uint offset = 0, uint limit = 100);
    void save(Tenant tenant);
    void update(Tenant tenant);
    void remove(TenantId id);
}
