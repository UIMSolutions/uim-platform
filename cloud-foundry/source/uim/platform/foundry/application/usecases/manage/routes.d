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
    auto dom = domains.findById(req.domainId, req.tenantId);
    if (dom is null)
      return CommandResult(false, "", "Domain not found");

    // Check route availability
    if (!resolver.isRouteAvailable(req.tenantId, req.host, req.domainId))
      return CommandResult(false, "", "Route host is already taken for this domain");

    auto now = Clock.currStdTime();
    auto r = Route();
    r.id = randomUUID();
    r.spaceId = req.spaceId;
    r.domainId = req.domainId;
    r.tenantId = req.tenantId;
    r.host = req.host;
    r.path = req.path;
    r.port = req.port;
    r.protocol = req.protocol;
    r.createdBy = req.createdBy;
    r.createdAt = now;
    r.updatedAt = now;

    routes.save(r);
    return CommandResult(r.id, "");
  }

  Route* getRoute(TenantId tenantId, RouteId id) {
    return routes.findById(tenantId, id);
  }

  Route[] listRoutes(TenantId tenantId) {
    return routes.findByTenant(tenantId);
  }

  Route[] listBySpace(TenantId tenantId, SpaceId spaceId) {
    return routes.findBySpace(spaceId, tenantId);
  }

  CommandResult deleteRoute(TenantId tenantId, RouteId id) {
    auto existing = routes.findById(tenantId, id);
    if (existing is null)
      return CommandResult(false, "", "Route not found");

    routes.remove(tenantId, id);
    return CommandResult(true, id.toString, "");
  }

  /// Map an application to a route.
  CommandResult mapRoute(MapRouteRequest req) {
    if (req.routeId.isEmpty)
      return CommandResult(false, "", "Route ID is required");
    if (req.appId.isEmpty)
      return CommandResult(false, "", "Application ID is required");

    if (!resolver.mapApp(req.routeId, req.tenantId, req.appId))
      return CommandResult(false, "", "Cannot map application to route");

    return CommandResult(req.routeId, "");
  }

  /// Unmap an application from a route.
  CommandResult unmapRoute(MapRouteRequest req) {
    if (req.routeId.isEmpty)
      return CommandResult(false, "", "Route ID is required");
    if (req.appId.isEmpty)
      return CommandResult(false, "", "Application ID is required");

    if (!resolver.unmapApp(req.routeId, req.tenantId, req.appId))
      return CommandResult(false, "", "Cannot unmap application from route");

    return CommandResult(req.routeId, "");
  }

  // --- Domains ---

  CommandResult createDomain(CreateDomainRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Domain name is required");

    auto existing = domains.findByName(req.tenantId, req.name);
    if (existing !is null)
      return CommandResult(false, "", "Domain with this name already exists");

    auto now = Clock.currStdTime();
    auto d = CfDomain();
    d.id = randomUUID();
    d.ownerOrgId = req.ownerOrgId;
    d.tenantId = req.tenantId;
    d.name = req.name;
    d.scope_ = req.scope_;
    d.isInternal = req.isInternal;
    d.createdBy = req.createdBy;
    d.createdAt = now;
    d.updatedAt = now;

    domains.save(d);
    return CommandResult(d.id, "");
  }

  CfDomain[] listDomains(TenantId tenantId) {
    return domains.findByTenant(tenantId);
  }

  CommandResult deleteDomain(TenantId tenantId, CfDomainId id) {
    auto existing = domains.findById(tenantId, id);
    if (existing is null)
      return CommandResult(false, "", "Domain not found");

    // Remove all routes on this domain
    auto routesOnDomain = routes.findByDomain(tenantId, id);
    foreach (r; routesOnDomain)
      routes.remove(r.tenantId, r.id);

    domains.remove(tenantId, id);
    return CommandResult(true, id.toString, "");
  }
}
