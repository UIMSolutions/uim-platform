/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Translate business exceptions to the protocol neutral EntitySetException.
module uim.platform.datasphere.presentation.odata.errors;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

EntitySetException toEntitySetException(DatasphereException e) pure nothrow {
  final switch (e.kind) {
  case DspErrorKind.invalid:
    return new EntitySetException(400, "BadRequest", e.msg);
  case DspErrorKind.notFound:
    return new EntitySetException(404, "NotFound", e.msg);
  case DspErrorKind.conflict:
    return new EntitySetException(409, "Conflict", e.msg);
  case DspErrorKind.ruleViolation:
    return new EntitySetException(422, "BusinessRuleViolation", e.msg);
  case DspErrorKind.unauthorized:
    return new EntitySetException(401, "Unauthorized", e.msg);
  }
}

/// Run dg, translating DatasphereException.
T translated(T)(scope T delegate() @safe dg) {
  try
    return dg();
  catch (DatasphereException e)
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

  assert(status(() { translated!int(delegate int() { throw DspException.conflict("dup"); }); }) == 409);
  assert(status(() { translated!int(delegate int() { throw DspException.ruleViolation("no"); }); }) == 422);
}
