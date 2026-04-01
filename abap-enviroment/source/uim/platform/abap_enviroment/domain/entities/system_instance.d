module uim.platform.abap_enviroment.domain.entities.system_instance;

import uim.platform.abap_enviroment.domain.types;

/// Provisioned ABAP Cloud system instance.
struct SystemInstance
{
    SystemInstanceId id;
    TenantId tenantId;
    SubaccountId subaccountId;
    string name;
    string description;
    SystemPlan plan = SystemPlan.standard;
    SystemStatus status = SystemStatus.provisioning;

    /// Runtime parameters
    string region;
    string sapSystemId;       // 3-char SID
    string adminEmail;
    ushort abapRuntimeSize;   // in GB
    ushort hanaMemorySize;    // in GB

    /// Connectivity
    string serviceUrl;
    string webSocketUrl;
    string sapClient;

    /// Software stack
    string softwareVersion;
    string stackVersion;

    /// Metadata
    string createdBy;
    long createdAt;
    long updatedAt;
}
