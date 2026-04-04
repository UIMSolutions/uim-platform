/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.services.route_resolver;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.route;
import uim.platform.foundry.domain.entities.cf_domain;
import uim.platform.foundry.domain.ports.repositories.route;
import uim.platform.foundry.domain.ports.repositories.domain;

// import std.algorithm : canFind, remove;

/// Domain service that handles route resolution —
/// validates host/domain uniqueness and manages app-to-route mappings.
class RouteResolver
{
  private RouteRepository routeRepo;
  private DomainRepository domainRepo;

  this(RouteRepository routeRepo, DomainRepository domainRepo)
  {
    this.routeRepo = routeRepo;
    this.domainRepo = domainRepo;
  }

  /// Check if a host+domain combination is already taken.
  bool isRouteAvailable(TenantId tenantId, string host, DomainId domainId)
  {
    auto existing = routeRepo.findByHostAndDomain(tenantId, host, domainId);
    return existing is null;
  }

  /// Validate that a domain is accessible for the given org.
  bool isDomainAccessible(DomainId domainId, OrgId orgId, TenantId tenantId)
  {
    auto dom = domainRepo.findById(domainId, tenantId);
    if (dom is null)
      return false;

    // Shared and internal domains are accessible to all orgs
    if (dom.scope_ == DomainScope.shared_ || dom.scope_ == DomainScope.internal_)
      return true;

    // Private domains must belong to the org
    return dom.ownerOrgId == orgId;
  }

  /// Map an application to a route.
  bool mapApp(RouteId routeId, AppId appId, TenantId tenantId)
  {
    auto route = routeRepo.findById(routeId, tenantId);
    if (route is null)
      return false;

    // Already mapped?
    if (route.mappedAppIds.canFind(appId))
      return true;

    route.mappedAppIds ~= appId;
    routeRepo.update(*route);
    return true;
  }

  /// Unmap an application from a route.
  bool unmapApp(RouteId routeId, AppId appId, TenantId tenantId)
  {
    auto route = routeRepo.findById(routeId, tenantId);
    if (route is null)
      return false;

    string[] updated;
    foreach (ref id; route.mappedAppIds)
      if (id != appId)
        updated ~= id;

    if (updated.length == route.mappedAppIds.length)
      return false; // app was not mapped

    route.mappedAppIds = updated;
    routeRepo.update(*route);
    return true;
  }
}
