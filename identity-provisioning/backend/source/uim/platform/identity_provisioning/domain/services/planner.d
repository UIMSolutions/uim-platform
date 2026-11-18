/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Provisioning planner: compares the (transformed) source identities with the
/// entities already provisioned to a target and plans create / update /
/// delete / skip operations. Pure — the application layer executes the plan.
module uim.platform.identity_provisioning.domain.services.planner;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Order-independent checksum of an attribute set (FNV-1a 64 over sorted "k=v").
string attributeChecksum(const Attribute[] attributes) {
  string[] lines;
  foreach (a; attributes)
    lines ~= a.key ~ "=" ~ a.value;
  lines.sort();
  ulong hash = 0xcbf29ce484222325UL;
  foreach (line; lines) {
    foreach (c; cast(const(ubyte)[]) line) {
      hash ^= c;
      hash *= 0x100000001b3UL;
    }
    hash ^= 0x0a;
    hash *= 0x100000001b3UL;
  }
  return format("%016x", hash);
}

/// Plan the operations of a run.
///
///   * full      — create new, update every existing entity, delete vanished ones
///   * delta     — create new, update changed (or previously failed), skip unchanged, delete vanished
///   * simulate  — the delta plan; the runner only logs it
///
/// Users are planned before groups (group members must exist), deletions last.
PlannedOperation[] planOperations(JobType type, const SourceIdentity[] identities, const ProvisionedEntity[] existing) {
  PlannedOperation[] users, groups, deletions;
  bool[string] seen;

  foreach (identity; identities) {
    auto key = enumText(identity.entityType) ~ ":" ~ identity.externalId;
    if (key in seen)
      continue; // duplicates in the source: first one wins
    seen[key] = true;

    PlannedOperation op;
    op.entityType = identity.entityType;
    op.externalId = identity.externalId;
    op.name = identity.name;
    foreach (a; identity.attributes)
      op.attributes ~= Attribute(a.key, a.value);
    op.checksum = attributeChecksum(identity.attributes);

    auto match = existing.filter!(e => e.entityType == identity.entityType && e.externalId == identity.externalId);
    if (match.empty) {
      op.operation = OperationType.create;
      op.reason = "new in source";
    } else {
      auto current = match.front;
      op.existingId = current.id;
      op.targetId = current.targetId;
      if (type == JobType.full) {
        op.operation = OperationType.update;
        op.reason = "full run";
      } else if (current.status == EntityStatus.error || current.status == EntityStatus.pending) {
        op.operation = OperationType.update;
        op.reason = "retry after " ~ enumText(current.status);
      } else if (current.checksum != op.checksum) {
        op.operation = OperationType.update;
        op.reason = "attributes changed";
      } else {
        op.operation = OperationType.skip;
        op.reason = "unchanged";
      }
    }
    (identity.entityType == EntityType.user ? users : groups) ~= op;
  }

  foreach (e; existing) {
    if ((enumText(e.entityType) ~ ":" ~ e.externalId) in seen)
      continue;
    PlannedOperation op;
    op.operation = OperationType.delete_;
    op.entityType = e.entityType;
    op.externalId = e.externalId;
    op.name = e.name;
    op.existingId = e.id;
    op.targetId = e.targetId;
    op.checksum = e.checksum;
    op.reason = "no longer in source";
    deletions ~= op;
  }
  // groups first when deleting (memberships), users first otherwise
  deletions.sort!((a, b) => a.entityType > b.entityType);
  return users ~ groups ~ deletions;
}

///
unittest {
  auto a = [Attribute("x", "1"), Attribute("y", "2")];
  auto b = [Attribute("y", "2"), Attribute("x", "1")];
  assert(attributeChecksum(a) == attributeChecksum(b));
  assert(attributeChecksum(a) != attributeChecksum([Attribute("x", "1")]));
  assert(attributeChecksum([Attribute("x", "12")]) != attributeChecksum([Attribute("x1", "2")]));

  auto ada = SourceIdentity("u1", EntityType.user, "ada", a);
  auto alan = SourceIdentity("u2", EntityType.user, "alan", b);
  auto team = SourceIdentity("g1", EntityType.group, "team", [Attribute("members", "ada,alan")]);

  // first run: everything is new, users before groups
  auto plan = planOperations(JobType.delta, [team, ada, alan], null);
  assert(plan.length == 3 && plan.all!(p => p.operation == OperationType.create));
  assert(plan[2].entityType == EntityType.group);

  // second run: unchanged → skip, changed → update, vanished → delete
  ProvisionedEntity e1, e2, e3;
  e1 = ProvisionedEntity(TenantId("t"));
  e1.externalId = "u1";
  e1.checksum = attributeChecksum(a);
  e1.status = EntityStatus.active;
  e2 = ProvisionedEntity(TenantId("t"));
  e2.externalId = "u2";
  e2.checksum = "stale";
  e2.status = EntityStatus.active;
  e3 = ProvisionedEntity(TenantId("t"));
  e3.externalId = "u3";
  e3.targetId = "P0003";
  auto second = planOperations(JobType.delta, [ada, alan], [e1, e2, e3]);
  assert(second[0].operation == OperationType.skip && second[0].existingId == e1.id);
  assert(second[1].operation == OperationType.update && second[1].reason == "attributes changed");
  assert(second[2].operation == OperationType.delete_ && second[2].targetId == "P0003");

  // full runs update unchanged entities as well; failed entities are retried
  assert(planOperations(JobType.full, [ada], [e1])[0].operation == OperationType.update);
  e1.status = EntityStatus.error;
  assert(planOperations(JobType.delta, [ada], [e1])[0].reason == "retry after error");
}
