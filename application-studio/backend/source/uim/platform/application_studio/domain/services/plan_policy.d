/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Limits of the dev space plans.
module uim.platform.application_studio.domain.services.plan_policy;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// What a plan allows per tenant (count / running) and per dev space (sizes).
struct PlanLimits {
  int maxDevSpaces;
  int maxRunning;
  int maxMemoryMb;
  int maxDiskGb;
  int maxHibernateAfterDays;
}

PlanLimits limitsOf(DevSpacePlan plan) pure nothrow {
  final switch (plan) {
  case DevSpacePlan.free_:
    return PlanLimits(2, 1, 4096, 10, 7);
  case DevSpacePlan.standard:
    return PlanLimits(10, 2, 8192, 20, 14);
  case DevSpacePlan.professional:
    return PlanLimits(50, 10, 16_384, 64, 30);
  }
}

/// Check the sizes of a dev space against its plan.
void validateSizing(const ref DevSpace ds) {
  auto l = limitsOf(ds.plan);
  auto plan = enumText(ds.plan);
  validate(ds.memoryLimitMb >= 1024 && ds.memoryLimitMb % 512 == 0,
    "Memory must be a multiple of 512 MB and at least 1024 MB");
  validate(ds.memoryLimitMb <= l.maxMemoryMb, "The " ~ plan ~ " plan allows at most " ~ l.maxMemoryMb.to!string ~ " MB memory");
  validate(ds.diskLimitGb >= 1, "Disk must be at least 1 GB");
  validate(ds.diskLimitGb <= l.maxDiskGb, "The " ~ plan ~ " plan allows at most " ~ l.maxDiskGb.to!string ~ " GB disk");
  validate(ds.hibernateAfterDays >= 0, "Hibernation delay must not be negative");
  // free dev spaces always hibernate; 0 (= never) only on paid plans
  validate(ds.hibernateAfterDays <= l.maxHibernateAfterDays && (ds.hibernateAfterDays > 0 || ds.plan != DevSpacePlan.free_),
    "The " ~ plan ~ " plan hibernates idle dev spaces after 1–" ~ l.maxHibernateAfterDays.to!string ~ " days");
}

/// A new dev space may only be created while the tenant is below its plan's count.
void ensureCapacity(DevSpacePlan plan, size_t existingOfPlan) {
  auto l = limitsOf(plan);
  ensureState(existingOfPlan < l.maxDevSpaces, "The " ~ enumText(plan) ~ " plan allows at most "
      ~ l.maxDevSpaces.to!string ~ " dev spaces per tenant");
}

/// A dev space may only start while fewer than maxRunning of its plan occupy compute.
void ensureRunSlot(DevSpacePlan plan, size_t runningOfPlan) {
  auto l = limitsOf(plan);
  ensureState(runningOfPlan < l.maxRunning, "The " ~ enumText(plan) ~ " plan allows only "
      ~ l.maxRunning.to!string ~ " running dev space(s) — stop another one first");
}

///
unittest {
  DevSpace ds;
  ds.plan = DevSpacePlan.free_;
  ds.memoryLimitMb = 4096;
  ds.diskLimitGb = 10;
  ds.hibernateAfterDays = 7;
  validateSizing(ds);

  bool failed(void delegate() @safe f) {
    try
      f();
    catch (StudioException)
      return true;
    return false;
  }

  ds.memoryLimitMb = 8192;
  assert(failed(() => validateSizing(ds)));
  ds.memoryLimitMb = 4096;
  ds.hibernateAfterDays = 0;
  assert(failed(() => validateSizing(ds)));
  ds.plan = DevSpacePlan.professional;
  validateSizing(ds);

  ensureCapacity(DevSpacePlan.free_, 1);
  assert(failed(() => ensureCapacity(DevSpacePlan.free_, 2)));
  assert(failed(() => ensureRunSlot(DevSpacePlan.free_, 1)));
}
