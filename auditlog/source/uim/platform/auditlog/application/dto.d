module application.dto;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.audit_log_entry : AuditAttribute;

// ──────────────── Audit Log Entry DTOs ────────────────

struct WriteAuditLogRequest
{
    TenantId tenantId;
    UserId userId;
    string userName;
    ServiceId serviceId;
    string serviceName;
    AuditCategory category;
    AuditSeverity severity;
    AuditAction action;
    AuditOutcome outcome;
    string objectType;
    string objectId;
    string message;
    AuditAttribute[] attributes;
    string ipAddress;
    string userAgent;
    string correlationId;
    string originApp;
}

struct AuditLogQueryRequest
{
    TenantId tenantId;
    AuditCategory[] categories;
    long timeFrom;
    long timeTo;
    int limit = 500;    // SAP default page size
    int offset;
}

// ──────────────── Retention Policy DTOs ────────────────

struct CreateRetentionPolicyRequest
{
    TenantId tenantId;
    string name;
    string description;
    int retentionDays;
    AuditCategory[] categories;
    bool isDefault;
}

struct UpdateRetentionPolicyRequest
{
    RetentionPolicyId id;
    TenantId tenantId;
    string name;
    string description;
    int retentionDays;
    AuditCategory[] categories;
    RetentionStatus status;
}

// ──────────────── Audit Config DTOs ────────────────

struct CreateAuditConfigRequest
{
    TenantId tenantId;
    string name;
    bool logDataAccess;
    bool logDataModification;
    bool logSecurityEvents;
    bool logConfigurationChanges;
    bool enableDataMasking;
    string[] maskedFields;
    string[] excludedServices;
    AuditSeverity minimumSeverity;
    int rateLimitPerSecond;
}

struct UpdateAuditConfigRequest
{
    AuditConfigId id;
    TenantId tenantId;
    string name;
    ConfigStatus status;
    bool logDataAccess;
    bool logDataModification;
    bool logSecurityEvents;
    bool logConfigurationChanges;
    bool enableDataMasking;
    string[] maskedFields;
    string[] excludedServices;
    AuditSeverity minimumSeverity;
    int rateLimitPerSecond;
}

// ──────────────── Export Job DTOs ────────────────

struct CreateExportJobRequest
{
    TenantId tenantId;
    UserId requestedBy;
    ExportFormat format_;
    AuditCategory[] categories;
    long timeFrom;
    long timeTo;
}

// ──────────────── Security Event DTOs ────────────────

struct WriteSecurityEventRequest
{
    TenantId tenantId;
    UserId userId;
    string userName;
    string eventType;
    string ipAddress;
    string userAgent;
    string clientId;
    string identityProvider;
    string authMethod;
    AuditOutcome outcome;
    string failureReason;
    string riskLevel;
}

// ──────────────── Data Access Log DTOs ────────────────

struct WriteDataAccessLogRequest
{
    TenantId tenantId;
    UserId accessedBy;
    string dataSubject;
    string dataObjectType;
    string dataObjectId;
    string[] accessedFields;
    string purpose;
    string channel;
}

// ──────────────── Config Change Log DTOs ────────────────

struct WriteConfigChangeLogRequest
{
    TenantId tenantId;
    UserId changedBy;
    string configType;
    string configObjectId;
    AuditAttribute[] changes;
    string reason;
}

// ──────────────── Generic result ────────────────

struct CommandResult
{
    string id;
    string error;

    bool isSuccess() const
    {
        return error.length == 0;
    }
}
