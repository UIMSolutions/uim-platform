/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions of the cloud management domain.
///
/// Entities throw these when an operation would violate a business rule; the
/// application layer translates them into UsecaseResult codes (see ResultCode).
module uim.platform.management.domain.exceptions.errors;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Result codes used in UsecaseResult.code (aligned with HTTP status codes so
/// that all driving adapters can map them the same way).
enum ResultCode : size_t {
  ok = 200,
  created = 201,
  invalid = 400,
  notFound = 404,
  conflict = 409,
  ruleViolation = 422,
}

/// Base class of all management domain exceptions.
class ManagementException : Exception {
  ResultCode code;

  this(string msg, ResultCode code = ResultCode.ruleViolation, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.code = code;
  }
}

/// An operation is not allowed in the current lifecycle state.
class InvalidStateTransition : ManagementException {
  this(string entity, string from, string operation, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(entity ~ " cannot " ~ operation ~ " in status '" ~ from ~ "'", ResultCode.ruleViolation, file, line);
  }
}

/// A limit (quota, maximum number of children) would be exceeded.
class LimitExceeded : ManagementException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, ResultCode.ruleViolation, file, line);
  }
}

///
unittest {
  mixin(ShowTest!("ManagementException"));

  auto e = new InvalidStateTransition("Subaccount", "suspended", "be suspended");
  assert(e.code == ResultCode.ruleViolation);
  assert(e.msg == "Subaccount cannot be suspended in status 'suspended'");
}
