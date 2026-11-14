/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.entities.transport_route;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Directed connection from a source node to a destination node.
/// Routes model the landscape topology (linear DEV → QA → PROD, star, or
/// combinations); the landscape must stay acyclic.
struct TransportRoute {
  mixin TenantEntity!TransportRouteId;

  string name;
  string description;
  TransportNodeId sourceNodeId;
  TransportNodeId destinationNodeId;
  RouteStatus status = RouteStatus.enabled;
  bool isSequential = true;
  int sequence = 0;

  bool isEnabled() const {
    return status == RouteStatus.enabled;
  }

  bool connects(TransportNodeId source, TransportNodeId destination) const {
    return sourceNodeId == source && destinationNodeId == destination;
  }

  bool touches(TransportNodeId node) const {
    return sourceNodeId == node || destinationNodeId == node;
  }

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("sourceNodeId", sourceNodeId.value)
      .set("destinationNodeId", destinationNodeId.value)
      .set("status", enumName(status))
      .set("isSequential", isSequential)
      .set("sequence", sequence);
  }
}
