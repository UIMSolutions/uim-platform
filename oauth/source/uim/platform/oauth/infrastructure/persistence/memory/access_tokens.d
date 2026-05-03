/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.access_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryAccessTokenRepository : TenantRepository!(AccessToken, AccessTokenId), AccessTokenRepository {

    bool existsByTokenValue(string tokenValue) {
        foreach (e; findAll)
            if (e.tokenValue == tokenValue)
                return true;
        return false;
    }

    AccessToken findByTokenValue(string tokenValue) {
        foreach (e; findAll)
            if (e.tokenValue == tokenValue)
                return e;
        return AccessToken.init;
    }

    size_t countByClientId(string clientId) {
        return findByClientId(clientId).length;
    }

    AccessToken[] filterByClientId(AccessToken[] tokens, string clientId) {
        return tokens.filter!(e => e.clientId == clientId).array;
    }

    AccessToken[] findByClientId(string clientId) {
        return findAll().filter!(e => e.clientId == clientId).array;
    }

    void removeByClientId(string clientId) {
        findByClientId(clientId).each!(e => remove(e));
    }

    size_t countByUserId(string userId) {
        return findByUserId(userId).length;
    }

    AccessToken[] filterByUserId(AccessToken[] tokens, string userId) {
        return tokens.filter!(e => e.userId == userId).array;
    }

    AccessToken[] findByUserId(string userId) {
        return findAll().filter!(e => e.userId == userId).array;
    }

    void removeByUserId(string userId) {
        findByUserId(userId).each!(e => remove(e));
    }

    size_t countByStatus(TokenStatus status) {
        return findByStatus(status).length;
    }

    AccessToken[] filterByStatus(AccessToken[] tokens, TokenStatus status) {
        return tokens.filter!(e => e.status == status).array;
    }

    AccessToken[] findByStatus(TokenStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void removeByStatus(TokenStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

}
