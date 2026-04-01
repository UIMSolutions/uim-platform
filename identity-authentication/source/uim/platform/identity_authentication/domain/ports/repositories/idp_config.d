module uim.platform.identity_authentication.domain.ports.repositories.idp_config;

// import uim.platform.identity_authentication.domain.entities.idp_config;
// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Port: outgoing — external IdP configuration persistence.
interface IdpConfigRepository {
    IdpConfig findById(string id);
    IdpConfig findDefaultForTenant(TenantId tenantId);
    IdpConfig[] findByTenant(TenantId tenantId);
    IdpConfig findByDomainHint(TenantId tenantId, string emailDomain);
    void save(IdpConfig config);
    void update(IdpConfig config);
    void remove(string id);
}
