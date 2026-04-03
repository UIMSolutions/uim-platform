/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.app_route_repository;

import uim.platform.html_repository.domain.entities.app_route;
import uim.platform.html_repository.domain.types;

interface AppRouteRepository {
  AppRoute findById(AppRouteId id);
  AppRoute findByPathPrefix(TenantId tenantId, string pathPrefix);
  AppRoute[] findByApp(HtmlAppId appId);
  AppRoute[] findByTenant(TenantId tenantId);
  void save(AppRoute route);
  void update(AppRoute route);
  void remove(AppRouteId id);
  long countByApp(HtmlAppId appId);
  long countByTenant(TenantId tenantId);
}
