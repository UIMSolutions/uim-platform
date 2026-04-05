/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.sites;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.site;
import uim.platform.workzone.domain.ports.repositories.sites;

// import std.algorithm : filter;
// import std.array : array;

class MemorySiteRepository : SiteRepository {
  private Site[SiteId] store;

  Site[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(s => s.tenantId == tenantId).array;
  }

  Site* findById(SiteId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Site* findByAlias(string alias_, TenantId tenantId)
  {
    foreach (ref s; store.byValue())
      if (s.tenantId == tenantId && s.alias_ == alias_)
        return &s;
    return null;
  }

  void save(Site site)
  {
    store[site.id] = site;
  }

  void update(Site site)
  {
    store[site.id] = site;
  }

  void remove(SiteId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
