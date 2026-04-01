module uim.platform.identity_authentication.domain.entities.tenant;

// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Tenant represents an isolated identity namespace.
struct Tenant {
    TenantId id;
    string name;
    string subdomain;
    SsoProtocol defaultSsoProtocol = SsoProtocol.oidc;
    AuthMethod[] allowedAuthMethods;
    bool mfaEnforced;
    string[] trustedIdpIds;
    long createdAt;
    long updatedAt;
}
