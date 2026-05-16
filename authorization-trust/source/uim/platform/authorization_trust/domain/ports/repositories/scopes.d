/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.ports.repositories.scopes;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

interface ScopeRepository : ITenantRepository!(ScopeEntity, ScopeId) {

  bool        existsByName(string name);
  ScopeEntity findByName(string name);
  void       removeByName(string name);

  size_t countByAppId(string appId);
  ScopeEntity[] findByAppId(string appId);
  void removeByAppId(string appId);

}
