/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.ports.usecases.manage_actions;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Driving port: the transport audit trail.
interface IManageTransportActionsUseCase {
  UsecaseResult recordAction(RecordActionInput input);
  UsecaseResult updateActionStatus(TenantId tenantId, TransportActionId id, ActionStatus status, string errorMessage = "");

  bool hasAction(TenantId tenantId, TransportActionId id);
  TransportAction getAction(TenantId tenantId, TransportActionId id);
  /// Newest first.
  TransportAction[] listActions(TenantId tenantId);
  TransportAction[] listActionsByNode(TenantId tenantId, TransportNodeId nodeId);
  TransportAction[] listActionsByRequest(TenantId tenantId, TransportRequestId requestId);
  TransportAction[] listActionsByStatus(TenantId tenantId, ActionStatus actionStatus);
}
