module domain.entities.namespace;

import domain.types;

/// A Kubernetes namespace within a Kyma environment.
struct Namespace
{
    NamespaceId id;
    KymaEnvironmentId environmentId;
    TenantId tenantId;
    string name;
    string description;
    NamespaceStatus status = NamespaceStatus.active;

    // Resource quotas
    string cpuLimit;
    string memoryLimit;
    string cpuRequest;
    string memoryRequest;
    int podLimit;
    QuotaEnforcement quotaEnforcement = QuotaEnforcement.enforce;

    // Labels and annotations
    string[string] labels;
    string[string] annotations;

    // Istio sidecar injection
    bool istioInjection = true;

    // Metadata
    string createdBy;
    long createdAt;
    long modifiedAt;
}
