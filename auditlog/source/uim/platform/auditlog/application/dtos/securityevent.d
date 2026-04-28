module uim.platform.auditlog.application.dtos.securityevent;
import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
struct WriteSecurityEventRequest {
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
