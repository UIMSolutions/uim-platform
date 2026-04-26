/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.memory.app_routes;

// import uim.platform.html_repository.domain.ports.repositories.app_routes;
// import uim.platform.html_repository.domain.entities.app_route;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class AppRouteMemoryRepository : TenantRepository!(AppRoute, AppRouteId), AppRouteRepository {

  AppRoute findByPathPrefix(TenantId tenantId, string pathPrefix) {
    foreach (e; findAll) {
      if (e.tenantId == tenantId && e.pathPrefix == pathPrefix) return e;
    }
    return AppRoute.init;
  }

  size_t countByApp(HtmlAppId appId) {
    return findByApp(appId).length;
  }
  AppRoute[] filterByApp(AppRoute[] routes, HtmlAppId appId) {
    return routes.filter!(r => r.appId == appId).array;
  }
  AppRoute[] findByApp(HtmlAppId appId) {
    return filterByApp(findAll(), appId);
  }
  void removeByApp(HtmlAppId appId) {
    findByApp(appId).each!(r => remove(r.id));
  }

}
