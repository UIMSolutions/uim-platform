module uim.platform.xyz.domain.entities.auth_token;

import uim.platform.xyz.domain.types;

/// A resolved authentication token for a destination.
struct AuthToken
{
    string type_;           // "Bearer", "Basic", "SAML", etc.
    string value_;          // the actual token or encoded credentials
    long expiresAt;
    TokenStatus status = TokenStatus.valid;
    string httpHeaderSuggestion;  // e.g. "Authorization"
    string error;
}
