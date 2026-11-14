/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Small helpers shared by the interactors.
module uim.platform.events.application.services.support;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// Return the entity or throw notFound.
T required(T)(T entity, lazy string what) {
  if (entity.isNull)
    throw EventsException.notFound(what);
  return entity;
}

/// Initialise id, tenant and audit fields of a new entity.
void stampCreated(E, TId)(ref E entity, TenantId tenantId, UserId actor, string requestedId) {
  if (tenantId.isNull)
    throw EventsException.invalid("Tenant is required");
  entity.id = TId(requestedId.strip.length > 0 ? requestedId.strip : newResourceId());
  entity.tenantId = tenantId;
  entity.createdAt = nowStdTime();
  entity.updatedAt = entity.createdAt;
  entity.createdBy = actor;
  entity.updatedBy = actor;
}

/// Refresh the audit fields of a changed entity.
void stampUpdated(E)(ref E entity, UserId actor) {
  entity.updatedAt = nowStdTime();
  entity.updatedBy = actor;
}

/// "1 queue" / "2 queues"
string countOf(size_t n, string noun) {
  return format("%d %s%s", n, noun, n == 1 ? "" : "s");
}

/// Apply an enum patch (parsed, case insensitive).
void applyEnum(E)(const Patch!string p, ref E target, string field) {
  if (p.isSet)
    target = parseDomainEnum!E(p.value, field);
}

///
unittest {
  assert(countOf(1, "queue") == "1 queue" && countOf(2, "queue") == "2 queues");
  QueueStatus s;
  Patch!string p;
  applyEnum(p, s, "status");
  assert(s == QueueStatus.active);
  p = "INACTIVE";
  applyEnum(p, s, "status");
  assert(s == QueueStatus.inactive);
}
