/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.sites;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.site;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
interface SiteRepository : ITenantRepository!(Site, SiteId) {

  bool existsByAlias(string alias_, TenantId tenantId);
  Site findByAlias(string alias_, TenantId tenantId);
  void removeByAlias(string alias_, TenantId tenantId);

}
