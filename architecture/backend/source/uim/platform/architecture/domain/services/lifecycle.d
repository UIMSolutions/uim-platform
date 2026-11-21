/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Lifecycle governance: allowed status transitions and deletion rules.
///
///   proposed ──► approved ──► inDevelopment ──► active ──► deprecated ──► retired
///      │  ▲          │  ▲            │                         │
///      │  └──────────┘  └────────────┘ (back to review)        └──► active (reinstated)
///      └──► retired (rejected)       approved/inDevelopment ──► retired (cancelled)
module uim.platform.architecture.domain.services.lifecycle;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

private alias S = LifecycleStatus;

/// Target states reachable from a state.
LifecycleStatus[] nextStatuses(LifecycleStatus from) pure {
  final switch (from) {
  case S.proposed:
    return [S.approved, S.retired];
  case S.approved:
    return [S.proposed, S.inDevelopment, S.active, S.retired];
  case S.inDevelopment:
    return [S.approved, S.active, S.retired];
  case S.active:
    return [S.deprecated_];
  case S.deprecated_:
    return [S.active, S.retired];
  case S.retired:
    return [];
  }
}

bool canTransition(LifecycleStatus from, LifecycleStatus to) pure {
  return from == to || nextStatuses(from).canFind(to);
}

/// Throws ruleViolation for a forbidden transition.
void requireTransition(LifecycleStatus from, LifecycleStatus to) {
  if (canTransition(from, to))
    return;
  auto allowed = nextStatuses(from).map!(s => cast(string) s).array;
  throw ArchitectureException.ruleViolation(format("A %s building block cannot become %s (allowed: %s)", cast(string) from,
      cast(string) to, allowed.length ? allowed.join(", ") : "none — retired is final"));
}

/// Blocks in use (active) or still in use (deprecated) must be retired first.
void requireDeletable(const BuildingBlock b) {
  if (b.status == S.active || b.status == S.deprecated_)
    throw ArchitectureException.ruleViolation(format("Building block '%s' is %s — deprecate and retire it before deleting",
        b.id.value, cast(string) b.status));
}

///
unittest {
  assert(canTransition(S.proposed, S.approved) && canTransition(S.active, S.active));
  assert(!canTransition(S.proposed, S.active) && !canTransition(S.retired, S.active));
  assert(failsWith(ArchitectureErrorKind.ruleViolation, () { requireTransition(S.active, S.proposed); }));
  BuildingBlock b;
  b.status = S.active;
  assert(failsWith(ArchitectureErrorKind.ruleViolation, () { requireDeletable(b); }));
  b.status = S.retired;
  requireDeletable(b);
}
