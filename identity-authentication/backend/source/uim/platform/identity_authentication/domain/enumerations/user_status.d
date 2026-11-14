/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.enumerations.user_status;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Status of a user in the identity directory.
enum UserStatus {
  /// User may sign in.
  active,
  /// Deactivated by an administrator (soft delete).
  inactive,
  /// Locked — after too many failed logins or by an administrator.
  locked,
  /// Created, e-mail address not yet verified.
  pendingVerification,
}

UserStatus toUserStatus(string value) {
  mixin(EnumSwitch("UserStatus", "active"));
}

UserStatus[] toUserStatuses(string[] values)
  => values.map!toUserStatus.array;

string toString(UserStatus value)
  => value.to!string;

string[] toString(UserStatus[] values)
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("UserStatus"));

  assert("locked".toUserStatus == UserStatus.locked);
  assert("unknown".toUserStatus == UserStatus.active);
  assert(UserStatus.pendingVerification.toString == "pendingVerification");
  assert(["active", "locked"].toUserStatuses == [UserStatus.active, UserStatus.locked]);
}
