/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.repositories.html_apps;

// import uim.platform.html_repository.domain.entities.html_app;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
interface HtmlAppRepository : ITenantRepository!(HtmlApp, HtmlAppId) {

  size_t countByName(TenantId tenantId, string name);
  HtmlApp[] findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);
  
  size_t countByServiceInstance(ServiceInstanceId instanceId);
  HtmlApp[] findByServiceInstance(ServiceInstanceId instanceId);
  void removeByServiceInstance(ServiceInstanceId instanceId);

  size_t countBySpace(SpaceId spaceId);
  HtmlApp[] findBySpace(SpaceId spaceId);
  void removeBySpace(SpaceId spaceId);

  size_t countPublic(TenantId tenantId);
  HtmlApp[] findPublic(TenantId tenantId);
  void removePublic(TenantId tenantId);

}
