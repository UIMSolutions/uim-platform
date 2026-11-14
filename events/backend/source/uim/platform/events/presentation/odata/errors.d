/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Translate business exceptions to the protocol neutral EntitySetException.
module uim.platform.events.presentation.odata.errors;

import uim.platform.events;

mixin(ShowModule!());

@safe:

EntitySetException toEntitySetException(EventsException e) pure nothrow {
  final switch (e.kind) {
  case EventsErrorKind.invalid:
    return new EntitySetException(400, "BadRequest", e.msg);
  case EventsErrorKind.notFound:
    return new EntitySetException(404, "NotFound", e.msg);
  case EventsErrorKind.conflict:
    return new EntitySetException(409, "Conflict", e.msg);
  case EventsErrorKind.ruleViolation:
    return new EntitySetException(422, "BusinessRuleViolation", e.msg);
  case EventsErrorKind.quotaExceeded:
    return new EntitySetException(422, "QuotaExceeded", e.msg);
  case EventsErrorKind.gateway:
    return new EntitySetException(502, "BadGateway", e.msg);
  }
}

/// Run dg, translating EventsException.
T translated(T)(scope T delegate() @safe dg) {
  try
    return dg();
  catch (EventsException e)
    throw toEntitySetException(e);
}

///
unittest {
  bool caught;
  try
    translated!int(delegate int() { throw EventsException.quotaExceeded("full"); });
  catch (EntitySetException e)
    caught = e.status == 422 && e.code == "QuotaExceeded";
  assert(caught);
}
