module uim.platform.identity_authentication.domain.ports.tenant;

import uim.platform.identity_authentication.domain.entities.tenant;
import uim.platform.identity_authentication.domain.types;

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
