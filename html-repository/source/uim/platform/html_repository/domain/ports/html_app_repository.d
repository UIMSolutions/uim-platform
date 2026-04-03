/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.html_app_repository;

import uim.platform.html_repository.domain.entities.html_app;
import uim.platform.html_repository.domain.types;

interface HtmlAppRepository {
  HtmlApp findById(HtmlAppId id);
  HtmlApp findByName(TenantId tenantId, string name);
  HtmlApp[] findByTenant(TenantId tenantId);
  HtmlApp[] findBySpace(SpaceId spaceId);
  HtmlApp[] findByServiceInstance(ServiceInstanceId instanceId);
  HtmlApp[] findPublic(TenantId tenantId);
  void save(HtmlApp app);
  void update(HtmlApp app);
  void remove(HtmlAppId id);
  long countByTenant(TenantId tenantId);
  long countByServiceInstance(ServiceInstanceId instanceId);
}
