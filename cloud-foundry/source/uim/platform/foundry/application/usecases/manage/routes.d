/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.usecases.manage.routes;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.route;
// import uim.platform.foundry.domain.entities.cf_domain;

// // import uim.platform.foundry.domain.ports.repositories.route;
// // import uim.platform.foundry.domain.ports.repositories.domain;
// import uim.platform.foundry.domain.ports;
// import uim.platform.foundry.domain.services.route_resolver;
// import uim.platform.foundry.application.dto;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class ManageRoutesUseCase { // TODO: UIMUseCase {
  private IRouteRepository routes;
  private IDomainRepository domains;
  private RouteResolver resolver;

  this(IRouteRepository routes, IDomainRepository domains, RouteResolver resolver) {
    this.routes = routes;
    this.domains = domains;
    this.resolver = resolver;
  }

  // --- Routes ---

  CommandResult createRoute(CreateRouteRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.spaceId.isEmpty)
      return CommandResult(false, "", "Space ID is required");
    if (req.domainId.isEmpty)
      return CommandResult(false, "", "Domain ID is required");
    if (req.host.length == 0)
      return CommandResult(false, "", "Host is required");

    // Verify domain exists
    auto dom = domains.findById(req.tenantId, req.domainId);
    if (dom.isNull)
      return CommandResult(false, "", "Domain not found");

    // Check route availability
    if (!resolver.isRouteAvailable(req.tenantId, req.host, req.domainId))
      return CommandResult(false, "", "Route host is already taken for this domain");

    auto now = Clock.currStdTime();
    auto route = Route();
    route.initEntity(req.tenantId, req.createdBy);
    route.spaceId = req.spaceId;
    route.domainId = req.domainId;
    route.host = req.host;
    route.path = req.path;
    route.port = req.port;
    route.protocol = req.protocol;

    routes.save(route);
    return CommandResult(true, route.id.value, "");
  }

  Route getRoute(TenantId tenantId, RouteId id) {
    return routes.findById(tenantId, id);
  }

  Route[] listRoutes(TenantId tenantId) {
    return routes.findByTenant(tenantId);
  }

  Route[] listBySpace(TenantId tenantId, SpaceId spaceId) {
    return routes.findBySpace(tenantId, spaceId);
  }

  CommandResult deleteRoute(TenantId tenantId, RouteId id) {
    auto route = routes.findById(tenantId, id);
    if (route.isNull)
      return CommandResult(false, "", "Route not found");

    routes.remove(route);
    return CommandResult(true, id.value, "");
  }

  /// Map an application to a route.
  CommandResult mapRoute(MapRouteRequest req) {
    if (req.routeId.isEmpty)
      return CommandResult(false, "", "Route ID is required");
    if (req.appId.isEmpty)
      return CommandResult(false, "", "Application ID is required");

    if (!resolver.mapApp(req.tenantId, req.routeId, req.appId))
      return CommandResult(false, "", "Cannot map application to route");

    return CommandResult(true, req.routeid.value, "");
  }

  /// Unmap an application from a route.
  CommandResult unmapRoute(MapRouteRequest req) {
    if (req.routeId.isEmpty)
      return CommandResult(false, "", "Route ID is required");
    if (req.appId.isEmpty)
      return CommandResult(false, "", "Application ID is required");

    if (!resolver.unmapApp(req.tenantId, req.routeId, req.appId))
      return CommandResult(false, "", "Cannot unmap application from route");

    return CommandResult(true, req.routeid.value, "");
  }

  // --- Domains ---

  CommandResult createDomain(CreateDomainRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Domain name is required");

    if (domains.existsByName(req.tenantId, req.name))
      return CommandResult(false, "", "Domain with this name already exists");

    auto now = Clock.currStdTime();
    auto d = CfDomain();
    d.initEntity(req.tenantId, req.createdBy);
    d.ownerOrgId = req.ownerOrgId;
    d.name = req.name;
    d.scope_ = req.scope_;
    d.isInternal = req.isInternal;

    domains.save(d);
    return CommandResult(true, d.id.value, "");
  }

  CfDomain[] listDomains(TenantId tenantId) {
    return domains.findByTenant(tenantId);
  }

  CommandResult deleteDomain(TenantId tenantId, CfDomainId domainId) {
    auto domain = domains.findById(tenantId, domainId);
    if (domain.isNull)
      return CommandResult(false, "", "Domain not found");

    // Remove all routes on this domain
    auto routesOnDomain = routes.findByDomain(tenantId, domainId);
    routesOnDomain.each!(route => routes.remove(route));

    domains.remove(domain);
    return CommandResult(true, domain.id.value, "");
  }
}
