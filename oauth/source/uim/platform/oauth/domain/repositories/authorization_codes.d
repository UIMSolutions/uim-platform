/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.repositories.authorization_codes;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

interface AuthorizationCodeRepository : ITenantRepository!(AuthorizationCode, AuthorizationCodeId) {

    bool existsByCode(string code);
    AuthorizationCode findByCode(string code);
    void removeByCode(string code);

    size_t countByClientId(string clientId);
    AuthorizationCode[] findByClientId(string clientId);
    void removeByClientId(string clientId);

    size_t countByStatus(AuthCodeStatus status);
    AuthorizationCode[] findByStatus(AuthCodeStatus status);
    void removeByStatus(AuthCodeStatus status);

}
