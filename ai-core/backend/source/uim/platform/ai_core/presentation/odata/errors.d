/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Translate business exceptions to the protocol neutral EntitySetException.
module uim.platform.ai_core.presentation.odata.errors;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

EntitySetException toEntitySetException(AiCoreException e) pure nothrow {
  final switch (e.kind) {
  case AiCoreErrorKind.invalid:
    return new EntitySetException(400, "BadRequest", e.msg);
  case AiCoreErrorKind.notFound:
    return new EntitySetException(404, "NotFound", e.msg);
  case AiCoreErrorKind.conflict:
    return new EntitySetException(409, "Conflict", e.msg);
  case AiCoreErrorKind.ruleViolation:
    return new EntitySetException(422, "BusinessRuleViolation", e.msg);
  }
}

/// Run dg, translating AiCoreException.
T translated(T)(scope T delegate() @safe dg) {
  try
    return dg();
  catch (AiCoreException e)
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

  assert(status(() { translated!int(delegate int() { throw AiCoreException.conflict("dup"); }); }) == 409);
  assert(status(() { translated!int(delegate int() { throw AiCoreException.ruleViolation("no"); }); }) == 422);
}
