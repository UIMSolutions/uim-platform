/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.repositories.oauth_clients;

import uim.platform.oauth;
mixin(ShowModule!());

@safe:

interface OAuthClientRepository : ITenantRepository!(OAuthClient, OAuthClientId) {

    bool existsByClient(TenantId tenantId, string clientId);
    OAuthClient findByClient(TenantId tenantId, string clientId);
    void removeByClient(TenantId tenantId, string clientId);

    size_t countByStatus(TenantId tenantId, ClientStatus status);
    OAuthClient[] findByStatus(TenantId tenantId, ClientStatus status);
    void removeByStatus(TenantId tenantId, ClientStatus status);

}
