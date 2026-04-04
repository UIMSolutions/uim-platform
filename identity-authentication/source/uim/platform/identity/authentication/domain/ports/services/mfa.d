/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.ports.repositories.services.mfa;

// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Port: outgoing — multi-factor authentication adapter.
interface MfaService
{
  /// Generate a new MFA secret (e.g., TOTP seed).
  string generateSecret(MfaType mfaType);

  /// Validate a one-time code against the stored secret.
  bool validateCode(MfaType mfaType, string secret, string code);

  /// Send an OTP via SMS or email.
  void sendOtp(MfaType mfaType, string destination, string code);
}
