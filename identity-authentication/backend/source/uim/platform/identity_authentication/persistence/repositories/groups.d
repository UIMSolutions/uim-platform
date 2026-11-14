/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.repositories.groups;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class GroupRepository : TenantRepository!(IAGroup, GroupId), IGroupRepository {
  mixin TenantRepositoryTemplate!(GroupRepository, IAGroup, GroupId);

  bool existsByName(TenantId tenantId, string name) {
    return !findByName(tenantId, name).isNull;
  }

  IAGroup findByName(TenantId tenantId, string name) {
    foreach (g; findByTenant(tenantId))
      if (sicmp(g.name, name) == 0)
        return g;
    return IAGroup.init;
  }

  void removeByName(TenantId tenantId, string name) {
    remove(findByName(tenantId, name));
  }

  IAGroup[] findByMember(TenantId tenantId, UserId userId) {
    return findByTenant(tenantId).filter!(g => g.hasMember(userId)).array;
  }
}
///
unittest {
  assert(tenantRepositoryTest(new GroupRepository()));
}
