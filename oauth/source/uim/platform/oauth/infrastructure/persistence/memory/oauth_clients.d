/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.repositories.oauth_clients;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryOAuthClientRepository : TenantRepository!(OAuthClient, OAuthClientId), OAuthClientRepository {

    // #region ByClient
    bool existsByClient(TenantId tenantId, string clientId) {
        return findByClient(tenantId, clientId).id != OAuthClientId.init;
    }
    OAuthClient findByClient(TenantId tenantId, string clientId) {
        foreach (e; findByTenant(tenantId))
            if (e.clientId == clientId) return e;
        return OAuthClient.init;
    }
    void removeByClient(TenantId tenantId, string clientId) {
        foreach (e; findByTenant(tenantId))
            if (e.clientId == clientId) {
                remove(e);
                return;
            }
    }
    // #endregion ByClient

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, ClientStatus status) {
        return findByStatus(tenantId, status).length;
    }

    OAuthClient[] filterByStatus(OAuthClient[] clients, ClientStatus status) {
        return clients.filter!(e => e.status == status).array;
    }

    OAuthClient[] findByStatus(TenantId tenantId, ClientStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, ClientStatus status) {
        findByStatus(tenantId, status).each!(entity => remove(entity));
    }
    // #endregion ByStatus

}
