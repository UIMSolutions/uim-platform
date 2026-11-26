/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions. Driving adapters translate the kind into their
/// protocol (HTTP status, OData error, CLI exit code, GUI dialog).
module uim.platform.application_autoscaler.domain.exceptions.autoscaler;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// Category of a failure.
enum AasErrorKind {
  invalid, /// malformed or incomplete input (400)
  notFound, /// a referenced resource does not exist (404)
  conflict, /// uniqueness conflict (409)
  ruleViolation, /// a business rule forbids the operation (422)
  unauthorized /// missing or wrong credentials (401)
}

class AutoscalerException : Exception {
  AasErrorKind kind;

  this(AasErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static AutoscalerException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AutoscalerException(AasErrorKind.invalid, msg, file, line);
  }

  static AutoscalerException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AutoscalerException(AasErrorKind.notFound, what ~ " not found", file, line);
  }

  static AutoscalerException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AutoscalerException(AasErrorKind.conflict, msg, file, line);
  }

  static AutoscalerException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AutoscalerException(AasErrorKind.ruleViolation, msg, file, line);
  }

  static AutoscalerException unauthorized(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AutoscalerException(AasErrorKind.unauthorized, msg, file, line);
  }
}

alias AasException = AutoscalerException;

/// True if dg throws an AutoscalerException of the kind (test helper).
bool failsWith(AasErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (AutoscalerException e)
    return e.kind == kind;
  return false;
}

/// Throw invalid if a required text is empty.
void requireText(string value, string what) {
  if (value.strip.length == 0)
    throw AasException.invalid(what ~ " is required");
}

/// Throw invalid if a text is longer than max characters.
void requireMaxLength(string value, size_t max, string what) {
  if (value.length > max)
    throw AasException.invalid(format("%s must not exceed %d characters", what, max));
}

/// Throw invalid if a number is outside [min, max].
void requireRange(long value, long min, long max, string what) {
  if (value < min || value > max)
    throw AasException.invalid(format("%s must be between %d and %d", what, min, max));
}

///
unittest {
  assert(failsWith(AasErrorKind.notFound, () { throw AasException.notFound("Binding 'x'"); }));
  assert(!failsWith(AasErrorKind.conflict, () {}));
  assert(failsWith(AasErrorKind.invalid, () { requireText(" ", "Name"); }));
  assert(failsWith(AasErrorKind.invalid, () { requireMaxLength("abc", 2, "Name"); }));
  assert(failsWith(AasErrorKind.invalid, () { requireRange(0, 1, 10, "Instances"); }));
}
