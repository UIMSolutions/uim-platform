/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.domain.entities.operation;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Tracks a (possibly asynchronous) broker operation on an instance or binding.
struct Operation {
  mixin TenantEntity!OperationId;

  ResourceType resourceType = ResourceType.serviceInstance;
  string resourceId;
  OperationType type = OperationType.create;
  OperationStatus status = OperationStatus.pending;
  string description;
  string errorMessage;
  int rescheduleCount;
  long startedAt;
  long completedAt;

  bool isFinal() const {
    return status == OperationStatus.succeeded || status == OperationStatus.failed;
  }

  void start(long at) {
    ensureOperationTransition(status, OperationStatus.inProgress);
    status = OperationStatus.inProgress;
    startedAt = at;
  }

  void succeed(long at) {
    ensureOperationTransition(status, OperationStatus.succeeded);
    status = OperationStatus.succeeded;
    errorMessage = "";
    completedAt = at;
  }

  void fail(string error, long at) {
    ensureOperationTransition(status, OperationStatus.failed);
    status = OperationStatus.failed;
    errorMessage = error.length > 0 ? error : "Operation failed";
    completedAt = at;
  }
}

///
unittest {
  Operation op;
  op.start(1);
  op.succeed(2);
  assert(op.isFinal && op.completedAt == 2);
  assert(failsWith(ServiceManagerErrorKind.ruleViolation, () { op.fail("late", 3); }));
}
