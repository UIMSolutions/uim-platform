module uim.platform.auditlog.domain.entities.config_change_log;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_log_entry : AuditAttribute;

import uim.platform.auditlog;
mixin(ShowModule!());
/// Tracks security-critical configuration changes.
@safe:
struct ConfigChangeLog {
    AuditLogId auditLogId; // references parent audit entry
    TenantId tenantId;
    UserId changedBy;
    string configType; // e.g., "security_policy", "idp_settings", "role_mapping"
    string configObjectId;
    AuditAttribute[] changes; // old/new value pairs
    string reason; // change justification
    long timestamp;
}
