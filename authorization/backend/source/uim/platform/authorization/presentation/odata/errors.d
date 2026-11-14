/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Translate business exceptions to the protocol neutral EntitySetException.
module uim.platform.authorization.presentation.odata.errors;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

EntitySetException toEntitySetException(AuthorizationException e) pure nothrow {
  final switch (e.kind) {
  case AuthorizationErrorKind.invalid:
    return new EntitySetException(400, "BadRequest", e.msg);
  case AuthorizationErrorKind.notFound:
    return new EntitySetException(404, "NotFound", e.msg);
  case AuthorizationErrorKind.conflict:
    return new EntitySetException(409, "Conflict", e.msg);
  case AuthorizationErrorKind.ruleViolation:
    return new EntitySetException(422, "BusinessRuleViolation", e.msg);
  }
}

/// Run dg, translating AuthorizationException.
T translated(T)(scope T delegate() @safe dg) {
  try
    return dg();
  catch (AuthorizationException e)
    throw toEntitySetException(e);
}

///
unittest {
  bool caught;
  try
    translated!int(delegate int() { throw AuthorizationException.ruleViolation("nope"); });
  catch (EntitySetException e)
    caught = e.status == 422 && e.code == "BusinessRuleViolation";
  assert(caught);
}
