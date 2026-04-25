/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.persistence.memory.routes;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.route;
// import uim.platform.foundry.domain.ports.repositories.route;

// import std.algorithm : canFind, filter;
// import std.array : array;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class MemoryRouteRepository : TenantRepository!(Route, RouteId), IRouteRepository {

  Route findByHostAndDomain(TenantId tenantId, string host, DomainId domainId) {
    foreach (e; findByTenant(tenantId))
      if (e.host == host && e.domainId == domainId)
        return e;
    return Route.init;
  }

  // #region ByDomain
  size_t countByDomain(TenantId tenantId, CfDomainId domainId) {
    return findByDomain(tenantId, domainId).length;
  }

  Route[] filterByDomain(TenantId tenantId, CfDomainId domainId) {
    return findByDomain(tenantId, domainId);
  }

  Route[] findByDomain(TenantId tenantId, CfDomainId domainId) {
    return findByDomain(findByTenant(tenantId), domainId);
  }

  void removeByDomain(TenantId tenantId, CfDomainId domainId) {
    findByDomain(tenantId, domainId).each!(e => remove(e.id));
  }
  // #endregion ByDomain

  // #region ByApp
  size_t countByApp(TenantId tenantId, AppId appId) {
    return findByApp(tenantId, appId).length;
  }

  Route[] filterByApp(TenantId tenantId, AppId appId) {
    return findByApp(tenantId, appId);
  }

  Route[] findByApp(TenantId tenantId, AppId appId) {
    return findByTenant(tenantId).filter!(e => e.mappedAppIds.canFind(appId)).array;
  }

  void removeByApp(TenantId tenantId, AppId appId) {
    findByApp(tenantId, appId).each!(e => remove(e));
  }
  // #endregion ByApp

}
