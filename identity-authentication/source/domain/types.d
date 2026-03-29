module domain.types;

/// Unique identifier type alias for type safety.
alias UserId = string;
alias GroupId = string;
alias TenantId = string;
alias ApplicationId = string;
alias PolicyId = string;
alias SessionId = string;
alias TokenId = string;

/// Authentication method supported by the platform.
enum AuthMethod
{
    form,
    spnego,
    social,
    certificate,
    saml,
    oidc,
    apiKey,
}

/// Multi-factor authentication type.
enum MfaType
{
    none,
    totp,
    sms,
    email,
}

/// SSO protocol.
enum SsoProtocol
{
    saml2,
    oidc,
}

/// User status in the identity directory.
enum UserStatus
{
    active,
    inactive,
    locked,
    pendingVerification,
}

/// Risk level determined by risk-based authentication.
enum RiskLevel
{
    low,
    medium,
    high,
    critical,
}

/// Token type.
enum TokenType
{
    access,
    refresh,
    idToken,
    samlAssertion,
}

/// Provisioning job status.
enum JobStatus
{
    pending,
    running,
    completed,
    failed,
}

/// Identity provider type for delegation.
enum IdpType
{
    local,
    saml,
    oidc,
    ldap,
    corporate,
}
