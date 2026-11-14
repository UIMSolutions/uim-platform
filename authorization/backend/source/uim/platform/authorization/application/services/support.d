/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Small helpers shared by the interactors.
module uim.platform.authorization.application.services.support;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Return the entity or throw notFound.
T required(T)(T entity, lazy string what) {
  if (entity.isNull)
    throw AuthorizationException.notFound(what);
  return entity;
}

/// Initialise id, tenant and audit fields of a new entity.
void stampCreated(E)(ref E entity, TenantId tenantId, UserId actor) {
  if (tenantId.isNull)
    throw AuthorizationException.invalid("Tenant is required");
  alias TId = typeof(entity.id);
  entity.id = TId(newResourceId());
  entity.tenantId = tenantId;
  entity.createdAt = nowStdTime();
  entity.updatedAt = entity.createdAt;
  entity.createdBy = actorOrSystem(actor);
  entity.updatedBy = entity.createdBy;
}

/// Refresh the audit fields of a changed entity.
void stampUpdated(E)(ref E entity, UserId actor) {
  entity.updatedAt = nowStdTime();
  entity.updatedBy = actorOrSystem(actor);
}

UserId actorOrSystem(UserId actor) {
  return actor.isNull ? UserId("system") : actor;
}

string countOf(size_t n, string noun) {
  return format("%d %s%s", n, noun, n == 1 ? "" : "s");
}
