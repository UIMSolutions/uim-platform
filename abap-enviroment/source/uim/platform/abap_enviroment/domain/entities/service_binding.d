module domain.entities.service_binding;

import domain.types;

/// Exposed service endpoint from a binding.
struct ExposedEndpoint
{
    string path;
    string serviceName;
    string serviceVersion;
    bool requiresAuth = true;
}

/// Service binding that exposes CDS/RAP services via OData/REST/SOAP.
struct ServiceBinding
{
    ServiceBindingId id;
    TenantId tenantId;
    SystemInstanceId systemInstanceId;
    ServiceDefinitionId serviceDefinitionId;
    string name;
    string description;

    BindingType bindingType = BindingType.odataV4;
    BindingStatus status = BindingStatus.active;

    /// Exposed endpoints
    ExposedEndpoint[] endpoints;

    /// Runtime URL
    string serviceUrl;
    string metadataUrl;

    /// Metadata
    string createdBy;
    long createdAt;
    long updatedAt;
}
