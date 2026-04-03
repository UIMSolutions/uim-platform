module uim.platform.master_data_integration.domain.entities.data_model;

import uim.platform.master_data_integration.domain.types;

/// Defines the schema/structure of a master data entity type.
struct DataModel
{
    DataModelId id;
    TenantId tenantId;
    string name;                    // e.g. "BusinessPartner", "CostCenter"
    string namespace;               // e.g. "sap.odm.businesspartner"
    string version_;                // e.g. "2.0.0"
    string description;
    MasterDataCategory category = MasterDataCategory.businessPartner;

    FieldDefinition[] fields;
    string[] keyFields;             // Fields that form the primary key
    string[] requiredFields;

    bool isActive;
    string createdBy;
    long createdAt;
    long modifiedAt;
}

/// A field definition within a data model.
struct FieldDefinition
{
    string name;
    string displayName;
    FieldType type_ = FieldType.string_;
    bool isRequired;
    bool isKey;
    string defaultValue;
    int maxLength;
    string referenceModel;          // For reference fields
    string description;
}
