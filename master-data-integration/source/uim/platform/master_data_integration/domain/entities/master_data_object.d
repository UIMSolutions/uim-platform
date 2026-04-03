module uim.platform.xyz.domain.entities.master_data_object;

import uim.platform.xyz.domain.types;

/// A master data record — the core entity managed by MDI.
struct MasterDataObject
{
    MasterDataObjectId id;
    TenantId tenantId;
    DataModelId dataModelId;
    MasterDataCategory category = MasterDataCategory.businessPartner;
    RecordStatus status = RecordStatus.active;

    string objectType;          // e.g. "sap.odm.businesspartner.BusinessPartner"
    string displayName;
    string description;

    // Versioning
    VersionId currentVersion;
    long versionNumber;

    // Key fields
    string localId;             // ID in the source system
    string globalId;            // Globally unique / canonical ID

    // Payload as key-value (simplified; real MDI uses deep structures)
    string[string] attributes;

    // Source system tracking
    string sourceSystem;
    string sourceClient;

    // Metadata
    string createdBy;
    long createdAt;
    long modifiedAt;
    string modifiedBy;
}
