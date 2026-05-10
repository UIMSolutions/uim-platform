/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.ports.repositories.scopes;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

interface ScopeRepository {
  bool        existsById(ScopeId id);
  ScopeEntity findById(ScopeId id);

  bool        existsByName(string name);
  ScopeEntity findByName(string name);

  ScopeEntity[] findAll();
  ScopeEntity[] findByAppId(string appId);

  void save(ScopeEntity scope_);
  void update(ScopeEntity scope_);
  void remove(ScopeId id);

  size_t count();
}
