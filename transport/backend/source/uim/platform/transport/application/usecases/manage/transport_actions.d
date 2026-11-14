/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.usecases.manage.transport_actions;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class ManageTransportActionsUseCase : IManageTransportActionsUseCase {
  protected ITransportActionRepository actions;

  this(ITransportActionRepository actions) {
    this.actions = actions;
  }

  UsecaseResult recordAction(RecordActionInput input) {
    auto a = TransportAction(input.tenantId);
    if (input.id.length > 0)
      a.id = TransportActionId(input.id);
    if (actions.existsById(input.tenantId, a.id))
      return errorResult(409, "Transport action '" ~ a.id.value ~ "' already exists");

    if (input.actionType.length > 0 && !tryParseEnum!ActionType(input.actionType, a.actionType))
      return errorResult(400, "Invalid actionType '" ~ input.actionType ~ "' (" ~ enumNames!ActionType.join(", ") ~ ")");
    if (input.actionStatus.length > 0 && !tryParseEnum!ActionStatus(input.actionStatus, a.actionStatus))
      return errorResult(400, "Invalid actionStatus '" ~ input.actionStatus ~ "'");

    a.nodeId = TransportNodeId(input.nodeId);
    a.requestId = TransportRequestId(input.requestId);
    a.routeId = TransportRouteId(input.routeId);
    a.performedBy = input.performedBy;
    a.createdBy = UserId(input.performedBy);
    a.performedAt = Clock.currStdTime();
    a.description = input.description;
    a.logDetails = input.logDetails;
    a.errorMessage = input.errorMessage;
    if (a.actionStatus != ActionStatus.initial && a.actionStatus != ActionStatus.running)
      a.completedAt = a.performedAt;

    auto invalid = TransportValidator.validateAction(a);
    if (invalid.length > 0)
      return errorResult(400, "Invalid action: " ~ invalid);
    actions.save(a);
    return okResult(a.id.value, "Transport action recorded");
  }

  UsecaseResult updateActionStatus(TenantId tenantId, TransportActionId id, ActionStatus status, string errorMessage = "") {
    auto a = actions.findById(tenantId, id);
    if (a.isNull)
      return notFoundResult("Transport action", id.value);
    if (status == ActionStatus.initial || status == ActionStatus.running) {
      a.actionStatus = status;
      a.update();
    } else {
      a.complete(status, Clock.currStdTime(), errorMessage);
    }
    actions.update(a);
    return okResult(id.value, "Transport action set to " ~ enumName(status));
  }

  bool hasAction(TenantId tenantId, TransportActionId id) {
    return actions.existsById(tenantId, id);
  }

  TransportAction getAction(TenantId tenantId, TransportActionId id) {
    return actions.findById(tenantId, id);
  }

  TransportAction[] listActions(TenantId tenantId) {
    return newestFirst(actions.findByTenant(tenantId));
  }

  TransportAction[] listActionsByNode(TenantId tenantId, TransportNodeId nodeId) {
    return newestFirst(actions.findByNode(tenantId, nodeId));
  }

  TransportAction[] listActionsByRequest(TenantId tenantId, TransportRequestId requestId) {
    return newestFirst(actions.findByRequest(tenantId, requestId));
  }

  TransportAction[] listActionsByStatus(TenantId tenantId, ActionStatus actionStatus) {
    return newestFirst(actions.findByStatus(tenantId, actionStatus));
  }

  protected static TransportAction[] newestFirst(TransportAction[] items) {
    return items.sort!((a, b) => a.performedAt > b.performedAt).array;
  }
}
