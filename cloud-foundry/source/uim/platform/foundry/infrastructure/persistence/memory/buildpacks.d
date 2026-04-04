/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.persistence.memory.buildpack;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.buildpack;
import uim.platform.foundry.domain.ports.repositories.buildpack;

// import std.algorithm : filter;
// import std.array : array;

class MemoryBuildpackRepository : BuildpackRepository {
  private Buildpack[BuildpackId] store;

  Buildpack[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  Buildpack* findById(BuildpackId id, TenantId tenantId)
  {
    if (auto p = id in store && p.tenantId == tenantId)
      return p;
    return null;
  }

  Buildpack* findByName(TenantId tenantId, string name)
  {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.name == name)
        return &e;
    return null;
  }

  Buildpack[] findEnabled(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.enabled).array;
  }

  Buildpack[] findByStack(TenantId tenantId, string stack)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.stack == stack).array;
  }

  void save(Buildpack bp)
  {
    store[bp.id] = bp;
  }

  void update(Buildpack bp)
  {
    store[bp.id] = bp;
  }

  void remove(BuildpackId id, TenantId tenantId)
  {
    if (auto p = id in store && p.tenantId == tenantId)
      store.remove(id);
  }
}
