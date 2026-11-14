/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.dtos.operation;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct CompleteOperationRequest {
  TenantId tenantId;
  UserId actor;
  OperationId id;

  bool succeeded = true;
  string errorMessage;
}
