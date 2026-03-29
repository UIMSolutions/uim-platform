module domain.ports.idp_config;

import domain.entities.idp_config;
import domain.types;

/// Port: outgoing — external IdP configuration persistence.
interface IdpConfigRepository
{
    IdpConfig findById(string id);
    IdpConfig findDefaultForTenant(TenantId tenantId);
    IdpConfig[] findByTenant(TenantId tenantId);
    IdpConfig findByDomainHint(TenantId tenantId, string emailDomain);
    void save(IdpConfig config);
    void update(IdpConfig config);
    void remove(string id);
}
