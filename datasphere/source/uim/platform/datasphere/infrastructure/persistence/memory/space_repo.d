/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.space;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.space;
import uim.platform.datasphere.domain.ports.repositories.spaces;

import std.algorithm : filter;
import std.array : array;

class MemorySpaceRepository : TenantRepository!(Space, SpaceId), SpaceRepository {
  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(e => e.name == name);
  }

  Space findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return Space.init;
  }

  void removeByName(TenantId tenantId, string name) {
    findByName(tenantId, name).remove;

}
