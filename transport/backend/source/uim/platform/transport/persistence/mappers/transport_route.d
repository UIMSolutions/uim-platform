/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.persistence.mappers.transport_route;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

struct TransportRouteMapper {
  static Json toRecord(const TransportRoute e) {
    auto r = baseRecord(e);
    r["name"] = e.name;
    r["description"] = e.description;
    r["sourceNodeId"] = e.sourceNodeId.value;
    r["destinationNodeId"] = e.destinationNodeId.value;
    r["status"] = enumName(e.status);
    r["isSequential"] = e.isSequential;
    r["sequence"] = e.sequence;
    return r;
  }

  static TransportRoute fromRecord(Json r) {
    TransportRoute e;
    readBase(e, r);
    e.name = fieldString(r, "name");
    e.description = fieldString(r, "description");
    e.sourceNodeId = TransportNodeId(fieldString(r, "sourceNodeId"));
    e.destinationNodeId = TransportNodeId(fieldString(r, "destinationNodeId"));
    e.status = fieldEnum!RouteStatus(r, "status", RouteStatus.enabled);
    e.isSequential = fieldBool(r, "isSequential", true);
    e.sequence = fieldInt(r, "sequence");
    return e;
  }
}
