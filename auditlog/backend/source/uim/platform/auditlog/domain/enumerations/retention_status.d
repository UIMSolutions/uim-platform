/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.enumerations.retention_status;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Retention policy status.
enum RetentionStatus {
  active,
  inactive,
  expired,
}

RetentionStatus toRetentionStatus(string value) {
  mixin(EnumSwitch("RetentionStatus", "active"));
}

RetentionStatus[] toRetentionStatus(string[] values) {
  return values.map!toRetentionStatus.array;
}

string toString(RetentionStatus s) {
  return s.to!string;
}

string[] toString(RetentionStatus[] statuses) {
  return statuses.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("RetentionStatus"));

  assert("active".toRetentionStatus == RetentionStatus.active);
  assert("inactive".toRetentionStatus == RetentionStatus.inactive);
  assert("expired".toRetentionStatus == RetentionStatus.expired);

  assert(RetentionStatus.active.toString == "active");
  assert(RetentionStatus.inactive.toString == "inactive");
  assert(RetentionStatus.expired.toString == "expired");

  assert(["active", "expired"].toRetentionStatus == [RetentionStatus.active, RetentionStatus.expired
    ]);
  assert([RetentionStatus.active, RetentionStatus.expired].toString == ["active", "expired"
    ]);
}

