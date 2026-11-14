/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// State machines of instances, bindings and operations.
///
///   Instance:  creating → created | failed | deleting
///              created  → updating | deleting | orphaned
///              updating → created | failed
///              failed   → updating | deleting
///              deleting → failed            (removal itself ends the lifecycle)
///              orphaned → deleting
///
///   Binding:   creating → created | failed | deleting
///              created  → deleting
///              failed   → deleting
///              deleting → failed
///
///   Operation: pending → inProgress | succeeded | failed
///              inProgress → succeeded | failed
module uim.platform.service_manager.domain.services.lifecycle;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

bool canTransition(ServiceInstanceStatus from, ServiceInstanceStatus to) {
  with (ServiceInstanceStatus) final switch (from) {
  case creating:
    return to == created || to == failed || to == deleting;
  case created:
    return to == updating || to == deleting || to == orphaned;
  case updating:
    return to == created || to == failed;
  case failed:
    return to == updating || to == deleting;
  case deleting:
    return to == failed;
  case orphaned:
    return to == deleting;
  }
}

bool canTransition(ServiceBindingStatus from, ServiceBindingStatus to) {
  with (ServiceBindingStatus) final switch (from) {
  case creating:
    return to == created || to == failed || to == deleting;
  case created:
    return to == deleting;
  case failed:
    return to == deleting;
  case deleting:
    return to == failed;
  }
}

bool canTransition(OperationStatus from, OperationStatus to) {
  with (OperationStatus) final switch (from) {
  case pending:
    return to == inProgress || to == succeeded || to == failed;
  case inProgress:
    return to == succeeded || to == failed;
  case succeeded, failed:
    return false;
  }
}

private void ensure(S)(S from, S to, string what) {
  if (from != to && !canTransition(from, to))
    throw ServiceManagerException.ruleViolation(what ~ " cannot change from '" ~ cast(string) from ~ "' to '" ~ cast(
        string) to ~ "'");
}

void ensureInstanceTransition(ServiceInstanceStatus from, ServiceInstanceStatus to) {
  ensure(from, to, "Service instance");
}

void ensureBindingTransition(ServiceBindingStatus from, ServiceBindingStatus to) {
  ensure(from, to, "Service binding");
}

void ensureOperationTransition(OperationStatus from, OperationStatus to) {
  if (from == to && (from == OperationStatus.succeeded || from == OperationStatus.failed))
    throw ServiceManagerException.ruleViolation("Operation is already " ~ cast(string) from);
  ensure(from, to, "Operation");
}

///
unittest {
  assert(canTransition(ServiceInstanceStatus.creating, ServiceInstanceStatus.created));
  assert(!canTransition(ServiceInstanceStatus.deleting, ServiceInstanceStatus.created));
  assert(canTransition(ServiceBindingStatus.created, ServiceBindingStatus.deleting));
  assert(!canTransition(OperationStatus.failed, OperationStatus.succeeded));
  ensureInstanceTransition(ServiceInstanceStatus.created, ServiceInstanceStatus.created); // no-op
  assert(failsWith(ServiceManagerErrorKind.ruleViolation, () {
      ensureOperationTransition(OperationStatus.succeeded, OperationStatus.succeeded);
    }));
}
