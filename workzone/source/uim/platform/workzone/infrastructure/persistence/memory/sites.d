/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.sites;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.site;
// import uim.platform.workzone.domain.ports.repositories.sites;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
// import std.algorithm : filter;
// import std.array : array;

class MemorySiteRepository : TenantRepository!(Site, SiteId), SiteRepository {

  // #region ByAlias
  bool existsByAlias(TenantId tenantId, string alias_) {
    return findByTenant(tenantId).any!(s => s.alias_ == alias_);
  }

  Site findByAlias(TenantId tenantId, string alias_) {
    foreach (s; findByTenant(tenantId))
      if (s.alias_ == alias_)
        return s;
    return Site.init;
  }

  void removeByAlias(TenantId tenantId, string alias_) {
    foreach (s; findByTenant(tenantId))
      if (s.alias_ == alias_)
        remove(s);
  }
  // #endregion ByAlias

}
