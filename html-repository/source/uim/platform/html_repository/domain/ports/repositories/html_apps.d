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
interface IHtmlAppRepository : ITenantRepository!(HtmlApp, HtmlAppId) {

  size_t countByName(TenantId tenantId, string name);
  HtmlApp[] findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);
  
  size_t countByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId);
  HtmlApp[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId);
  void removeByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId);

  size_t countBySpace(TenantId tenantId, SpaceId spaceId);
  HtmlApp[] findBySpace(TenantId tenantId, SpaceId spaceId);
  void removeBySpace(TenantId tenantId, SpaceId spaceId);

  size_t countPublic(TenantId tenantId);
  HtmlApp[] findPublic(TenantId tenantId);
  void removePublic(TenantId tenantId);

}
