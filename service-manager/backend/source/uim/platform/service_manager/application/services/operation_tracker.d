/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Creates and finishes Operation records for broker calls.
module uim.platform.service_manager.application.services.operation_tracker;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Synchronous: broker calls finish within the request (operations succeed
/// at once). Asynchronous: operations stay inProgress until
/// IManageOperations.completeOperation is called (e.g. by a broker callback).
enum ProvisioningMode {
  synchronous,
  asynchronous
}

class OperationTracker {
  protected IOperationRepository operations;
  ProvisioningMode mode;

  this(IOperationRepository operations, ProvisioningMode mode) {
    this.operations = operations;
    this.mode = mode;
  }

  bool synchronous() const {
    return mode == ProvisioningMode.synchronous;
  }

  /// Start an operation (not yet stored).
  Operation begin(TenantId tenantId, UserId actor, ResourceType type, string resourceId, OperationType kind, string description) {
    Operation op;
    stampCreated!(Operation, OperationId)(op, tenantId, actor, "");
    op.resourceType = type;
    op.resourceId = resourceId;
    op.type = kind;
    op.description = description;
    op.start(op.createdAt);
    return op;
  }

  /// Finish in synchronous mode and store.
  void finish(ref Operation op) {
    if (synchronous)
      op.succeed(nowStdTime());
    op.updatedAt = nowStdTime();
    operations.save(op);
  }
}
