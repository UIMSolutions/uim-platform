module uim.platform.identity_authentication.domain.entities.application;

import uim.platform.identity_authentication.domain.types;

/// Application (Service Provider) registered for SSO.
struct Application
{
    ApplicationId id;
    TenantId tenantId;
    string name;
    string description;
    SsoProtocol protocol = SsoProtocol.oidc;
    string clientId;
    string clientSecret;
    string[] redirectUris;
    string[] allowedScopes;
    string samlEntityId;
    string samlAcsUrl;
    string samlMetadataUrl;
    bool active = true;
    long createdAt;
    long updatedAt;
}
