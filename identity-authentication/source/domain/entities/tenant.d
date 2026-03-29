module domain.entities.tenant;

import domain.types;

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
