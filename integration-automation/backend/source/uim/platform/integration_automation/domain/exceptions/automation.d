/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions. Driving adapters translate the kind into their
/// protocol (HTTP status, OData error, CLI exit code, GUI dialog).
module uim.platform.integration_automation.domain.exceptions.automation;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

/// Category of a failure.
enum IaErrorKind {
  invalid, /// malformed or incomplete input (400)
  notFound, /// a referenced resource does not exist (404)
  conflict, /// uniqueness conflict (409)
  ruleViolation, /// a business rule forbids the operation (422)
  unauthorized /// missing or wrong credentials (401)
}

class IntegrationAutomationException : Exception {
  IaErrorKind kind;

  this(IaErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static IntegrationAutomationException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new IntegrationAutomationException(IaErrorKind.invalid, msg, file, line);
  }

  static IntegrationAutomationException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new IntegrationAutomationException(IaErrorKind.notFound, what ~ " not found", file, line);
  }

  static IntegrationAutomationException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new IntegrationAutomationException(IaErrorKind.conflict, msg, file, line);
  }

  static IntegrationAutomationException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new IntegrationAutomationException(IaErrorKind.ruleViolation, msg, file, line);
  }

  static IntegrationAutomationException unauthorized(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new IntegrationAutomationException(IaErrorKind.unauthorized, msg, file, line);
  }
}

alias IaException = IntegrationAutomationException;

/// True if dg throws an IntegrationAutomationException of the kind (test helper).
bool failsWith(IaErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (IntegrationAutomationException e)
    return e.kind == kind;
  return false;
}

/// Throw invalid if a required text is empty.
void requireText(string value, string what) {
  if (value.strip.length == 0)
    throw IaException.invalid(what ~ " is required");
}

/// Throw invalid if a text is longer than max characters.
void requireMaxLength(string value, size_t max, string what) {
  if (value.length > max)
    throw IaException.invalid(format("%s must not exceed %d characters", what, max));
}

/// Throw invalid if a number is outside [min, max].
void requireRange(long value, long min, long max, string what) {
  if (value < min || value > max)
    throw IaException.invalid(format("%s must be between %d and %d", what, min, max));
}

///
unittest {
  assert(failsWith(IaErrorKind.notFound, () { throw IaException.notFound("Workflow 'x'"); }));
  assert(!failsWith(IaErrorKind.conflict, () {}));
  assert(failsWith(IaErrorKind.invalid, () { requireText(" ", "Name"); }));
  assert(failsWith(IaErrorKind.invalid, () { requireMaxLength("abc", 2, "Name"); }));
  assert(failsWith(IaErrorKind.invalid, () { requireRange(70000, 0, 65535, "Port"); }));
}
