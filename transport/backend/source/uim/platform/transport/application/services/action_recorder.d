/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.services.action_recorder;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Writes the audit trail entries produced by the transport workflow.
class TransportActionRecorder {
  protected ITransportActionRepository repo;

  this(ITransportActionRepository repo) {
    this.repo = repo;
  }

  TransportAction record(TenantId tenantId, ActionType type, ActionStatus status,
      TransportNodeId nodeId, TransportRequestId requestId, string performedBy,
      string description, string log = "", string error = "", TransportRouteId routeId = TransportRouteId.init) {
    auto now = Clock.currStdTime();
    auto a = TransportAction(tenantId);
    a.actionType = type;
    a.nodeId = nodeId;
    a.requestId = requestId;
    a.routeId = routeId;
    a.performedBy = actor(performedBy);
    a.createdBy = UserId(a.performedBy);
    a.performedAt = now;
    a.description = description;
    a.logDetails = log;
    a.complete(status, now, error);
    repo.save(a);
    return a;
  }
}

/// Map an import result to the status of the recorded action.
ActionStatus toActionStatus(ImportStatus status) {
  switch (status) {
  case ImportStatus.success:
    return ActionStatus.success;
  case ImportStatus.warning:
    return ActionStatus.warning;
  case ImportStatus.failed:
    return ActionStatus.failed;
  case ImportStatus.running:
    return ActionStatus.running;
  default:
    return ActionStatus.initial;
  }
}
