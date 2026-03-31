module domain.services.route_resolver;

import domain.types;
import domain.entities.route;
import domain.entities.cf_domain;
import domain.ports.route_repository;
import domain.ports.domain_repository;

import std.algorithm : canFind, remove;

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
