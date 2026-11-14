/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Translate business exceptions to the protocol neutral EntitySetException.
module uim.platform.service_manager.presentation.odata.errors;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

EntitySetException toEntitySetException(ServiceManagerException e) pure nothrow {
  final switch (e.kind) {
  case ServiceManagerErrorKind.invalid:
    return new EntitySetException(400, "BadRequest", e.msg);
  case ServiceManagerErrorKind.notFound:
    return new EntitySetException(404, "NotFound", e.msg);
  case ServiceManagerErrorKind.conflict:
    return new EntitySetException(409, "Conflict", e.msg);
  case ServiceManagerErrorKind.ruleViolation:
    return new EntitySetException(422, "BusinessRuleViolation", e.msg);
  case ServiceManagerErrorKind.gateway:
    return new EntitySetException(502, "BadGateway", e.msg);
  }
}

/// Run dg, translating ServiceManagerException.
T translated(T)(scope T delegate() @safe dg) {
  try
    return dg();
  catch (ServiceManagerException e)
    throw toEntitySetException(e);
}

///
unittest {
  bool caught;
  try
    translated!int(delegate int() { throw ServiceManagerException.ruleViolation("nope"); });
  catch (EntitySetException e)
    caught = e.status == 422 && e.code == "BusinessRuleViolation";
  assert(caught);
}
