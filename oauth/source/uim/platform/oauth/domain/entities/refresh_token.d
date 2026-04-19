/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.entities.refresh_token;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct RefreshToken {
    RefreshTokenId id;
    TenantId tenantId;
    string tokenValue;
    TokenStatus status = TokenStatus.active;
    string clientId;
    string userId;
    string scopes;
    string accessTokenId;
    long expiresAt;
    string issuedAt;
    string createdAt;

    Json refreshTokenToJson() {
        import std.conv : to;
        return Json.emptyObject
            .set("id", id.value)
            .set("tenantId", tenantId.value)
            .set("status", status.to!string)
            .set("clientId", clientId)
            .set("userId", userId)
            .set("scopes", scopes)
            .set("accessTokenId", accessTokenId)
            .set("expiresAt", expiresAt)
            .set("issuedAt", issuedAt)
            .set("createdAt", createdAt);
    }
}
