/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Lifecycle (status transition) rules of the Agentry domain objects.
/// Pure business logic — no persistence, no framework.
module uim.platform.agentry.domain.services.lifecycle;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Statuses reachable from `from` (excluding staying in the same status).
AppStatus[] nextStatuses(AppStatus from) pure nothrow {
  final switch (from) with (AppStatus) {
  case draft:
    return [active, archived];
  case active:
    return [deprecated_, archived];
  case deprecated_:
    return [active, archived];
  case archived:
    return [];
  }
}

DefinitionStatus[] nextStatuses(DefinitionStatus from) pure nothrow {
  final switch (from) with (DefinitionStatus) {
  case draft:
    return [published, archived];
  case published:
    return [archived];
  case archived:
    return [draft];
  }
}

AppVersionStatus[] nextStatuses(AppVersionStatus from) pure nothrow {
  final switch (from) with (AppVersionStatus) {
  case pending:
    return [published, withdrawn];
  case published:
    return [deprecated_, withdrawn];
  case deprecated_:
    return [published, withdrawn];
  case withdrawn:
    return [];
  }
}

DeviceStatus[] nextStatuses(DeviceStatus from) pure nothrow {
  final switch (from) with (DeviceStatus) {
  case enrolled:
    return [active, suspended, removed];
  case active:
    return [suspended, removed];
  case suspended:
    return [active, removed];
  case removed:
    return [];
  }
}

SyncStatus[] nextStatuses(SyncStatus from) pure nothrow {
  final switch (from) with (SyncStatus) {
  case pending:
    return [inProgress, cancelled];
  case inProgress:
    return [completed, failed, cancelled];
  case completed:
    return [];
  case failed:
    return [pending]; // retry
  case cancelled:
    return [];
  }
}

DeploymentStatus[] nextStatuses(DeploymentStatus from) pure nothrow {
  final switch (from) with (DeploymentStatus) {
  case pending:
    return [deploying, failed];
  case deploying:
    return [deployed, failed];
  case deployed:
    return [rolledBack];
  case failed:
    return [pending, rolledBack];
  case rolledBack:
    return [];
  }
}

/// Backend connections may switch freely (the status reflects test results).
ConnectionStatus[] nextStatuses(ConnectionStatus from) pure nothrow {
  return [ConnectionStatus.active, ConnectionStatus.inactive, ConnectionStatus.error, ConnectionStatus.testing];
}

/// True if a status change is allowed (staying in the same status always is).
bool canTransition(E)(E from, E to) if (is(E == enum)) {
  return from == to || nextStatuses(from).canFind(to);
}

/// Throws InvalidTransitionException if the change is not allowed.
void ensureTransition(E)(string entity, E from, E to) if (is(E == enum)) {
  if (!canTransition(from, to))
    throw new InvalidTransitionException(entity, enumValue(from), enumValue(to));
}

/// Terminal statuses accept no further transitions.
bool isTerminal(E)(E status) if (is(E == enum)) {
  return nextStatuses(status).length == 0;
}
///
unittest {
  mixin(ShowTest!("lifecycle"));

  assert(canTransition(DefinitionStatus.draft, DefinitionStatus.published));
  assert(!canTransition(DefinitionStatus.published, DefinitionStatus.draft));
  assert(canTransition(AppVersionStatus.pending, AppVersionStatus.pending));
  assert(!canTransition(AppVersionStatus.withdrawn, AppVersionStatus.published));
  assert(canTransition(SyncStatus.failed, SyncStatus.pending));
  assert(isTerminal(SyncStatus.completed));
  assert(!isTerminal(DeploymentStatus.deployed));

  bool thrown;
  try
    ensureTransition("Deployment", DeploymentStatus.rolledBack, DeploymentStatus.deploying);
  catch (InvalidTransitionException e)
    thrown = e.from == "rolledBack" && e.to == "deploying";
  assert(thrown);
}
