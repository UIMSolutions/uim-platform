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
ClientType toClientType(string value) {
    switch(value.toLower()) {
        case "confidential": return ClientType.confidential;
        case "public": return ClientType.public_;
        default: return ClientType.confidential; // default
    }
}
ClientType[] toClientType(string[] values) {
    return values.map!(toClientType).array;
}
string toString(ClientType value) {
    return value.to!string();
}
string[] toStrings(ClientType[] values) {
    return values.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("ClientType"));

    assert("confidential".toClientType == ClientType.confidential);
    assert("public".toClientType == ClientType.public_);

    assert("".toClientType == ClientType.confidential); // default
    assert("some".toClientType == ClientType.confidential); // default

    assert(ClientType.confidential.toString == "confidential");
    assert(ClientType.public_.toString == "public_");

    assert(["confidential", "public"].toClientType == [ClientType.confidential, ClientType.public_]);
    assert([ClientType.confidential, ClientType.public_].toStrings == ["confidential", "public_"]);
}

/// OAuth client status
enum ClientStatus {
    active,
    inactive,
    blocked
}
ClientStatus toClientStatus(string value) {
    mixin(EnumSwitch("ClientStatus", "active"));
}
ClientStatus[] toClientStatuses(string[] values) {
    return values.map!(toClientStatus).array;
}
string toString(ClientStatus value) {
    return value.to!string();
}
string[] toStrings(ClientStatus[] values) {
    return values.map!toString.array;
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
