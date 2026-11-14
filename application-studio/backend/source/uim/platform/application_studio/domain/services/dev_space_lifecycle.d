/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Allowed status transitions of dev spaces and the scope of the child aggregates.
module uim.platform.application_studio.domain.services.dev_space_lifecycle;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// The dev space an aggregate belongs to.
DevSpaceId devSpaceOf(TEntity)(const TEntity entity) {
  static if (is(TEntity == DevSpace))
    return entity.id;
  else static if (__traits(hasMember, TEntity, "devSpaceId"))
    return entity.devSpaceId;
  else
    return DevSpaceId.init;
}

/// The project an aggregate belongs to.
ProjectId projectOf(TEntity)(const TEntity entity) {
  static if (is(TEntity == Project))
    return entity.id;
  else static if (__traits(hasMember, TEntity, "projectId"))
    return entity.projectId;
  else
    return ProjectId.init;
}

/// True if a dev space may move from `from` to `target`.
///
///   starting    → running | error
///   running     → stopping | hibernating
///   stopping    → stopped | error
///   stopped     → starting | deleting
///   hibernating → hibernated | error
///   hibernated  → resuming | deleting
///   resuming    → running | error
///   deleting    → error          (completion removes the dev space)
///   error       → starting | deleting
bool canTransition(DevSpaceStatus from, DevSpaceStatus target) pure nothrow {
  with (DevSpaceStatus) final switch (from) {
  case starting:
    return target == running || target == error;
  case running:
    return target == stopping || target == hibernating;
  case stopping:
    return target == stopped || target == error;
  case stopped:
    return target == starting || target == deleting;
  case hibernating:
    return target == hibernated || target == error;
  case hibernated:
    return target == resuming || target == deleting;
  case resuming:
    return target == running || target == error;
  case deleting:
    return target == error;
  case error:
    return target == starting || target == deleting;
  }
}

/// Move `ds` to `target` or throw a conflict.
void transitionTo(ref DevSpace ds, DevSpaceStatus target) {
  ensureState(canTransition(ds.status, target), "Dev space '" ~ ds.name ~ "' cannot change from '"
      ~ enumText(ds.status) ~ "' to '" ~ enumText(target) ~ "'");
  ds.status = target;
}

/// Projects are created and launched only in a running dev space.
void requireRunning(const DevSpace ds, string forWhat) {
  ensureState(ds.status == DevSpaceStatus.running, "Dev space '" ~ ds.name ~ "' must be running to "
      ~ forWhat ~ " (status: " ~ enumText(ds.status) ~ ")");
}

/// True if a running dev space has been idle long enough to hibernate.
bool isIdle(const DevSpace ds, long now) pure nothrow {
  if (ds.status != DevSpaceStatus.running || ds.hibernateAfterDays <= 0)
    return false;
  auto last = ds.lastAccessedAt > 0 ? ds.lastAccessedAt : ds.startedAt;
  return last > 0 && now - last >= ds.hibernateAfterDays * stdTimeDay;
}

///
unittest {
  assert(canTransition(DevSpaceStatus.starting, DevSpaceStatus.running));
  assert(!canTransition(DevSpaceStatus.running, DevSpaceStatus.deleting)); // stop first
  assert(canTransition(DevSpaceStatus.hibernated, DevSpaceStatus.resuming));
  assert(!canTransition(DevSpaceStatus.deleting, DevSpaceStatus.starting));

  DevSpace ds;
  ds.name = "dev";
  ds.status = DevSpaceStatus.running;
  ds.hibernateAfterDays = 2;
  ds.startedAt = 1;
  assert(!isIdle(ds, 1 + stdTimeDay));
  assert(isIdle(ds, 1 + 2 * stdTimeDay));
  ds.lastAccessedAt = 2 * stdTimeDay;
  assert(!isIdle(ds, 1 + 2 * stdTimeDay));

  transitionTo(ds, DevSpaceStatus.stopping);
  bool conflict;
  try
    transitionTo(ds, DevSpaceStatus.running);
  catch (StudioConflictException)
    conflict = true;
  assert(conflict);

  Project p;
  p.devSpaceId = DevSpaceId("d1");
  assert(devSpaceOf(p).value == "d1");
  RunConfiguration r;
  r.projectId = ProjectId("p1");
  assert(projectOf(r).value == "p1");
}
