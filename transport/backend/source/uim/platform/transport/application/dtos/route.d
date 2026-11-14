/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.dtos.route;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

struct CreateRouteInput {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string sourceNodeId;
  string destinationNodeId;
  string status; /// RouteStatus name, default enabled
  bool isSequential = true;
  int sequence;
  UserId createdBy;
}

struct UpdateRouteInput {
  TenantId tenantId;
  TransportRouteId routeId;
  string name;
  string description;
  string status;
  bool isSequential = true;
  int sequence;
  UserId updatedBy;

  static UpdateRouteInput from(const TransportRoute r) {
    UpdateRouteInput u;
    u.tenantId = r.tenantId;
    u.routeId = r.id;
    u.name = r.name;
    u.description = r.description;
    u.status = enumName(r.status);
    u.isSequential = r.isSequential;
    u.sequence = r.sequence;
    return u;
  }
}
