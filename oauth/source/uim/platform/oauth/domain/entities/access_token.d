/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.entities.access_token;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct AccessToken {
    mixin TenantEntity!(AccessTokenId);

    string tokenValue;
    TokenType tokenType = TokenType.bearer;
    TokenStatus status = TokenStatus.active;
    string clientId;
    string userId;
    string scopes;
    long expiresAt;
    string issuedAt;

    Json toJson() const {
        return entityToJson
            .set("tokenValue", tokenValue)
            .set("tokenType", tokenType.toString())
            .set("status", status.toString())
            .set("clientId", clientId)
            .set("userId", userId)
            .set("scopes", scopes)
            .set("expiresAt", expiresAt)
            .set("issuedAt", issuedAt);
    }
}
