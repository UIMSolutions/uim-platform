/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions. Driving adapters translate the kind into their
/// protocol (HTTP status, CLI exit code, GUI dialog).
module uim.platform.task_center.domain.exceptions.taskcenter;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// Category of a business failure.
enum TaskCenterErrorKind {
  invalid, /// malformed or incomplete input
  notFound, /// a referenced resource does not exist
  conflict, /// uniqueness conflict (e.g. task already claimed)
  ruleViolation, /// a business rule forbids the operation
  forbidden, /// the caller may not act on the resource (e.g. not the claimer)
  gateway /// a task provider endpoint failed
}

class TaskCenterException : Exception {
  TaskCenterErrorKind kind;

  this(TaskCenterErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static TaskCenterException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new TaskCenterException(TaskCenterErrorKind.invalid, msg, file, line);
  }

  static TaskCenterException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new TaskCenterException(TaskCenterErrorKind.notFound, what ~ " not found", file, line);
  }

  static TaskCenterException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new TaskCenterException(TaskCenterErrorKind.conflict, msg, file, line);
  }

  static TaskCenterException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new TaskCenterException(TaskCenterErrorKind.ruleViolation, msg, file, line);
  }

  static TaskCenterException forbidden(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new TaskCenterException(TaskCenterErrorKind.forbidden, msg, file, line);
  }

  static TaskCenterException gateway(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new TaskCenterException(TaskCenterErrorKind.gateway, msg, file, line);
  }
}

/// True if dg throws a TaskCenterException of the kind (test helper).
bool failsWith(TaskCenterErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (TaskCenterException e)
    return e.kind == kind;
  return false;
}

/// Throw invalid if a required text is empty.
void requireText(string value, string what) {
  if (value.strip.length == 0)
    throw TaskCenterException.invalid(what ~ " is required");
}

/// Throw invalid if a number is negative.
void requireNonNegative(long value, string what) {
  if (value < 0)
    throw TaskCenterException.invalid(what ~ " must not be negative");
}

/// Throw invalid unless the text is empty or an ISO date.
void requireOptionalDate(string value, string what) {
  if (value.length > 0 && !isIsoDate(value))
    throw TaskCenterException.invalid(what ~ " must be an ISO date (YYYY-MM-DD), got '" ~ value ~ "'");
}

/// True for http:// and https:// URLs with a host.
bool isHttpUrl(string url) pure {
  foreach (scheme; ["http://", "https://"])
    if (url.startsWith(scheme) && url.length > scheme.length && url[scheme.length] != '/')
      return true;
  return false;
}

///
unittest {
  assert(failsWith(TaskCenterErrorKind.notFound, () { throw TaskCenterException.notFound("Task 'x'"); }));
  assert(!failsWith(TaskCenterErrorKind.conflict, () {}));
  assert(failsWith(TaskCenterErrorKind.invalid, () { requireText(" ", "Title"); }));
  assert(failsWith(TaskCenterErrorKind.invalid, () { requireOptionalDate("tomorrow", "dueDate"); }));
  requireOptionalDate("", "dueDate");
  assert(isHttpUrl("https://s4.example.com/tasks") && !isHttpUrl("ftp://x") && !isHttpUrl("http:///x"));
}
