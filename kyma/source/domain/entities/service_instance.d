module domain.entities.service_instance;

import domain.types;

/// A service instance provisioned from the BTP service catalog.
struct ServiceInstance
{
    ServiceInstanceId id;
    NamespaceId namespaceId;
    KymaEnvironmentId environmentId;
    TenantId tenantId;
    string name;
    string description;
    ServiceInstanceStatus status = ServiceInstanceStatus.creating;

    // Service catalog reference
    string serviceOfferingName;
    string servicePlanName;
    string servicePlanId;
    string externalName;

    // Parameters
    string parametersJson;

    // Labels and annotations
    string[string] labels;

    // Binding count
    int bindingCount;

    // Metadata
    string createdBy;
    long createdAt;
    long modifiedAt;
}
