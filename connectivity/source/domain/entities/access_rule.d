module domain.entities.access_rule;

import domain.types;

/// Access control rule for exposed on-premise backend resources.
struct AccessRule
{
    RuleId id;
    ConnectorId connectorId;
    TenantId tenantId;
    string description;
    AccessProtocol protocol = AccessProtocol.https;
    string virtualHost;
    ushort virtualPort;
    string urlPathPrefix;       // e.g., "/sap/opu/odata"
    AccessPolicy policy = AccessPolicy.allow;
    bool principalPropagation;  // allow user context forwarding
    long createdAt;
    long updatedAt;
}
