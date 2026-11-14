/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.entities.transport_action;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Audit trail record of a transport operation (export, import, forward, reset, ...).
struct TransportAction {
  mixin TenantEntity!TransportActionId;

  ActionType actionType = ActionType.export_;
  ActionStatus actionStatus = ActionStatus.initial;
  TransportNodeId nodeId;
  TransportRequestId requestId;
  TransportRouteId routeId;
  string performedBy;
  long performedAt;
  long completedAt;
  string description;
  string errorMessage;
  string logDetails;

  void complete(ActionStatus result, long now, string error = "") {
    actionStatus = result;
    completedAt = now;
    errorMessage = error;
    updatedAt = now;
  }

  Json toJson() const {
    return entityToJson
      .set("actionType", enumName(actionType))
      .set("actionStatus", enumName(actionStatus))
      .set("nodeId", nodeId.value)
      .set("requestId", requestId.value)
      .set("routeId", routeId.value)
      .set("performedBy", performedBy)
      .set("performedAt", performedAt)
      .set("completedAt", completedAt)
      .set("description", description)
      .set("errorMessage", errorMessage)
      .set("logDetails", logDetails);
  }
}
