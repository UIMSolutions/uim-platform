/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.repositories.refresh_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

interface RefreshTokenRepository : ITenantRepository!(RefreshToken, RefreshTokenId) {

    bool existsByTokenValue(string tokenValue);
    RefreshToken findByTokenValue(string tokenValue);
    void removeByTokenValue(string tokenValue);

    size_t countByClientId(string clientId);
    RefreshToken[] findByClientId(string clientId);
    void removeByClientId(string clientId);

    size_t countByStatus(TokenStatus status);
    RefreshToken[] findByStatus(TokenStatus status);
    void removeByStatus(TokenStatus status);

}
