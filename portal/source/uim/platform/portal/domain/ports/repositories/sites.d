/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.ports.repositories.sites;

// import uim.platform.portal.domain.entities.site;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// Port: outgoing — site persistence.
interface SiteRepository : ITenantRepository!(Site, SiteId) {

  bool existsByAlias(TenantId tenantId, string alias_);
  Site findByAlias(TenantId tenantId, string alias_);
  void removeByAlias(TenantId tenantId, string alias_);

  size_t countByStatus(TenantId tenantId, SiteStatus status);
  Site[] findByStatus(TenantId tenantId, SiteStatus status, uint offset = 0, uint limit = 100);
  void removeByStatus(TenantId tenantId, SiteStatus status);
  
}
