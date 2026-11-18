/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Lifecycle rules: validation and planning (pure — the application layer executes the plan).
module uim.platform.object_store.domain.services.lifecycle_planner;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Validate a lifecycle rule (422 on violation).
void validateLifecycleRule(const LifecycleRule r) {
  validate(r.expirationDays >= 0 && r.transitionDays >= 0 && r.noncurrentVersionExpirationDays >= 0,
    "Lifecycle days must not be negative");
  validate(r.expirationDays > 0 || r.transitionDays > 0 || r.noncurrentVersionExpirationDays > 0,
    "Lifecycle rule '" ~ r.name ~ "' needs expirationDays, transitionDays or noncurrentVersionExpirationDays");
  validate(r.transitionDays == 0 || r.transitionStorageClass != StorageClass.standard,
    "Objects cannot transition to the standard storage class");
  validate(r.expirationDays == 0 || r.transitionDays == 0 || r.transitionDays < r.expirationDays,
    "transitionDays must be smaller than expirationDays");
}

/// Whole days between two std times.
int ageInDays(long since, long now) pure nothrow {
  return since <= 0 || now <= since ? 0 : cast(int)((now - since) / stdTimeDay);
}

/// Plan the lifecycle steps for the objects and versions of one bucket.
///
///   * expire: objects (active or archived, not on legal hold) older than
///     expirationDays — age counts from the last write (updatedAt)
///   * transition: active objects older than transitionDays whose storage
///     class is hotter than the target
///   * purgeVersion: noncurrent versions (and delete markers) older than
///     noncurrentVersionExpirationDays, unless the object is on legal hold
///
/// The first enabled rule that matches decides per object and step kind.
LifecycleStep[] planLifecycle(const LifecycleRule[] rules, const StorageObject[] objects,
    const ObjectVersion[] versions, long now) {
  LifecycleStep[] steps;
  bool[string] expired, transitioned, purged, onHold;
  foreach (ref o; objects)
    if (o.legalHold)
      onHold[o.id.value] = true;

  foreach (ref r; rules) {
    if (r.status != RuleStatus.enabled)
      continue;
    foreach (ref o; objects) {
      if (o.legalHold || !o.name.startsWith(r.prefix) || o.id.value in expired)
        continue;
      auto age = ageInDays(o.updatedAt, now);
      if (r.expirationDays > 0 && age >= r.expirationDays && o.status != ObjectStatus.deleted) {
        steps ~= LifecycleStep(LifecycleStepKind.expire, o.id, ObjectVersionId.init, o.name, o.storageClass, r.name);
        expired[o.id.value] = true;
        continue;
      }
      if (r.transitionDays > 0 && age >= r.transitionDays && o.status == ObjectStatus.active
          && temperature(o.storageClass) < temperature(r.transitionStorageClass) && o.id.value !in transitioned) {
        steps ~= LifecycleStep(LifecycleStepKind.transition, o.id, ObjectVersionId.init, o.name,
          r.transitionStorageClass, r.name);
        transitioned[o.id.value] = true;
      }
    }
    if (r.noncurrentVersionExpirationDays > 0)
      foreach (ref v; versions) {
        if (v.isLatest || !v.objectKey.startsWith(r.prefix) || v.objectId.value in onHold || v.id.value in purged)
          continue;
        if (ageInDays(v.createdAt, now) >= r.noncurrentVersionExpirationDays) {
          steps ~= LifecycleStep(LifecycleStepKind.purgeVersion, v.objectId, v.id, v.objectKey, StorageClass.standard, r.name);
          purged[v.id.value] = true;
        }
      }
  }
  return steps;
}

///
unittest {
  mixin(ShowTest!("planLifecycle"));

  auto now = parseIsoTime("2026-11-18T00:00:00Z");
  StorageObject obj(string key, int ageDays, StorageClass c = StorageClass.standard) {
    auto o = StorageObject(TenantId("t"));
    o.name = key;
    o.storageClass = c;
    o.updatedAt = now - ageDays * stdTimeDay;
    return o;
  }

  LifecycleRule logs;
  logs.name = "logs";
  logs.prefix = "logs/";
  logs.transitionDays = 30;
  logs.transitionStorageClass = StorageClass.coldline;
  logs.expirationDays = 365;
  validateLifecycleRule(logs);

  auto fresh = obj("logs/new.log", 3);
  auto old = obj("logs/old.log", 40);
  auto ancient = obj("logs/2024.log", 400);
  auto cold = obj("logs/cold.log", 50, StorageClass.archive);
  auto other = obj("data/x.bin", 900);
  auto held = obj("logs/held.log", 900);
  held.legalHold = true;

  auto v1 = ObjectVersion(TenantId("t"));
  v1.objectId = old.id;
  v1.objectKey = old.name;
  v1.createdAt = now - 10 * stdTimeDay;
  auto v2 = v1;
  v2.id = ObjectVersionId("v2");
  v2.isLatest = true;

  LifecycleRule versionsRule;
  versionsRule.name = "versions";
  versionsRule.noncurrentVersionExpirationDays = 7;

  auto steps = planLifecycle([logs, versionsRule], [fresh, old, ancient, cold, other, held], [v1, v2], now);
  assert(steps.length == 3, steps.length.to!string);
  assert(steps[0].kind == LifecycleStepKind.transition && steps[0].key == "logs/old.log");
  assert(steps[1].kind == LifecycleStepKind.expire && steps[1].key == "logs/2024.log");
  assert(steps[2].kind == LifecycleStepKind.purgeVersion && steps[2].versionId == v1.id);

  logs.status = RuleStatus.disabled;
  assert(planLifecycle([logs], [ancient], null, now).length == 0);

  LifecycleRule bad;
  bad.name = "bad";
  bool rejected;
  try validateLifecycleRule(bad);
  catch (ObjectStoreValidationException) rejected = true;
  assert(rejected);
}
