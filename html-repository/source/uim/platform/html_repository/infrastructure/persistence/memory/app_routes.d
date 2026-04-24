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
  AppRoute findById(AppRouteId id) {
    foreach (e; findAll) {
      if (e.id == id) return e;
    }
    return AppRoute.init;
  }

  AppRoute findByPathPrefix(TenantId tenantId, string pathPrefix) {
    foreach (e; findAll) {
      if (e.tenantId == tenantId && e.pathPrefix == pathPrefix) return e;
    }
    return AppRoute.init;
  }

  AppRoute[] findByApp(HtmlAppId appId) {
    AppRoute[] result;
    foreach (e; findAll) {
      if (e.appId == appId) result ~= e;
    }
    return result;
  }

  AppRoute[] findByTenant(TenantId tenantId) {
    AppRoute[] result;
    foreach (e; findAll) {
      if (e.tenantId == tenantId) result ~= e;
    }
    return result;
  }

  void save(AppRoute route) {
    store ~= route;
  }

  void update(AppRoute route) {
    foreach (i, e; store) {
      if (e.id == route.id) {
        store[i] = route;
        return;
      }
    }
  }

  void remove(AppRouteId id) {
    AppRoute[] result;
    foreach (e; findAll) {
      if (e.id != id) result ~= e;
    }
    store = result;
  }

  size_t countByApp(HtmlAppId appId) {
    size_t count = 0;
    foreach (e; findAll) {
      if (e.appId == appId) count++;
    }
    return count;
  }

  size_t countByTenant(TenantId tenantId) {
    size_t count = 0;
    foreach (e; findAll) {
      if (e.tenantId == tenantId) count++;
    }
    return count;
  }
}
