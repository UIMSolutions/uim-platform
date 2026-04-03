module uim.platform.xyz.domain.entities.api_client;

import uim.platform.xyz.domain.types;

/// API client / technical user for service-to-service access.
struct ApiClient
{
    ApiClientId id;
    TenantId tenantId;
    string name;
    string description;
    string clientId;
    string clientSecret;
    string[] scopes;
    bool active = true;
    long createdAt;
    long expiresAt;     // 0 = no expiry
    long lastUsedAt;

    bool isExpired(long now) const
    {
        return expiresAt > 0 && now > expiresAt;
    }
}
