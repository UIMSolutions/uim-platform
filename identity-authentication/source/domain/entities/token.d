module domain.entities.token;

import domain.types;

/// Issued security token.
struct Token
{
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
