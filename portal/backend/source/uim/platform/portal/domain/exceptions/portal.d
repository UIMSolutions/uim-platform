/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.exceptions.portal;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Base class of all business exceptions of the portal domain. `status` is the
/// HTTP-like status a driving adapter should report.
class PortalException : Exception {
  int status;

  this(string msg, int status = 400, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.status = status;
  }
}

/// Input violates a business rule (invalid alias, colour, URL, ...).
class PortalValidationException : PortalException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, 422, file, line);
  }
}

/// A referenced aggregate does not exist.
class PortalNotFoundException : PortalException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, 404, file, line);
  }
}

/// The operation conflicts with the current state (duplicate alias, dependents, wrong status).
class PortalConflictException : PortalException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, 409, file, line);
  }
}

/// Throw a validation exception unless `condition` holds.
void validate(bool condition, lazy string message) {
  if (!condition)
    throw new PortalValidationException(message);
}

/// Throw a conflict exception unless `condition` holds.
void ensureState(bool condition, lazy string message) {
  if (!condition)
    throw new PortalConflictException(message);
}

///
unittest {
  bool caught;
  try validate(false, "x");
  catch (PortalValidationException e) caught = e.status == 422;
  assert(caught);
  caught = false;
  try ensureState(false, "y");
  catch (PortalConflictException e) caught = e.status == 409;
  assert(caught);
}
