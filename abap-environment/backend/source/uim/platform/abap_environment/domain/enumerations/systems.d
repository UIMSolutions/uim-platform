/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.enumerations.systems;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Service plan of an ABAP environment instance.
enum SystemPlan {
  standard,
  free_, /// "free"
  development,
  test,
  production,
}

/// Lifecycle status of an ABAP system instance.
///
///   provisioning → active ⇄ suspended
///   active → updating → active
///   active | suspended | error → deleting → (removed)
enum SystemStatus {
  provisioning,
  active,
  updating,
  suspended,
  deleting,
  error,
}

/// True for states the reconciler still has to drive.
bool isTransitional(SystemStatus s) pure nothrow {
  return s == SystemStatus.provisioning || s == SystemStatus.updating || s == SystemStatus.deleting;
}

///
unittest {
  assert(enumText(SystemPlan.free_) == "free");
  assert(parseEnum!SystemPlan("FREE", SystemPlan.standard) == SystemPlan.free_);
  assert(SystemStatus.deleting.isTransitional && !SystemStatus.active.isTransitional);
}
