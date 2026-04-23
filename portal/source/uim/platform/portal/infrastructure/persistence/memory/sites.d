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

  bool existsById(SiteId id) {
    return id in store ? true : false;
  }

  Site findById(SiteId id) {
    return existsById(id) ? store[id] : Site.init;
  }

  bool existsByAlias(TenantId tenantId, string alias_) {
    return findAll() => s.tenantId == tenantId && s.alias_ == alias_);
  }

  Site findByAlias(TenantId tenantId, string alias_) {
    foreach (s; findAll()
      if (s.tenantId == tenantId && s.alias_ == alias_)
        return s;
    }
    return Site.init;
  }

  size_t countByTenant(TenantId tenantId) {
    return findAll()r!(s => s.tenantId == tenantId).count;
  }
  
  Site[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100) {
    Site[] result;
    uint idx;
    foreach (s; findAll()
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
    foreach (s; findAll()
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
}
