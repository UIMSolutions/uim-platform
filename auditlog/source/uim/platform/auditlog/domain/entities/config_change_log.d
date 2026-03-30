module domain.entities.config_change_log;

import domain.types;

import domain.entities.audit_log_entry : AuditAttribute;

/// Tracks security-critical configuration changes.
struct ConfigChangeLog
{
    AuditLogId auditLogId;      // references parent audit entry
    TenantId tenantId;
    UserId changedBy;
    string configType;          // e.g., "security_policy", "idp_settings", "role_mapping"
    string configObjectId;
    AuditAttribute[] changes;   // old/new value pairs
    string reason;              // change justification
    long timestamp;
}
