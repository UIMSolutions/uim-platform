/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions. Driving adapters translate the kind into their
/// protocol (HTTP status, OData error, CLI exit code, GUI dialog).
module uim.platform.architecture.domain.exceptions.architecture;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

/// Category of a failure.
enum ArchitectureErrorKind {
  invalid, /// malformed or incomplete input (400)
  notFound, /// a referenced building block / relationship does not exist (404)
  conflict, /// uniqueness conflict (409)
  ruleViolation /// a governance or ArchiMate rule forbids the operation (422)
}

class ArchitectureException : Exception {
  ArchitectureErrorKind kind;

  this(ArchitectureErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static ArchitectureException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new ArchitectureException(ArchitectureErrorKind.invalid, msg, file, line);
  }

  static ArchitectureException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new ArchitectureException(ArchitectureErrorKind.notFound, what ~ " not found", file, line);
  }

  static ArchitectureException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new ArchitectureException(ArchitectureErrorKind.conflict, msg, file, line);
  }

  static ArchitectureException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new ArchitectureException(ArchitectureErrorKind.ruleViolation, msg, file, line);
  }
}

/// True if dg throws an ArchitectureException of the kind (test helper).
bool failsWith(ArchitectureErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (ArchitectureException e)
    return e.kind == kind;
  return false;
}

/// Throw invalid if a required text is empty.
void requireText(string value, string what) {
  if (value.strip.length == 0)
    throw ArchitectureException.invalid(what ~ " is required");
}

/// Throw invalid if a text is longer than max characters.
void requireMaxLength(string value, size_t max, string what) {
  if (value.length > max)
    throw ArchitectureException.invalid(format("%s must not exceed %d characters", what, max));
}

///
unittest {
  assert(failsWith(ArchitectureErrorKind.notFound, () { throw ArchitectureException.notFound("Block 'x'"); }));
  assert(!failsWith(ArchitectureErrorKind.conflict, () {}));
  assert(failsWith(ArchitectureErrorKind.invalid, () { requireText(" ", "Name"); }));
  assert(failsWith(ArchitectureErrorKind.invalid, () { requireMaxLength("abc", 2, "Name"); }));
}
