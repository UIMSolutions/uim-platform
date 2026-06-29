/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.infrastructure.persistence.memory.pages;
// import uim.platform.portal.domain.entities.page;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.pages;

import uim.platform.portal;

// mixin(ShowModule!());

@safe:
class MemoryPageRepository : TenantRepository!(Page, PageId), PageRepository {

  bool existsByAlias(TenantId tenantId, SiteId siteId, string alias_) {
    return findByTenant(tenantId).filter!(p => p.siteId == siteId && p.alias_ == alias_).length > 0;
  }

  Page findByAlias(TenantId tenantId, SiteId siteId, string alias_) {
    return findByTenant(tenantId).filter!(p => p.siteId == siteId && p.alias_ == alias_).array;
  }

  Page[] findBySite(TenantId tenantId, SiteId siteId, size_t offset = 0, size_t limit = 100) {
    Page[] result;
    size_t idx;
    foreach (p; findByTenant(tenantId)) {
      if (p.siteId == siteId) {
        if (idx >= offset && result.length < limit)
          result ~= p;
        idx++;
      }
    }
    return result;
  }
}
