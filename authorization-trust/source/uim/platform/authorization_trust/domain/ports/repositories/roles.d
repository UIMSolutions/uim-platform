/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.ports.repositories.roles;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

interface RoleRepository {
  bool       existsById(RoleId id);
  RoleEntity findById(RoleId id);

  bool       existsByName(string name, string appId);
  RoleEntity findByName(string name, string appId);

  RoleEntity[] findAll();
  RoleEntity[] findByAppId(string appId);

  void save(RoleEntity role);
  void update(RoleEntity role);
  void remove(RoleId id);

  size_t count();
}
