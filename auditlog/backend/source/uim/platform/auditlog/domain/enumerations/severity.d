/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.enumerations.severity;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Severity / log level of an audit event.
enum AuditSeverity {
  info,
  warning,
  error,
  critical,
}

AuditSeverity toAuditSeverity(string value) {
  mixin(EnumSwitch("AuditSeverity", "info"));
}

AuditSeverity[] toAuditSeverity(string[] values) {
  return values.map!toAuditSeverity.array;
}

string toString(AuditSeverity s) {
  return s.to!string;
}

string[] toString(AuditSeverity[] severities) {
  return severities.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("AuditSeverity"));

  assert("info".toAuditSeverity == AuditSeverity.info);
  assert("warning".toAuditSeverity == AuditSeverity.warning);
  assert("error".toAuditSeverity == AuditSeverity.error);
  assert("critical".toAuditSeverity == AuditSeverity.critical);

  assert(AuditSeverity.info.toString == "info");
  assert(AuditSeverity.warning.toString == "warning");
  assert(AuditSeverity.error.toString == "error");
  assert(AuditSeverity.critical.toString == "critical");

  assert(["info", "error"].toAuditSeverity == [AuditSeverity.info, AuditSeverity.error
    ]);
  assert([AuditSeverity.info, AuditSeverity.error].toString == ["info", "error"
    ]);
}

