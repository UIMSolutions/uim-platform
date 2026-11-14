/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business and protocol exceptions. Driving adapters translate them into
/// their protocol: management APIs (OData/REST/CLI/GUI) use the kind, the
/// OAuth 2.0 endpoints use the RFC 6749 error code.
module uim.platform.oauth.domain.exceptions.oauth;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// Category of a management failure.
enum OAuthErrorKind {
  invalid, /// malformed or incomplete input
  notFound, /// a referenced resource does not exist
  conflict, /// uniqueness conflict
  ruleViolation /// a business rule forbids the operation
}

class OAuthException : Exception {
  OAuthErrorKind kind;

  this(OAuthErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static OAuthException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new OAuthException(OAuthErrorKind.invalid, msg, file, line);
  }

  static OAuthException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new OAuthException(OAuthErrorKind.notFound, what ~ " not found", file, line);
  }

  static OAuthException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new OAuthException(OAuthErrorKind.conflict, msg, file, line);
  }

  static OAuthException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new OAuthException(OAuthErrorKind.ruleViolation, msg, file, line);
  }
}

/// RFC 6749 §5.2 / §4.1.2.1 error codes.
enum OAuthError : string {
  invalidRequest = "invalid_request",
  invalidClient = "invalid_client",
  invalidGrant = "invalid_grant",
  unauthorizedClient = "unauthorized_client",
  unsupportedGrantType = "unsupported_grant_type",
  unsupportedResponseType = "unsupported_response_type",
  invalidScope = "invalid_scope",
  accessDenied = "access_denied",
  loginRequired = "login_required",
  serverError = "server_error"
}

/// A failure of the OAuth 2.0 protocol (token / authorize endpoints).
class OAuthProtocolException : Exception {
  OAuthError error;

  this(OAuthError error, string description, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(description, file, line);
    this.error = error;
  }

  /// HTTP status of the token endpoint response (RFC 6749 §5.2).
  int httpStatus() const pure nothrow {
    return error == OAuthError.invalidClient ? 401 : error == OAuthError.serverError ? 500 : 400;
  }
}

/// Throw an OAuthProtocolException.
noreturn protocolError(OAuthError error, string description, string file = __FILE__, size_t line = __LINE__) pure {
  throw new OAuthProtocolException(error, description, file, line);
}

/// True if dg throws an OAuthException of the kind (test helper).
bool failsWith(OAuthErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (OAuthException e)
    return e.kind == kind;
  return false;
}

/// True if dg throws an OAuthProtocolException with the error code (test helper).
bool failsWithProtocol(OAuthError error, scope void delegate() @safe dg) {
  try
    dg();
  catch (OAuthProtocolException e)
    return e.error == error;
  return false;
}

/// Throw invalid if a required text is empty.
void requireText(string value, string what) {
  if (value.strip.length == 0)
    throw OAuthException.invalid(what ~ " is required");
}

/// Throw invalid if a number is outside [min, max].
void requireRange(long value, long min, long max, string what) {
  if (value < min || value > max)
    throw OAuthException.invalid(format("%s must be between %d and %d", what, min, max));
}

///
unittest {
  assert(failsWith(OAuthErrorKind.notFound, () { throw OAuthException.notFound("Client 'x'"); }));
  assert(!failsWith(OAuthErrorKind.conflict, () {}));
  assert(failsWith(OAuthErrorKind.invalid, () { requireText(" ", "Name"); }));
  assert(failsWith(OAuthErrorKind.invalid, () { requireRange(0, 60, 100, "validity"); }));
  assert(failsWithProtocol(OAuthError.invalidGrant, () { protocolError(OAuthError.invalidGrant, "expired"); }));
  assert(new OAuthProtocolException(OAuthError.invalidClient, "").httpStatus == 401);
  assert(new OAuthProtocolException(OAuthError.invalidScope, "").httpStatus == 400);
}
