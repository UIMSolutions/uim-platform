/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.repositories.app_routes;
// import uim.platform.html_repository.domain.ports.repositories.app_routes;
// import uim.platform.html_repository.domain.entities.app_route;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class AppRouteMemoryRepository : TenantRepository!(AppRoute, AppRouteId), IAppRouteRepository {

  bool existsByPathPrefix(TenantId tenantId, string pathPrefix) {
    return findByTenant(tenantId).any!(e => e.pathPrefix == pathPrefix);
  }

  AppRoute findByPathPrefix(TenantId tenantId, string pathPrefix) {
    foreach (e; findByTenant(tenantId)) {
      if (e.tenantId == tenantId && e.pathPrefix == pathPrefix) return e;
    }
    return AppRoute.init;
  }

  void removeByPathPrefix(TenantId tenantId, string pathPrefix) {
    AppRoute route = findByPathPrefix(tenantId, pathPrefix);
    if (route.id != AppRouteId.init) {
      remove(route);
    }
  }

  size_t countByApp(TenantId tenantId, HtmlAppId appId) {
    return findByApp(tenantId, appId).length;
  }
  
  AppRoute[] filterByApp(AppRoute[] routes, HtmlAppId appId) {
    return routes.filter!(r => r.appId == appId).array;
  }
  
  AppRoute[] findByApp(TenantId tenantId, HtmlAppId appId) {
    return filterByApp(findByTenant(tenantId), appId);
  }

  void removeByApp(TenantId tenantId, HtmlAppId appId) {
    findByApp(tenantId, appId).each!(r => remove(r));
  }

}
