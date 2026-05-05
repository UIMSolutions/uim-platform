/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.refresh_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryRefreshTokenRepository : TenantRepository!(RefreshToken, RefreshTokenId), RefreshTokenRepository {
    
    // #region ByTokenValue
    bool existsByTokenValue(string tokenValue) {
        return findByTokenValue(tokenValue).id != RefreshTokenId.init;
    }
    RefreshToken findByTokenValue(string tokenValue) {
        foreach (e; findAll)
            if (e.tokenValue == tokenValue) return e;
        return RefreshToken.init;
    }
    void removeByTokenValue(string tokenValue) {
        import std.algorithm : remove;
        store = store.remove!(e => e.tokenValue == tokenValue);
    }
    // #endregion ByTokenValue

    // #region ByClientId
    size_t countByClientId(string clientId) {
        return findByClientId(clientId).length;
    }
    RefreshToken[] findByClientId(string clientId) {
        return findAll().filter!(e => e.clientId == clientId).array;
    }
    void removeByClientId(string clientId) {
        findByClientId(clientId).each!(e => remove(e));
    }
    // #endregion ByClientId

    // #region ByStatus
    size_t countByStatus(TokenStatus status) {
        return findByStatus(status).length;
    }
    RefreshToken[] findByStatus(TokenStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }
    void removeByStatus(TokenStatus status) {
        findByStatus(status).each!(e => remove(e));
    }
    // #endregion ByStatus

}
