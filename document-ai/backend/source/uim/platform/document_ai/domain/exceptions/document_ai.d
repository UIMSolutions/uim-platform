/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions. Driving adapters translate the kind into their
/// protocol (HTTP status, OData error, CLI exit code, GUI dialog).
module uim.platform.document_ai.domain.exceptions.document_ai;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

/// Category of a failure.
enum DaiErrorKind {
  invalid, /// malformed or incomplete input (400)
  notFound, /// a referenced resource does not exist (404)
  conflict, /// uniqueness conflict (409)
  ruleViolation, /// a business rule forbids the operation (422)
  unauthorized /// missing or wrong credentials (401)
}

class DocumentAiException : Exception {
  DaiErrorKind kind;

  this(DaiErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static DocumentAiException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DocumentAiException(DaiErrorKind.invalid, msg, file, line);
  }

  static DocumentAiException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DocumentAiException(DaiErrorKind.notFound, what ~ " not found", file, line);
  }

  static DocumentAiException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DocumentAiException(DaiErrorKind.conflict, msg, file, line);
  }

  static DocumentAiException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DocumentAiException(DaiErrorKind.ruleViolation, msg, file, line);
  }

  static DocumentAiException unauthorized(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new DocumentAiException(DaiErrorKind.unauthorized, msg, file, line);
  }
}

alias DaiException = DocumentAiException;

/// True if dg throws a DocumentAiException of the kind (test helper).
bool failsWith(DaiErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (DocumentAiException e)
    return e.kind == kind;
  return false;
}

/// Throw invalid if a required text is empty.
void requireText(string value, string what) {
  if (value.strip.length == 0)
    throw DaiException.invalid(what ~ " is required");
}

/// Throw invalid if a text is longer than max characters.
void requireMaxLength(string value, size_t max, string what) {
  if (value.length > max)
    throw DaiException.invalid(format("%s must not exceed %d characters", what, max));
}

/// Throw invalid if a number is outside [min, max].
void requireRange(long value, long min, long max, string what) {
  if (value < min || value > max)
    throw DaiException.invalid(format("%s must be between %d and %d", what, min, max));
}

///
unittest {
  assert(failsWith(DaiErrorKind.notFound, () { throw DaiException.notFound("Document 'x'"); }));
  assert(!failsWith(DaiErrorKind.conflict, () {}));
  assert(failsWith(DaiErrorKind.invalid, () { requireText(" ", "Name"); }));
  assert(failsWith(DaiErrorKind.invalid, () { requireMaxLength("abc", 2, "Name"); }));
  assert(failsWith(DaiErrorKind.invalid, () { requireRange(-1, 0, 10, "Quota"); }));
}
