/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions. Driving adapters translate the kind into their
/// protocol (HTTP status, OData error, CLI exit code, GUI dialog).
module uim.platform.data_retention.domain.exceptions.retention;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

/// Category of a failure.
enum DrErrorKind {
  invalid, /// malformed or incomplete input (400)
  notFound, /// a referenced resource does not exist (404)
  conflict, /// uniqueness conflict (409)
  ruleViolation, /// a business rule forbids the operation (422)
  unauthorized /// missing or wrong credentials (401)
}

class DataRetentionException : Exception {
  DrErrorKind kind;

  this(DrErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static DataRetentionException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DataRetentionException(DrErrorKind.invalid, msg, file, line);
  }

  static DataRetentionException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DataRetentionException(DrErrorKind.notFound, what ~ " not found", file, line);
  }

  static DataRetentionException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DataRetentionException(DrErrorKind.conflict, msg, file, line);
  }

  static DataRetentionException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DataRetentionException(DrErrorKind.ruleViolation, msg, file, line);
  }

  static DataRetentionException unauthorized(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DataRetentionException(DrErrorKind.unauthorized, msg, file, line);
  }
}

/// True if dg throws a DataRetentionException of the kind (test helper).
bool failsWith(DrErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (DataRetentionException e)
    return e.kind == kind;
  return false;
}

/// Throw invalid if a required text is empty.
void requireText(string value, string what) {
  if (value.strip.length == 0)
    throw DataRetentionException.invalid(what ~ " is required");
}

/// Throw invalid if a text is longer than max characters.
void requireMaxLength(string value, size_t max, string what) {
  if (value.length > max)
    throw DataRetentionException.invalid(format("%s must not exceed %d characters", what, max));
}

/// Throw invalid if a number is outside [min, max].
void requireRange(long value, long min, long max, string what) {
  if (value < min || value > max)
    throw DataRetentionException.invalid(format("%s must be between %d and %d", what, min, max));
}

///
unittest {
  assert(failsWith(DrErrorKind.notFound, () { throw DataRetentionException.notFound("Data subject 'x'"); }));
  assert(!failsWith(DrErrorKind.conflict, () {}));
  assert(failsWith(DrErrorKind.invalid, () { requireText(" ", "Name"); }));
  assert(failsWith(DrErrorKind.invalid, () { requireMaxLength("abc", 2, "Name"); }));
  assert(failsWith(DrErrorKind.invalid, () { requireRange(101, 0, 100, "Duration"); }));
}
