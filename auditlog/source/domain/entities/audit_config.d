module domain.entities.audit_config;

import domain.types;

/// Tenant-level audit logging configuration.
struct AuditConfig
{
    AuditConfigId id;
    TenantId tenantId;
    string name;
    ConfigStatus status = ConfigStatus.enabled;
    bool logDataAccess = true;
    bool logDataModification = true;
    bool logSecurityEvents = true;
    bool logConfigurationChanges = true;
    bool enableDataMasking;         // mask sensitive fields
    string[] maskedFields;          // field names to mask
    string[] excludedServices;      // services exempt from logging
    AuditSeverity minimumSeverity = AuditSeverity.info;
    int rateLimitPerSecond = 8;     // per-tenant rate limit
    long createdAt;
    long updatedAt;
}
