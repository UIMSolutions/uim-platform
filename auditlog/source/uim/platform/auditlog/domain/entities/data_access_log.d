module domain.entities.data_access_log;

import domain.types;

/// Tracks read-access to sensitive / personal data.
struct DataAccessLog
{
    AuditLogId auditLogId;      // references parent audit entry
    TenantId tenantId;
    UserId accessedBy;
    string dataSubject;         // person whose data was accessed
    string dataObjectType;      // e.g., "user_profile", "payment_info"
    string dataObjectId;
    string[] accessedFields;    // specific fields read
    string purpose;             // business justification
    string channel;             // API, UI, batch, etc.
    long timestamp;
}
