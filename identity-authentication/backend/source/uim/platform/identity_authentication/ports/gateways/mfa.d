/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.gateways.mfa;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driven port: one-time passwords (RFC 6238 TOTP). Authenticator apps use a
/// 30 s time step; codes delivered by SMS / e-mail use a 5 min step.
interface IMfaService {
  /// Generate a new MFA secret (base32 seed).
  string generateSecret(MfaType mfaType);

  /// The one-time code valid at `now` (stdTime) — sent by SMS / e-mail.
  string currentCode(MfaType mfaType, string secret, long now);

  /// Validate a one-time code (tolerates ±1 time step of clock drift).
  bool validateCode(MfaType mfaType, string secret, string code, long now);

  /// otpauth:// URI for authenticator apps (QR code).
  string provisioningUri(string secret, string account, string issuer);

  /// Deliver a code via SMS or e-mail.
  void sendOtp(MfaType mfaType, string destination, string code);
}

/// Driven port: delivery of one-time codes (SMS gateway, mail service …).
interface IOtpSender {
  void send(MfaType channel, string destination, string message);
}
