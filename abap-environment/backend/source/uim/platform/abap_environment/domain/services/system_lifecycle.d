/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Allowed status transitions of an ABAP system instance.
module uim.platform.abap_environment.domain.services.system_lifecycle;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// The system an aggregate belongs to (transports: their source system).
SystemInstanceId systemOf(TEntity)(const TEntity entity) {
  static if (is(TEntity == SystemInstance))
    return entity.id;
  else static if (is(TEntity == TransportRequest))
    return entity.sourceSystemId;
  else
    return entity.systemInstanceId;
}

/// True if a system may move from `from` to `target`.
///
///   provisioning → active | error
///   active       → updating | suspended | deleting
///   updating     → active | error
///   suspended    → active | deleting
///   deleting     → error           (completion removes the system)
///   error        → deleting
bool canTransition(SystemStatus from, SystemStatus target) pure nothrow {
  final switch (from) {
  case SystemStatus.provisioning:
    return target == SystemStatus.active || target == SystemStatus.error;
  case SystemStatus.active:
    return target == SystemStatus.updating || target == SystemStatus.suspended || target == SystemStatus.deleting;
  case SystemStatus.updating:
    return target == SystemStatus.active || target == SystemStatus.error;
  case SystemStatus.suspended:
    return target == SystemStatus.active || target == SystemStatus.deleting;
  case SystemStatus.deleting:
    return target == SystemStatus.error;
  case SystemStatus.error:
    return target == SystemStatus.deleting;
  }
}

/// Move `system` to `target` or throw a conflict.
void transitionTo(ref SystemInstance system, SystemStatus target) {
  ensureState(canTransition(system.status, target), "System '" ~ system.name ~ "' cannot change from '"
      ~ enumText(system.status) ~ "' to '" ~ enumText(target) ~ "'");
  system.status = target;
}

/// The system must be active to accept development, users and jobs.
void requireActive(const SystemInstance system, string forWhat) {
  ensureState(system.status == SystemStatus.active, "System '" ~ system.name ~ "' must be active to "
      ~ forWhat ~ " (status: " ~ enumText(system.status) ~ ")");
}

///
unittest {
  assert(canTransition(SystemStatus.provisioning, SystemStatus.active));
  assert(!canTransition(SystemStatus.provisioning, SystemStatus.suspended));
  assert(canTransition(SystemStatus.suspended, SystemStatus.active));
  assert(!canTransition(SystemStatus.deleting, SystemStatus.active));

  SystemInstance s;
  s.name = "dev";
  s.status = SystemStatus.active;
  transitionTo(s, SystemStatus.suspended);
  assert(s.status == SystemStatus.suspended);
  bool conflict;
  try
    transitionTo(s, SystemStatus.updating);
  catch (AbapConflictException)
    conflict = true;
  assert(conflict);
}
