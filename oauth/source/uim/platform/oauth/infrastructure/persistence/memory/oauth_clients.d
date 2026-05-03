/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.oauth_clients;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryOAuthClientRepository : TenantRepository!(OAuthClient, OAuthClientId), OAuthClientRepository {

    bool existsByClientId(string clientId) {
        return findAll().any!(e => e.clientId == clientId);
    }
    OAuthClient findByClientId(string clientId) {
        foreach (e; findAll)
            if (e.clientId == clientId) return e;
        return OAuthClient.init;
    }
    void removeByClientId(string clientId) {
        foreach (e; findAll)
            if (e.clientId == clientId) {
                remove(e);
                return;
            }
    }

    size_t countByStatus(ClientStatus status) {
        return findByStatus(status).length;
    }
    OAuthClient[] findByStatus(ClientStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }
    void removeByStatus(ClientStatus status) {
        findByStatus(status).each!(e => remove(e.id));
    }

}
