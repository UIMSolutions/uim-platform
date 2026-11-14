/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Translate business exceptions to the protocol neutral EntitySetException.
module uim.platform.task_center.presentation.odata.errors;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

EntitySetException toEntitySetException(TaskCenterException e) pure nothrow {
  final switch (e.kind) {
  case TaskCenterErrorKind.invalid:
    return new EntitySetException(400, "BadRequest", e.msg);
  case TaskCenterErrorKind.notFound:
    return new EntitySetException(404, "NotFound", e.msg);
  case TaskCenterErrorKind.conflict:
    return new EntitySetException(409, "Conflict", e.msg);
  case TaskCenterErrorKind.ruleViolation:
    return new EntitySetException(422, "BusinessRuleViolation", e.msg);
  case TaskCenterErrorKind.forbidden:
    return new EntitySetException(403, "Forbidden", e.msg);
  case TaskCenterErrorKind.gateway:
    return new EntitySetException(502, "BadGateway", e.msg);
  }
}

/// Run dg, translating TaskCenterException.
T translated(T)(scope T delegate() @safe dg) {
  try
    return dg();
  catch (TaskCenterException e)
    throw toEntitySetException(e);
}

///
unittest {
  bool caught;
  try
    translated!int(delegate int() { throw TaskCenterException.forbidden("not yours"); });
  catch (EntitySetException e)
    caught = e.status == 403 && e.code == "Forbidden";
  assert(caught);
}
