/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.dtos.action;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Manually record an entry in the transport audit trail.
struct RecordActionInput {
  TenantId tenantId;
  string id;
  string actionType; /// ActionType name (export, import, forward, reset, delete, schedule)
  string actionStatus; /// ActionStatus name, default initial
  string nodeId;
  string requestId;
  string routeId;
  string performedBy;
  string description;
  string logDetails;
  string errorMessage;
}
