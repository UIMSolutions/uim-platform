/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.infrastructure.persistence.memory.oauth_clients;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class MemoryOAuthClientRepository : TenantRepository!(OAuthClient, OAuthClientId), OAuthClientRepository {
  
  size_t countByApp(TenantId tenantId, string appId) {
    return filterByApp(findByTenant(tenantId), appId).length;
  }
  OAuthClient[] filterByApp(OAuthClient[] clients, string appId) {
    return clients.filter!(c => c.appId == appId).array;
  }
  OAuthClient[] findByApp(TenantId tenantId, string  appId) {
    return filterByApp(findByTenant(tenantId), appId);
  }
  void removeByApp(TenantId tenantId, string appId) {
    findByApp(tenantId, appId).each!(c => remove(c));
  }
}
