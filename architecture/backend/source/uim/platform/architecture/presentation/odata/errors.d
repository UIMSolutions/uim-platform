/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Translate business exceptions to the protocol neutral EntitySetException.
module uim.platform.architecture.presentation.odata.errors;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

EntitySetException toEntitySetException(ArchitectureException e) pure nothrow {
  final switch (e.kind) {
  case ArchitectureErrorKind.invalid:
    return new EntitySetException(400, "BadRequest", e.msg);
  case ArchitectureErrorKind.notFound:
    return new EntitySetException(404, "NotFound", e.msg);
  case ArchitectureErrorKind.conflict:
    return new EntitySetException(409, "Conflict", e.msg);
  case ArchitectureErrorKind.ruleViolation:
    return new EntitySetException(422, "BusinessRuleViolation", e.msg);
  }
}

/// Run dg, translating ArchitectureException.
T translated(T)(scope T delegate() @safe dg) {
  try
    return dg();
  catch (ArchitectureException e)
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

  assert(status(() { translated!int(delegate int() { throw ArchitectureException.conflict("dup"); }); }) == 409);
  assert(status(() { translated!int(delegate int() { throw ArchitectureException.ruleViolation("no"); }); }) == 422);
}
