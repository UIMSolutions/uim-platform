/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.repositories.groups;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driven port: group persistence.
interface IGroupRepository : ITenantRepository!(IAGroup, GroupId) {
  bool existsByName(TenantId tenantId, string name);
  IAGroup findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);

  IAGroup[] findByMember(TenantId tenantId, UserId userId);
}
