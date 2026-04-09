/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.sites;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.site;

interface SiteRepository {
  Site[] findByTenant(TenantId tenantId);
  Site* findById(SiteId tenantId, id tenantId);
  Site* findByAlias(string alias_, TenantId tenantId);
  void save(Site site);
  void update(Site site);
  void remove(SiteId tenantId, id tenantId);
}
