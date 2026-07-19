module uim.platform.auditlog.application.dtos.securityevent;
import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
struct WriteSecurityEventRequest {
    TenantId tenantId; // Required for multi-tenant context
    UserId userId; // Identity user ID (from Identity Authentication)

    string userName; // Optional: can be used for display purposes, but should not be used as a unique identifier
    string eventType; // e.g., "UserLogin", "UserLogout", "PasswordChange", etc.
    string ipAddress; // Optional: IP address from which the event originated
    string userAgent;   // Optional: User agent string of the client used for the event
    string clientId;    // Optional: Client application ID involved in the event, if applicable
    string identityProvider; // Optional: Identity provider used for authentication, if applicable
    string authMethod; // Optional: Authentication method used (e.g., "Password", "MFA", "OAuth2", etc.)
    AuditOutcome outcome; // e.g., "Success", "Failure", "Unknown"
    string failureReason; // Optional: Reason for failure if outcome is "Failure"
    string riskLevel; // Optional: Risk level associated with the event (e.g., "Low", "Medium", "High")
    // 
    string correlationId; // Optional: Correlation ID for tracing related events across systems
    long timestamp; // Event timestamp in milliseconds since epoch
    string additionalData; // Optional: Any additional data or context related to the event, stored as a JSON string or key-value pairs

    // Json toJson() const {
    //     return Json.emptyObject
    //         .set("tenantId", tenantId.value)
    //         .set("userId", userId)
    //         .set("userName", userName)
    //         .set("eventType", eventType)
    //         .set("ipAddress", ipAddress)
    //         .set("userAgent", userAgent)
    //         .set("clientId", clientId)
    //         .set("identityProvider", identityProvider)
    //         .set("authMethod", authMethod)
    //         .set("outcome", outcome.to!string)
    //         .set("failureReason", failureReason)
    //         .set("riskLevel", riskLevel)
    //         .set("correlationId", correlationId)
    //         .set("timestamp", timestamp)
    //         .set("additionalData", additionalData);
    // }
}
