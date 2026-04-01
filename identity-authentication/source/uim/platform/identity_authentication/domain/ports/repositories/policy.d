module uim.platform.identity_authentication.domain.ports.repositories.policy;

// import uim.platform.identity_authentication.domain.entities.policy;
// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Port: outgoing — authorization policy persistence.
interface PolicyRepository {
    AuthorizationPolicy findById(PolicyId id);
    AuthorizationPolicy[] findByTenant(TenantId tenantId);
    AuthorizationPolicy[] findByApplication(ApplicationId appId);
    void save(AuthorizationPolicy policy);
    void update(AuthorizationPolicy policy);
    void remove(PolicyId id);
}
