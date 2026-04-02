module uim.platform.content_agent.domain.entities.content_provider;

import domain.types;

/// Describes a content type offered by a provider.
struct ProvidedContentType
{
    ContentTypeId typeId;
    string name;
    ContentCategory category;
    string description;
    string version_;
}

/// A registered content provider from which content can be discovered and assembled.
struct ContentProvider
{
    ContentProviderId id;
    TenantId tenantId;
    string name;
    string description;
    string endpoint;
    string authToken;
    ProviderStatus status = ProviderStatus.active;
    ProvidedContentType[] contentTypes;
    string createdBy;
    long registeredAt;
    long lastSyncAt;
}
