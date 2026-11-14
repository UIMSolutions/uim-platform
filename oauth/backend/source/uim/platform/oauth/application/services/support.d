/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Small helpers shared by the interactors.
module uim.platform.oauth.application.services.support;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// Return the entity or throw notFound.
T required(T)(T entity, lazy string what) {
  if (entity.isNull)
    throw OAuthException.notFound(what);
  return entity;
}

/// Initialise id, tenant and audit fields of a new entity.
void stampCreated(E, TId)(ref E entity, TenantId tenantId, UserId actor, string requestedId) {
  if (tenantId.isNull)
    throw OAuthException.invalid("Tenant is required");
  auto id = requestedId.strip;
  if (id.length > 128 || id.canFind('/') || id.canFind('\''))
    throw OAuthException.invalid("Invalid id '" ~ id ~ "'");
  entity.id = TId(id.length > 0 ? id : newResourceId());
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

/// "1 token" / "2 tokens"
string countOf(size_t n, string noun) {
  return format("%d %s%s", n, noun, n == 1 ? "" : "s");
}

/// Apply an enum patch (parsed, case insensitive).
void applyEnum(E)(const Patch!string p, ref E target, string field) {
  if (p.isSet)
    target = parseDomainEnum!E(p.value, field);
}

/// Trim, drop blanks and duplicates (order kept).
string[] normalizeTexts(const string[] values) {
  string[] result;
  foreach (v; values) {
    auto t = v.strip;
    if (t.length > 0 && !result.canFind(t))
      result ~= t;
  }
  return result;
}

/// Names of the active scopes of a tenant.
string[] activeScopeNames(IOAuthScopeRepository scopes, TenantId tenantId) {
  string[] names;
  foreach (s; scopes.findAll(tenantId))
    if (s.isActive)
      names ~= s.name;
  return names;
}

///
unittest {
  assert(countOf(1, "token") == "1 token" && countOf(2, "token") == "2 tokens");
  assert(normalizeTexts([" a", "a", "", "b "]) == ["a", "b"]);
  ClientStatus s;
  Patch!string p;
  applyEnum(p, s, "status");
  assert(s == ClientStatus.active);
  p = "BLOCKED";
  applyEnum(p, s, "status");
  assert(s == ClientStatus.blocked);
}
