/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.infrastructure.persistence.memory.sites;

// import uim.platform.portal.domain.entities.site;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.sites;

import uim.platform.portal;

mixin(ShowModule!());

@safe:
class MemorySiteRepository : SiteRepository {
  private Site[SiteId] store;

  Site findById(SiteId id) {
    if (auto p = id in store)
      return *p;
    return Site.init;
  }

  Site findByAlias(TenantId tenantId, string alias_) {
    foreach (s; store.byValue()) {
      if (s.tenantId == tenantId && s.alias_ == alias_)
        return s;
    }
    return Site.init;
  }

  Site[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100) {
    Site[] result;
    uint idx;
    foreach (s; store.byValue()) {
      if (s.tenantId == tenantId) {
        if (idx >= offset && result.length < limit)
          result ~= s;
        idx++;
      }
    }
    return result;
  }

  Site[] findByStatus(TenantId tenantId, SiteStatus status, uint offset = 0, uint limit = 100) {
    Site[] result;
    uint idx;
    foreach (s; store.byValue()) {
      if (s.tenantId == tenantId && s.status == status) {
        if (idx >= offset && result.length < limit)
          result ~= s;
        idx++;
      }
    }
    return result;
  }

  void save(Site site) {
    store[site.id] = site;
  }

  void update(Site site) {
    store[site.id] = site;
  }

  void remove(SiteId id) {
    store.remove(id);
  }

  size_t countByTenant(TenantId tenantId) {
    return store.byValue().filter!(s => s.tenantId == tenantId).count;
  }
}
