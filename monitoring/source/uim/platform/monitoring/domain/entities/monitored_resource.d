module uim.platform.xyz.domain.entities.monitored_resource;

import uim.platform.xyz.domain.types;

/// A monitored application, database system, or service on SAP BTP.
struct MonitoredResource
{
    MonitoredResourceId id;
    TenantId tenantId;
    SubaccountId subaccountId;
    string name;
    string description;
    ResourceType resourceType = ResourceType.javaApplication;
    ResourceState state = ResourceState.unknown;
    string url;
    string runtime;
    string region;
    int instanceCount;
    string[] tags;
    string registeredBy;
    long registeredAt;
    long lastSeenAt;
}
