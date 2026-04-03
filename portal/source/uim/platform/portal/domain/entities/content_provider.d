module uim.platform.xyz.domain.entities.content_provider;

import uim.platform.xyz.domain.types;

/// Content provider — source of apps and content.
struct ContentProvider
{
    ProviderId id;
    TenantId tenantId;
    string name;
    string description;
    ProviderType providerType = ProviderType.local;
    string contentEndpointUrl;  // URL for federated/remote content
    string authToken;           // bearer token for remote providers
    bool active = true;
    CatalogId[] catalogIds;
    long createdAt;
    long updatedAt;
    long lastSyncedAt;
}
