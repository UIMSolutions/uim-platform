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

    size_t countByClientId(string clientId);
    OAuthClient findByClientId(string clientId);
    void removeByClientId(string clientId);

    size_t countByStatus(ClientStatus status);
    OAuthClient[] findByStatus(ClientStatus status);
    void removeByStatus(ClientStatus status);

}
