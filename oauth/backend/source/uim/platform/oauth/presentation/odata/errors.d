/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Translate business and protocol exceptions to the protocol neutral EntitySetException.
module uim.platform.oauth.presentation.odata.errors;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

EntitySetException toEntitySetException(OAuthException e) pure nothrow {
  final switch (e.kind) {
  case OAuthErrorKind.invalid:
    return new EntitySetException(400, "BadRequest", e.msg);
  case OAuthErrorKind.notFound:
    return new EntitySetException(404, "NotFound", e.msg);
  case OAuthErrorKind.conflict:
    return new EntitySetException(409, "Conflict", e.msg);
  case OAuthErrorKind.ruleViolation:
    return new EntitySetException(422, "BusinessRuleViolation", e.msg);
  }
}

/// Protocol failures inside management actions (e.g. RequestClientToken) keep their RFC code.
EntitySetException toEntitySetException(OAuthProtocolException e) pure nothrow {
  return new EntitySetException(e.httpStatus == 401 ? 401 : e.httpStatus == 500 ? 500 : 422, cast(string) e.error, e.msg);
}

/// Run dg, translating OAuthException / OAuthProtocolException.
T translated(T)(scope T delegate() @safe dg) {
  try
    return dg();
  catch (OAuthException e)
    throw toEntitySetException(e);
  catch (OAuthProtocolException e)
    throw toEntitySetException(e);
}

///
unittest {
  int status(scope void delegate() @safe dg) {
    try
      dg();
    catch (EntitySetException e)
      return e.status;
    return 0;
  }

  assert(status(() { translated!int(delegate int() { throw OAuthException.conflict("dup"); }); }) == 409);
  assert(status(() { translated!int(delegate int() { protocolError(OAuthError.invalidClient, "x"); }); }) == 401);
  assert(status(() { translated!int(delegate int() { protocolError(OAuthError.invalidScope, "x"); }); }) == 422);
}
