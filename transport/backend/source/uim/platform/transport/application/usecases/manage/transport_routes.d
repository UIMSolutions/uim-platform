/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.usecases.manage.transport_routes;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class ManageTransportRoutesUseCase : IManageTransportRoutesUseCase {
  protected ITransportRouteRepository routes;
  protected ITransportNodeRepository nodes;

  this(ITransportRouteRepository routes, ITransportNodeRepository nodes) {
    this.routes = routes;
    this.nodes = nodes;
  }

  UsecaseResult createRoute(CreateRouteInput input) {
    auto t = input.tenantId;
    auto route = TransportRoute(t);
    if (input.id.length > 0)
      route.id = TransportRouteId(input.id);
    if (routes.existsById(t, route.id))
      return errorResult(409, "Transport route '" ~ route.id.value ~ "' already exists");

    RouteStatus status = RouteStatus.enabled;
    if (input.status.length > 0 && !tryParseEnum!RouteStatus(input.status, status))
      return errorResult(400, "Invalid route status '" ~ input.status ~ "'");

    route.name = input.name.strip;
    route.description = input.description;
    route.sourceNodeId = TransportNodeId(input.sourceNodeId);
    route.destinationNodeId = TransportNodeId(input.destinationNodeId);
    route.status = status;
    route.isSequential = input.isSequential;
    route.sequence = input.sequence;
    route.createdBy = input.createdBy;
    route.updatedBy = input.createdBy;

    auto invalid = TransportValidator.validateRoute(route);
    if (invalid.length > 0)
      return errorResult(400, "Invalid route: " ~ invalid);

    auto source = nodes.findById(t, route.sourceNodeId);
    if (source.isNull)
      return notFoundResult("Source node", route.sourceNodeId.value);
    auto destination = nodes.findById(t, route.destinationNodeId);
    if (destination.isNull)
      return notFoundResult("Destination node", route.destinationNodeId.value);

    auto existing = routes.findByTenant(t);
    if (existing.any!(r => r.name == route.name))
      return errorResult(409, "A transport route named '" ~ route.name ~ "' already exists");

    auto landscape = TransportLandscape(nodes.findByTenant(t), existing);
    if (landscape.hasRoute(route.sourceNodeId, route.destinationNodeId))
      return errorResult(409, "A route from '" ~ source.name ~ "' to '" ~ destination.name ~ "' already exists");
    if (landscape.wouldCreateCycle(route.sourceNodeId, route.destinationNodeId))
      return errorResult(422, "Route '" ~ source.name ~ "' → '" ~ destination.name
          ~ "' would create a cycle in the transport landscape");

    routes.save(route);
    return okResult(route.id.value, "Transport route '" ~ route.name ~ "' created");
  }

  UsecaseResult updateRoute(UpdateRouteInput input) {
    auto route = routes.findById(input.tenantId, input.routeId);
    if (route.isNull)
      return notFoundResult("Transport route", input.routeId.value);

    RouteStatus status = route.status;
    if (input.status.length > 0 && !tryParseEnum!RouteStatus(input.status, status))
      return errorResult(400, "Invalid route status '" ~ input.status ~ "'");

    auto name = input.name.strip;
    if (name.length > 0 && name != route.name) {
      if (routes.findByTenant(input.tenantId).any!(r => r.name == name && r.id != route.id))
        return errorResult(409, "A transport route named '" ~ name ~ "' already exists");
      route.name = name;
    }
    route.description = input.description;
    route.status = status;
    route.isSequential = input.isSequential;
    route.sequence = input.sequence;
    route.update(input.updatedBy);
    routes.update(route);
    return okResult(route.id.value, "Transport route '" ~ route.name ~ "' updated");
  }

  UsecaseResult enableRoute(TenantId tenantId, TransportRouteId id) {
    return setStatus(tenantId, id, RouteStatus.enabled);
  }

  UsecaseResult disableRoute(TenantId tenantId, TransportRouteId id) {
    return setStatus(tenantId, id, RouteStatus.disabled);
  }

  protected UsecaseResult setStatus(TenantId tenantId, TransportRouteId id, RouteStatus status) {
    auto route = routes.findById(tenantId, id);
    if (route.isNull)
      return notFoundResult("Transport route", id.value);
    route.status = status;
    route.update();
    routes.update(route);
    return okResult(id.value, "Transport route '" ~ route.name ~ "' " ~ enumName(status));
  }

  UsecaseResult deleteRoute(TenantId tenantId, TransportRouteId id) {
    auto route = routes.findById(tenantId, id);
    if (route.isNull)
      return notFoundResult("Transport route", id.value);
    routes.remove(route);
    return okResult(id.value, "Transport route '" ~ route.name ~ "' deleted");
  }

  bool hasRoute(TenantId tenantId, TransportRouteId id) {
    return routes.existsById(tenantId, id);
  }

  TransportRoute getRoute(TenantId tenantId, TransportRouteId id) {
    return routes.findById(tenantId, id);
  }

  TransportRoute[] listRoutes(TenantId tenantId) {
    return routes.findByTenant(tenantId)
      .sort!((a, b) => a.sequence == b.sequence ? a.name < b.name : a.sequence < b.sequence).array;
  }

  TransportRoute[] listRoutesBySourceNode(TenantId tenantId, TransportNodeId nodeId) {
    return routes.findBySourceNode(tenantId, nodeId);
  }

  TransportRoute[] listRoutesByDestinationNode(TenantId tenantId, TransportNodeId nodeId) {
    return routes.findByDestinationNode(tenantId, nodeId);
  }
}
