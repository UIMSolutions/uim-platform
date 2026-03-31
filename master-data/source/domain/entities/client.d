module domain.entities.client;

import domain.types;

/// A connected client system participating in master data integration.
struct Client
{
    ClientId id;
    TenantId tenantId;
    string name;
    string description;
    ClientType clientType = ClientType.sapS4Hana;
    ClientStatus status = ClientStatus.disconnected;

    // Connection details
    string systemUrl;
    string destinationName;         // SAP BTP destination reference
    string communicationArrangement;

    // Capabilities
    MasterDataCategory[] supportedCategories;
    bool supportsInitialLoad;
    bool supportsDeltaReplication;
    bool supportsKeyMapping;

    // Authentication
    string authType;                // "oauth2", "basic", "certificate"
    string clientIdRef;             // Reference to credential store
    string certificateRef;

    // Metadata
    string createdBy;
    long createdAt;
    long modifiedAt;
    long lastSyncAt;
}
