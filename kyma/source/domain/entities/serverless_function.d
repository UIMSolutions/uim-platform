module uim.platform.xyz.domain.entities.serverless_function;

import domain.types;

/// A serverless function deployed in a Kyma namespace.
struct ServerlessFunction
{
    FunctionId id;
    NamespaceId namespaceId;
    KymaEnvironmentId environmentId;
    TenantId tenantId;
    string name;
    string description;
    FunctionRuntime runtime = FunctionRuntime.nodejs20;
    FunctionStatus status = FunctionStatus.building;

    // Source code
    string sourceCode;
    string handler;
    string dependencies;

    // Scaling
    ScalingType scalingType = ScalingType.auto_;
    int minReplicas = 1;
    int maxReplicas = 5;

    // Resources
    string cpuRequest;
    string cpuLimit;
    string memoryRequest;
    string memoryLimit;

    // Environment variables
    string[string] envVars;

    // Labels
    string[string] labels;

    // Timeout in seconds
    int timeoutSeconds = 180;

    // Metadata
    string createdBy;
    long createdAt;
    long modifiedAt;
}
