module uim.platform.xyz.domain.entities.key_mapping;

import uim.platform.xyz.domain.types;

/// A key mapping entry — maps IDs across different systems.
struct KeyMapping
{
    KeyMappingId id;
    TenantId tenantId;
    MasterDataObjectId masterDataObjectId;
    MasterDataCategory category = MasterDataCategory.businessPartner;

    string objectType;              // e.g. "BusinessPartner"

    // Mapping pairs
    KeyMappingEntry[] entries;

    long createdAt;
    long modifiedAt;
}

/// A single system-to-key mapping entry.
struct KeyMappingEntry
{
    ClientId clientId;
    string systemId;
    string localKey;
    KeyMappingSourceType sourceType = KeyMappingSourceType.local;
    bool isPrimary;
}
