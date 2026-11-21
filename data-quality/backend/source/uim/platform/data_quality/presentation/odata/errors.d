/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Translate business exceptions to the protocol neutral EntitySetException.
module uim.platform.data_quality.presentation.odata.errors;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

EntitySetException toEntitySetException(DataQualityException e) pure nothrow {
  final switch (e.kind) {
  case DqErrorKind.invalid:
    return new EntitySetException(400, "BadRequest", e.msg);
  case DqErrorKind.notFound:
    return new EntitySetException(404, "NotFound", e.msg);
  case DqErrorKind.conflict:
    return new EntitySetException(409, "Conflict", e.msg);
  case DqErrorKind.ruleViolation:
    return new EntitySetException(422, "BusinessRuleViolation", e.msg);
  }
}

/// Run dg, translating DataQualityException.
T translated(T)(scope T delegate() @safe dg) {
  try
    return dg();
  catch (DataQualityException e)
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

  assert(status(() { translated!int(delegate int() { throw DataQualityException.conflict("dup"); }); }) == 409);
  assert(status(() { translated!int(delegate int() { throw DataQualityException.ruleViolation("no"); }); }) == 422);
}
