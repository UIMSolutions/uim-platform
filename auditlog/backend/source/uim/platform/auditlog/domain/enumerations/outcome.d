/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.enumerations.outcome;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Outcome of the audited operation.
enum AuditOutcome {
  success,
  failure,
  denied,
  error,
}

AuditOutcome toAuditOutcome(string value) {
  mixin(EnumSwitch("AuditOutcome", "success"));
}

AuditOutcome[] toAuditOutcome(string[] values) {
  return values.map!toAuditOutcome.array;
}

string toString(AuditOutcome o) {
  return o.to!string;
}

string[] toString(AuditOutcome[] outcomes) {
  return outcomes.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("AuditOutcome"));

  assert("success".toAuditOutcome == AuditOutcome.success);
  assert("failure".toAuditOutcome == AuditOutcome.failure);
  assert("denied".toAuditOutcome == AuditOutcome.denied);
  assert("error".toAuditOutcome == AuditOutcome.error);

  assert(AuditOutcome.success.toString == "success");
  assert(AuditOutcome.failure.toString == "failure");
  assert(AuditOutcome.denied.toString == "denied");
  assert(AuditOutcome.error.toString == "error");

  assert(["success", "failure"].toAuditOutcome == [AuditOutcome.success, AuditOutcome.failure
    ]);
  assert([AuditOutcome.success, AuditOutcome.failure].toString == ["success", "failure"
    ]);
}

