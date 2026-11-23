/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions. Driving adapters translate the kind into their
/// protocol (HTTP status, OData error, CLI exit code, GUI dialog).
module uim.platform.data_quality.domain.exceptions.dataquality;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

/// Category of a failure.
enum DqErrorKind {
  invalid, /// malformed or incomplete input (400)
  notFound, /// a referenced resource does not exist (404)
  conflict, /// uniqueness conflict (409)
  ruleViolation, /// a business rule forbids the operation (422)
  unauthorized /// missing or wrong credentials (401)
}

class DataQualityException : Exception {
  DqErrorKind kind;

  this(DqErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static DataQualityException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DataQualityException(DqErrorKind.invalid, msg, file, line);
  }

  static DataQualityException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DataQualityException(DqErrorKind.notFound, what ~ " not found", file, line);
  }

  static DataQualityException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DataQualityException(DqErrorKind.conflict, msg, file, line);
  }

  static DataQualityException unauthorized(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DataQualityException(DqErrorKind.unauthorized, msg, file, line);
  }

  static DataQualityException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DataQualityException(DqErrorKind.ruleViolation, msg, file, line);
  }
}

/// True if dg throws a DataQualityException of the kind (test helper).
bool failsWith(DqErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (DataQualityException e)
    return e.kind == kind;
  return false;
}

/// Throw invalid if a required text is empty.
void requireText(string value, string what) {
  if (value.strip.length == 0)
    throw DataQualityException.invalid(what ~ " is required");
}

/// Throw invalid if a text is longer than max characters.
void requireMaxLength(string value, size_t max, string what) {
  if (value.length > max)
    throw DataQualityException.invalid(format("%s must not exceed %d characters", what, max));
}

/// Throw invalid if a number is outside [min, max].
void requireRange(double value, double min, double max, string what) {
  if (value < min || value > max || value != value)
    throw DataQualityException.invalid(format("%s must be between %s and %s", what, min, max));
}

///
unittest {
  assert(failsWith(DqErrorKind.notFound, () { throw DataQualityException.notFound("Dataset 'x'"); }));
  assert(!failsWith(DqErrorKind.conflict, () {}));
  assert(failsWith(DqErrorKind.invalid, () { requireText(" ", "Name"); }));
  assert(failsWith(DqErrorKind.invalid, () { requireMaxLength("abc", 2, "Name"); }));
  assert(failsWith(DqErrorKind.invalid, () { requireRange(101, 0, 100, "threshold"); }));
}
