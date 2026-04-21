/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.repositories.app_routes;

// import uim.platform.html_repository.domain.entities.app_route;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
interface AppRouteRepository : ITenantRepository!(AppRoute, AppRouteId) {

  bool existsByPathPrefix(TenantId tenantId, string pathPrefix);
  AppRoute findByPathPrefix(TenantId tenantId, string pathPrefix);
  void removeByPathPrefix(TenantId tenantId, string pathPrefix);

  size_t countByApp(HtmlAppId appId);
  AppRoute[] findByApp(HtmlAppId appId);
  void removeByApp(HtmlAppId appId);
  
}
