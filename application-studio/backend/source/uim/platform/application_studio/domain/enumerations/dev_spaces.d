/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.enumerations.dev_spaces;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Service plan of a dev space; it limits count, parallel runs and sizes (see domain.services.plan_policy).
enum DevSpacePlan {
  free_, /// "free" (trial)
  standard,
  professional,
}

/// Lifecycle status of a dev space.
///
///   starting → running → stopping → stopped → starting
///   running → hibernating → hibernated → resuming → running   (inactivity)
///   stopped | hibernated | error → deleting → (removed)
enum DevSpaceStatus {
  starting,
  running,
  stopping,
  stopped,
  hibernating,
  hibernated,
  resuming,
  deleting,
  error,
}

/// True for states the reconciler still has to drive.
bool isTransitional(DevSpaceStatus s) pure nothrow {
  with (DevSpaceStatus)
    return s == starting || s == stopping || s == hibernating || s == resuming || s == deleting;
}

/// True while the dev space occupies compute (counts against the running limit).
bool occupiesCompute(DevSpaceStatus s) pure nothrow {
  with (DevSpaceStatus)
    return s == starting || s == running || s == resuming;
}

/// Origin of a dev space type.
enum DevSpaceTypeCategory {
  predefined, /// shipped with the service (protected)
  custom, /// defined by the tenant
  thirdParty,
}

///
unittest {
  assert(enumText(DevSpacePlan.free_) == "free");
  assert(parseEnum!DevSpacePlan("FREE", DevSpacePlan.standard) == DevSpacePlan.free_);
  assert(DevSpaceStatus.deleting.isTransitional && !DevSpaceStatus.running.isTransitional);
  assert(DevSpaceStatus.resuming.occupiesCompute && !DevSpaceStatus.hibernated.occupiesCompute);
}
