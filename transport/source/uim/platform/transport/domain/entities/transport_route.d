/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.entities.transport_route;

import uim.platform.transport;

// mixin(ShowModule!());

@safe:

/// Directed connection from a source node to a destination node.
/// Models the transport landscape topology (linear, star, or complex pipelines).
struct TransportRoute {
    mixin TenantEntity!TransportRouteId;

    string name;
    string description;
    TransportNodeId sourceNodeId;
    TransportNodeId destinationNodeId;
    RouteStatus status = RouteStatus.enabled;
    bool isSequential = true;
    int sequence = 0;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("sourceNodeId", sourceNodeId.value)
            .set("destinationNodeId", destinationNodeId.value)
            .set("status", status.to!string)
            .set("isSequential", isSequential)
            .set("sequence", sequence);
    }
}
