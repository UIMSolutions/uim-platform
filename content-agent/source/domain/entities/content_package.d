module uim.platform.content_agent.domain.entities.content_package;

import uim.platform.content_agent.domain.types;

/// A single content item within a package.
struct ContentItem
{
    string id;
    string name;
    ContentCategory category;
    ContentProviderId providerId;
    string version_;
    string description;
    string[] dependencies;
}

/// A package containing bundled content for transport across landscapes.
struct ContentPackage
{
    ContentPackageId id;
    TenantId tenantId;
    SubaccountId subaccountId;
    string name;
    string description;
    string version_;
    PackageStatus status = PackageStatus.draft;
    ContentFormat format = ContentFormat.mtar;
    ContentItem[] items;
    string[] tags;
    string createdBy;
    long createdAt;
    long updatedAt;
    long assembledAt;
    long packageSizeBytes;
}
