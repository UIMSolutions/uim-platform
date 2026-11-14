/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.enumerations.mfa_type;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Multi-factor authentication type.
enum MfaType {
  none,
  /// Time-based one-time password (RFC 6238, authenticator app)
  totp,
  /// One-time password sent by SMS
  sms,
  /// One-time password sent by e-mail
  email,
}

MfaType toMfaType(string value) {
  mixin(EnumSwitch("MfaType", "none"));
}

MfaType[] toMfaTypes(string[] values)
  => values.map!toMfaType.array;

string toString(MfaType value)
  => value.to!string;

string[] toString(MfaType[] values)
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("MfaType"));

  assert("totp".toMfaType == MfaType.totp);
  assert("unknown".toMfaType == MfaType.none);
  assert(MfaType.email.toString == "email");
  assert(["none", "sms"].toMfaTypes == [MfaType.none, MfaType.sms]);
}
