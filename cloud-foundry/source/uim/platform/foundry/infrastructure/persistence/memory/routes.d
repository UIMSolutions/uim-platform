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

  bool existsByHostAndDomain(TenantId tenantId, string host, CfDomainId domainId) {
    return !findByHostAndDomain(tenantId, host, domainId).isNull;
  }

  Route findByHostAndDomain(TenantId tenantId, string host, CfDomainId domainId) {
    foreach (e; findByTenant(tenantId))
      if (e.host == host && e.domainId == domainId)
        return e;
    return Route.init;
  }

  void removeByHostAndDomain(TenantId tenantId, string host, CfDomainId domainId) {
    foreach (e; findByTenant(tenantId))
      if (e.host == host && e.domainId == domainId)
        return remove(e);
  }

  // #region ByDomain
  size_t countByDomain(TenantId tenantId, CfDomainId domainId) {
    return findByDomain(tenantId, domainId).length;
  }

  Route[] filterByDomain(Route[] routes, CfDomainId domainId) {
    return routes.filter!(e => e.domainId == domainId).array;
  }

  Route[] findByDomain(TenantId tenantId, CfDomainId domainId) {
    return filterByDomain(findByTenant(tenantId), domainId);
  }

  void removeByDomain(TenantId tenantId, CfDomainId domainId) {
    findByDomain(tenantId, domainId).each!(e => remove(e));
  }
  // #endregion ByDomain

  // #region ByApp
  size_t countByApp(TenantId tenantId, AppId appId) {
    return findByApp(tenantId, appId).length;
  }

  Route[] filterByApp(Route[] routes, AppId appId) {
    return routes.filter!(e => e.mappedAppIds.any!(id => id == appId)).array;
  }

  Route[] findByApp(TenantId tenantId, AppId appId) {
    return filterByApp(findByTenant(tenantId), appId);
  }

  void removeByApp(TenantId tenantId, AppId appId) {
    findByApp(tenantId, appId).each!(e => remove(e));
  }
  // #endregion ByApp


  // #region BySpace
  size_t countBySpace(TenantId tenantId, SpaceId spaceId) {
    return findBySpace(tenantId, spaceId).length;
  }

  Route[] filterBySpace(Route[] routes, SpaceId spaceId) {
    return routes.filter!(e => e.mappedSpaceIds.canFind(spaceId)).array;
  }

  Route[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return filterBySpace(findByTenant(tenantId), spaceId);
  }

  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(e => remove(e));
  }
  // #endregion BySpace
}
