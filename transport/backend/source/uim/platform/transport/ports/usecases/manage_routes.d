/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.ports.usecases.manage_routes;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Driving port: maintain the routes between nodes (acyclic, no duplicates).
interface IManageTransportRoutesUseCase {
  UsecaseResult createRoute(CreateRouteInput input);
  UsecaseResult updateRoute(UpdateRouteInput input);
  UsecaseResult enableRoute(TenantId tenantId, TransportRouteId id);
  UsecaseResult disableRoute(TenantId tenantId, TransportRouteId id);
  UsecaseResult deleteRoute(TenantId tenantId, TransportRouteId id);

  bool hasRoute(TenantId tenantId, TransportRouteId id);
  TransportRoute getRoute(TenantId tenantId, TransportRouteId id);
  TransportRoute[] listRoutes(TenantId tenantId);
  TransportRoute[] listRoutesBySourceNode(TenantId tenantId, TransportNodeId nodeId);
  TransportRoute[] listRoutesByDestinationNode(TenantId tenantId, TransportNodeId nodeId);
}
