module uim.platform.xyz.domain.entities.service_binding;

import domain.types;

/// A service binding — connects a service instance to an application/function.
struct ServiceBinding
{
    ServiceBindingId id;
    ServiceInstanceId serviceInstanceId;
    NamespaceId namespaceId;
    KymaEnvironmentId environmentId;
    TenantId tenantId;
    string name;
    string description;
    ServiceBindingStatus status = ServiceBindingStatus.creating;

    // Secret reference
    string secretName;
    string secretNamespace;

    // Parameters
    string parametersJson;

    // Credentials (resolved)
    string[string] credentials;

    // Labels
    string[string] labels;

    // Metadata
    string createdBy;
    long createdAt;
    long modifiedAt;
}
