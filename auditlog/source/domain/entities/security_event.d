module domain.entities.security_event;

import domain.types;

/// Enriched security event — login/logout, auth failures, privilege changes.
struct SecurityEvent
{
    AuditLogId auditLogId;      // references the parent audit entry
    TenantId tenantId;
    UserId userId;
    string userName;
    string eventType;           // e.g., "login", "loginFailed", "mfaChallenge"
    string ipAddress;
    string userAgent;
    string clientId;            // OAuth client id
    string identityProvider;
    string authMethod;          // e.g., "password", "mfa", "sso", "certificate"
    AuditOutcome outcome = AuditOutcome.success;
    string failureReason;
    string riskLevel;           // low, medium, high
    long timestamp;
}
