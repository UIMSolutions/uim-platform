module uim.platform.architecture.application.dto;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct CreateArchitectureBlockRequest {
    TenantId tenantId;
    ArchitectureBlockId blockId;

    string name;
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
}

struct UpdateArchitectureBlockRequest {
    TenantId tenantId;
    ArchitectureBlockId blockId;
    
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
}

struct CreateBusinessBlockRequest {
    TenantId tenantId;
    BusinessBlockId blockId;

    string name;
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
}

struct UpdateBusinessBlockRequest {
    TenantId tenantId;
    BusinessBlockId blockId;
    
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
}

struct CreateDataBlockRequest {
    TenantId tenantId;
    DataBlockId blockId;

    string name;
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
}

struct UpdateDataBlockRequest {
    TenantId tenantId;
    DataBlockId blockId;
    
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
}

struct CreateSolutionBlockRequest {
    TenantId tenantId;
    SolutionBlockId blockId;

    string name;
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
}

struct UpdateSolutionBlockRequest {
    TenantId tenantId;
    SolutionBlockId blockId;
    
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
}

struct CreateTechnologyBlockRequest {
    TenantId tenantId;
    TechnologyBlockId blockId;

    string name;
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
}

struct UpdateTechnologyBlockRequest {
    TenantId tenantId;
    TechnologyBlockId blockId;
    
    string description;
    string owner;
    string lifecycleState;
    string status;
    string versionLabel;
    string[] tags;
}