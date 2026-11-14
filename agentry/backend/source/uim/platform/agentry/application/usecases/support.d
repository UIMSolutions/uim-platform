/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Shared helpers of the use case implementations: uniform results and
/// mapping of business exceptions to result codes.
///
/// Result codes: 200/201 success, 400 invalid input, 404 not found,
/// 409 conflict (duplicate), 422 business rule / lifecycle violation.
module uim.platform.agentry.application.usecases.support;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

UsecaseResult succeeded(string id, string message, size_t code = 200, Json data = Json.emptyObject) {
  return UsecaseResult(true, id, message, code, data);
}

UsecaseResult created(string id, string message) {
  return UsecaseResult(true, id, message, 201);
}

UsecaseResult notFound(string what, string id = "") {
  return UsecaseResult(false, id, what ~ (id.length ? " '" ~ id ~ "'" : "") ~ " not found", 404);
}

UsecaseResult invalid(string[] errors) {
  return UsecaseResult(false, "", "Invalid data: " ~ errors.join("; "), 400);
}

UsecaseResult invalid(string error) {
  return invalid([error]);
}

UsecaseResult conflict(string message) {
  return UsecaseResult(false, "", message, 409);
}

UsecaseResult rejected(string message, string id = "") {
  return UsecaseResult(false, id, message, 422);
}

/// Run a use case body and translate business exceptions into results.
UsecaseResult guarded(scope UsecaseResult delegate() @safe body) {
  try
    return body();
  catch (AgentryException e)
    return rejected(e.msg);
}

/// Parse an optional enum value from a DTO string. Empty keeps current,
/// unknown values are reported in errors.
bool readEnum(E)(string text, ref E target, string field, ref string[] errors) {
  if (text.length == 0)
    return false;
  E parsed;
  if (!tryParseEnum!E(text, parsed)) {
    errors ~= field ~ " must be one of " ~ enumValues!E().join(", ");
    return false;
  }
  target = parsed;
  return true;
}

/// Create an entity: keep a caller supplied id, otherwise generate one.
T newEntity(T, TId)(TenantId tenantId, TId id, UserId by) {
  auto e = T(tenantId);
  if (!id.isNull)
    e.id = id;
  e.createdBy = by;
  e.updatedBy = by;
  return e;
}

/// Mark an entity as changed (updatedAt / updatedBy).
void touch(T)(ref T entity, UserId by) {
  if (by.isNull)
    entity.update();
  else
    entity.update(by);
}

/// Assign a string only if a value is supplied (partial updates).
void assignIf(ref string target, string value) {
  if (value.length > 0)
    target = value;
}

long nowStdTime() @trusted {
  return Clock.currStdTime();
}
