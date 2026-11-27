/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions. Driving adapters translate the kind into their
/// protocol (HTTP status, OData error, CLI exit code, GUI dialog).
module uim.platform.datasphere.domain.exceptions.datasphere;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

/// Category of a failure.
enum DspErrorKind {
  invalid, /// malformed or incomplete input (400)
  notFound, /// a referenced resource does not exist (404)
  conflict, /// uniqueness conflict (409)
  ruleViolation, /// a business rule forbids the operation (422)
  unauthorized /// missing or wrong credentials (401)
}

class DatasphereException : Exception {
  DspErrorKind kind;

  this(DspErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static DatasphereException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DatasphereException(DspErrorKind.invalid, msg, file, line);
  }

  static DatasphereException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DatasphereException(DspErrorKind.notFound, what ~ " not found", file, line);
  }

  static DatasphereException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DatasphereException(DspErrorKind.conflict, msg, file, line);
  }

  static DatasphereException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DatasphereException(DspErrorKind.ruleViolation, msg, file, line);
  }

  static DatasphereException unauthorized(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DatasphereException(DspErrorKind.unauthorized, msg, file, line);
  }
}

alias DspException = DatasphereException;

/// True if dg throws a DatasphereException of the kind (test helper).
bool failsWith(DspErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (DatasphereException e)
    return e.kind == kind;
  return false;
}

/// Throw invalid if a required text is empty.
void requireText(string value, string what) {
  if (value.strip.length == 0)
    throw DspException.invalid(what ~ " is required");
}

/// Throw invalid if a text is longer than max characters.
void requireMaxLength(string value, size_t max, string what) {
  if (value.length > max)
    throw DspException.invalid(format("%s must not exceed %d characters", what, max));
}

/// Throw invalid if a number is outside [min, max].
void requireRange(long value, long min, long max, string what) {
  if (value < min || value > max)
    throw DspException.invalid(format("%s must be between %d and %d", what, min, max));
}

///
unittest {
  assert(failsWith(DspErrorKind.notFound, () { throw DspException.notFound("Space 'x'"); }));
  assert(!failsWith(DspErrorKind.conflict, () {}));
  assert(failsWith(DspErrorKind.invalid, () { requireText(" ", "Name"); }));
  assert(failsWith(DspErrorKind.invalid, () { requireMaxLength("abc", 2, "Name"); }));
  assert(failsWith(DspErrorKind.invalid, () { requireRange(0, 1, 10, "Priority"); }));
}
