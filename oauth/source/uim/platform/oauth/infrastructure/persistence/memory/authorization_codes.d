/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.authorization_codes;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryAuthorizationCodeRepository : TenantRepository!(AuthorizationCode, AuthorizationCodeId), AuthorizationCodeRepository {

    bool existsByCode(string code) {
        return findByCode(code).id != AuthorizationCodeId.init;
    }
    AuthorizationCode findByCode(string code) {
        foreach (e; findAll)
            if (e.code == code) return e;
        return AuthorizationCode.init;
    }
    void removeByCode(string code) {
        import std.algorithm : remove;
        store = store.remove!(e => e.code == code);
    }

    // #region ByClientId
    size_t countByClientId(string clientId) {
        return findByClientId(clientId).length;
    }
    AuthorizationCode[] findByClientId(string clientId) {
        return findAll().filter!(e => e.clientId == clientId).array;
    }
    void removeByClientId(string clientId) {
        findByClientId(clientId).each!(e => remove(e));
    }
    // #endregion ByClientId

    // #region ByStatus
    size_t countByStatus(AuthCodeStatus status) {
        return findByStatus(status).length;
    }
    AuthorizationCode[] findByStatus(AuthCodeStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }
    void removeByStatus(AuthCodeStatus status) {
        findByStatus(status).each!(e => remove(e));
    }
    // #endregion ByStatus

}
