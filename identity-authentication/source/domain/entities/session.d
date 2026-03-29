module domain.entities.session;

import domain.types;

/// Authenticated session.
struct Session {
    SessionId id;
    UserId userId;
    TenantId tenantId;
    ApplicationId applicationId;
    AuthMethod authMethod;
    MfaType mfaUsed = MfaType.none;
    string ipAddress;
    string userAgent;
    RiskLevel riskLevel = RiskLevel.low;
    long createdAt;
    long expiresAt;
    bool revoked;
}
