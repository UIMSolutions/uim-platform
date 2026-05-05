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
class MemorySiteRepository : TenantRepository!(Site, SiteId), SiteRepository {

  bool existsByAlias(TenantId tenantId, string alias_) {
    return findByTenant(tenantId).any!(s => s.alias_ == alias_);
  }

  Site findByAlias(TenantId tenantId, string alias_) {
    foreach (s; findByTenant(tenantId)) {
      if (s.alias_ == alias_)
        return s;
    }
    return Site.init;
  }

  size_t countByStatus(TenantId tenantId, SiteStatus status) {
    return findByStatus(tenantId, status).length;
  }
  Site[] filterByStatus(Site[] sites, SiteStatus status) {
    return sites.filter!(s => s.status == status).array;
  }  
  Site[] findByStatus(TenantId tenantId, SiteStatus status, size_t offset = 0, size_t limit = 100) {
    Site[] result;
    size_t idx;
    foreach (s; findByTenant(tenantId)) {
      if (s.status == status) {
        if (idx >= offset && result.length < limit)
          result ~= s;
        idx++;
      }
    }
    return result;
  }
  void removeByStatus(TenantId tenantId, SiteStatus status) {
    findByStatus(tenantId, status).each!(entity => remove(entity));
  }
  
}
