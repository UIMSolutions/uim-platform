/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.ports.repositories.oauth_clients;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:

interface OAuthClientRepository : ITentRepository!(OAuthClient, OAuthClientId) {

  size_t countByApp(TenantId tenantId, string appId);
  OAuthClient[] findByApp(TenantId tenantId, string appId);
  void removeByApp(TenantId tenantId, string appId);

}
