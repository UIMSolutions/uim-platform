/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.entities.authorization_code;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct AuthorizationCode {
    mixin TenantEntity!(AuthorizationCodeId);

    string code;
    string clientId;
    string userId;
    string redirectUri;
    string scopes;
    AuthCodeStatus status = AuthCodeStatus.active;
    long expiresAt;
    string issuedAt;

    Json toJson() const {
        return entityToJson
            .set("code", code)
            .set("clientId", clientId)
            .set("userId", userId)
            .set("redirectUri", redirectUri)
            .set("scopes", scopes)
            .set("status", status.toString())
            .set("expiresAt", expiresAt)
            .set("issuedAt", issuedAt);
    }
}
