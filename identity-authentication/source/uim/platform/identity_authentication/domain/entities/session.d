module uim.platform.identity_authentication.domain.entities.session;

// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
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
