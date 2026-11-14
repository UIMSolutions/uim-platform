/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.domain.enumerations.operation;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Kind of an (asynchronous) broker operation.
enum OperationType : string {
  create = "create",
  update = "update",
  delete_ = "delete",
  bind = "bind",
  unbind = "unbind"
}

/// Progress of an operation. succeeded and failed are final.
enum OperationStatus : string {
  pending = "pending",
  inProgress = "inProgress",
  succeeded = "succeeded",
  failed = "failed"
}
