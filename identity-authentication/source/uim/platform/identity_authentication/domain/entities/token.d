module uim.platform.identity_authentication.domain.entities.token;

// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Issued security token.
struct Token {
    TokenId id;
    UserId userId;
    TenantId tenantId;
    ApplicationId applicationId;
    TokenType tokenType;
    string tokenValue;
    string[] scopes;
    long issuedAt;
    long expiresAt;
    bool revoked;
}
