/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Small helpers shared by the interactors.
module uim.platform.service_manager.application.services.support;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Return the entity or throw notFound.
T required(T)(T entity, lazy string what) {
  if (entity.isNull)
    throw ServiceManagerException.notFound(what);
  return entity;
}

/// Initialise id, tenant and audit fields of a new entity.
void stampCreated(E, TId)(ref E entity, TenantId tenantId, UserId actor, string requestedId) {
  if (tenantId.isNull)
    throw ServiceManagerException.invalid("Tenant is required");
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

/// "a" / "an" free plural helper for messages.
string countOf(size_t n, string noun) {
  return format("%d %s%s", n, noun, n == 1 ? "" : "s");
}
