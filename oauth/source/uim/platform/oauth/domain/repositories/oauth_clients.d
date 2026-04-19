/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.repositories.oauth_clients;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

interface OAuthClientRepository {
    bool existsById(OAuthClientId id);
    OAuthClient findById(OAuthClientId id);
    OAuthClient findByClientId(string clientId);
    OAuthClient[] findAll();
    OAuthClient[] findByTenant(TenantId tenantId);
    OAuthClient[] findByStatus(ClientStatus status);
    void save(OAuthClient entity);
    void update(OAuthClient entity);
    void remove(OAuthClientId id);
}
