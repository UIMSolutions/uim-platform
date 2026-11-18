/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.exceptions.object_store;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Base class of all business exceptions of the object store domain.
/// `status` is the HTTP-like status a driving adapter should report.
class ObjectStoreException : Exception {
  int status;

  this(string msg, int status = 400, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.status = status;
  }
}

/// Input violates a business rule (bad bucket name, quota exceeded, unknown region, ...).
class ObjectStoreValidationException : ObjectStoreException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, 422, file, line);
  }
}

/// A referenced aggregate does not exist.
class ObjectStoreNotFoundException : ObjectStoreException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, 404, file, line);
  }
}

/// The operation conflicts with the current state (duplicate, suspended bucket, legal hold, archived, ...).
class ObjectStoreConflictException : ObjectStoreException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, 409, file, line);
  }
}

/// The caller is not allowed to perform the operation (policies, binding permission, bad credentials).
class ObjectStoreAccessDeniedException : ObjectStoreException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, 403, file, line);
  }
}

/// Throw a validation exception unless `condition` holds.
void validate(bool condition, lazy string message) {
  if (!condition)
    throw new ObjectStoreValidationException(message);
}

/// Throw a conflict exception unless `condition` holds.
void ensureState(bool condition, lazy string message) {
  if (!condition)
    throw new ObjectStoreConflictException(message);
}

/// Throw an access denied exception unless `condition` holds.
void ensureAccess(bool condition, lazy string message) {
  if (!condition)
    throw new ObjectStoreAccessDeniedException(message);
}

/// HTTP-like status → OData style error code.
string errorCodeOf(int status) pure nothrow {
  switch (status) {
  case 403:
    return "AccessDenied";
  case 404:
    return "NotFound";
  case 405:
    return "MethodNotAllowed";
  case 409:
    return "Conflict";
  case 413:
    return "PayloadTooLarge";
  case 422:
    return "BusinessRuleViolation";
  default:
    return "BadRequest";
  }
}
