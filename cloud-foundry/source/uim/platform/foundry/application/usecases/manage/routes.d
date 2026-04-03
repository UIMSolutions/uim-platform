module uim.platform.foundry.application.usecases.manage.routes;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.route;
import uim.platform.foundry.domain.entities.cf_domain;

// import uim.platform.foundry.domain.ports.route;
// import uim.platform.foundry.domain.ports.domain;
import uim.platform.foundry.domain.ports;
import uim.platform.foundry.domain.services.route_resolver;
import uim.platform.foundry.application.dto;

class ManageRoutesUseCase
{
  private RouteRepository routeRepo;
  private DomainRepository domainRepo;
  private RouteResolver resolver;

  this(RouteRepository routeRepo, DomainRepository domainRepo, RouteResolver resolver)
  {
    this.routeRepo = routeRepo;
    this.domainRepo = domainRepo;
    this.resolver = resolver;
  }

  // --- Routes ---

  CommandResult createRoute(CreateRouteRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.spaceId.length == 0)
      return CommandResult("", "Space ID is required");
    if (req.domainId.length == 0)
      return CommandResult("", "Domain ID is required");
    if (req.host.length == 0)
      return CommandResult("", "Host is required");

    // Verify domain exists
    auto dom = domainRepo.findById(req.domainId, req.tenantId);
    if (dom is null)
      return CommandResult("", "Domain not found");

    // Check route availability
    if (!resolver.isRouteAvailable(req.tenantId, req.host, req.domainId))
      return CommandResult("", "Route host is already taken for this domain");

    auto now = Clock.currStdTime();
    auto r = Route();
    r.id = randomUUID().toString();
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

    routeRepo.save(r);
    return CommandResult(r.id, "");
  }

  Route* getRoute(RouteId id, TenantId tenantId)
  {
    return routeRepo.findById(id, tenantId);
  }

  Route[] listRoutes(TenantId tenantId)
  {
    return routeRepo.findByTenant(tenantId);
  }

  Route[] listBySpace(SpaceId spaceId, TenantId tenantId)
  {
    return routeRepo.findBySpace(spaceId, tenantId);
  }

  CommandResult deleteRoute(RouteId id, TenantId tenantId)
  {
    auto existing = routeRepo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Route not found");

    routeRepo.remove(id, tenantId);
    return CommandResult(id, "");
  }

  /// Map an application to a route.
  CommandResult mapRoute(MapRouteRequest req)
  {
    if (req.routeId.length == 0)
      return CommandResult("", "Route ID is required");
    if (req.appId.length == 0)
      return CommandResult("", "Application ID is required");

    if (!resolver.mapApp(req.routeId, req.tenantId, req.appId))
      return CommandResult("", "Cannot map application to route");

    return CommandResult(req.routeId, "");
  }

  /// Unmap an application from a route.
  CommandResult unmapRoute(MapRouteRequest req)
  {
    if (req.routeId.length == 0)
      return CommandResult("", "Route ID is required");
    if (req.appId.length == 0)
      return CommandResult("", "Application ID is required");

    if (!resolver.unmapApp(req.routeId, req.tenantId, req.appId))
      return CommandResult("", "Cannot unmap application from route");

    return CommandResult(req.routeId, "");
  }

  // --- Domains ---

  CommandResult createDomain(CreateDomainRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Domain name is required");

    auto existing = domainRepo.findByName(req.tenantId, req.name);
    if (existing !is null)
      return CommandResult("", "Domain with this name already exists");

    auto now = Clock.currStdTime();
    auto d = CfDomain();
    d.id = randomUUID().toString();
    d.ownerOrgId = req.ownerOrgId;
    d.tenantId = req.tenantId;
    d.name = req.name;
    d.scope_ = req.scope_;
    d.isInternal = req.isInternal;
    d.createdBy = req.createdBy;
    d.createdAt = now;
    d.updatedAt = now;

    domainRepo.save(d);
    return CommandResult(d.id, "");
  }

  CfDomain[] listDomains(TenantId tenantId)
  {
    return domainRepo.findByTenant(tenantId);
  }

  CommandResult deleteDomain(DomainId id, TenantId tenantId)
  {
    auto existing = domainRepo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Domain not found");

    // Remove all routes on this domain
    auto routes = routeRepo.findByDomain(id, tenantId);
    foreach (r; routes)
      routeRepo.remove(r.id, tenantId);

    domainRepo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
