module uim.platform.xyz.domain.entities.audit_event;

import uim.platform.xyz.domain.types;

/// Immutable audit log entry.
struct AuditEvent
{
    string id;
    TenantId tenantId;
    AuditEventType eventType;
    string actorId;     // user or client that performed the action
    string actorType;   // "User", "ApiClient", "System"
    string targetId;    // affected resource ID
    string targetType;  // "User", "Group", "Schema", etc.
    string description;
    string ipAddress;
    string userAgent;
    string[string] details;  // additional key-value metadata
    long timestamp;
}
