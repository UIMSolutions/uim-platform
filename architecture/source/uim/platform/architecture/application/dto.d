module uim.platform.architecture.application.dto;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct ArchiMateRelationshipRequest {
    string relationshipType;
    string targetBlockId;
    string description;
}

struct CreateArchitectureBlockRequest {
    TenantId tenantId;
    ArchitectureBlockId blockId;

    string title;
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
    string capabilityProvided;
    string[] requiredInterfaces;
    bool lastVersion;
    long validDate;
    string archimateDomain;
    string archimateAspect;
    string viewpoint;
    ArchiMateRelationshipRequest[] relationships;
}

struct UpdateArchitectureBlockRequest {
    TenantId tenantId;
    ArchitectureBlockId blockId;
    
    string title;
    string description;
    string productId;
    string moduleId;
    string serviceId;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
    string capabilityProvided;
    string[] requiredInterfaces;
    bool lastVersion;
    long validDate;
    string archimateDomain;
    string archimateAspect;
    string viewpoint;
    ArchiMateRelationshipRequest[] relationships;
}

struct CreateBusinessBlockRequest {
    TenantId tenantId;
    BusinessBlockId blockId;

    string title;
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
    string archimateDomain;
    string archimateAspect;
    string viewpoint;
    ArchiMateRelationshipRequest[] relationships;
}

struct UpdateBusinessBlockRequest {
    TenantId tenantId;
    BusinessBlockId blockId;
    
    string title;
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
    string archimateDomain;
    string archimateAspect;
    string viewpoint;
    ArchiMateRelationshipRequest[] relationships;
}

struct CreateDataBlockRequest {
    TenantId tenantId;
    DataBlockId blockId;

    string title;
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
    string dataOwner;
    string dataClassification;
    string leanixObjectType;
    string leanixFactSheetId;
    string sourceSystem;
    string archimateDomain;
    string archimateAspect;
    string viewpoint;
    ArchiMateRelationshipRequest[] relationships;
}

struct UpdateDataBlockRequest {
    TenantId tenantId;
    DataBlockId blockId;
    
    string title;
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
    string dataOwner;
    string dataClassification;
    string leanixObjectType;
    string leanixFactSheetId;
    string sourceSystem;
    string archimateDomain;
    string archimateAspect;
    string viewpoint;
    ArchiMateRelationshipRequest[] relationships;
}

struct CreateSolutionBlockRequest {
    TenantId tenantId;
    SolutionBlockId blockId;

    string title;
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
    string mappedAbbId;
    string vendorOrComponent;
    string deploymentEndpoint;
    string leanixObjectType;
    string leanixFactSheetId;
    string providerApplicationId;
    string consumerApplicationId;
    string archimateDomain;
    string archimateAspect;
    string viewpoint;
    ArchiMateRelationshipRequest[] relationships;
}

struct UpdateSolutionBlockRequest {
    TenantId tenantId;
    SolutionBlockId blockId;
    
    string title;
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
    string mappedAbbId;
    string vendorOrComponent;
    string deploymentEndpoint;
    string leanixObjectType;
    string leanixFactSheetId;
    string providerApplicationId;
    string consumerApplicationId;
    string archimateDomain;
    string archimateAspect;
    string viewpoint;
    ArchiMateRelationshipRequest[] relationships;
}

struct CreateTechnologyBlockRequest {
    TenantId tenantId;
    TechnologyBlockId blockId;

    string title;
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
    string archimateDomain;
    string archimateAspect;
    string viewpoint;
    ArchiMateRelationshipRequest[] relationships;
}

struct UpdateTechnologyBlockRequest {
    TenantId tenantId;
    TechnologyBlockId blockId;
    
    string title;
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
    string archimateDomain;
    string archimateAspect;
    string viewpoint;
    ArchiMateRelationshipRequest[] relationships;
}