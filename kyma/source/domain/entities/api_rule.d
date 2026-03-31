module domain.entities.api_rule;

import domain.types;

/// An API rule — exposes a service or function via the API Gateway.
struct ApiRule
{
    ApiRuleId id;
    NamespaceId namespaceId;
    KymaEnvironmentId environmentId;
    TenantId tenantId;
    string name;
    string description;
    ApiRuleStatus status = ApiRuleStatus.notReady;

    // Service reference
    string serviceName;
    int servicePort;

    // Gateway
    string gateway;
    string host;

    // Rules (access strategies per path)
    ApiRuleEntry[] rules;

    // TLS
    bool tlsEnabled = true;
    string tlsSecretName;

    // CORS
    bool corsEnabled;
    string[] corsAllowOrigins;
    string[] corsAllowMethods;
    string[] corsAllowHeaders;

    // Labels
    string[string] labels;

    // Metadata
    string createdBy;
    long createdAt;
    long modifiedAt;
}

/// A single rule entry within an API rule.
struct ApiRuleEntry
{
    string path;
    ApiHttpMethod[] methods;
    AccessStrategy accessStrategy = AccessStrategy.noAuth;
    string[] requiredScopes;
    string[] audiences;
    string[] trustedIssuers;
}
