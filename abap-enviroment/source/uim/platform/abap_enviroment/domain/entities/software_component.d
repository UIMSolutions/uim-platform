module uim.platform.abap_enviroment.domain.entities.software_component;

import uim.platform.abap_enviroment.domain.types;

/// Commit entry in a software component's history.
struct ComponentCommit
{
    string commitId;
    string message;
    string author;
    long timestamp;
}

/// ABAP software component (git-managed development object container).
struct SoftwareComponent
{
    SoftwareComponentId id;
    TenantId tenantId;
    SystemInstanceId systemInstanceId;
    string name;
    string description;
    ComponentType componentType = ComponentType.developmentPackage;
    ComponentStatus status = ComponentStatus.notCloned;

    /// Repository information
    string repositoryUrl;
    string branch;
    BranchStrategy branchStrategy = BranchStrategy.main;
    string currentCommitId;
    ComponentCommit[] commitHistory;

    /// Namespace
    string namespace;
    string softwareComponentVersion;

    /// Metadata
    string clonedBy;
    long clonedAt;
    long lastPulledAt;
    long createdAt;
    long updatedAt;
}
