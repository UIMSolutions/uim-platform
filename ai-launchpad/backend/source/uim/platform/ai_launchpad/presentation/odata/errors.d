/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Translate business exceptions to the protocol neutral EntitySetException.
module uim.platform.ai_launchpad.presentation.odata.errors;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

EntitySetException toEntitySetException(AiLaunchpadException e) pure nothrow {
  final switch (e.kind) {
  case AilpErrorKind.invalid:
    return new EntitySetException(400, "BadRequest", e.msg);
  case AilpErrorKind.notFound:
    return new EntitySetException(404, "NotFound", e.msg);
  case AilpErrorKind.conflict:
    return new EntitySetException(409, "Conflict", e.msg);
  case AilpErrorKind.ruleViolation:
    return new EntitySetException(422, "BusinessRuleViolation", e.msg);
  case AilpErrorKind.unauthorized:
    return new EntitySetException(401, "Unauthorized", e.msg);
  }
}

/// Run dg, translating AiLaunchpadException.
T translated(T)(scope T delegate() @safe dg) {
  try
    return dg();
  catch (AiLaunchpadException e)
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

  assert(status(() { translated!int(delegate int() { throw AilpException.conflict("dup"); }); }) == 409);
  assert(status(() { translated!int(delegate int() { throw AilpException.ruleViolation("no"); }); }) == 422);
}
