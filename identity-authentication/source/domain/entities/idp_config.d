module uim.platform.identity_authentication.domain.entities.idp_config;

import uim.platform.identity_authentication.domain.types;

/// External Identity Provider configuration for delegated authentication.
struct IdpConfig
{
    string id;
    TenantId tenantId;
    string name;
    IdpType idpType;
    string metadataUrl;
    string authorizationEndpoint;
    string tokenEndpoint;
    string userInfoEndpoint;
    string clientId;
    string clientSecret;
    string[] domainHints; // email domains that route to this IdP
    bool isDefault;
    bool active = true;
    long createdAt;
    long updatedAt;
}
