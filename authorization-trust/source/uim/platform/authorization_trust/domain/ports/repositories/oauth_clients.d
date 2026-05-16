/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.ports.repositories.oauth_clients;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

interface OAuthClientRepository : ITenantRepository!(OAuthClientEntity, OAuthClientId) {

  bool existsByClientId(TenantId tenantId, string clientId);
  OAuthClientEntity findByClientId(TenantId tenantId, string clientId);
  void removeByClientId(TenantId tenantId, string clientId);

  size_t countByAppId(TenantId tenantId, string appId);
  OAuthClientEntity[] findByAppId(TenantId tenantId, string appId);
  void removeByAppId(TenantId tenantId, string appId);

}
