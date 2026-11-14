/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions. Driving adapters translate the kind into their
/// protocol (HTTP status, OData error, CLI exit code, GUI dialog).
module uim.platform.authorization.domain.exceptions.authorization;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Category of a business failure.
enum AuthorizationErrorKind {
  invalid, /// malformed or incomplete input                → 400
  notFound, /// a referenced resource does not exist         → 404
  conflict, /// uniqueness conflict                          → 409
  ruleViolation, /// a business rule forbids the operation   → 422
}

class AuthorizationException : Exception {
  AuthorizationErrorKind kind;

  this(AuthorizationErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static AuthorizationException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AuthorizationException(AuthorizationErrorKind.invalid, msg, file, line);
  }

  static AuthorizationException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AuthorizationException(AuthorizationErrorKind.notFound, what ~ " not found", file, line);
  }

  static AuthorizationException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AuthorizationException(AuthorizationErrorKind.conflict, msg, file, line);
  }

  static AuthorizationException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AuthorizationException(AuthorizationErrorKind.ruleViolation, msg, file, line);
  }
}

/// True if dg throws an AuthorizationException of this kind (test helper).
bool failsWith(AuthorizationErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (AuthorizationException e)
    return e.kind == kind;
  return false;
}

///
unittest {
  mixin(ShowTest!("AuthorizationException"));

  assert(failsWith(AuthorizationErrorKind.notFound, () { throw AuthorizationException.notFound("Policy 'x'"); }));
  assert(!failsWith(AuthorizationErrorKind.conflict, () {}));
  assert(AuthorizationException.notFound("Policy 'x'").msg == "Policy 'x' not found");
}
