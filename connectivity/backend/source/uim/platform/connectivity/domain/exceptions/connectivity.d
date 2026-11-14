/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.exceptions.connectivity;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Base class of all business exceptions of the connectivity domain.
/// `status` is the HTTP-like status a driving adapter should report.
class ConnectivityException : Exception {
  int status;

  this(string msg, int status = 400, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.status = status;
  }
}

/// Input violates a business rule (invalid name, host, port, URL, auth settings, ...).
class ConnectivityValidationException : ConnectivityException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, 422, file, line);
  }
}

/// A referenced aggregate does not exist.
class ConnectivityNotFoundException : ConnectivityException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, 404, file, line);
  }
}

/// The operation conflicts with the current state (duplicate name, dependents, wrong status).
class ConnectivityConflictException : ConnectivityException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, 409, file, line);
  }
}

/// Throw a validation exception unless `condition` holds.
void validate(bool condition, lazy string message) {
  if (!condition)
    throw new ConnectivityValidationException(message);
}

/// Throw a conflict exception unless `condition` holds.
void ensureState(bool condition, lazy string message) {
  if (!condition)
    throw new ConnectivityConflictException(message);
}
