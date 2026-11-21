/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Governance lifecycle of a building block (architecture repository).
module uim.platform.architecture.domain.enumerations.lifecycle;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

enum LifecycleStatus : string {
  proposed = "proposed", /// identified, not yet reviewed by the architecture board
  approved = "approved", /// accepted as standard / target
  inDevelopment = "inDevelopment", /// being built or introduced
  active = "active", /// in production use
  deprecated_ = "deprecated", /// still in use, phase-out planned — no new usage
  retired = "retired" /// no longer in use (kept for traceability)
}

LifecycleStatus parseLifecycleStatus(string text) {
  // historic values of the 1.x API
  switch (enumKey(text)) {
  case "identified", "draft", "candidate":
    return LifecycleStatus.proposed;
  case "development", "indevelopment", "building":
    return LifecycleStatus.inDevelopment;
  case "production", "live":
    return LifecycleStatus.active;
  case "deprecated", "phaseout", "sunset":
    return LifecycleStatus.deprecated_;
  case "decommissioned", "obsolete", "endoflife":
    return LifecycleStatus.retired;
  default:
    return parseEnumValue!LifecycleStatus(text, "Lifecycle status");
  }
}

/// Approved, in development or active — the block is (going to be) used.
bool isInUse(LifecycleStatus s) pure {
  return s == LifecycleStatus.approved || s == LifecycleStatus.inDevelopment || s == LifecycleStatus.active;
}

/// Deprecated or retired — nothing new should depend on it.
bool isPhasingOut(LifecycleStatus s) pure {
  return s == LifecycleStatus.deprecated_ || s == LifecycleStatus.retired;
}

///
unittest {
  assert(parseLifecycleStatus("identified") == LifecycleStatus.proposed);
  assert(parseLifecycleStatus("DEPRECATED") == LifecycleStatus.deprecated_);
  assert(parseLifecycleStatus("in-development") == LifecycleStatus.inDevelopment);
  assert(isInUse(LifecycleStatus.active) && !isInUse(LifecycleStatus.retired));
  assert(isPhasingOut(LifecycleStatus.deprecated_) && !isPhasingOut(LifecycleStatus.proposed));
}
