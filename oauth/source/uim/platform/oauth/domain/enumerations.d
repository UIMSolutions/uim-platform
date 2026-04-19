/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.enumerations;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// OAuth client type
enum ClientType {
    confidential,
    public_
}

/// OAuth client status
enum ClientStatus {
    active,
    inactive,
    blocked
}

/// OAuth grant types
enum GrantType {
    authorizationCode,
    clientCredentials,
    refreshToken,
    implicit_
}

/// OAuth token type
enum TokenType {
    bearer
}

/// Access/refresh token status
enum TokenStatus {
    active,
    expired,
    revoked
}

/// OAuth scope status
enum ScopeStatus {
    active,
    inactive
}

/// Authorization code status
enum AuthCodeStatus {
    active,
    used,
    expired
}

/// Reason for token revocation
enum RevocationReason {
    manual,
    clientBlocked,
    userRevoked,
    securityBreach,
    expired
}

/// Branding element type
enum BrandingElement {
    logo,
    background,
    primaryColor,
    secondaryColor,
    pageTitle,
    footerText
}
