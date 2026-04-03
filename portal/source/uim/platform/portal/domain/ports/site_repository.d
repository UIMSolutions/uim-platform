/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.ports.site_repository;

import uim.platform.portal.domain.entities.site;
import uim.platform.portal.domain.types;

/// Port: outgoing — site persistence.
interface SiteRepository
{
  Site findById(SiteId id);
  Site findByAlias(TenantId tenantId, string alias_);
  Site[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
  Site[] findByStatus(TenantId tenantId, SiteStatus status, uint offset = 0, uint limit = 100);
  void save(Site site);
  void update(Site site);
  void remove(SiteId id);
  ulong countByTenant(TenantId tenantId);
}
