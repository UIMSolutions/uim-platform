/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.ports.usecases.manage_operations;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface IManageOperations {
  Operation[] listOperations(TenantId tenantId);
  Operation getOperation(TenantId tenantId, OperationId id);
  /// Finish an in-progress operation and apply the result to its resource.
  Operation completeOperation(CompleteOperationRequest request);
  /// Only final operations can be removed.
  void deleteOperation(TenantId tenantId, OperationId id);
}
