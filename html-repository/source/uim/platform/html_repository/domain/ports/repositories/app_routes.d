/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.repositories.app_routes;

import uim.platform.html_repository.domain.entities.app_route;
import uim.platform.html_repository.domain.types;

interface AppRouteRepository {
  bool existsById(AppRouteId id);
  AppRoute findById(AppRouteId id);

  bool existsByPathPrefix(TenantId tenantId, string pathPrefix);
  AppRoute findByPathPrefix(TenantId tenantId, string pathPrefix);

  size_t countByApp(HtmlAppId appId);
  AppRoute[] findByApp(HtmlAppId appId);
  
  size_t countByTenant(TenantId tenantId);
  AppRoute[] findByTenant(TenantId tenantId);

  void save(AppRoute route);
  void update(AppRoute route);
  void remove(AppRouteId id);
}
