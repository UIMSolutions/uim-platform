module uim.platform.xyz.domain.entities.kyma_module;

import uim.platform.xyz.domain.types;

/// A Kyma module — an optional component that can be enabled/disabled.
struct KymaModule
{
    ModuleId id;
    KymaEnvironmentId environmentId;
    TenantId tenantId;
    string name;
    string description;
    ModuleType moduleType = ModuleType.custom;
    ModuleStatus status = ModuleStatus.disabled;

    // Version info
    string version_;
    string channel;

    // Custom resource definition
    string customResourcePolicy;
    string configurationJson;

    // Dependencies — other modules that must be enabled
    string[] requiredModules;

    // Metadata
    string enabledBy;
    long enabledAt;
    long modifiedAt;
}
